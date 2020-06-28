//
//  Keychain.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation
import os

enum KeychainField: String {
    case name
    case token
}


struct Keychain {


//    static func save(field KeychainField, name: String) {
//        // via https://medium.com/@MatiasGelos/ios-storing-enums-in-keychain-409ec7a5e93e
//        let nameData = Data(name.utf8)
//        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainField.name.rawValue, accessGroup: KeychainConfiguration.accessGroup)
//
//        do {
//            try passwordItem.saveEncodedPassword(nameData)
//        }
//        catch {
//            os_log(.error, log: log, "Can't save value for field '%@' into keychain: %{public}@", KeychainField.name.rawValue, error.localizedDescription)
//        }
//    }
//
//
//
//    static func readLoginSecrets() -> LoginSecrets? {
//        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainField.loginSecrets.rawValue, accessGroup: KeychainConfiguration.accessGroup)
//        var passwordData:Data
//        var loginSecrets: LoginSecrets?
//
//        do {
//            passwordData = try passwordItem.readPasswordData()
//            loginSecrets = try JSONDecoder().decode(LoginSecrets.self, from: passwordData)
//        }
//        catch {
//            // do nothing
//        }
//        return loginSecrets
//    }


    static let log = OSLog(subsystem: "com.euclidsoftware.masjidsignin", category: "Keychain")

    static func save(field account: KeychainField, value password: String) {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account.rawValue, accessGroup: KeychainConfiguration.accessGroup)

        do {
            try passwordItem.savePassword(password)
        }
        catch {
            os_log(.error, log: log, "Can't save value for field '%@' into keychain: %{public}@", account.rawValue, error.localizedDescription)
        }
    }

    static func read(field account:KeychainField) -> String? {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account.rawValue, accessGroup: KeychainConfiguration.accessGroup)
        var password:String?

        do {
            password = try passwordItem.readPassword()
        }
        catch {
            os_log(.error, log: log, "Can't read value for field '%@' into keychain: %{public}@", account.rawValue, error.localizedDescription)
            password = nil
        }
        return password
    }

    static func delete(field account: KeychainField) {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: account.rawValue, accessGroup: KeychainConfiguration.accessGroup)

        do {
            try passwordItem.deleteItem()
        }
        catch {
            os_log(.error, log: log, "Can't delete value for field '%@' into keychain: {public}%@", account.rawValue, error.localizedDescription)
        }
    }


}
