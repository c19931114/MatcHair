//
//  PostEditViewController.swift
//  Voyage
//
//  Created by Crystal on 2018/9/9.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import Photos
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class ShowPictureViewController: UIViewController {
    
    var picture: UIImage?
    
    let transition = CATransition()

    // Get a reference to the storage service using the default Firebase App
    // Create a storage reference from our storage service
    let storageRef = Storage.storage().reference()
    var ref: DatabaseReference!

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pictureView: UIImageView!
    
    @IBAction func goBack(_ sender: UIStoryboardSegue) {
        self.dismiss(animated: false) //
    }
    
    @IBAction func save(_ sender: Any) {
        
        guard let image = picture else {
            print("no image")
            return
        }
        
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } // 把照片存進手機
        
    }
    
    @IBAction func next(_ sender: Any) {
        
        guard let image = picture else {

            return
        }

//        self.transition.duration = 0.5
//        self.transition.type = CATransitionType.push
//        self.transition.subtype = CATransitionSubtype.fromRight
//        self.transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        self.view.window!.layer.add(self.transition, forKey: kCATransition)
//        
//        let tabController = self.view.window!.rootViewController as? UITabBarController
//        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
//        tabController?.selectedIndex = 2

        performSegue(withIdentifier: "goEdit", sender: image)

    }
    
}

extension ShowPictureViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        pictureView.image = picture
        setLayout()
        
    }
    
    private func setLayout() {
        
        saveButton.layer.borderColor = #colorLiteral(red: 0.9246133566, green: 0.9246349931, blue: 0.9246233106, alpha: 1)
        saveButton.layer.borderWidth = 2
        saveButton.layer.cornerRadius = 5
        
        nextButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        nextButton.layer.borderWidth = 2
        nextButton.layer.cornerRadius = 5
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let image = sender as? UIImage else { return }

        guard let postViewController = segue.destination as? PostViewController else { return }

        postViewController.picture = image // 為什麼不能馬上show照片Ｑ

    }
    
}
