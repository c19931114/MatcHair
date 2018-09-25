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
    case post
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
            
        case .post:
            
            return UIStoryboard
                .postStoryboard()
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

    func image() -> UIImage {

        switch self {

        case .home: return #imageLiteral(resourceName: "tab_main_normal")

        case .appointment: return #imageLiteral(resourceName: "tab_appointment_normal")

        case .post: return #imageLiteral(resourceName: "tab_post")

        case .like: return #imageLiteral(resourceName: "tab_like_normal")

        case .profile: return #imageLiteral(resourceName: "tab_profile_normal")

        }

    }

    func selectedImage() -> UIImage {

        switch self {

        case .home: return #imageLiteral(resourceName: "tab_main_normal").withRenderingMode(.alwaysTemplate)

        case .appointment: return #imageLiteral(resourceName: "tab_appointment_normal").withRenderingMode(.alwaysTemplate)

        case .post: return #imageLiteral(resourceName: "tab_post").withRenderingMode(.alwaysTemplate)

        case .like: return #imageLiteral(resourceName: "tab_like_normal").withRenderingMode(.alwaysTemplate)

        case .profile: return #imageLiteral(resourceName: "tab_profile_normal").withRenderingMode(.alwaysTemplate)

        }

    }

}

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTab()

    }

    private func setupTab() {

        tabBar.unselectedItemTintColor = UIColor(
            red: 142 / 255.0,
            green: 212 / 255.0,
            blue: 242 / 255.0,
            alpha: 1.0)
        // #8ED4F2

        tabBar.tintColor = UIColor(
            red: 3 / 255.0,
            green: 121 / 255.0,
            blue: 200 / 255.0,
            alpha: 1.0)
        // #0379C8

        // 背景色
        tabBar.barTintColor = UIColor(
            red: 255 / 255.0,
            green: 255 / 255.0,
            blue: 255 / 255.0,
            alpha: 1.0)

        var controllers = [UIViewController]()

        let tabs: [Tab] = [.home, .appointment, .post, .like, .profile]

        for tab in tabs {

            let controller = tab.controller()

            let item = UITabBarItem(
                title: nil,
                image: tab.image(),
                selectedImage: tab.selectedImage()
            )

            item.imageInsets = UIEdgeInsets(
                top: 6,
                left: 0,
                bottom: -6,
                right: 0
            )

            controller.tabBarItem = item

            controllers.append(controller)
        }

        setViewControllers(controllers, animated: false)
    }
    
}
