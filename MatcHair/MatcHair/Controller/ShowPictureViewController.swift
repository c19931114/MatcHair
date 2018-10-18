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
    @IBOutlet weak var gradietView: UIView!

    let transition = CATransition()

    // Get a reference to the storage service using the default Firebase App
    // Create a storage reference from our storage service
    let storageRef = Storage.storage().reference()
    var ref: DatabaseReference!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pictureView: UIImageView!
    
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

        performSegue(withIdentifier: "goEdit", sender: image)

    }
    
}

extension ShowPictureViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        pictureView.image = picture
        
    }

    override func viewDidLayoutSubviews() {
        setGradientView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setLayout()
    }
    
    private func setLayout() {

        nextButton.setImage(#imageLiteral(resourceName: "btn_next").withRenderingMode(.alwaysTemplate), for: .normal)
        nextButton.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    func setGradientView() {

        let gradient = CAGradientLayer()
        gradient.frame = gradietView.bounds

        gradient.colors = [UIColor(red: 164/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1.0).cgColor,
                           UIColor(red: 234/255.0, green: 188/255.0, blue: 171/255.0, alpha: 1.0).cgColor]

        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)

        gradietView.layer.insertSublayer(gradient, at: 0)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let image = sender as? UIImage else { return }

        guard let postViewController = segue.destination as? PostViewController else { return }

        postViewController.picture = image

    }
    
}
