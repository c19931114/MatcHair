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
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static let shared = UIApplication.shared.delegate as? AppDelegate

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        window?.tintColor = UIColor(
            red: 3 / 255.0,
            green: 121 / 255.0,
            blue: 200 / 255.0,
            alpha: 1.0)
        FirebaseApp.configure() // 放後面會 crash

        FBSDKApplicationDelegate.sharedInstance().application(
            application,
            didFinishLaunchingWithOptions: launchOptions)
        
        FBSDKSettings.setAppID("1934375866856449")

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

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

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let result = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return result
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let result = FBSDKApplicationDelegate.sharedInstance().application(
            application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return result
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
