//
//  LikePostCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/29.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class LikePostCollectionViewCell: UICollectionViewCell {

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

    }

}
