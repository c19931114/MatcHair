//
//  AppointmentViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/30.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class DesignerAppointmentViewController: UIViewController {

    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    let fullScreenSize = UIScreen.main.bounds.size
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    var designerPendingPosts = [(Appointment, User, Post)]()
    var designerConfirmPosts = [Appointment]()

    @IBOutlet weak var designerPendingCollectionView: UICollectionView!
    @IBOutlet weak var designerConfirmCollectionView: UICollectionView!

    @IBAction func switchStament(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            designerPendingCollectionView.isHidden = false
            designerConfirmCollectionView.isHidden = true
        case 1:
            designerPendingCollectionView.isHidden = true
            designerConfirmCollectionView.isHidden = false
        default:
            designerPendingCollectionView.isHidden = true
            designerConfirmCollectionView.isHidden = true
            
        }
    }

    @IBAction private func goToChatRoom(_ sender: Any) {
        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}

extension DesignerAppointmentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()

        designerConfirmCollectionView.isHidden = true

    }
    private func setupCollectionView() {

        designerPendingCollectionView.dataSource = self
        designerPendingCollectionView.delegate = self

        let waitingIdentifier = String(describing: DesignerPendingCollectionViewCell.self)
        let waitingXib = UINib(nibName: waitingIdentifier, bundle: nil)
        designerPendingCollectionView.register(waitingXib, forCellWithReuseIdentifier: waitingIdentifier)

        designerConfirmCollectionView.dataSource = self
        designerConfirmCollectionView.delegate = self

        let acceptIdentifier = String(describing: DesignerAcceptCollectionViewCell.self)
        let acceptXib = UINib(nibName: acceptIdentifier, bundle: nil)
        designerConfirmCollectionView.register(acceptXib, forCellWithReuseIdentifier: acceptIdentifier)

    }
}

extension DesignerAppointmentViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch collectionView {

        case designerPendingCollectionView:
            return designerPendingPosts.count
        default:
            return designerConfirmPosts.count
        }

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch collectionView {
        case designerPendingCollectionView:

            let cell = designerPendingCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: DesignerPendingCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? DesignerPendingCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = designerPendingPosts[indexPath.row]

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
//
//            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
//    //        postCell.reservationTimeLabel.text = "\(post.reservation.date), \(post.reservation.time.afternoon)"
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

            let cell = designerConfirmCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: DesignerAcceptCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? DesignerAcceptCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = designerConfirmPosts[indexPath.row]

//            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
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
        }

    }
//
//    @objc func cancelButtonTapped(sender: UIButton) {
//        //        print(sender.tag)
//        //        print(sender.isSelected)
//
//        guard let userID = UserManager.shared.getUserUID() else { return }
//
//        let designerWaitingPost = designerWaitingPosts[sender.tag]
//
//        sender.isSelected = !sender.isSelected
//        if sender.isSelected {
//
//            sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
//            ref.child("likePosts/\(userID)/\(designerWaitingPost.postID)").setValue(true)
//
//        } else {
//
//            sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
//            ref.child("likePosts/\(userID)/\(designerWaitingPost.postID)").removeValue()
//
//        }
//
//    }

}

extension DesignerAppointmentViewController: UICollectionViewDelegateFlowLayout {

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
