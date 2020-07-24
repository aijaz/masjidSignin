//
//  ManualEntryViewController.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/24/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ManualEntryController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var addEntryButton: UIButton!
    @IBOutlet weak var numPeopleSeg: UISegmentedControl!

    weak var presenter: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        nameField.delegate = self
        phoneField.delegate = self
        emailField.delegate = self

    }

    @IBAction func handleAddEntry(_ sender: Any) {
        guard let _ = Keychain.read(field: .token) else {
            alert(title: "You're not logged in.", message: "Please log in.")
            return
        }
        guard let name = nameField.text else { alert(title: "Missing name", message: "Please enter a name"); return }
        guard let phone = phoneField.text else { alert(title: "Missing phone", message: "Please enter a phone"); return }

        addEntryButton.isEnabled = false
        
        let scanTimeInSeconds = Date().timeIntervalSince1970

        let morf = UserDefaults.standard.string(forKey: "morf")
        let numPeople = numPeopleSeg.selectedSegmentIndex + 1

        let inPersonPayload = InPersonSigninPayload(name: name
            , phone: phone
            , email: emailField.text ?? ""
            , scanTime: scanTimeInSeconds
            , clientId: UUID().uuidString
            , numPeople: numPeople
            , maleOrFemale: morf
        )

        for _ in (1...numPeople) {				    
            SessionEntries.add(payload: inPersonPayload)
        }
        presenter!.refresh()

        // submit payload
        let network = Network()
        network.submit(payload: inPersonPayload) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.dismiss(animated: true) {
                        self.presenter?.alert(title: error.appDescription(), message: "The record has been saved locally")
                    }
                }
                else {
                    self.dismiss(animated: true)
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            }
        }

    }

    func alert(title: String, message: String) {
        let alertController2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController2.addAction(ok)
        self.present(alertController2, animated: true, completion: nil)
    }
}


extension ManualEntryController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // via https://stackoverflow.com/a/44676911/7221535
    func formattedNumber(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX - XXXX"

        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField != phoneField { return true }
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        textField.text = formattedNumber(number: newString)
        return false
    }

}
