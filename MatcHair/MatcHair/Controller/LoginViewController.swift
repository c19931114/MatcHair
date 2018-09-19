//
//  LoginViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/19.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipNowButton: UIButton!
    
    @IBAction func login(_ sender: Any) {

        
    }
    @IBAction func skipNow(_ sender: Any) {
        
        
    }
    
    

}

extension LoginViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setUpLayout()
        
    }
    
    func setUpLayout() {
        
        loginButton.layer.borderColor = #colorLiteral(red: 0.9246133566, green: 0.9246349931, blue: 0.9246233106, alpha: 1)
        loginButton.layer.borderWidth = 1
//        loginButton.layer.cornerRadius = 5
        
        skipNowButton.layer.borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        skipNowButton.layer.borderWidth = 1
//        skipNowButton.layer.cornerRadius = 5
        
    }
}
