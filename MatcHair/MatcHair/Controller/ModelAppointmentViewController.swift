//
//  ModelAppointmentViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/30.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class ModelAppointmentViewController: UIViewController {

    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()
    let fullScreenSize = UIScreen.main.bounds.size
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    var modelPendingAppointment = [Appointment]() // [(AppointmentInfo, User, URL, PostInfo)]
    var modelConfirmPosts = [AppointmentInfo]()

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
        loadModelPendingAppointments()

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

    func loadModelPendingAppointments() {

        modelPendingAppointment = []

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("appointmentPosts/pending")
            .queryOrdered(byChild: "modelUID")
            .queryEqual(toValue: currentUserUID)
            .observe(.childAdded) { (snapshot) in

                guard let value = snapshot.value else { return }

                guard let appointmentJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

                do {
                    let appointmentInfo = try self.decoder.decode(AppointmentInfo.self, from: appointmentJSON)
                    self.getDesignerImageURLWith(appointmentInfo)

                } catch {
                    print(error)
                }

        }

    }

    func getDesignerImageURLWith(_ appointmentInfo: AppointmentInfo) {

        let fileName = appointmentInfo.designerUID

        self.storageRef.child(fileName).downloadURL(completion: { (url, error) in

            if let designerImageURL = url {

                self.getDesignerInfoWiyh(appointmentInfo, designerImageURL)

            } else {
                print(error as Any)
            }

        })
        
    }

    func getDesignerInfoWiyh(_ appointmentInfo: AppointmentInfo, _ designerImageURL: URL) {

        self.ref.child("users/\(appointmentInfo.designerUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let designerJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let designer = try self.decoder.decode(User.self, from: designerJSON)
                self.getPostInfoWith(appointmentInfo, designer, designerImageURL)

            } catch {
                print(error)
            }

        }
    }

    func getPostInfoWith(_ appointmentInfo: AppointmentInfo, _ designer: User, _ designerImageURL: URL) {

        self.ref.child("allPosts/\(appointmentInfo.postID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let postJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {

                let postInfo = try self.decoder.decode(PostInfo.self, from: postJSON)
                
                let appointment =
                    Appointment(
                        info: appointmentInfo,
                        designer: designer,
                        designerImageURL: designerImageURL,
                        model: nil, modelImageURL: nil,
                        postInfo: postInfo)

                self.modelPendingAppointment.insert(appointment, at: 0)

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
            return modelPendingAppointment.count
        default:
            return modelConfirmPosts.count
        }

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var categories = [String]()

        switch collectionView {
        case modelPendingCollectionView:

            let cell = modelPendingCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ModelPendingCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? ModelPendingCollectionViewCell else {
                return UICollectionViewCell()
            }

            let appointment = modelPendingAppointment[indexPath.row]
            // (appointment, designerData, postData)

            postCell.postImage.kf.setImage(with: URL(string: appointment.postInfo.pictureURL))
            postCell.designerImage.kf.setImage(with: appointment.designerImageURL)
            postCell.designerNameLabel.text = appointment.designer?.name
            postCell.reservationTimeLabel.text =
                "\(appointment.postInfo.reservation.date), \(appointment.info.timing)"

            if appointment.postInfo.category.shampoo { categories.append("洗髮") }
            if appointment.postInfo.category.haircut { categories.append("剪髮") }
            if appointment.postInfo.category.dye { categories.append("染髮") }
            if appointment.postInfo.category.permanent { categories.append("燙髮") }
            if appointment.postInfo.category.treatment { categories.append("護髮") }
            if appointment.postInfo.category.other { categories.append("其他") }

            postCell.categoryLabel.text = categories.joined(separator: ", ")

            // target action
            postCell.cancelButton.tag = indexPath.row
            postCell.cancelButton.addTarget(
                self,
                action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)

            return postCell

        default:

            let cell = modelConfirmCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ModelAcceptCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? ModelAcceptCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = modelConfirmPosts[indexPath.row]

//            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))
//            postCell.reservationTimeLabel.text = "\(post.reservation.date), afternoon"

            postCell.userImage.kf.setImage(
                with: URL(string: ""))

            // target action
            //            postCell.cancelButton.tag = indexPath.row
            //            postCell.cancelButton.addTarget(
            //                self,
            //                action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)

            return postCell
        }

    }

    @objc func cancelButtonTapped(sender: UIButton) {

        let pendingPost = modelPendingAppointment[sender.tag]

        ref.child("appointmentPosts/pending/\(pendingPost.info.appointmentID)").removeValue()

        modelPendingAppointment.remove(at: sender.tag)

        modelPendingCollectionView.reloadData()

    }

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
