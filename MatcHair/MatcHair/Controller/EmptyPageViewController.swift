//
//  EmptyPageViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/17.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class EmptyPageViewController: UIViewController {

    let fullScreenSize = UIScreen.main.bounds.size

    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var loginMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        setEmptyPage()
        
    }

    func setEmptyPage() {

        loginImage.image = loginImage.image?.withRenderingMode(.alwaysTemplate)
        loginImage.tintColor = #colorLiteral(red: 0.7568627451, green: 0.8274509804, blue: 0.8274509804, alpha: 1)

        loginMessageLabel.textColor = UIColor(red: 169/255.0, green: 185/255.0, blue: 192/255.0, alpha: 1)
        loginMessageLabel.textAlignment = .center
        loginMessageLabel.font = loginMessageLabel.font.withSize(15)

        loginButton.backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.8274509804, blue: 0.8274509804, alpha: 1)
        loginButton.setImage(#imageLiteral(resourceName: "facebook_logo").withRenderingMode(.alwaysTemplate), for: .normal)
        loginButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        loginButton.layer.cornerRadius = 5
        loginButton.layer.shadowRadius = 2
        loginButton.layer.shadowColor = #colorLiteral(red: 0.662745098, green: 0.7254901961, blue: 0.7529411765, alpha: 1)
        loginButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        loginButton.layer.masksToBounds = false
        loginButton.layer.shadowOpacity = 1.0

    }

}
