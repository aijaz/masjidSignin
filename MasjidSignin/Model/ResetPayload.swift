//
//  ResetPayload.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/6/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import Foundation

struct ResetPayload: Encodable {
    let guid: String
    let password: String
}
