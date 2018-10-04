//
//  AppointmentCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/28.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class DesignerPendingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var reservationTimeLabel: UILabel!

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBAction func chat(_ sender: UIButton) {
    }

    @IBAction func accept(_ sender: UIButton) {
    }

    @IBAction func cancel(_ sender: UIButton) {
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
