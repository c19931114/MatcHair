//
//  HomeViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/26.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class HomeViewController: UIViewController {
    
    let decoder = JSONDecoder()

    var ref: DatabaseReference!
    var allPosts = [Post]()
    let fullScreenSize = UIScreen.main.bounds.size

    @IBOutlet weak var homePostCollectionView: UICollectionView!

}

extension HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()

        loadHomePosts()

    }

    private func setupCollectionView() {

        homePostCollectionView.dataSource = self
        homePostCollectionView.delegate = self

        let identifier = String(describing: PostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        homePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

    }

    func loadHomePosts() {

        ref.child("allPosts").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postData = try self.decoder.decode(Post.self, from: postJSONData)
                self.allPosts.insert(postData, at: 0)
            } catch {
                print(error)
            }

            self.homePostCollectionView.reloadData()

        }

    }

}

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPosts.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = homePostCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: PostCollectionViewCell.self),
            for: indexPath)

        guard let postCell = cell as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let post = allPosts[indexPath.row]

        postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
//        postCell.userImage.kf.setImage(with: URL(string: post.user.image))
//        postCell.userNameLabel.text = post.user.name
        postCell.locationLabel.text = "\(post.reservation.location.city), \(post.reservation.location.district)"

        // taget action
        postCell.likeButton.tag = indexPath.row
        postCell.likeButton.addTarget(
            self,
            action: #selector(likeButtonTapped(sender:)), for: .touchUpInside)

        return postCell

    }

    @objc func likeButtonTapped(sender: UIButton) {
//        print(sender.tag)
//        print(sender.isSelected)

        guard let userID = UserManager.shared.getUserUID() else { return }

        let likePost = allPosts[sender.tag]

        sender.isSelected = !sender.isSelected
        if sender.isSelected {

            sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
            ref.child("likePosts/\(userID)/\(likePost.postID)").setValue(true)

        } else {

            sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
            ref.child("likePosts/\(userID)/\(likePost.postID)").removeValue()

        }

    }

}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) // 每個 section 的邊界(?
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 20 // 上下
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // 左右
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = fullScreenSize.width - 30
        let height = width * 27 / 25
        return CGSize(width: width, height: height)

    }
    
}
