//
//  ChatLogController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/28.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class ChatLogController: UICollectionViewController {

    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    let keychain = KeychainSwift()

    var user: User? {
        didSet {
            navigationItem.title = user?.name
        }
    }

    lazy var inputTextField: UITextField = {

        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self // laxy var 才可以, let 不行
        return textField
    }()

    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "asd", style: .plain, target: nil, action: nil)

        collectionView.backgroundColor = .white

        setupInputComponents()

        ref = Database.database().reference()

    }

    func setupInputComponents() {

        let containerView = UIView()
//        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(self.inputTextField)
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.lightGray
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    }

    @objc func handleSend() {

        guard let messageID = ref.child("messages").childByAutoId().key else { return }
        let toID = user?.uid

        ref.child("messages/\(messageID)").updateChildValues(
            [
                "text": inputTextField.text!,
                "toID": toID
            ]
        )

//        let properties = ["text": inputTextField.text!]
//        sendMessageWithProperties(properties as [String : AnyObject])
    }

}

extension ChatLogController: UITextFieldDelegate {

    // 按 Enter 送出
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
