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
import FBSDKShareKit
import KeychainSwift
import Crashlytics

class LoginViewController: UIViewController {

    private let fbLoginManager = FBSDKLoginManager()
    let keychain = KeychainSwift()

    // Get a reference to the storage service using the default Firebase App
    // Create a storage reference from our storage service
    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    var userDefaults = UserDefaults.standard

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var skipNowButton: UIButton!
    
    @IBAction func login(_ sender: Any) {

        fbLogin()
    }

    @IBAction func skipNow(_ sender: Any) {
        AppDelegate.shared?.window?.rootViewController
            = UIStoryboard.mainStoryboard().instantiateInitialViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isStatusBarHidden = true
        ref = Database.database().reference()

//        let button = UIButton(type: .roundedRect)
//        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
//        button.setTitle("Crash", for: [])
//        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
//        view.addSubview(button)

    }

//    @IBAction func crashButtonTapped(_ sender: AnyObject) {
//        Crashlytics.sharedInstance().crash()
//    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.isStatusBarHidden = false
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
                        self.keychain.set(FBSDKAccessToken.current().tokenString, forKey: "userToken")

                        Auth.auth().signInAndRetrieveData(with: credential) { (authDataResult, error) in

                            if let error = error {

                                print("Can't Login: \(error)")
                                return

                            } else {

                                guard let uid = Auth.auth().currentUser?.uid else { return }
                                self.keychain.set(uid, forKey: "userUID")

                                guard let userName
                                    = Auth.auth().currentUser?.displayName else { return }

                                guard let photoURLString
                                    = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
                                let largePhotoURLString = photoURLString + "?type=large"
                                let largePhotoURL = URL(string: largePhotoURLString)!

//                                self.getUserDetail(with: uid, userName)

                                self.uploadUserImageToStorage(with: uid, userName, largePhotoURL)

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

    func getUserDetail(with uid: String, _ userName: String) {

        FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])?.start(
                completionHandler: { (connection, result, error) in

                    if error != nil {
                        print("Error: \(String(describing: error))")
                        
                    } else {

                        guard let userInfo = result as? [String: Any] else { return }

//                        guard let userName = userInfo["name"] as? String else { return }
//                        guard let userEmail = userInfo["email"] as? String else { return }

                        guard let userImageInfo = userInfo["picture"] as? [String: Any] else { return }
                        guard let userImageData = userImageInfo["data"] as? [String: Any] else { return }
                        guard let userImageURLString = userImageData["url"] as? String else { return }
                        guard let userImageURL = URL(string: userImageURLString) else { return }

//                        self.userDefaults.set(userImageURL, forKey: "userImageURL")

                        self.uploadUserImageToStorage(with: uid, userName, userImageURL)

                    }
            })

    }

    func uploadUserImageToStorage(with uid: String, _ userName: String, _ userImageURL: URL) {

        guard let userImageData = try? Data(contentsOf: userImageURL) else { return }

        guard let userImage = UIImage(data: userImageData),
            let uploadData = userImage.jpegData(compressionQuality: 0.1) else {

                print("no image")
                return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let fileName: String = "\(uid)"

        storageRef.child("user-images").child(fileName)
            .putData(uploadData, metadata: metadata) { (metadata, error) in

                guard metadata != nil else {
                // Uh-oh, an error occurred!
                    print(error as Any)
                    return
                }

                self.storageRef.child("user-images").child(fileName)
                    .downloadURL(completion: { (url, error) in

                    guard let userImageURL = url else {
                        print(error as Any)
                        return
                    }

                    self.uploadUserInfoToDatabaseWith(uid, userName, userImageURL)

                })

//                self.uploadUserInfoToDatabaseWith(with: uid, userName)

        }

    }

    func uploadUserInfoToDatabaseWith(_ uid: String, _ userName: String, _ userImage: URL) {

        ref.child("users/\(uid)").updateChildValues(
            [
                "name": userName,
                "imageURL": userImage.absoluteString,
                "uid": uid
            ]
        )

    }

}
