//
//  ListViewController.swift
//  MasjidSignin
//
//  Created by Aijaz Ansari on 6/24/20.
//  Copyright © 2020 Euclid Software, LLC. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    var items = [SigninsResult.Item]()
    let formatter = DateFormatter()
    private let rc = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.refreshControl = rc
        // Configure Refresh Control
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)

        formatter.dateFormat = "MM/dd/YYYY HH:mm"

        refresh()
    }

    @objc func refresh() {
        let n = Network()
        n.signins(lessThan: nil) {
            result, error in
            if let result = result {
                self.items = result.data
                DispatchQueue.main.async {
                    self.rc.endRefreshing()
                    self.tableView.reloadData()
                }
            }
            else if let error = error {
                DispatchQueue.main.async {
                    self.alert(title: "ERROR", message: error.appDescription())
                }
            }
        }
    }

    func getMore() {
        var lessThan: Int? = nil
        if items.count > 0 {
            lessThan = items.last!.id
        }

        let n = Network()
        n.signins(lessThan: lessThan) {
            result, error in
            if let result = result {
                self.items.append(contentsOf: result.data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else if let error = error {
                self.alert(title: "ERROR", message: error.appDescription())
            }
        }
    }


    func alert(title: String, message: String) {
        let alertController2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController2.addAction(ok)
        present(alertController2, animated: true, completion: nil)
    }
}

extension ListViewController {
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
        let item = items[row]
        cell.nameLabel.text = item.name
        cell.phoneLabel.text = item.phone
        cell.emailLabel.text = item.email
        cell.uuidLabel.text = ""
        cell.scanTimeLabel.text = formatter.string(from: Date(timeIntervalSince1970: item.epoch))
        cell.nLabel.text = "\(item.id)"
        return cell
    }

}


extension ListViewController {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let numRows = items.count
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        for indexPath in indexPaths {
            if numRows == indexPath.row + 1 {
                getMore()
                tableView.reloadData()
                return
            }
        }
    }

}
