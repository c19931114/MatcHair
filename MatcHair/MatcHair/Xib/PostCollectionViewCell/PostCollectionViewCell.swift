//
//  PostCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/20.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    let fullScreenSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!

    @IBAction func like(_ sender: UIButton) {
    }

    @IBAction func chat(_ sender: UIButton) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()

//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(postImageTapped))
//        postImage.isUserInteractionEnabled = true
//        postImage.addGestureRecognizer(tapGestureRecognizer)

        setCellShadow()
        chatButton.isHidden = true

    }

    func setCellShadow() {

        let width = fullScreenSize.width - 40
        let height = width * 27 / 25

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: width, height: height),
            cornerRadius: self.contentView.layer.cornerRadius
            ).cgPath

        // shadowOffset 偏移
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
    }

    @objc func postImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {

        let tappedImage = tapGestureRecognizer.view as? UIImageView
        print("tap")
        
    }

}
