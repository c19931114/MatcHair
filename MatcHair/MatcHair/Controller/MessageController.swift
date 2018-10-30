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
import KeychainSwift

class MessageController: UITableViewController {

    let cellId = "cellId"
    var ref: DatabaseReference!
    let decoder = JSONDecoder()
    let keychain = KeychainSwift()

    var messageInfos = [MessageInfo]()
    var messageInfosDictionary = [String: MessageInfo]()
    var chatPartner: String?
    var chatPartnerUID: String?

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

        observeUserMessages()

    }

    func observeUserMessages() {

        messageInfos.removeAll()
        messageInfosDictionary.removeAll()
//        tableView.reloadData()

        guard let currentUserUID = keychain.get("userUID") else {
            tableView.reloadData()
            return
        }

        ref.child("user-messages").child(currentUserUID).observe(.childAdded) { (snapshot) in

            let messageID = snapshot.key

            self.fetchMessagesWith(messageID, currentUserUID)

        }
    }

    func fetchMessagesWith(_ messageID: String, _ currentUserUID: String) {

        ref.child("messages").child(messageID).observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {

                self.tableView.reloadData()
                return
            }

            guard let messageJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {

                let messageData = try self.decoder.decode(Message.self, from: messageJSONData)
                self.fetchUserWith(messageData, currentUserUID)

            } catch {
                print(error)
            }
        }
    }

    func fetchUserWith(_ message: Message, _ currentUserUID: String) {

        if message.fromID == currentUserUID {
            chatPartnerUID = message.toID
        } else {
            chatPartnerUID = message.fromID
        }

        ref.child("users").child(chatPartnerUID!).observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {
                self.tableView.reloadData()
                return
            }

            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {

                let userData = try self.decoder.decode(User.self, from: userJSONData)
//                self.messageInfos.append(MessageInfo(message: message, user: userData))

                if message.fromID == currentUserUID {
                    self.chatPartnerUID = message.toID
                } else {
                    self.chatPartnerUID = message.fromID
                }

                self.messageInfosDictionary[self.chatPartnerUID!] = MessageInfo(message: message, user: userData)
                self.messageInfos = Array(self.messageInfosDictionary.values)

                self.messageInfos.sort(by: { (message1, message2) -> Bool in

                    return message1.message.timestamp > message2.message.timestamp
                })

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
        return messageInfos.count
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let messageInfo = messageInfos[indexPath.row]

        showChatLogControllerForUser(user: messageInfo.user)
    }

}
