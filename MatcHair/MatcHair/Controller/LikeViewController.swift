//
//  LikeViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/27.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class LikeViewController: UIViewController {

    let decoder = JSONDecoder()

    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()
//    var likePosts = [(PostInfo, User)]()
    var likePosts = [Post]()
    let fullScreenSize = UIScreen.main.bounds.size
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!
    var selectedTiming: String?
    let transition = CATransition()

    @IBOutlet weak var likePostCollectionView: UICollectionView!

    @IBAction private func goToChatRoom(_ sender: Any) {
        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}
extension LikeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()

        loadLikePosts()

        observeDeleteAction()

    }

    private func setupCollectionView() {

        likePostCollectionView.dataSource = self
        likePostCollectionView.delegate = self

        let identifier = String(describing: LikePostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        likePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

    }
    // observe .childRemove
    func observeDeleteAction() {

        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        ref.child("likePosts/\(currentUserID)").observe(.childRemoved) { (snapshot) in
//            let postID = snapshot.key
            self.loadLikePosts()
            self.likePostCollectionView.reloadData()

        }
    }

    func loadLikePosts() {

        self.likePosts = []

        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        ref.child("likePosts/\(currentUserID)").observe(.childAdded) { (snapshot) in

            let postID = snapshot.key

            self.ref
                .child("allPosts")
                .queryOrderedByKey()
                .queryEqual(toValue: postID)
                .observeSingleEvent(of: .value) { (snapshot) in

                    guard let value = snapshot.value as? NSDictionary else { return }

                    guard let postJSONData =
                        try? JSONSerialization.data(withJSONObject: value.allValues[0]) else { return }

                    do {
                        let postData = try self.decoder.decode(PostInfo.self, from: postJSONData)
                        self.getAuthorInfo(with: postData)
                    } catch {
                        print(error)
                    }
            }

        }

    }

    func getAuthorInfo(with postData: PostInfo) {

        self.ref.child("users/\(postData.authorUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let userData = try self.decoder.decode(User.self, from: userJSONData)
                self.getAuthorImageURL(with: postData, userData)

            } catch {
                print(error)
            }

        }
    }

    func getAuthorImageURL(with postData: PostInfo, _ userData: User) {

        let fileName = postData.authorUID

        self.storageRef.child(fileName).downloadURL(completion: { (url, error) in

            if let authorImageURL = url {

                let post = Post(info: postData, author: userData, authorImageURL: authorImageURL)
                self.likePosts.insert(post, at: 0)

            } else {
                print(error as Any)
            }

            self.likePosts.sort(by: { $0.info.createTime > $1.info.createTime })
            self.likePostCollectionView.reloadData()

        })

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
            withReuseIdentifier: String(describing: LikePostCollectionViewCell.self),
            for: indexPath)

        guard let postCell = cell as? LikePostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let post = likePosts[indexPath.row]

        postCell.userNameLabel.text = post.author.name
        postCell.userImage.kf.setImage(with: post.authorImageURL)

        postCell.postImage.kf.setImage(with: URL(string: post.info.pictureURL))
        postCell.locationLabel.text =
            "\(post.info.reservation.location.city), \(post.info.reservation.location.district)"

        // target action
        postCell.likeButton.tag = indexPath.row
        postCell.likeButton.addTarget(
            self,
            action: #selector(self.unlikeButtonTapped(sender:)), for: .touchUpInside)

        postCell.reservationButton.tag = indexPath.row
        postCell.reservationButton.addTarget(
            self,
            action: #selector(reservationButtonTapped(sender:)),
            for: .touchUpInside)

        return postCell

    }

    @objc func unlikeButtonTapped(sender: UIButton) {

        print(sender.tag)
        print(sender.isSelected) // false

        guard let userID = Auth.auth().currentUser?.uid else { return }

        let likePost = likePosts[sender.tag]

        ref.child("likePosts/\(userID)/\(likePost.info.postID)").removeValue()

        likePosts.remove(at: sender.tag)

        likePostCollectionView.reloadData()

    }

    @objc func reservationButtonTapped(sender: UIButton) {

        var timingOption = [String]()

        let reservationPost = likePosts[sender.tag]
        let timing = reservationPost.info.reservation.time

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
            title: "\(reservationPost.info.reservation.date)",
        options: timingOption) {(value) -> Void in

            print("selected: \(value)")
            self.selectedTiming = value

            self.uploadAppointment(post: reservationPost.info, with: value)

            // 向左換 tab 頁
            self.transition.duration = 0.5
            self.transition.type = CATransitionType.push
            self.transition.subtype = CATransitionSubtype.fromLeft
            self.transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.view.window!.layer.add(self.transition, forKey: kCATransition)

            self.tabBarController?.selectedIndex = 1

        }

    }

    private func uploadAppointment(post: PostInfo, with timing: String) {

        guard let currentUserUID = UserManager.shared.getUserUID() else {return }

        guard let appointmentID = self.ref.child("appointmentPosts").childByAutoId().key else { return }

        ref.child("appointmentPosts/pending/\(appointmentID)").setValue(
            [
                "designerUID": post.authorUID,
                "modelUID": currentUserUID,
                "postID": post.postID,
                "timing": timing,
                "appointmentID": appointmentID,
            ]
        )

    }

    // TODO
    func removeLikeAlert(title: String = "移除最愛", message: String) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in

        }

        let cancle = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancle)

        present(alertController, animated: true, completion: nil)
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

extension LikeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//        let selectedPost = likePosts[indexPath.row].0
//        let detailForPost = DetailViewController.detailForPost(selectedPost)
//        self.present(detailForPost, animated: true)
    }
}
