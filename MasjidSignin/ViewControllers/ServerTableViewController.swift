//
//  ServerTableViewController.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/24/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class ServerTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell",
                                                 for: indexPath) as! SettingsServerCell

        if row == 0 {
            cell.setting = .host
            cell.headingLabel.text = "Host"
            if let serverHost = UserDefaults.standard.string(forKey: "serverHost") {
                cell.textField.text = serverHost
            }
            else {
                cell.textField.text = nil
            }
        }

        cell.textField.delegate = cell
        return cell

    }
}
