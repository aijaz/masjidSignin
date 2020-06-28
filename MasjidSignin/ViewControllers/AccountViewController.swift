//
//  AccountViewController.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/24/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!


    var token: String?
    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        token = Keychain.read(field: .token)
        name = Keychain.read(field: .name)
        refreshView()

        if let startDate = UserDefaults.standard.object(forKey: "sessionStartDate") as? Date {
            startPicker.date = startDate
        }
        if let endDate = UserDefaults.standard.object(forKey: "sessionEndDate") as? Date {
            endPicker.date = endDate
        }

    }


    @IBAction func startPickerChanged(_ sender: Any) {
        print("Start changed, \(startPicker.date)")
        UserDefaults.standard.set(startPicker.date, forKey: "sessionStartDate")
    }


    @IBAction func endPickerChanged(_ sender: Any) {
        print("End changed, \(endPicker.date)")
        UserDefaults.standard.set(endPicker.date, forKey: "sessionEndDate")
    }


    @IBAction func handleButtonTap(_ sender: Any) {
        if let _ = token, let _ = name {
            handleLogout()
        }
        else {
            handleLogin()
        }
    }

    func refreshView() {
        if let _ = token, let name = name {
            captionLabel.text = "You are logged in as \(name)"
            button.setTitle("Log out", for: .normal)
        }
        else {
            captionLabel.text = "You are not logged in"
            button.setTitle("Log in", for: .normal)
        }
    }

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
                    self.token = loginResponse.token
                    self.name = loginResponse.name
                    Keychain.save(field: .token, value: loginResponse.token)
                    Keychain.save(field: .name, value: loginResponse.name)
                    DispatchQueue.main.async {
                        self.refreshView()
                    }
                }
                else {
                    let alertController2 = UIAlertController(title: "Login Failed", message: "The username/password combination you entered was incorrect.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alertController2.addAction(ok)
                    DispatchQueue.main.async {
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
        token = nil
        name = nil
        refreshView()
    }

}

extension AccountViewController  {

}
