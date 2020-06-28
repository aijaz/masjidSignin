//
//  ViewController.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/23/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var sessionEntriesTableViewController: SessionEntriesTableViewController!
    @IBOutlet weak var listSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    func refresh() {
        sessionEntriesTableViewController.refresh(all: listSegmentedControl.selectedSegmentIndex == 0)
        sessionEntriesTableViewController.tableView.reloadData()
    }

    @IBAction func handleListChange(_ sender: Any) {
        refresh()
    }

    @IBAction func handleCameraTap(_ sender: Any) {
        let vc = ScannerViewController()
        vc.presenter = self
        present(vc, animated: true)
    }

    @IBAction func handleManualEntryTap(_ sender: Any) {
        let vc = ManualEntryController(nibName: "ManualEntryViewController", bundle: nil)
        vc.presenter = self
        present(vc, animated: true)
    }

    func alert(title: String, message: String) {
        let alertController2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController2.addAction(ok)
        present(alertController2, animated: true, completion: nil)
    }

    func scanned(str: String) {
        let array = str.components(separatedBy: "+")
        if array.count < 2 {
            alert(title: "Invalid Code", message: "Too few data items")
            return
        }
        guard let token = Keychain.read(field: .token) else {
            alert(title: "You're not logged in", message: "You need to log in")
            return
        }
        let api = array[0]
        if api == "2" {
            if array.count != 4 {
                alert(title: "Invalid code", message: "Wrong number of data items for API version \(api)")
                return
            }
            let name = array[1]
            let phone = array[2]
            let email = array[3]
            let payload = InPersonSigninPayload(token: token
                , name: name
                , phone: phone
                , email: email
                , scanTime: Date().timeIntervalSince1970
                , clientId: UUID().uuidString
            )

            SessionEntries.add(payload: payload)
            refresh()

            let n = Network()
            n.submit(payload: payload) { result, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.alert(title: error.appDescription(), message: "The record has been saved locally")
                    }
                }
            }
        }
        else {
            alert(title: "Invalid Code", message: "Unknown API")
            return
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if segue.identifier == "embedPayloadList" {
            sessionEntriesTableViewController = segue.destination as? SessionEntriesTableViewController
            refresh()
        }
    }

    @IBAction func handleRefresh(_ sender: Any) {
        refresh()
    }

    @IBAction func handleRetry(_ sender: Any) {
        let allFailedEntries = FailedEntries.read()
        if allFailedEntries.count == 0 { return }
        let network = Network()
        for payload in allFailedEntries {
            network.submit(payload: payload) { result, error in
                DispatchQueue.main.async {
                    if let _ = error {
                        AudioServicesPlaySystemSound(SystemSoundID(1073))
                    }
                    else {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    }
                    FailedEntries.removeFirst()
                    // will be added back to end if it fails
                }

            }
        }
    }

}

