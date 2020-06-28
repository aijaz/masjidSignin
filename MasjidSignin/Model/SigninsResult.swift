//
//  SigninsResult.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/25/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct SigninsResult: Codable {

    struct Item: Codable {
        let id: Int
        let epoch: Double
        let name: String
        let phone: String
        let email: String
    }

    let data: [Item]
}
