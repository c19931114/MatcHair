//
//  LoginViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/19.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class LoginViewController: UIViewController {

    private let fbLoginManager = FBSDKLoginManager()

    // Get a reference to the storage service using the default Firebase App
    // Create a storage reference from our storage service
    let storageRef = Storage.storage().reference()
//    var ref: DatabaseReference!

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipNowButton: UIButton!
    
    @IBAction func login(_ sender: Any) {

        fbLogin()
    }

    @IBAction func skipNow(_ sender: Any) {
        AppDelegate.shared?.window?.rootViewController
            = UIStoryboard.mainStoryboard().instantiateInitialViewController()
    }
    
}

extension LoginViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        ref = Database.database().reference()

    }

    func fbLogin() {

        fbLoginManager.logIn(
            withReadPermissions: ["public_profile", "email"],
            from: self, handler: { (logInAction, error) in

                if logInAction != nil {

                    guard let cancel = logInAction?.isCancelled else { return }

                    let fbTokenInfo = logInAction?.token
//                    let userID = fbTokenInfo?.userID
//                    print("\(String(describing: userID))")

                    if !cancel {
                        print("登入成功")

                        AppDelegate.shared?.window?.rootViewController
                            = UIStoryboard.mainStoryboard().instantiateInitialViewController()

                        guard let facebookToken = fbTokenInfo?.tokenString else {
                            print("no token")
                            return
                        }
                        print(facebookToken)

                        self.getUserDetails()

                    } else {
                        print("cancel")
                    }

                } else {

                    print(error as Any)
                }
        })

    }

    func getUserDetails() {

        FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, first_name, last_name, email, picture"])?.start(
                completionHandler: { (connection, result, error) in

                    if error != nil {

                        print("Error: \(String(describing: error))")
                    } else {

                        guard let userInfo = result as? [String: Any] else { return }

//                        guard let userName = userInfo["name"] as? String else { return }
//                        guard let userEmail = userInfo["email"] as? String else { return }

                        guard let userPictureInfo = userInfo["picture"] as? [String: Any] else { return }
                        guard let userPictureData = userPictureInfo["data"] as? [String: Any] else { return }
                        guard let userPictureURLString = userPictureData["url"] as? String else { return }
                        self.uploadUserPicture(with: userPictureURLString)

                    }
            })

    }

    func uploadUserPicture(with urlString: String) {

        if let photoData = try? Data(contentsOf: URL(string: urlString)!) {

            if let photo = UIImage(data: photoData) {

                print(photo)

            }

        } else {
            print("error")

        }




        
    }

}
