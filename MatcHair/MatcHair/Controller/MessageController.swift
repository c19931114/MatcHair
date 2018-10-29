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

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            title: "test",
//            style: .plain,
//            target: self,
//            action: #selector(showChatLogControllerForUser))

        navigationItem.title = "Message"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "leave",
            style: .plain,
            target: self,
            action: #selector(handleCancel))

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        ref = Database.database().reference()

        fetchUser()

    }

    func fetchUser() {

        ref.child("users").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {

                self.tableView.reloadData()
                return
            }

            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {

                let userData = try self.decoder.decode(User.self, from: userJSONData)
                self.users.append(userData)
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
        cell.detailTextLabel?.text = user.name
        cell.profileImageView.kf.setImage(with: URL(string: user.image))

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        showChatLogControllerForUser(user: user)
    }

}

class UserCell: UITableViewCell {

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "icon_person")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel?.frame = CGRect(
            x: 64,
            y: textLabel!.frame.origin.y - 2,
            width: textLabel!.frame.width,
            height: textLabel!.frame.height)

        detailTextLabel?.frame = CGRect(
            x: 64,
            y: detailTextLabel!.frame.origin.y + 2,
            width: detailTextLabel!.frame.width,
            height: detailTextLabel!.frame.height)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        addSubview(profileImageView)

        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
