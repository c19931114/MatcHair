//
//  TabBarViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/19.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

private enum Tab {
    
    case home
    case appointment
    case chat
    case like
    case profile
    
    func controller() -> UIViewController {
        
        switch self {
            
        case .home:
            
            return UIStoryboard
                .homeStoryboard()
                .instantiateInitialViewController()!
        
        case .appointment:
            
            return UIStoryboard
                .appointmentStoryboard()
                .instantiateInitialViewController()!
            
        case .chat:
            
            return UIStoryboard
                .chatStoryboard()
                .instantiateInitialViewController()!
            
        case .like:
            
            return UIStoryboard
                .likeStoryboard()
                .instantiateInitialViewController()!
            
        case .profile:
            
            return UIStoryboard
                .profileStoryboard()
                .instantiateInitialViewController()!
            
        }
        
    }

}

class TabBarViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
