//
//  ChatroomController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/1.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import KeychainSwift
import Firebase

class ChatroomController: UIViewController {

    var messages = [Message]()
    let keychain = KeychainSwift()
    var ref: DatabaseReference!

    @IBOutlet weak var messageListTableView: UITableView!

    @IBAction func leave(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        messageListTableView.register(
//            MessageListCell.self,
//            forCellReuseIdentifier: String(describing: MessageListCell.self))

        ref = Database.database().reference()

//        observeUserMessages()

    }

    @IBAction func showChat(_ sender: Any) {

        showChatController()
    }

    func showChatController() {

        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())

        navigationController?.pushViewController(chatLogController, animated: true)

    }

    func observeUserMessages() {
        guard let currentUserUID = keychain.get("userUID") else {
            // show empty page
            return
        }

        ref.child("messages").child(currentUserUID).observe(.childAdded) { (snapshot) in
            print(snapshot)
        }

    }
    
}

extension ChatroomController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}

extension ChatroomController: UITableViewDelegate {

}
