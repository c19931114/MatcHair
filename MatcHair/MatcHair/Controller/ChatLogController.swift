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

            if let user = user {
//                nameLabel.text = "\(user.name) >"
                nameLabel.text = "\(user.name)"
                navigationItem.titleView = titleView
//                titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUserProfile)))
            }
//            observeMessages() // 移到 viewDidLoad 不然會一直進來跑, 因為user一直丟進來
        }
    }

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var titleView: UIView = {

        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        containerView.addSubview(nameLabel)
        //x,y,w,h
        nameLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

        return containerView
    }()

    lazy var inputTextField: UITextField = {

        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self // laxy var 才可以, let 不行
        return textField
    }()

    lazy var sendButton: UIButton = {

        let button = UIButton(type: .system)
        button.setTitle("👋", for: .normal)
        button.tintColor = #colorLiteral(red: 0.8645840287, green: 0.5463376045, blue: 0.5011332035, alpha: 1)
        //  sendButton.contentMode = .center
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSendTextMessage), for: .touchUpInside)
        return button
    }()

    lazy var inputContainerView: UIView = {

        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white

        let uploadImageView = UIImageView()
        uploadImageView.backgroundColor = #colorLiteral(red: 0.8645840287, green: 0.5463376045, blue: 0.5011332035, alpha: 1)
        uploadImageView.image = #imageLiteral(resourceName: "Album Camera Icon").withRenderingMode(.alwaysTemplate)
        uploadImageView.tintColor = .white
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.layer.cornerRadius = 16
        uploadImageView.layer.masksToBounds = true
        uploadImageView.contentMode = .scaleAspectFill
        uploadImageView.isUserInteractionEnabled = true // 預設不能點擊
        uploadImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true

        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 10).isActive = true
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

        return containerView

    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)

        //collectionView?.keyboardDismissMode = .interactive
        //尚未處理 inputContainerView 會有黑畫面

        navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: #imageLiteral(resourceName: "btn_more_three_dots"), style: .plain, target: self, action: #selector(handleBlockUser))
        setupInputComponents()

        ref = Database.database().reference()
        observeMessages()

    }
    
    @objc func handleBlockUser() {
        showBlockAlert()
    }
    func showBlockAlert() {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let blockAction = UIAlertAction(title: "封鎖此用戶", style: .destructive, handler: showBlockMessage)
        alertController.addAction(blockAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func showBlockMessage(alert: UIAlertAction) {

        let alertController = UIAlertController(
            title: nil,
            message: "確定封鎖此用戶？",
            preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        alertController.addAction(
            UIAlertAction(title: "確定", style: .destructive, handler: uploadBlockedUID))

        self.present(alertController, animated: true, completion: nil)
    }

    func uploadBlockedUID(alert: UIAlertAction) {

        guard let currentUserUID = keychain.get("userUID") else { return }

        if let user = user {
            ref.child("users/\(currentUserUID)/blockedUIDs/\(user.uid)").setValue(true)
        }

        NotificationCenter.default.post(name: .reFetchAllPosts, object: nil, userInfo: nil)
        navigationController?.popViewController(animated: true)
    }

    @objc func showUserProfile() {

        let homeNav = UIStoryboard.homeStoryboard().instantiateInitialViewController()
        dismiss(animated: false, completion: nil)

        let profileForDesigner = ProfileViewController.profileForDesigner(self.user!.uid)
        homeNav?.navigationController?.pushViewController(profileForDesigner, animated: true) //失敗

    }

    func setupInputComponents() {

        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainerView)
        //x,y,w,h
        inputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true

    }

    @objc func handleUploadTap() {

        let imagePickerController = UIImagePickerController()

        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        // need to conform UIImagePickerControllerDelegate, UINavigationControllerDelegate

        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func handleSendTextMessage() {
        var text = [String: String]()
        let textString = inputTextField.text!
//        print(sendButton)
//        print(sendButton.titleLabel)
//        print(sendButton.titleLabel?.text)
        if textString.trimmingCharacters(in: .whitespaces).isEmpty {
            print("emptyText")
            text = ["text": "👋"]
        } else {
            text = ["text": inputTextField.text!]
        }

//        if sendButton.titleLabel?.text
        sendMessage(with: text)
    }

    fileprivate func sendImageMessageWith(_ imageURL: String, image: UIImage) {

        let imageInfo = [
            "imageURL": imageURL,
            "imageWidth": image.size.width,
            "imageHeight": image.size.height
            ] as [String: Any]

        sendMessage(with: imageInfo)
    }

    private func sendMessage(with properties: [String: Any]) {

        guard let messageID = ref.child("messages").childByAutoId().key else { return }
        guard let toID = user?.uid,
            let fromID = keychain.get("userUID") else { return }
        let timestamp = Int(Date().timeIntervalSince1970)

        var values = ["toID": toID, "fromID": fromID, "timestamp": timestamp] as [String: Any]

        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})

        ref.child("messages/\(messageID)").updateChildValues(values) { (error, ref) in

            if error != nil {
                print(error as Any)
                return
            }
            self.inputTextField.text = nil
            self.sendButton.setTitle("👋", for: .normal)
            self.sendButton.setImage(nil, for: .normal)

            //true:已讀, false:未讀
            self.ref.child("user-messages").child(fromID).child(toID).updateChildValues([messageID: false])
            self.ref.child("user-messages").child(toID).child(fromID).updateChildValues([messageID: false])
        }
    }

    func observeMessages() {

        guard let currentUserUID = keychain.get("userUID"),
            let chatPartnerUID = user?.uid else { return }

        ref.child("user-messages").child(currentUserUID).child(chatPartnerUID)
            .observe(.childAdded) { (snapshot) in

            let messageID = snapshot.key
            self.fetchMessagesWith(messageID, currentUserUID, chatPartnerUID)
        }

    }

    private func fetchMessagesWith(_ messageID: String, _ currentUserUID: String, _ chatPartnerUID: String) {

        ref.child("messages").child(messageID).observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let messageJSONData =
                try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let messageData = try self.decoder.decode(Message.self, from: messageJSONData)

                // 這邊要 handle 好 >< 不過改了 user-messages 結構就不用了 ><
//                if messageData.toID == self.user?.uid || messageData.fromID == self.user?.uid {

                    self.messages.append(messageData)
                    self.collectionView.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
//                }
                self.handleMessageBeenReadWith(messageID, currentUserUID, chatPartnerUID)

            } catch {
                print(error)
            }

        }
    }

    //true:已讀, false:未讀
    private func handleMessageBeenReadWith(_ messageID: String, _ currentUserUID: String, _ chatPartnerUID: String) {

        ref.child("user-messages").child(currentUserUID).child(chatPartnerUID).updateChildValues([messageID: true])
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(messages.count)
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

        setupCellStyle(cell, message: message)

        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 30
        } else if message.imageURL != nil {
            //fall in here if it is an image
            cell.bubbleWidthAnchor?.constant = 200
        }

        return cell
    }

    fileprivate func setupCellStyle(_ cell: ChatMessageCell, message: Message) {

        if let profileImageUrl = self.user?.imageURL {
            cell.profileImageView.kf.setImage(with: URL(string: profileImageUrl))
        }

        if message.fromID == Auth.auth().currentUser?.uid {
            //outgoing
            cell.bubbleView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9490196078, alpha: 1)
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleView.layer.borderWidth = 0

        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = .white
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.layer.borderWidth = 1
            cell.bubbleView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)

        }

        if let messageImageURL = message.imageURL {
            cell.messageImageView.kf.setImage(with: URL(string: messageImageURL))
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear

        } else {
            cell.messageImageView.isHidden = true
        }
    }
}

extension ChatLogController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        var height: CGFloat = 80

        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 16
        } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
            //fall in here if it is an image

            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            height = CGFloat(imageHeight) / CGFloat(imageWidth) * 200
            // cell.bubbleWidthAnchor?.constant = 200
        }

        return CGSize(width: view.frame.width, height: height)
        // cell 是整個螢幕的寬度沒錯喔 但只顯示 bubbleView 所以 width 的值是沒有錯的唷
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
        handleSendTextMessage()
        return true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {

        if let text = textField.text, let textRange = Range(range, in: text) {

            let updatedText = text.replacingCharacters(in: textRange, with: string)

            if updatedText.trimmingCharacters(in: .whitespaces).isEmpty {
                sendButton.setTitle("👋", for: .normal)
                sendButton.setImage(nil, for: .normal)
            } else {
                sendButton.setTitle("", for: .normal)
                sendButton.setImage(#imageLiteral(resourceName: "btn_send").withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }

        return true
    }
    
}

extension ChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {

            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(selectedImage)
        }

        dismiss(animated: true, completion: nil)
    }

    private func uploadToFirebaseStorageUsingImage(_ image: UIImage) {

        let imageName = UUID().uuidString

        if let uploadData = image.jpegData(compressionQuality: 0.2) {

            storageRef.child("message-images").child(imageName)
                .putData(uploadData, metadata: nil, completion: { (metadata, error) in

                    guard metadata != nil else {
                        print("Failed to upload image:", error as Any)
                        return
                    }

                    self.storageRef.child("message-images").child(imageName)
                        .downloadURL(completion: { (url, error) in

                            guard let url = url else {
                                print(error as Any)
                                return
                            }
                            self.sendImageMessageWith(url.absoluteString, image: image)
                    })
            })
        }
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(
    _ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
