//
//  SettingsMorfCell.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class SettingsMorfCell: UITableViewCell {
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    weak var vc: SettingsTableViewController!

    @IBAction func handleSegmentedControlChange(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 1 {
            UserDefaults.standard.set("F", forKey: "morf")
        }
        else {
            UserDefaults.standard.set("M", forKey: "morf")
        }
    }
}
