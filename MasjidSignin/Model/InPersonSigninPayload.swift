//
//  InPersonSigninPayload.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct InPersonSigninPayload: Codable {
    let name: String
    let phone: String
    let email: String
    let scanTime: Double // Time interval since 1970
    let clientId: String
    let numPeople: Int?
    let maleOrFemale: String?

    enum CodingKeys: String, CodingKey {
        case name
        case phone
        case email
        case scanTime = "scan_time"
        case clientId
        case numPeople = "num_people"
        case maleOrFemale = "morf"
    }

}
