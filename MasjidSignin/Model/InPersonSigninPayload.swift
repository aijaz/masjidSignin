//
//  InPersonSigninPayload.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct InPersonSigninPayload: Codable {
    let token: String
    let name: String
    let phone: String
    let email: String
    let scanTime: Double // Time interval since 1970
    let clientId: String

    enum CodingKeys: String, CodingKey {
        case token
        case name
        case phone
        case email
        case scanTime = "scan_time"
        case clientId
    }

}
