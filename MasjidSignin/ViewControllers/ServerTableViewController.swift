//
//  ServerTableViewController.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/24/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class ServerTableViewController: UITableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell",
                                                 for: indexPath) as! SettingsServerCell

        if row == 0 {
            cell.setting = .scheme
            cell.headingLabel.text = "Scheme"
            if let serverScheme = UserDefaults.standard.string(forKey: "serverScheme") {
                cell.textField.text = serverScheme
            }
            else {
                cell.textField.text = nil
            }
        }
        else if row == 1 {
            cell.setting = .host
            cell.headingLabel.text = "Host"
            if let serverHost = UserDefaults.standard.string(forKey: "serverHost") {
                cell.textField.text = serverHost
            }
            else {
                cell.textField.text = nil
            }
        }
        else if row == 2 {
            cell.setting = .path
            cell.headingLabel.text = "Path"
            if let serverPath = UserDefaults.standard.string(forKey: "serverPath") {
                cell.textField.text = serverPath
            }
            else {
                cell.textField.text = nil
            }
        }
        else if row == 3 {
            cell.setting = .port
            cell.headingLabel.text = "Port"
            if let serverPort = UserDefaults.standard.string(forKey: "serverPort") {
                cell.textField.text = serverPort
            }
            else {
                cell.textField.text = nil
            }
        }

        cell.textField.delegate = cell
        return cell

    }
}
