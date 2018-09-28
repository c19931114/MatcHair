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
    var myPosts: [MyPost] = []
    var ref: DatabaseReference!
    
    @IBOutlet weak var profileCollectionView: UICollectionView!

}

extension ProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()

        loadProfilePosts()

    }

    private func setupCollectionView() {

        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self

        let profileCellIdentifier = String(describing: ProfileCollectionViewCell.self)
        let profileXib = UINib(nibName: profileCellIdentifier, bundle: nil)
        profileCollectionView.register(profileXib, forCellWithReuseIdentifier: profileCellIdentifier)

        let postCellIdentifier = String(describing: MyPostCollectionViewCell.self)
        let postXib = UINib(nibName: postCellIdentifier, bundle: nil)
        profileCollectionView.register(postXib, forCellWithReuseIdentifier: postCellIdentifier)

    }

    func loadProfilePosts() {

        guard let userUID = UserManager.shared.getUserUID() else { return }

        ref.child("usersPosts").queryOrdered(byChild: "userUID")
            .queryEqual(toValue: userUID).observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postData = try self.decoder.decode(MyPost.self, from: postJSONData)
                self.myPosts.insert(postData, at: 0)
            } catch {
                print(error)
            }

            self.profileCollectionView.reloadData()

        }
    }

}

extension ProfileViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1

        default:
            return myPosts.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0:

            let cell = profileCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ProfileCollectionViewCell.self),
                for: indexPath)

            guard let profileCell = cell as? ProfileCollectionViewCell else {
                return UICollectionViewCell()
            }

            profileCell.userNameLabel.text = UserManager.shared.getUserName()
            profileCell.userImage.kf.setImage(with: UserManager.shared.getUserImageURL())
            profileCell.postsCountLabel.text = "\(myPosts.count) 則貼文"

            return profileCell

        default:

            let cell = profileCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MyPostCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? MyPostCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = myPosts[indexPath.row]

            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))

            return postCell
        }

    }

}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0) // 每個 section 的邊界(?
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 1 // 上下
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1 // 左右
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        switch indexPath.section {
        case 0:

            let width = fullScreenSize.width
            let height = CGFloat(112.0)
            return CGSize(width: width, height: height)

        default:

            let width = (fullScreenSize.width - 2) / 3
            let height = width
            return CGSize(width: width, height: height)
        }

    }

}
