//
//  ModelWaitingCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/30.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class ModelPendingCollectionViewCell: UICollectionViewCell {

    let fullScreenSize = UIScreen.main.bounds.size

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var designerImage: UIImageView!
    @IBOutlet weak var reservationTimeLabel: UILabel!

    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var designerNameButton: UIButton!
    @IBOutlet weak var designerImageButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        chatButton.isHidden = true

        setCellShadow()
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
        self.layer.shadowOpacity = 0.2
        self.layer.masksToBounds = false
    }

}
