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
import FirebaseStorage
import Kingfisher

class ProfileViewController: UIViewController {

    let decoder = JSONDecoder()

    let fullScreenSize = UIScreen.main.bounds.size
    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()
    var myPosts: [MyPost] = []
    var currentUserImageURL: URL?
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    @IBOutlet weak var profileCollectionView: UICollectionView!

    @IBAction private func goToChatRoom(_ sender: Any) {
        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}

extension ProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()

        getUserImage()

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

    func getUserImage() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        let fileName = currentUserUID

        self.storageRef.child(fileName).downloadURL(completion: { (url, error) in

            if let url = url {
                self.currentUserImageURL = url
            } else {
                print(error as Any)
            }
            self.profileCollectionView.reloadData()

        })
    }

    func loadProfilePosts() {

        self.myPosts = []

        guard let currnetUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("usersPosts/\(currnetUserUID)").observe(.childAdded) { (snapshot) in

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

            if let userName = Auth.auth().currentUser?.displayName {
                profileCell.userNameLabel.text = userName
            }

            profileCell.userImage.kf.setImage(with: currentUserImageURL)

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

extension ProfileViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedPost = myPosts[indexPath.row]
        let detailForPost = DetailViewController.detailForMyPost(selectedPost)
        self.present(detailForPost, animated: true)
    }
}
