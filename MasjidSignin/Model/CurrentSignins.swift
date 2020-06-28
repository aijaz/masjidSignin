//
//  CurrentSignins.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct CurrentSignins: Decodable {
    struct Signin: Decodable {
        let id: String
        let name: String
        let phone: String
        let email: String
        let difficultyBreathing: Bool
        let dryCough: Bool
        let soreThroat: Bool
        let lossOfTaste: Bool
        let testedPositive: Bool
        let contactWithTestedPositive: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case phone
            case email
            case difficultyBreathing = "breathing"
            case dryCough = "cough"
            case soreThroat = "sore"
            case lossOfTaste = "taste"
            case testedPositive = "positive"
            case contactWithTestedPositive = "contact"
        }
    }

    let data: [Signin]
}
