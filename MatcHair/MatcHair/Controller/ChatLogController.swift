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

    let cellId = "cellId"
    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    let decoder = JSONDecoder()
    let keychain = KeychainSwift()

    var messages = [Message]()

    var user: User? {
        didSet {
            navigationItem.title = user?.name

            observeMessages()
        }
    }

    lazy var inputTextField: UITextField = {

        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self // laxy var 才可以, let 不行
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "asd", style: .plain, target: nil, action: nil)

        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)

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
        containerView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let sendButton = UIButton(type: .system)
//        sendButton.setTitle("Send", for: .normal)
        sendButton.setImage(#imageLiteral(resourceName: "btn_send").withRenderingMode(.alwaysTemplate), for: .normal)
        sendButton.tintColor = #colorLiteral(red: 0.8645840287, green: 0.5463376045, blue: 0.5011332035, alpha: 1)
//        sendButton.contentMode = .center
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = #colorLiteral(red: 0.9374653697, green: 0.7858970761, blue: 0.7262797952, alpha: 1) //UIColor.lightGray
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

        let toID = user!.uid
        guard let fromID = keychain.get("userUID") else { return }
        let timestamp = Int(Date().timeIntervalSince1970)

        let values =
            [
                "text": inputTextField.text!,
                "toID": toID,
                "fromID": fromID,
                "timestamp": timestamp
            ] as [String: Any]

        ref.child("messages/\(messageID)").updateChildValues(values) { (error, ref) in

            if error != nil {
                print(error!)
                return
            }

            self.inputTextField.text = nil

            self.ref.child("user-messages").child(fromID).updateChildValues([messageID: 1])

            self.ref.child("user-messages").child(toID).updateChildValues([messageID: 1])

        }

//        let properties = ["text": inputTextField.text!]
//        sendMessageWithProperties(properties as [String : AnyObject])
    }

    func observeMessages() {

        guard let currentUserUID = keychain.get("userUID") else {
            collectionView.reloadData()
            return
        }

        // 不用 ref 因為還來不及初始化
        Database.database().reference()
            .child("user-messages").child(currentUserUID).observe(.childAdded) { (snapshot) in

            let messageID = snapshot.key

            self.fetchMessagesWith(messageID, currentUserUID)
        }

    }

    func fetchMessagesWith(_ messageID: String, _ currentUserUID: String) {

        ref.child("messages").child(messageID).observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {

                self.collectionView.reloadData()
                return
            }

            guard let messageJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let messageData = try self.decoder.decode(Message.self, from: messageJSONData)

//                if messageData.toID == self.user?.uid {

                    self.messages.append(messageData)
                    self.collectionView.reloadData()

//                }

            } catch {
                print(error)
            }

        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellId,
            for: indexPath) as? ChatMessageCell else {
                
            return UICollectionViewCell()
        }

        let message = messages[indexPath.item]
        cell.textView.text = message.text

        if message.fromID == Auth.auth().currentUser?.uid {
            //outgoing
            cell.bubbleView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
        } else {
            //incomming
            cell.bubbleView.backgroundColor = .white
            cell.bubbleView.layer.borderWidth = 1
            cell.bubbleView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        }

        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text).width + 32

        return cell
    }

}

extension ChatLogController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        var height: CGFloat = 80

        let text = messages[indexPath.item].text

        height = estimateFrameForText(text: text).height + 20

        return CGSize(width: view.frame.width, height: height)
    }

    fileprivate func estimateFrameForText(text: String) -> CGRect {

        // 200 是 ChatMessageCell 裡 bubbleView 的寬
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        // 16 是 ChatMessageCell 裡 textView 的 font size
        return NSString(string: text)
            .boundingRect(
                with: size,
                options: options,
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
                context: nil)
    }
}

extension ChatLogController: UITextFieldDelegate {

    // 按 Enter 送出
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
