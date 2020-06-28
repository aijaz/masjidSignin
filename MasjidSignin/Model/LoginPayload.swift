//
//  LoginPayload.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct LoginPayload: Encodable {
    let email: String
    let password: String
    let source = "iOS"
}
