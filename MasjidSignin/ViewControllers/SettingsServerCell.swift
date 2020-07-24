//
//  SettingsServerCell.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

enum serverSetting {
    case scheme
    case host
    case path
    case port
}

class SettingsServerCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var headingLabel: UILabel!

    var setting: serverSetting!


    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        handleTextFieldUpdate()

    }

    func handleTextFieldUpdate() {
        switch setting {
            case .scheme:
                UserDefaults.standard.set(textField.text, forKey: "serverScheme")
            case .host:
                UserDefaults.standard.set(textField.text, forKey: "serverHost")
            case .path:
                UserDefaults.standard.set(textField.text, forKey: "serverPath")
            case .port:
                if let text = textField.text {
                    if text == "" {
                        UserDefaults.standard.set(nil, forKey: "serverPort")
                    }
                    else {
                        UserDefaults.standard.set(Int(text), forKey: "serverPort")
                    }
                }
                else {
                    UserDefaults.standard.set(nil, forKey: "serverPort")
            }

            case .none:
                break
        }
        UserDefaults.standard.synchronize()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleTextFieldUpdate()
        textField.resignFirstResponder()
        return true
    }

}
