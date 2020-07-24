//
//  SettingsActionCell.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class SettingsActionCell: UITableViewCell {
    @IBOutlet weak var actionButton: UIButton!

    var callback: (() -> ())!

    @IBAction func handleButtonPress(_ sender: Any) {
        callback()
    }
}
