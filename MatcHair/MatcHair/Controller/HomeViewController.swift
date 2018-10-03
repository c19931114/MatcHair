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
    var allPosts = [(Post, User)]()
    var likePostIDs = [String]()
    var likePostIndex: Int?
    var selectedTiming: String?

    let fullScreenSize = UIScreen.main.bounds.size
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    @IBOutlet weak var homePostCollectionView: UICollectionView!

    @IBAction private func goToChatRoom(_ sender: Any) {

        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}

extension HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()

        loadAllPosts()
        loadLikePosts()

//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        homePostCollectionView.collectionViewLayout = layout

    }

    private func setupCollectionView() {

        homePostCollectionView.dataSource = self
        homePostCollectionView.delegate = self

        let identifier = String(describing: PostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        homePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

    }

    func loadAllPosts() {

        ref.child("allPosts").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }
//            print(value.allKeys)
            guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postData = try self.decoder.decode(Post.self, from: postJSONData)

                self.getUserInfo(with: postData)

            } catch {
                print(error)
            }

        }

    }

    func getUserInfo(with postData: Post) {

        self.ref.child("users/\(postData.userUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let userData = try self.decoder.decode(User.self, from: userJSONData)
                self.allPosts.insert((postData, userData), at: 0)

            } catch {
                print(error)
            }

            self.homePostCollectionView.reloadData()

        }
    }

    func loadLikePosts() {

        guard let currentUserUID = UserManager.shared.getUserUID() else { return }

        ref.child("likePosts/\(currentUserUID)").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let likePostIDs = value.allKeys as? [String] else { return }
            self.likePostIDs = likePostIDs

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

        postCell.userNameLabel.text = post.1.name
        postCell.userImage.kf.setImage(with: URL(string: post.1.image))

        postCell.postImage.kf.setImage(with: URL(string: post.0.pictureURL))
        postCell.locationLabel.text = "\(post.0.reservation.location.city), \(post.0.reservation.location.district)"

        // taget action
        postCell.likeButton.tag = indexPath.row
        postCell.likeButton.addTarget(
            self,
            action: #selector(self.likeButtonTapped(sender:)), for: .touchUpInside)

        postCell.reservationButton.tag = indexPath.row
        postCell.reservationButton.addTarget(
            self,
            action: #selector(reservationButtonTapped(sender:)),
            for: .touchUpInside)

        return postCell

    }

    @objc func likeButtonTapped(sender: UIButton) {

        guard let userUID = UserManager.shared.getUserUID() else { return }

        let likePost = allPosts[sender.tag].0

        sender.isSelected = !sender.isSelected
        if sender.isSelected {

//            sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
            ref.child("likePosts/\(userUID)/\(likePost.postID)").setValue(true)

        } else {

//            sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
            ref.child("likePosts/\(userUID)/\(likePost.postID)").removeValue()

        }

    }

    @objc func reservationButtonTapped(sender: UIButton) {
        
        var timingOption = [String]()

        let reservationPost = allPosts[sender.tag].0
        let timing = reservationPost.reservation.time

        if timing.morning {
            timingOption.append("早上")
        }

        if timing.afternoon {
            timingOption.append("下午")
        }

        if timing.night {
            timingOption.append("晚上")
        }
        print(timing)
        print(timingOption)

        PickerDialog().show(
            title: "\(reservationPost.reservation.date)",
            options: timingOption) {(value) -> Void in

                print("selected: \(value)")
                self.selectedTiming = value
                
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

        let width = fullScreenSize.width - 40
        let height = width * 27 / 25
        return CGSize(width: width, height: height)

    }

}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedPost = allPosts[indexPath.row].0
        let detailForPost = DetailViewController.detailForPost(selectedPost)
        self.present(detailForPost, animated: true)
    }
}
