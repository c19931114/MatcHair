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

    let pendingPosts = [(ReservationPost, String, String)]()
    let confirmPosts = [ReservationPost]()

    @IBOutlet weak var modelPendingCollectionView: UICollectionView!
    @IBOutlet weak var modelConfirmCollectionView: UICollectionView!

    @IBAction func switchStament(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            modelPendingCollectionView.isHidden = false
            modelConfirmCollectionView.isHidden = true
        case 1:
            modelPendingCollectionView.isHidden = true
            modelConfirmCollectionView.isHidden = false
        default:
            modelPendingCollectionView.isHidden = true
            modelConfirmCollectionView.isHidden = true
        }
    }
    @IBAction private func goToChatRoom(_ sender: Any) {
        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}

extension ModelAppointmentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        modelConfirmCollectionView.isHidden = true

        setupCollectionView()
        loadPendingPosts()

    }

    private func setupCollectionView() {

        modelPendingCollectionView.dataSource = self
        modelPendingCollectionView.delegate = self

        let pendingIdentifier = String(describing: ModelPendingCollectionViewCell.self)
        let pendingXib = UINib(nibName: pendingIdentifier, bundle: nil)
        modelPendingCollectionView.register(pendingXib, forCellWithReuseIdentifier: pendingIdentifier)

        modelConfirmCollectionView.dataSource = self
        modelConfirmCollectionView.delegate = self

        let confirmIdentifier = String(describing: ModelAcceptCollectionViewCell.self)
        let confirmXib = UINib(nibName: confirmIdentifier, bundle: nil)
        modelConfirmCollectionView.register(confirmXib, forCellWithReuseIdentifier: confirmIdentifier)

    }

    func loadPendingPosts() {

        ref.child("appointmentPosts").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }
            print(value.allKeys)
            guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postData = try self.decoder.decode(ReservationPost.self, from: postJSONData)
                print(postData)

//                self.getUserInfo(with: postData)

            } catch {
                print(error)
            }

        }

    }
    
}

extension ModelAppointmentViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch collectionView {

        case modelPendingCollectionView:
            return pendingPosts.count
        default:
            return confirmPosts.count
        }

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch collectionView {
        case modelPendingCollectionView:

            let cell = modelPendingCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ModelPendingCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? ModelPendingCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = pendingPosts[indexPath.row]

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

//            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
//            postCell.reservationTimeLabel.text = "\(post.reservation.date), \(post.reservation.time.afternoon)"
//            postCell.reservationTimeLabel.text = "\(post.reservation.date), afternoon"
//
//            postCell.userImage.kf.setImage(
//                with: URL(string: ""))

            // taget action
//            postCell.cancelButton.tag = indexPath.row
//            postCell.cancelButton.addTarget(
//                self,
//                action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)
            return postCell

        default:

            let cell = modelConfirmCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ModelAcceptCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? ModelAcceptCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = confirmPosts[indexPath.row]

//            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
//            postCell.reservationTimeLabel.text = "\(post.reservation.date), afternoon"

            postCell.userImage.kf.setImage(
                with: URL(string: ""))

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
