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

    var pendingPosts = [(Appointment, User, Post)]()
    var confirmPosts = [Appointment]()

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
        loadPendingAppointments()

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

    func loadPendingAppointments() {

        ref.child("appointmentPosts").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }
            print(value.allKeys)
            guard let appointmentJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let appointmentData = try self.decoder.decode(Appointment.self, from: appointmentJSONData)
                print(appointmentData)

                self.getDesignerInfo(with: appointmentData)

            } catch {
                print(error)
            }

        }

    }

    func getDesignerInfo(with appointment: Appointment) {

        self.ref.child("users/\(appointment.designerUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let designerJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let designerData = try self.decoder.decode(User.self, from: designerJSONData)
                self.getPostInfo(with: appointment, designerData)
            } catch {
                print(error)
            }

        }
    }

    func getPostInfo(with appointment: Appointment, _ designerData: User) {

        self.ref.child("allPosts/\(appointment.postID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postData = try self.decoder.decode(Post.self, from: postJSONData)
                self.pendingPosts.insert((appointment, designerData, postData), at: 0)

            } catch {
                print(error)
            }

            self.modelPendingCollectionView.reloadData()

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
            // (appointment, designerData, postData)

            postCell.postImage.kf.setImage(with: URL(string: post.2.pictureURL))
            postCell.userImage.kf.setImage(with: URL(string: "\(post.1.image)"))
            postCell.reservationTimeLabel.text = "\(post.2.reservation.date), \(post.0.timing)"

            var categories = [String]()
            if post.2.category.shampoo { categories.append("洗髮") }
            if post.2.category.haircut { categories.append("剪髮") }
            if post.2.category.dye { categories.append("染髮") }
            if post.2.category.permanent { categories.append("燙髮") }
            if post.2.category.treatment { categories.append("護髮") }
            if post.2.category.other { categories.append("其他") }

            postCell.categoryLabel.text = categories.joined(separator: ", ")

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
