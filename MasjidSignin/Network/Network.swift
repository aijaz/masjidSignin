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
        }
    }
}

struct Network {
    var serverURL = "http://localhost:5000/api/v1.0/"

    func loginWith(email: String
        , password: String
        , calling callback: @escaping (LoginResponse?, NetworkError?) -> ()
    ) {

        let session = URLSession.shared
        let request = getRequestFor(urlString: "login")

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
        let request = getRequestFor(urlString: "logout")
        let payload = LogoutPayload(token: token)

        let encoder = JSONEncoder()
        var jsonData: Data!
        do {
            jsonData = try encoder.encode(payload)
        }
        catch {
            callback(NetworkError.encodingError)
            return
        }

        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
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

    func getRequestFor(urlString: String) -> URLRequest {
        let url = URL(string: "\(serverURL)\(urlString)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")


        return request
    }

    func signins(lessThan: Int?
        , calling callback: @escaping (SigninsResult?, NetworkError?) -> ()
    ) {
        guard let token = Keychain.read(field: .token) else { return }


        let session = URLSession.shared
        let request = getRequestFor(urlString: "signins")

        let payload = SigninsPayload(token: token, lessThan: lessThan)
        let encoder = JSONEncoder()
        var jsonData: Data!
        do {
            jsonData = try encoder.encode(payload)
        }
        catch {
            callback(nil, NetworkError.encodingError)
            return
        }
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
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
        guard let _ = Keychain.read(field: .token) else { return }

        let session = URLSession.shared
        let request = getRequestFor(urlString: "signin")

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

}
