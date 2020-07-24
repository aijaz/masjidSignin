//
//  ReservationSigninPayload.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct ReservationRedeemPayload: Codable {
    let uuid: String
    let maleOrFemale: String

    enum CodingKeys: String, CodingKey {
        case uuid
        case maleOrFemale = "morf"
    }

}
