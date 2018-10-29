//
//  MessageController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/29.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MessageController: UITableViewController {

    let cellId = "cellId"
    var ref: DatabaseReference!
    let decoder = JSONDecoder()
    var users = [User]()
    var messageInfos = [MessageInfo]()
    var messageInfosDictionary = [String: MessageInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(handleCancel))

        navigationItem.title = "Message"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "New Message",
            style: .plain,
            target: self,
            action: #selector(handleNewMessage))

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        ref = Database.database().reference()

        observeMessages()

    }

    func observeMessages() {

        ref.child("messages").observe(.childAdded) { (snapshot) in
            print(snapshot)

            guard let value = snapshot.value as? NSDictionary else {

                self.tableView.reloadData()
                return
            }

            guard let messageJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {

                let messageData = try self.decoder.decode(Message.self, from: messageJSONData)

                self.fetchUserWith(messageData)

            } catch {
                print(error)
            }
        }

    }

    func fetchUserWith(_ message: Message) {

        ref.child("users").child(message.toID).observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {
                self.tableView.reloadData()
                return
            }

            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {

                let userData = try self.decoder.decode(User.self, from: userJSONData)
                self.messageInfos.append(MessageInfo(message: message, user: userData))

                self.messageInfosDictionary[message.toID] = MessageInfo(message: message, user: userData)

                self.tableView.reloadData()

            } catch {
                print(error)
            }
        }

    }

    func showChatLogControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }

    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let navController = NavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageInfosDictionary.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }

        let messageInfo = messageInfos[indexPath.row]

        cell.messageInfo = messageInfo

//        cell.profileImageView.kf.setImage(with: URL(string: messageInfo.user.image))
//        cell.textLabel?.text = messageInfo.user.name
//        cell.detailTextLabel?.text = messageInfo.message.text

        return cell
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let user = users[indexPath.row]
//        showChatLogControllerForUser(user: user)
//    }

}
