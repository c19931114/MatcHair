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
    var ref: DatabaseReference!

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

        ref = Database.database().reference()

    }

    func fbLogin() {

        fbLoginManager.logIn(
            withReadPermissions: ["public_profile", "email"],
            from: self, handler: { (logInAction, error) in

                if logInAction != nil {

                    guard let cancel = logInAction?.isCancelled else { return }

                    if !cancel {
                        print("登入成功")

                        AppDelegate.shared?.window?.rootViewController
                            = UIStoryboard.mainStoryboard().instantiateInitialViewController()

                        // Log in Firebase
                        let credential =
                            FacebookAuthProvider.credential(
                                withAccessToken: FBSDKAccessToken.current().tokenString)

                        Auth.auth().signInAndRetrieveData(with: credential) { (authDataResult, error) in

                            if let error = error {

                                print("Can't Login: \(error)")
                                return

                            } else {

                                guard let uid = Auth.auth().currentUser?.uid else {return }

                                guard let userName
                                    = Auth.auth().currentUser?.displayName else { return }

                                guard let photoURL
                                    = Auth.auth().currentUser?.photoURL else { return }

                                print(Auth.auth().currentUser?.description)

                                self.uploadUserPictureToStorage(with: uid, and: userName, and: photoURL)

                            }
                        }

                    } else {
                        print("cancel")
                    }

                } else {

                    print("取消登入")
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
//                        self.uploadUserPicture(with: userPictureURLString)

                    }
            })

    }

    func uploadUserPictureToStorage(with uid: String, and userName: String, and photoURL: URL) {

        guard let photoData = try? Data(contentsOf: photoURL) else { return }

        guard let photo = UIImage(data: photoData),
            let uploadData =  photo.jpegData(compressionQuality: 0.5) else {

                print("no image")
                return
        }

        storageRef
            .child("\(userName).jpg")
            .putData(uploadData, metadata: nil) { (metadata, error) in

                guard metadata != nil else {
                // Uh-oh, an error occurred!
                    print(error as Any)
                    return
                }

                self.uploadUserInfoToDatabase(with: uid , and: userName, and: photoURL)

        }

    }

    func uploadUserInfoToDatabase(with uid: String, and userName: String, and photoURL: URL) {

        ref.child("users/\(uid)").setValue(
            [
                "user": userName,
                "photo": photoURL.absoluteString
            ]
        )

    }

}
