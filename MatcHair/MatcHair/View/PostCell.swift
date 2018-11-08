//
//  PostCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/11/8.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class PostCell: UICollectionViewCell {

    lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "picture_placeholder02")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
//        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()

    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 30 //60
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
//        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUserTap)))
        return imageView
    }()

    lazy var userNameTextView: UITextView = {
        let textView = UITextView()
        textView.text = "SAMPLE TEXT FOR NOW"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.clear
        textView.textColor = .white
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
//        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUserTap)))
        return textView
    }()

    lazy var locationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "icon_location01")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "location"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
        return button
    }()

//    lazy var chatButton: UIButton = {
//        let button = UIButton()
//        button.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
//        return button
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .blue

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
