//
//  ProfileViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/20.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController {

    let fullScreenSize = UIScreen.main.bounds.size
    var posts: [String] = []
    var ref: DatabaseReference!

    @IBOutlet weak var userPhotoImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var postCollectionView: UICollectionView!

    @IBAction func set(_ sender: Any) {

    }

}

extension ProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        showUserData()

        loadPost()

    }

    private func setupCollectionView() {

        postCollectionView.dataSource = self

        let identifier = String(describing: PostCollectionViewCell.self)

        let xib = UINib(nibName: identifier, bundle: nil)

        postCollectionView.register(xib, forCellWithReuseIdentifier: identifier)
    }

//    func setCellLayout() {
//
//        guard let layout = postCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
//
//        layout.minimumLineSpacing = 5
//
//        let width = (fullScreenSize.width - 10.0) / 2
//        let height = width * 0.62
//        layout.itemSize = CGSize(width: width, height: height)
//
//    }

    func showUserData() {
        userNameLabel.text = UserManager.shared.getUserName()
        userPhotoImage.kf.setImage(with: Auth.auth().currentUser?.photoURL)

    }

    func loadPost() {

        guard let userUID = Auth.auth().currentUser?.uid else { return }

        ref.child("users/\(userUID)/posts").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value else { return }
            
            print(value)

        }
    }

}

extension ProfileViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = postCollectionView.dequeueReusableCell(
            withReuseIdentifier: "postCell",
            for: indexPath) as? PostCollectionViewCell {

//            let cellIndexPath = postInfoCell[indexPath.row]

            return cell
        } else {
            return UICollectionViewCell()
        }
    }

}
