//
//  ProfileCollectionViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/27.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import KeychainSwift
import FBSDKLoginKit

class ProfileCollectionViewCell: UICollectionViewCell {

    let keychain = KeychainSwift()

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    
    @IBAction func editProfile(_ sender: Any) {
        
    }

    @IBAction func logout(_ sender: Any) {

        keychain.clear()

        FBSDKLoginManager().logOut()

        AppDelegate.shared?.window?.rootViewController
            = UIStoryboard.loginStoryboard().instantiateInitialViewController()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
