//
//  SettingsTableViewController.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 7/14/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    var settingStartTime = false
    var settingEndTime = false


}

extension SettingsTableViewController {


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Server"
        }
        else if section == 0 {
            if let name = Keychain.read(field: .name) {
                return "Account: Logged in as \(name)"
            }
            else {
                return "Account: Not logged in"
            }
        }
        else if section == 1 {
            return "Session"
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let _ = Keychain.read(field: .token) {
                // logged in
                return 1
            }
            else {
                // not logged in
                return 2
            }
        }
        else if section == 1 {
            return 4
        }
        else if section == 2 {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row

        if section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell",
                                                     for: indexPath)

            return cell
        }
        else if section == 0 {
            if let _ = Keychain.read(field: .token) {
                // logged in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell",
                                                         for: indexPath) as! SettingsActionCell

                cell.actionButton.setTitle("Logout", for: .normal)
                cell.callback = { self.handleLogout() }
                return cell
            }
            else {
                // not logged in
                if row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell",
                                                             for: indexPath) as! SettingsActionCell

                    cell.actionButton.setTitle("Login", for: .normal)
                    cell.callback = { self.handleLogin() }
                    return cell
                }
                else if row == 1{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell",
                                                             for: indexPath) as! SettingsActionCell

                    cell.actionButton.setTitle("Forgot Password", for: .normal)
                    cell.callback = { self.handleReset() }
                    return cell

                }
            }
        }
        else if section == 1 {
            if row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MorfCell",
                                                         for: indexPath) as! SettingsMorfCell
                cell.vc = self
                if let morf = UserDefaults.standard.string(forKey: "morf") {
                    if morf == "F" {
                        cell.segmentedControl.selectedSegmentIndex = 1
                        return cell
                    }
                }
                cell.segmentedControl.selectedSegmentIndex = 0
                return cell
            }
            else if row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell",
                                                         for: indexPath) as! SettingsActionCell

                cell.actionButton.setTitle("Start session now", for: .normal)

                cell.callback = {
                    UserDefaults.standard.set(Date(), forKey: "sessionStartDate")
                    UserDefaults.standard.set(Date().addingTimeInterval(3600), forKey: "sessionEndDate")
                    self.tableView.reloadData()
                }
                return cell

            }
            else if row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell",
                                                         for: indexPath) as! SettingsTimeCell
                cell.isStart = true
                cell.vc = self
                cell.refresh()
                return cell
            }
            else if row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell",
                                                         for: indexPath) as! SettingsTimeCell
                cell.isStart = false
                cell.vc = self
                cell.refresh()
                return cell
            }
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row == 0 {
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 2 { return }
        let row = indexPath.row

        if section == 0 {
            let cell = tableView.cellForRow(at: indexPath) as! SettingsActionCell
            cell.callback()
        }
        else if section == 1 {
            if row == 1 {
                let cell = tableView.cellForRow(at: indexPath) as! SettingsActionCell
                cell.callback()
            }
            else if row == 2 {
                settingStartTime = !settingStartTime
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            else if row == 3 {
                settingEndTime = !settingEndTime
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}


extension SettingsTableViewController {
    func handleReset() {
        let alertController = UIAlertController(title: "Reset Password", message: "Enter the password reset code and your new password", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Password reset code"
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }


        let resetAction = UIAlertAction(title: "Reset Password", style: .default) { (_) in
            let codeField = alertController.textFields![0]
            let passwordField = alertController.textFields![1]

            let network = Network()

            network.resetPasswordWith(guid: codeField.text ?? "", password: passwordField.text ?? "") { error in
                if let _ = error {
                    let alertController2 = UIAlertController(title: "Reset Failed", message: "The code/password combination you entered was incorrect.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alertController2.addAction(ok)
                    DispatchQueue.main.async {
                        self.present(alertController2, animated: true, completion: nil)
                    }
                }
                else {
                    let alertController2 = UIAlertController(title: "Reset Complete", message: "Your password has been reset", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alertController2.addAction(ok)
                    DispatchQueue.main.async {
                        self.present(alertController2, animated: true, completion: nil)
                        self.tableView.reloadData()
                    }
                }
            }

        }


        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(resetAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

    }

}

extension SettingsTableViewController {
    func handleLogin() {
        let alertController = UIAlertController(title: nil, message: "Login", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }

        let loginAction = UIAlertAction(title: "Login", style: .default) { (_) in
            let emailField = alertController.textFields![0]
            let passwordField = alertController.textFields![1]

            let network = Network()

            network.loginWith(email: emailField.text ?? "", password: passwordField.text ?? "") { loginResponse, error in
                if let loginResponse = loginResponse {
                    Keychain.save(field: .token, value: loginResponse.token)
                    Keychain.save(field: .name, value: loginResponse.name)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let alertController2 = UIAlertController(title: "Login Failed", message: "The username/password combination you entered was incorrect.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        alertController2.addAction(ok)
                        self.present(alertController2, animated: true, completion: nil)
                    }
                }
            }

        }


        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func handleLogout() {
        let network = Network()
        network.logout(calling: { _ in })
        Keychain.delete(field: .token)
        Keychain.delete(field: .name)
        self.tableView.reloadData()
    }

}
