//
//  LoginResponse.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct LoginResponse: Decodable {
    let name: String
    let token: String
}
