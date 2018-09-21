//
//  UIStoryboard+Crystal.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/19.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func loginStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Login", bundle: nil)
    }

    static func mainStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static func homeStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Home", bundle: nil)
    }
    
    static func appointmentStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Appointment", bundle: nil)
    }
    
    static func chatStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Chat", bundle: nil)
    }
    
    static func likeStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Like", bundle: nil)
    }
    
    static func profileStoryboard() -> UIStoryboard {
        
        return UIStoryboard(name: "Profile", bundle: nil)
    }

    static func postStoryboard() -> UIStoryboard {

        return UIStoryboard(name: "Post", bundle: nil)
    }
    
}
