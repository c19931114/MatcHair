//
//  AppDelegate.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/19.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let shared = UIApplication.shared.delegate as? AppDelegate

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        FirebaseApp.configure() // 放後面會 crash

        FBSDKApplicationDelegate.sharedInstance().application(
            application,
            didFinishLaunchingWithOptions: launchOptions)
        
        FBSDKSettings.setAppID("1934375866856449")

        guard UserManager.shared.getUserToken() == nil else {
            switchToMainStoryBoard()
            return true
        }

        return true
    }
    
    func switchToLoginStoryBoard() {
        
        guard Thread.current.isMainThread else {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.switchToLoginStoryBoard()
            }
            
            return
        }
        
        window?.rootViewController = UIStoryboard.loginStoryboard().instantiateInitialViewController()
    }

    func switchToMainStoryBoard() {

        guard Thread.current.isMainThread else {

            DispatchQueue.main.async { [weak self] in

                self?.switchToMainStoryBoard()
            }

            return
        }

        window?.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        FBSDKAppEvents.activateApp()

    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }

}
