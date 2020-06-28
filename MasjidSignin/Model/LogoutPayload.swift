//
//  LogoutPayload.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/24/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct LogoutPayload: Encodable {
    let token: String
}
