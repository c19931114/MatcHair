//
//  NewMessageController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/29.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import KeychainSwift

class NewMessageController: UITableViewController {

    let cellId = "cellId"
    var ref: DatabaseReference!
    let decoder = JSONDecoder()
    var keychain = KeychainSwift()
    var users = [User]()
    var messages = [Message]()
    var blockedUIDs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "New Message"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(handleCancel))

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        ref = Database.database().reference()

//        fetchUser()
        loadBlockedUser()

    }

    func loadBlockedUser() {

        guard let currentUserUID = keychain.get("userUID") else { return }

        ref.child("users/\(currentUserUID)/blockedUIDs").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {
                self.blockedUIDs = []
                self.fetchUser(with: currentUserUID)
                return
            }

            guard let blockedUIDs = value.allKeys as? [String] else { return }
            self.blockedUIDs = blockedUIDs

            self.fetchUser(with: currentUserUID)
        }
    }

    func fetchUser(with currentUserUID: String) {

        ref.child("users").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {

                self.tableView.reloadData()
                return
            }

            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {

                let userData = try self.decoder.decode(User.self, from: userJSONData)

                if userData.uid != currentUserUID {

                    var flag = true // 沒有 flag 會一直重複新增
                    for blockedUID in self.blockedUIDs {
                        if userData.uid == blockedUID {
                            flag = false
                        }
                    }

                    if flag {

                        self.users.append(userData)
                    }
                }

                self.tableView.reloadData()

            } catch {
                print(error)
            }
        }
    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }

        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
//        cell.detailTextLabel?.text = user.name
        cell.profileImageView.kf.setImage(with: URL(string: user.imageURL))

        return cell
    }

    var messageController: MessageController?

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]

        dismiss(animated: true) {
            self.messageController?.showChatLogControllerForUser(user: user)
        }

    }

}
