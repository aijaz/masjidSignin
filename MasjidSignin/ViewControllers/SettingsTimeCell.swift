//
//  SettingsTimeCell.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class SettingsTimeCell: UITableViewCell {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var picker: UIDatePicker!

    weak var vc: SettingsTableViewController!
    var isStart = false
    let df = DateFormatter()

    func refresh() {
        df.timeStyle = .short
        df.dateStyle = .short

        if isStart {
            headingLabel.text = "Session start time"
            picker.date = UserDefaults.standard.object(forKey: "sessionStartDate") as? Date ?? Date()
            valueLabel.text = df.string(from: picker.date)

            if vc.settingStartTime {
                picker.isHidden = false
            }
            else {
                picker.isHidden = true
            }
        }
        else {
            headingLabel.text = "Session end time"
            picker.date = UserDefaults.standard.object(forKey: "sessionEndDate") as? Date ?? Date().addingTimeInterval(3600)
            valueLabel.text = df.string(from: picker.date)

            if vc.settingEndTime {
                picker.isHidden = false
            }
            else {
                picker.isHidden = true
            }
        }

    }

    @IBAction func handleButtonPress(_ sender: Any) {
        if isStart {
            vc.settingStartTime = !vc.settingStartTime
        }
        else {
            vc.settingEndTime = !vc.settingEndTime
        }
        vc.tableView.reloadData()
        refresh()
    }


    @IBAction func handlePickerValueChanged(_ sender: Any) {
        if isStart {
            UserDefaults.standard.set(picker.date, forKey: "sessionStartDate")
        }
        else {
            UserDefaults.standard.set(picker.date, forKey: "sessionEndDate")
        }
        refresh()
    }

}

