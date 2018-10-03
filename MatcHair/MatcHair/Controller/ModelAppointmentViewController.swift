//
//  ModelAppointmentViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/30.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class ModelAppointmentViewController: UIViewController {

    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    let fullScreenSize = UIScreen.main.bounds.size
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    // fake data
    var modelWaitingPosts: [Post] = [Post(
        postID: "postID",
        category: Category(dye: false, haircut: true, other: false, permanent: false, shampoo: false, treatment: false),
        content: "content",
        payment: "1200",
        pictureURL: "https://firebasestorage.googleapis.com/v0/b/matchair-f9ac8.appspot.com/o/%E6%A8%B8%E5%AF%B6%E8%8B%B1.png?alt=media&token=7c088130-ac9d-48c6-8fa9-d8607767e32b",
        reservation: Reservation(date: "2018/10/30", location: Location(address: "基隆路一段", city: "台北市", district: "信義區"), time: Timing(afternoon: true, morning: false, night: false)),
        userUID: "cYUWWGgyRRTKYdVl6wwSXXbNmVI3",
        isLiked: false)]

    var modelAcceptPosts: [Post] = [Post(
        postID: "postID",
        category: Category(dye: false, haircut: true, other: false, permanent: false, shampoo: false, treatment: false),
        content: "content",
        payment: "1200",
        pictureURL: "https://firebasestorage.googleapis.com/v0/b/matchair-f9ac8.appspot.com/o/%E6%A8%B8%E5%AF%B6%E8%8B%B1.png?alt=media&token=7c088130-ac9d-48c6-8fa9-d8607767e32b",
        reservation: Reservation(date: "2018/10/30", location: Location(address: "基隆路一段", city: "台北市", district: "信義區"), time: Timing(afternoon: true, morning: false, night: false)),
        userUID: "cYUWWGgyRRTKYdVl6wwSXXbNmVI3",
        isLiked: false)]

    @IBOutlet weak var modelWatingCollectionView: UICollectionView!
    @IBOutlet weak var modelAcceptCollectionView: UICollectionView!

    @IBAction func switchStament(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            modelWatingCollectionView.isHidden = false
            modelAcceptCollectionView.isHidden = true
        case 1:
            modelWatingCollectionView.isHidden = true
            modelAcceptCollectionView.isHidden = false
        default:
            modelWatingCollectionView.isHidden = true
            modelAcceptCollectionView.isHidden = true
        }
    }
    @IBAction private func goToChatRoom(_ sender: Any) {
        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}

extension ModelAppointmentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        modelAcceptCollectionView.isHidden = true

        setupCollectionView()

    }

    private func setupCollectionView() {

        modelWatingCollectionView.dataSource = self
        modelWatingCollectionView.delegate = self

        let waitingIdentifier = String(describing: ModelPendingCollectionViewCell.self)
        let waitingXib = UINib(nibName: waitingIdentifier, bundle: nil)
        modelWatingCollectionView.register(waitingXib, forCellWithReuseIdentifier: waitingIdentifier)

        modelAcceptCollectionView.dataSource = self
        modelAcceptCollectionView.delegate = self

        let acceptIdentifier = String(describing: ModelAcceptCollectionViewCell.self)
        let acceptXib = UINib(nibName: acceptIdentifier, bundle: nil)
        modelAcceptCollectionView.register(acceptXib, forCellWithReuseIdentifier: acceptIdentifier)

    }
}

extension ModelAppointmentViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch collectionView {

        case modelWatingCollectionView:
            return modelWaitingPosts.count
        default:
            return modelAcceptPosts.count
        }

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch collectionView {
        case modelWatingCollectionView:

            let cell = modelWatingCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ModelPendingCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? ModelPendingCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = modelWaitingPosts[indexPath.row]

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
            //            } catch {
            //                print(error)
            //            }
            //
            //            self.designerCollectionView.reloadData()
            //
            //        }

            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
            //        postCell.reservationTimeLabel.text = "\(post.reservation.date), \(post.reservation.time.afternoon)"
            postCell.reservationTimeLabel.text = "\(post.reservation.date), afternoon"

            postCell.userImage.kf.setImage(
                with: URL(string:
                    "https://firebasestorage.googleapis.com/v0/b/matchair-f9ac8.appspot.com/o/Crystal%20Liu_cYUWWGgyRRTKYdVl6wwSXXbNmVI3?alt=media&token=6b665617-868e-4f14-a3c4-d2c9c5706c47"))

            // taget action
//            postCell.cancelButton.tag = indexPath.row
//            postCell.cancelButton.addTarget(
//                self,
//                action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)
            return postCell

        default:

            let cell = modelAcceptCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ModelAcceptCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? ModelAcceptCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = modelAcceptPosts[indexPath.row]

            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
            postCell.reservationTimeLabel.text = "\(post.reservation.date), afternoon"

            postCell.userImage.kf.setImage(
                with: URL(string:
                    "https://firebasestorage.googleapis.com/v0/b/matchair-f9ac8.appspot.com/o/Crystal%20Liu_cYUWWGgyRRTKYdVl6wwSXXbNmVI3?alt=media&token=6b665617-868e-4f14-a3c4-d2c9c5706c47"))

            // taget action
            //            postCell.cancelButton.tag = indexPath.row
            //            postCell.cancelButton.addTarget(
            //                self,
            //                action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)

            return postCell
        }

    }

//    @objc func cancelButtonTapped(sender: UIButton) {
//        //        print(sender.tag)
//        //        print(sender.isSelected)
//
//        guard let userID = UserManager.shared.getUserUID() else { return }
//
//        let modelWaitingPost = modelWaitingPosts[sender.tag]
//
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected {
//
//            sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
//            ref.child("likePosts/\(userID)/\(modelWaitingPost.postID)").setValue(true)
//
//        } else {
//
//            sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
//            ref.child("likePosts/\(userID)/\(modelWaitingPost.postID)").removeValue()
//
//        }
//
//    }

}

extension ModelAppointmentViewController: UICollectionViewDelegateFlowLayout {

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
