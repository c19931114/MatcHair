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

    var designerPendingPosts = [(AppointmentInfo, User, PostInfo)]()
    var designerConfirmPosts = [AppointmentInfo]()

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

        ref = Database.database().reference()
        designerConfirmCollectionView.isHidden = true

        setupCollectionView()
        loadDesignerPendingAppointments()

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

    func loadDesignerPendingAppointments() {

        designerPendingPosts = []

        guard let currentUserUID = UserManager.shared.getUserUID() else { return }

        ref.child("appointmentPosts/pending")
            .queryOrdered(byChild: "designerUID")
            .queryEqual(toValue: currentUserUID)
            .observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }
            print(value.allKeys)
            guard let appointmentJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let appointmentData = try self.decoder.decode(AppointmentInfo.self, from: appointmentJSONData)
                print(appointmentData)

                self.getModelInfo(with: appointmentData)

            } catch {
                print(error)
            }

        }
    }

    func getModelInfo(with appointment: AppointmentInfo) {

        self.ref.child("users/\(appointment.modelUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let modelJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let modelData = try self.decoder.decode(User.self, from: modelJSONData)
                self.getPostInfo(with: appointment, modelData)
            } catch {
                print(error)
            }

        }
    }

    func getPostInfo(with appointment: AppointmentInfo, _ modelData: User) {

        self.ref.child("allPosts/\(appointment.postID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postData = try self.decoder.decode(PostInfo.self, from: postJSONData)
                self.designerPendingPosts.insert((appointment, modelData, postData), at: 0)

            } catch {
                print(error)
            }

            self.designerPendingCollectionView.reloadData()

        }
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

            postCell.postImage.kf.setImage(with: URL(string: post.2.pictureURL))
//            postCell.userImage.kf.setImage(with: URL(string: post.1.image))
            postCell.userNameLabel.text = post.1.name
            postCell.reservationTimeLabel.text = "\(post.2.reservation.date), \(post.0.timing)"

            // target action
            postCell.cancelButton.tag = indexPath.row
            postCell.cancelButton.addTarget(
                self,
                action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)

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

    @objc func cancelButtonTapped(sender: UIButton) {

        guard let userID = UserManager.shared.getUserUID() else { return }

        let pendingPost = designerPendingPosts[sender.tag]


    }

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
