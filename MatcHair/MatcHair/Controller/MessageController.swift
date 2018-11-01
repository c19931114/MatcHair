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
    var timer: Timer? // 可以設定只 sort & reload tableview 一次 (attemptReloadOfTable)
    // https://youtu.be/JK7pHuSfLyA?list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq&t=1354

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

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(observeUserMessages),
            name: .reFetchMessages,
            object: nil)

        ref = Database.database().reference()
//        observeUserMessages()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        observeUserMessages()
    }

     @objc func observeUserMessages() {

        messageInfos.removeAll()
        messageInfosDictionary.removeAll()
        tableView.reloadData()

        guard let currentUserUID = keychain.get("userUID") else {
            tableView.reloadData()
            return
        }

        ref.child("user-messages").child(currentUserUID).observe(.childAdded) { (snapshot) in

            let chatPartnerUID = snapshot.key

            self.ref.child("user-messages").child(currentUserUID).child(chatPartnerUID)
                .observe(.childAdded, with: { (snapshot) in

                    //true:已讀, false:未讀
                    let messageID = snapshot.key
                    guard let isRead = snapshot.value as? Bool else { return }

                    self.fetchMessagesWith(messageID, currentUserUID, isRead)

            })

        }
    }

    fileprivate func fetchMessagesWith(_ messageID: String, _ currentUserUID: String, _ isRead: Bool) {

        ref.child("messages").child(messageID).observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {

                self.tableView.reloadData()
                return
            }

            guard let messageJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {

                let messageData = try self.decoder.decode(Message.self, from: messageJSONData)
                self.fetchUserWith(messageData, currentUserUID, isRead)

            } catch {
                print(error)
            }
        }
    }

    fileprivate func fetchUserWith(_ message: Message, _ currentUserUID: String, _ isRead: Bool) {

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

                // 存成 dictionary 就可以更新至最後一筆
                self.messageInfosDictionary[self.chatPartnerUID!] =
                    MessageInfo(message: message, user: userData, isRead: isRead)

                self.attemptReloadOfTable()

            } catch {
                print(error)
            }
        }

    }

    fileprivate func attemptReloadOfTable() {

        self.timer?.invalidate()

        self.timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(self.handleReloadTable),
            userInfo: nil, repeats: false)
    }

    @objc func handleReloadTable() {

        messageInfos = Array(self.messageInfosDictionary.values)
        messageInfos.sort(by: { (message1, message2) -> Bool in
            return message1.message.timestamp > message2.message.timestamp
        })

        tableView.reloadData()

//        DispatchQueue.main.async(execute: {
//            self.tableView.reloadData()
//        }) //this will crash because of background thread, so lets call this on dispatch_async main thread
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

//        cell.profileImageView.kf.setImage(with: URL(string: messageInfo.user.imageURL))
//        cell.textLabel?.text = messageInfo.user.name
//        cell.detailTextLabel?.text = messageInfo.message.text

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let messageInfo = messageInfos[indexPath.row]

        showChatLogControllerForUser(user: messageInfo.user)
    }
}
