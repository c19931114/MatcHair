//
//  EmptyPageViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/17.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FBSDKLoginKit
//import FBSDKShareKit
import FirebaseAuth
import KeychainSwift
import FirebaseStorage
import FirebaseDatabase

class EmptyPageViewController: UIViewController {

    let fullScreenSize = UIScreen.main.bounds.size
    let keychain = KeychainSwift()
    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    let fbLoginManager = FBSDKLoginManager()

    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var loginMessageLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    @IBAction func fbLogin(_ sender: Any) {

        fbLogin()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setEmptyPage()

        ref = Database.database().reference()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

//        setEmptyPage()

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
                        //                        self.userDefaults.set(FBSDKAccessToken.current().tokenString, forKey: "userToken")

                        Auth.auth().signInAndRetrieveData(with: credential) { (authDataResult, error) in

                            if let error = error {

                                print("Can't Login: \(error)")
                                return

                            } else {

                                guard let uid = Auth.auth().currentUser?.uid else {return }
                                self.keychain.set(uid, forKey: "userUID")
                                //                                self.userDefaults.set(uid, forKey: "userUID")

                                guard let userName
                                    = Auth.auth().currentUser?.displayName else { return }
                                //                                self.userDefaults.set(userName, forKey: "userName")

                                guard let photoURLString
                                    = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
                                let largePhotoURLString = photoURLString + "?type=large"
                                let largePhotoURL = URL(string: largePhotoURLString)!

                                //                                self.userDefaults.set(largePhotoURL, forKey: "userImageURL")

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

        storageRef
            .child(fileName)
            .putData(uploadData, metadata: metadata) { (metadata, error) in

                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    print(error as Any)
                    return
                }

                //                self.storageRef.child(fileName).downloadURL(completion: { (url, error) in
                //
                //                    guard let userImageURL = url else {
                //                        return
                //                    }
                //
                //                    self.uploadUserInfoToDatabase(with: uid, userName)
                //
                //                })

                self.uploadUserInfoToDatabase(with: uid, userName)

        }

    }

    func uploadUserInfoToDatabase(with uid: String, _ userName: String) {

        ref.child("users/\(uid)").setValue(
            [
                "name": userName
            ]
        )

    }

}
