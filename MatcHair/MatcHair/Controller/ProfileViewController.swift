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

    let decoder = JSONDecoder()

    let fullScreenSize = UIScreen.main.bounds.size
    var profilePosts: [MyPost] = []
    var ref: DatabaseReference!
    
    @IBOutlet weak var profilePostCollectionView: UICollectionView!
    
    @IBOutlet weak var userPhotoImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var postCountLabel: UILabel!

    @IBAction func set(_ sender: Any) {

    }

}

extension ProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        showUserData()

        setupCollectionView()

        loadProfilePosts()

    }

    private func setupCollectionView() {

        profilePostCollectionView.dataSource = self

        let identifier = String(describing: PostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        profilePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

        guard let layout = profilePostCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumLineSpacing = 20

        let width = fullScreenSize.width - 30
        let height = width * 27 / 25
        layout.itemSize = CGSize(width: width, height: height)
    }

    func showUserData() {
        userNameLabel.text = UserManager.shared.getUserName()
        userPhotoImage.kf.setImage(with: UserManager.shared.getUserPhotoURL())

    }

    func loadProfilePosts() {

        guard let userUID = UserManager.shared.getUserUID() else { return }

        ref.child("users/\(userUID)/posts").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postData = try self.decoder.decode(MyPost.self, from: postJSONData)
                self.profilePosts.append(postData)
            } catch {
                print(error)
            }

            self.profilePostCollectionView.reloadData()
            self.postCountLabel.text = "\(self.profilePosts.count)"

        }
    }

}

extension ProfileViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profilePosts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = profilePostCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: PostCollectionViewCell.self),
            for: indexPath)

        guard let postCell = cell as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let profilePost = profilePosts[indexPath.row]

        postCell.postImage.kf.setImage(with: URL(string: profilePost.pictureURL))
        postCell.userImage.kf.setImage(with: UserManager.shared.getUserPhotoURL())
        postCell.reservationButton.isHidden = true

        return postCell
    }

}
