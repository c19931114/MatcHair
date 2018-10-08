//
//  ModelAcceptCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/30.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class ModelConfirmCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var designerImage: UIImageView!
    @IBOutlet weak var designerNameLabel: UILabel!
    @IBOutlet weak var reservationTimeLabel: UILabel!

    @IBOutlet weak var completeButton: UIButton!

    @IBAction func chat(_ sender: UIButton) {
    }

    @IBAction func complete(_ sender: UIButton) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
