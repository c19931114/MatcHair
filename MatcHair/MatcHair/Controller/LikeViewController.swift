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
    var likePosts = [(Post, User)]()
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

    }

    private func setupCollectionView() {

        likePostCollectionView.dataSource = self
        likePostCollectionView.delegate = self

        let identifier = String(describing: LikePostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        likePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

    }

    func loadLikePosts() {

        guard let userID = UserManager.shared.getUserUID() else { return }

        ref.child("likePosts/\(userID)").observe(.childAdded) { (snapshot) in

            let postID = snapshot.key

            // 有需要改成 .value 嗎
            self.ref.child("allPosts").observe(.childAdded) { (snapshot) in

                if snapshot.key == postID {

                    guard let value = snapshot.value as? NSDictionary else { return }
                    guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

                    do {
                        let postData = try self.decoder.decode(Post.self, from: postJSONData)

                        self.ref.child("users/\(postData.userUID)").observeSingleEvent(of: .value) { (snapshot) in

                            guard let value = snapshot.value as? NSDictionary else { return }

                            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

                            do {
                                let userData = try self.decoder.decode(User.self, from: userJSONData)
                                self.likePosts.insert((postData, userData), at: 0)

                            } catch {
                                print(error)
                            }

                            self.likePostCollectionView.reloadData()

                        }

                    } catch {
                        print(error)
                    }

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
            withReuseIdentifier: String(describing: LikePostCollectionViewCell.self),
            for: indexPath)

        guard let postCell = cell as? LikePostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let post = likePosts[indexPath.row]

//        ref.child("users/\(post.userUID)").observeSingleEvent(of: .value) { (snapshot) in
//
//            guard let value = snapshot.value as? NSDictionary else { return }
//
//            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }
//
//            do {
//                let userData = try self.decoder.decode(User.self, from: userJSONData)
//                postCell.userNameLabel.text = userData.name
//                postCell.userImage.kf.setImage(with: URL(string: userData.image))
//
//                postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
//                postCell.locationLabel.text = "\(post.reservation.location.city), \(post.reservation.location.district)"
//
//                // taget action
//                postCell.likeButton.tag = indexPath.row
//                postCell.likeButton.addTarget(
//                    self,
//                    action: #selector(self.unlikeButtonTapped(sender:)), for: .touchUpInside)
//
//            } catch {
//                print(error)
//            }
//        }

        postCell.userNameLabel.text = post.1.name
        postCell.userImage.kf.setImage(with: URL(string: post.1.image))

        postCell.postImage.kf.setImage(with: URL(string: post.0.pictureURL))
        postCell.locationLabel.text = "\(post.0.reservation.location.city), \(post.0.reservation.location.district)"

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

        sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)

        guard let userID = UserManager.shared.getUserUID() else { return }

        let likePost = likePosts[sender.tag]

        ref.child("likePosts/\(userID)/\(likePost.0.postID)").removeValue()

        likePosts.remove(at: sender.tag)

        likePostCollectionView.reloadData()

        sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal) // 不改回來的話 下次就變不回紅色

    }

    @objc func reservationButtonTapped(sender: UIButton) {

        var timingOption = [String]()

        let reservationPost = likePosts[sender.tag].0
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

            self.uploadAppointment(post: reservationPost, with: value)

            // 向左換 tab 頁
            self.transition.duration = 0.5
            self.transition.type = CATransitionType.push
            self.transition.subtype = CATransitionSubtype.fromLeft
            self.transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.view.window!.layer.add(self.transition, forKey: kCATransition)

            self.tabBarController?.selectedIndex = 1

        }

    }

    private func uploadAppointment(post: Post, with timing: String) {

        guard let currentUserUID = UserManager.shared.getUserUID() else {return }

        guard let appointmentID = self.ref.child("appointmentPosts").childByAutoId().key else { return }

        ref.child("appointmentPosts/\(appointmentID)").setValue(
            [
                "designerUID": post.userUID,
                "modelUID": currentUserUID,
                "postID": post.postID,
                "timing": timing,
                "appointmentID": appointmentID,
                "statement": "pending"
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

        let selectedPost = likePosts[indexPath.row].0
        let detailForPost = DetailViewController.detailForPost(selectedPost)
        self.present(detailForPost, animated: true)
    }
}
