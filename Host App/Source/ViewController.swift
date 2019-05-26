//
//  ViewController.swift
//  iOS Example
//
//  Created by Chad Pavliska on May 12, 2019.
//  Copyright © 2019 Chad Pavliska. All rights reserved.
//

import UIKit
import SkeletonKey

class ViewController: UITableViewController {

    // Tableview Assets
    enum SectionType { case props, appUsers, actions }
    var sections: [SectionType] = [.props, .appUsers, .actions]

    var manager: SessionManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bundleID = Bundle.main.bundleIdentifier {
            let config = Configuration(userProvider: UserProvider(), service: bundleID)
            manager = SessionManager(configuration: config)
        }

        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    @objc
    func handleRefresh(refreshControl: UIRefreshControl) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    // MARK: - IBActions

    @IBAction func tappedProcess(_ sender: UIButton) {
        guard let manager = manager else { return }

        print("Processing \(manager.checkState()) state.")
        manager.processState { (appUser, error) in
            if let error = error {
                print("Did not create app user. Error: \(error.localizedDescription)")
            }
            if let appUser = appUser {
                print("AppUser is \(appUser.displayName ?? "")")
            }
            self.tableView.reloadData()
        }
    }

    @IBAction func tappedReset(_ sender: Any) {
        guard let manager = manager else { return }

        presentAlert(msg: "Reset data and restore device back to blank state?") { (action) in
            manager.reset()
            self.tableView.reloadData()
            print("Reset data")
        }

    }


    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let manager = manager else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        switch getSection(for: indexPath.section) {
        case .props:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Session State"
                cell.detailTextLabel?.text = "\(manager.checkState())"
            case 1:
                cell.textLabel?.text = "User Set?"
                cell.detailTextLabel?.text = "\(manager.isUserSet)"
            case 2:
                cell.textLabel?.text = "Current User ID"
                cell.detailTextLabel?.text = manager.currentAppUserID
            case 3:
                cell.textLabel?.text = "App Device ID"
                cell.detailTextLabel?.text = manager.appDeviceID
            default:
                break
            }

        case .appUsers:
            let appUser = manager.appUsers[indexPath.row]
            cell.textLabel?.text = appUser.displayName
            cell.detailTextLabel?.text = "\(appUser.uid)"

        case .actions:
            switch indexPath.row {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "ProcessButtonCell", for: indexPath)
            case 1:
                return tableView.dequeueReusableCell(withIdentifier: "ResetButtonCell", for: indexPath)
            default:
                break
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let manager = manager else { return 0 }

        let sectionType = getSection(for: section)

        switch sectionType {
        case .props: return 4
        case .appUsers: return manager.appUsers.count
        case .actions: return 2
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch getSection(for: section) {
        case .props:
            return "PROPERTIES"
        case .appUsers:
            return "APP USERS"
        case .actions:
            return " "
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            if let appUser = self.manager?.appUsers[indexPath.row] {
                self.manager?.removeAppUser(uid: appUser.uid)
                self.tableView.reloadData()
            }
        }

        return [deleteAction]
    }

    // MARK: - Helper methods

    private func getSection(for section: Int) -> SectionType {
        return sections[section]
    }

    private func presentAlert(msg: String, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}
