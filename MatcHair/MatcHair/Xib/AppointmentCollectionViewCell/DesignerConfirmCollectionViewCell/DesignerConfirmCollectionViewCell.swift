//
//  DesignerAcceptCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/30.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class DesignerConfirmCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var modelImage: UIImageView!
    @IBOutlet weak var modelNameLabel: UILabel!
    @IBOutlet weak var reservationTimeLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!

    @IBAction func chat(_ sender: UIButton) {
    }

    @IBAction func cancel(_ sender: UIButton) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

}
