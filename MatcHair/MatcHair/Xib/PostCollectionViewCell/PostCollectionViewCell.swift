//
//  PostCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/20.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var reservationButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var pokeButton: UIButton!

    @IBAction func makeReservation(_ sender: UIButton) {
    }

    @IBAction func like(_ sender: UIButton) {
    }

    @IBAction func chat(_ sender: UIButton) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()

//        setCellShadow()

    }

    func setCellShadow() {

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.contentView.layer.cornerRadius
            ).cgPath

        // shadowOffset 偏移
        self.layer.shadowOffset = CGSize(width: 10, height: 10)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false

    }

}
