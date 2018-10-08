//
//  DesignerPendingViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/8.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class DesignerPendingViewController: UIViewController {

    let decoder = JSONDecoder()
    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    let fullScreenSize = UIScreen.main.bounds.size
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    var designerPendingAppointments = [Appointment]() // [(AppointmentInfo, User, URL, PostInfo)]

    @IBOutlet weak var designerPendingCollectionView: UICollectionView!

}

extension DesignerPendingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()
        loadDesignerPendingAppointments()

    }
    private func setupCollectionView() {

        designerPendingCollectionView.dataSource = self
        designerPendingCollectionView.delegate = self

        let waitingIdentifier = String(describing: DesignerPendingCollectionViewCell.self)
        let waitingXib = UINib(nibName: waitingIdentifier, bundle: nil)
        designerPendingCollectionView.register(waitingXib, forCellWithReuseIdentifier: waitingIdentifier)

    }

    func loadDesignerPendingAppointments() {

        designerPendingAppointments = []

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("appointments/pending")
            .queryOrdered(byChild: "designerUID")
            .queryEqual(toValue: currentUserUID)
            .observe(.childAdded) { (snapshot) in

                guard let value = snapshot.value else { return }

                guard let appointmentJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

                do {
                    let appointment = try self.decoder.decode(AppointmentInfo.self, from: appointmentJSON)
                    self.getModelImageURLWith(appointment)

                } catch {
                    print(error)
                }

        }
    }

    func getModelImageURLWith(_ appointment: AppointmentInfo) {

        let fileName = appointment.modelUID

        self.storageRef.child(fileName).downloadURL(completion: { (url, error) in

            if let modelImageURL = url {

                self.getModelInfoWith(appointment, modelImageURL)

            } else {
                print(error as Any)
            }

        })
    }

    func getModelInfoWith(_ appointmentInfo: AppointmentInfo, _ modelImageURL: URL) {

        self.ref.child("users/\(appointmentInfo.modelUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let modelJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let model = try self.decoder.decode(User.self, from: modelJSON)
                self.getPostInfoWith(appointmentInfo, model, modelImageURL)

            } catch {
                print(error)
            }

        }
    }

    func getPostInfoWith(_ appointmentInfo: AppointmentInfo, _ model: User, _ modelImageURL: URL) {

        self.ref.child("allPosts/\(appointmentInfo.postID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let postJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postInfo = try self.decoder.decode(PostInfo.self, from: postJSON)

                let appointment =
                    Appointment(
                        info: appointmentInfo,
                        designer: nil,
                        designerImageURL: nil,
                        model: model,
                        modelImageURL: modelImageURL,
                        postInfo: postInfo)

                self.designerPendingAppointments.insert(appointment, at: 0)

            } catch {
                print(error)
            }

            self.designerPendingAppointments.sort(by: { $0.info.createTime > $1.info.createTime })
            self.designerPendingCollectionView.reloadData()

        }
    }
}

extension DesignerPendingViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return designerPendingAppointments.count

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = designerPendingCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: DesignerPendingCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? DesignerPendingCollectionViewCell else {
                return UICollectionViewCell()
            }

            let appointment = designerPendingAppointments[indexPath.row]

            postCell.postImage.kf.setImage(with: URL(string: appointment.postInfo.pictureURL))
            postCell.modelImage.kf.setImage(with: appointment.modelImageURL)
            postCell.modelNameLabel.text = appointment.model?.name
            postCell.reservationTimeLabel.text =
            "\(appointment.postInfo.reservation.date), \(appointment.info.timing)"

            // target action
            postCell.cancelButton.tag = indexPath.row
            postCell.cancelButton.addTarget(
                self,
                action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)

            return postCell

    }

    @objc func cancelButtonTapped(sender: UIButton) {

        let pendingPost = designerPendingAppointments[sender.tag]

        ref.child("appointments/pending/\(pendingPost.info.appointmentID)").removeValue()

        designerPendingAppointments.remove(at: sender.tag)

        designerPendingCollectionView.reloadData()

    }

}

extension DesignerPendingViewController: UICollectionViewDelegateFlowLayout {

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
