//
//  Network.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case encodingError
    case decodingError
    case serverError(Error)
    case unknownIdError
    case unauthorizedError
    case otherError(String)

    func appDescription() -> String {
        switch self {
            case .encodingError:
                return "Encoding Error"
            case .decodingError:
                return "Decoding Error"
            case .serverError(let e) :
                return "Server Error (\(e.localizedDescription))"
            case .unknownIdError :
                return "Unknown ID"
            case .unauthorizedError:
                return "Unauthorized"
            case .otherError (let s):
                return "Sever Error \(s)"

        }
    }
}

struct Network {

    let scheme = UserDefaults.standard.string(forKey: "serverScheme") ?? ""
    let host = UserDefaults.standard.string(forKey: "serverHost") ?? ""
    let port = UserDefaults.standard.integer(forKey: "serverPort")
    let path = UserDefaults.standard.string(forKey: "serverPath") ?? ""


    func loginWith(email: String
        , password: String
        , calling callback: @escaping (LoginResponse?, NetworkError?) -> ()
    ) {

        let session = URLSession.shared
        var portString: String
        portString = ":\(port)"
        let url = URL(string: "\(scheme)://\(host)\(portString)\(path)login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")


        let loginPayload = LoginPayload(email: email, password: password)
        let encoder = JSONEncoder()
        var jsonData: Data!
        do {
            jsonData = try encoder.encode(loginPayload)
        }
        catch {
            callback(nil, NetworkError.encodingError)
            return
        }


        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                var loginResponse: LoginResponse!
                do {
                    loginResponse = try decoder.decode(LoginResponse.self, from: data)
                }
                catch {
                    callback(nil, NetworkError.decodingError)
                    return
                }
                callback(loginResponse, nil)
            }
            else {
                if let error = error {
                    callback(nil, NetworkError.serverError(error))
                    return
                }
                else {
                    callback(nil, nil)
                    return
                }
            }

        }

        task.resume()
    }

    func logout(calling callback: @escaping (NetworkError?) -> ()) {
        guard let token = Keychain.read(field: .token) else { return }

        let session = URLSession.shared
        let request = getRequestFor(urlString: "logout", token: token)

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                callback(NetworkError.serverError(error))
            }
            else {
                callback(nil)
                return
            }
        }

        task.resume()

    }

    func getRequestFor(urlString: String, token: String, httpMethod: String = "POST") -> URLRequest {
        var portString: String
        portString = ":\(port)"
        let url = URL(string: "\(scheme)://\(host)\(portString)\(path)\(urlString)")!

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "token")


        return request
    }

    func signins(lessThan: Int?
        , calling callback: @escaping (SigninsResult?, NetworkError?) -> ()
    ) {
        guard let token = Keychain.read(field: .token) else { return }


        let session = URLSession.shared

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = "\(path)signins"

        if let lessThan = lessThan {
            urlComponents.queryItems = [
                URLQueryItem(name: "less_than", value: "\(lessThan)"),
                URLQueryItem(name: "return_count", value: "100")
            ]
        }
        else {
            urlComponents.queryItems = [
                URLQueryItem(name: "return_count", value: "100")
            ]
        }
        guard let url = urlComponents.url else {
            callback(nil, NetworkError.encodingError)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "token")

        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                var result: SigninsResult!
                do {
                    result = try decoder.decode(SigninsResult.self, from: data)
                }
                catch {
                    callback(nil, NetworkError.decodingError)
                    return
                }
                callback(result, nil)
            }
            else {
                if let error = error {
                    callback(nil, NetworkError.serverError(error))
                    return
                }
                else {
                    callback(nil, nil)
                    return
                }
            }

        }

        task.resume()


    }

    func submit(payload: InPersonSigninPayload
        , calling callback: @escaping (ScanResult?, NetworkError?) -> ()
    ) {
        guard let token = Keychain.read(field: .token) else { return }

        let session = URLSession.shared
        let request = getRequestFor(urlString: "signin", token: token)

        let encoder = JSONEncoder()
        var jsonData: Data!
        do {
            jsonData = try encoder.encode(payload)
        }
        catch {
            callback(nil, NetworkError.encodingError)
            FailedEntries.add(payload: payload)
            return
        }

        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in

            if let error = error {
                FailedEntries.add(payload: payload)
                callback(nil, NetworkError.serverError(error))
            }
            else if let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode >= 400 {
                FailedEntries.add(payload: payload)
                callback(nil, NetworkError.unauthorizedError)
            }
            else if let data = data {
                let _ = self.handleScanResult(data: data, calling: callback)
            }
            else {
                FailedEntries.add(payload: payload)
                callback(nil, nil)
                return
            }
        }
        task.resume()
    }

    func redeemReservation(payload: RedeemReservationPayload, localPayload: InPersonSigninPayload
        , calling callback: @escaping (ScanResult?, NetworkError?) -> ()
    ) {
        guard let token = Keychain.read(field: .token) else { return }

        let session = URLSession.shared
        let request = getRequestFor(urlString: "redeemReservation", token: token)

        let encoder = JSONEncoder()
        var jsonData: Data!
        do {
            jsonData = try encoder.encode(payload)
        }
        catch {
            callback(nil, NetworkError.encodingError)
            for _ in Range (1...localPayload.numPeople) { FailedEntries.add(payload: localPayload) }
            return
        }

        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in

            if let error = error {
                for _ in Range (1...localPayload.numPeople) {
                    FailedEntries.add(payload: localPayload)
                    SessionEntries.add(payload: localPayload)
                }
                callback(nil, NetworkError.serverError(error))

            }
            else if let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode >= 400 {

                if let httpURLResponse = response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 400 {
                    guard let data = data else { callback(nil, NetworkError.decodingError); return; }
                    let decoder = JSONDecoder()
                    var errorPayload: ErrorPayload!
                    do {
                        errorPayload = try decoder.decode(ErrorPayload.self, from: data)
                    }
                    catch {
                        callback(nil, NetworkError.decodingError)
                        return
                    }

                    callback(nil, NetworkError.otherError(errorPayload.message))
                }
                else {
                    for _ in Range (1...localPayload.numPeople) {
                        FailedEntries.add(payload: localPayload)
                        SessionEntries.add(payload: localPayload)
                    }
                    callback(nil, NetworkError.unauthorizedError)
                }

            }
            else if let data = data {
                let _ = self.handleScanResult(data: data, calling: callback)
            }
            else {
                for _ in Range (1...localPayload.numPeople) {
                    FailedEntries.add(payload: localPayload)
                    SessionEntries.add(payload: localPayload)
                }
                callback(nil, nil)
                return
            }
        }
        task.resume()
    }

    func handleScanResult(data: Data, calling callback: @escaping (ScanResult?, NetworkError?) -> ()) -> Bool {
        let decoder = JSONDecoder()
        var scanResult: ScanResult!
        do {
            scanResult = try decoder.decode(ScanResult.self, from: data)
        }
        catch {
            callback(nil, NetworkError.decodingError)
            return true
        }
        if scanResult.result == "0" {
            callback(nil, NetworkError.unknownIdError)
            return true
        }
        else {
            callback(scanResult, nil)
            return false
        }
    }

    func resetPasswordWith(guid: String
        , password: String
        , calling callback: @escaping (NetworkError?) -> ()
    ) {

        let session = URLSession.shared
        var portString: String
        portString = ":\(port)"
        let url = URL(string: "\(scheme)://\(host)\(portString)\(path)verifyPasswordChange")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")


        let resetPayload = ResetPayload(guid: guid, password: password)
        let encoder = JSONEncoder()
        var jsonData: Data!
        do {
            jsonData = try encoder.encode(resetPayload)
        }
        catch {
            callback(NetworkError.encodingError)
            return
        }


        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                callback(NetworkError.serverError(error))
                return
            }
            else {
                callback(nil)
                return
            }

        }

        task.resume()
    }

}
