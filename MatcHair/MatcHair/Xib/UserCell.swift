//
//  UserCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/29.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {

    var ref: DatabaseReference!
//    var userName: String?

    var messageInfo: MessageInfo? {
        didSet {

            if let messageInfo = messageInfo {

                profileImageView.kf.setImage(with: URL(string: messageInfo.user.imageURL))
                textLabel?.text = messageInfo.user.name

                if messageInfo.message.imageURL == nil {
                    detailTextLabel?.text = messageInfo.message.text
                } else {
                    detailTextLabel?.text = "\(messageInfo.user.name) 傳送了一張圖片"
                }

                if messageInfo.isRead {
                    detailTextLabel?.textColor = .darkGray
                } else {
                    detailTextLabel?.textColor = .black
                }

            }

            if let seconds = messageInfo?.message.timestamp {

                let timestampDate = Date(timeIntervalSince1970: TimeInterval(seconds))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }

        }
    }

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "tab_profile_normal")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
//        label.text = "HH:SS:MM"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel?.frame = CGRect(
            x: 64,
            y: textLabel!.frame.origin.y - 1,
            width: textLabel!.frame.width + 10,
            height: textLabel!.frame.height)

        textLabel?.font = textLabel?.font.withSize(18)

        detailTextLabel?.frame = CGRect(
            x: 64,
            y: detailTextLabel!.frame.origin.y + 2,
            width: detailTextLabel!.frame.width + 10,
            height: detailTextLabel!.frame.height)

        detailTextLabel?.font = detailTextLabel?.font.withSize(14)

    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        ref = Database.database().reference()

        addSubview(profileImageView)
        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        addSubview(timeLabel)
        //x,y,w,h
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 8).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
