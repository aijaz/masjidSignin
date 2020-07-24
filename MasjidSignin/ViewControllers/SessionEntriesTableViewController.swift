//
//  SessionEntriesTableViewController.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/25/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class SessionEntriesTableViewController: UITableViewController {
    var items = [InPersonSigninPayload]()

    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
    }

    func refresh(all: Bool) {
        let startDate = UserDefaults.standard.object(forKey: "sessionStartDate") as? Date ?? Date(timeIntervalSince1970: 0)
        let endDate = UserDefaults.standard.object(forKey: "sessionEndDate") as? Date ?? Date()
        let startTimeInterval = startDate.timeIntervalSince1970
        let endTimeInterval = endDate.timeIntervalSince1970

        if all {
            items = SessionEntries.read().filter({ (payload) -> Bool in
                payload.scanTime >= startTimeInterval && payload.scanTime < endTimeInterval
            }).reversed()
        }
        else {
            items = FailedEntries.read().filter({ (payload) -> Bool in
                payload.scanTime >= startTimeInterval && payload.scanTime < endTimeInterval
            }).reversed()
        }
    }

}

extension SessionEntriesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayloadCell",
                                                 for: indexPath) as! PayloadCell
        let payload = items[row]
        cell.nameLabel.text = payload.name
        cell.phoneLabel.text = payload.phone
        cell.emailLabel.text = payload.email
        cell.uuidLabel.text = ""
        cell.scanTimeLabel.text = formatter.string(from: Date(timeIntervalSince1970: payload.scanTime))
        cell.nLabel.text = "\(100 + items.count - row)"
        if payload.maleOrFemale == "F" {
            cell.morfBg.backgroundColor = .systemPink
            cell.morfLabel.text = payload.maleOrFemale
        }
        else {
            cell.morfBg.backgroundColor = .systemTeal
            cell.morfLabel.text = "M"
        }
        cell.morfBg.layer.cornerRadius = 12

        return cell
    }

}
