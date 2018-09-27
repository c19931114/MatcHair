//
//  ProfileCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/27.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    
    @IBAction func editProfile(_ sender: Any) {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
