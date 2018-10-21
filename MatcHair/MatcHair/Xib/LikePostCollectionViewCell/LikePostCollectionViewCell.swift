//
//  LikePostCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/29.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class LikePostCollectionViewCell: UICollectionViewCell {

    let fullScreenSize = UIScreen.main.bounds.size

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var userImageButton: UIButton!

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!

    @IBAction func like(_ sender: UIButton) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setCellShadow()
        chatButton.isHidden = true

    }

    func setCellShadow() {

        let width = fullScreenSize.width - 40
        let height = width * 27 / 25

        self.layer.shadowColor = UIColor(
            red: 130 / 255.0,
            green: 139 / 255.0,
            blue: 160 / 255.0,
            alpha: 1.0).cgColor

        self.layer.shadowPath = UIBezierPath(
            roundedRect: CGRect(x: 0, y: 0, width: width, height: height),
            cornerRadius: self.contentView.layer.cornerRadius
            ).cgPath

        // shadowOffset 偏移
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
    }

}
