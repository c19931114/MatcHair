//
//  LikeViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/27.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class LikeViewController: UIViewController {

    let decoder = JSONDecoder()

    var ref: DatabaseReference!
    var likePosts = [Post]()
    let fullScreenSize = UIScreen.main.bounds.size

    @IBOutlet weak var likePostCollectionView: UICollectionView!

}
extension LikeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()

        loadLikePosts()

    }

    private func setupCollectionView() {

        likePostCollectionView.dataSource = self
        likePostCollectionView.delegate = self

        let identifier = String(describing: PostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        likePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

    }

    func loadLikePosts() {

        guard let userID = UserManager.shared.getUserUID() else { return }

        ref.child("likePosts/\(userID)").observe(.childAdded) { (snapshot) in

            let postID = snapshot.key

            self.ref.child("allPosts").observe(.childAdded) { (snapshot) in

                if snapshot.key == postID {

                    guard let value = snapshot.value as? NSDictionary else { return }
                    guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

                    do {
                        let postData = try self.decoder.decode(Post.self, from: postJSONData)
                        self.likePosts.insert(postData, at: 0)
                    } catch {
                        print(error)
                    }
                    
                    self.likePostCollectionView.reloadData()

                }
            }

        }

    }

}

extension LikeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likePosts.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = likePostCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: PostCollectionViewCell.self),
            for: indexPath)

        guard let postCell = cell as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let post = likePosts[indexPath.row]

        ref.child("users/\(post.userUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let userData = try self.decoder.decode(User.self, from: userJSONData)
                postCell.userNameLabel.text = userData.name
                postCell.userImage.kf.setImage(with: URL(string: userData.image))
            } catch {
                print(error)
            }

            self.likePostCollectionView.reloadData()

        }

        postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
        postCell.locationLabel.text = "\(post.reservation.location.city), \(post.reservation.location.district)"

        // taget action
//        postCell.likeButton.tag = indexPath.row
//        postCell.likeButton.addTarget(
//            self,
//            action: #selector(likeButtonTapped(sender:)), for: .touchUpInside)

        return postCell

    }

    @objc func likeButtonTapped(sender: UIButton) {

        print(sender.tag)
        print(sender.isSelected)

        sender.isSelected = !sender.isSelected
        if sender.isSelected {

            sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
            //            ref.child("likePosts/\()")

        } else {

            sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)

        }

    }

}

extension LikeViewController: UICollectionViewDelegateFlowLayout {

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

        let width = fullScreenSize.width - 40
        let height = width * 27 / 25
        return CGSize(width: width, height: height)

    }

}
