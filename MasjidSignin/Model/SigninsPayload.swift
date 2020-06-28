//
//  SigninsPayload.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/25/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation


struct SigninsPayload: Codable {
    let token: String
    let lessThan: Int?

    enum CodingKeys: String, CodingKey {
        case token
        case lessThan = "less_than"
    }
}
