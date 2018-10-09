//
//  DesignerConfirmViewController.swift
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

class DesignerConfirmViewController: UIViewController {

    let decoder = JSONDecoder()
    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    let fullScreenSize = UIScreen.main.bounds.size
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    var designerConfirmAppointments = [Appointment]() // [(AppointmentInfo, User, URL, PostInfo)]

    @IBOutlet weak var designerConfirmCollectionView: UICollectionView!

}

extension DesignerConfirmViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()
        loadDesignerConfirmAppointments()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadDesignerConfirmAppointments),
            name: Notification.Name.reFetchDesignerAppointments,
            object: nil)

    }
    private func setupCollectionView() {

        designerConfirmCollectionView.dataSource = self
        designerConfirmCollectionView.delegate = self

        let confirmIdentifier = String(describing: DesignerConfirmCollectionViewCell.self)
        let confirmXib = UINib(nibName: confirmIdentifier, bundle: nil)
        designerConfirmCollectionView.register(confirmXib, forCellWithReuseIdentifier: confirmIdentifier)

    }

    @objc func loadDesignerConfirmAppointments() {

        designerConfirmAppointments = []

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("appointments")
            .queryOrdered(byChild: "designerUID")
            .queryEqual(toValue: currentUserUID)
            .observeSingleEvent(of: .value) { (snapshot) in

                guard let value = snapshot.value as? NSDictionary else { return }

                for value in value.allValues {

                    guard let appointmentJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

                    do {
                        let appointmentInfo = try self.decoder.decode(AppointmentInfo.self, from: appointmentJSON)

                        if appointmentInfo.statement == "confirm" {

                            self.getModelImageURLWith(appointmentInfo)
                        } else {

                            self.designerConfirmCollectionView.reloadData()
                        }

                    } catch {
                        print(error)
                    }
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

                self.designerConfirmAppointments.insert(appointment, at: 0)

            } catch {
                print(error)
            }

            self.designerConfirmAppointments.sort(by: { $0.info.createTime > $1.info.createTime })
            self.designerConfirmCollectionView.reloadData()

        }
    }
}

extension DesignerConfirmViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return designerConfirmAppointments.count

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = designerConfirmCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: DesignerConfirmCollectionViewCell.self),
            for: indexPath)

        guard let appointmentCell = cell as? DesignerConfirmCollectionViewCell else {
            return UICollectionViewCell()
        }

        let appointment = designerConfirmAppointments[indexPath.row]

        appointmentCell.postImage.kf.setImage(with: URL(string: appointment.postInfo.pictureURL))
        appointmentCell.modelImage.kf.setImage(with: appointment.modelImageURL)
        appointmentCell.modelNameLabel.text = appointment.model?.name
        appointmentCell.reservationTimeLabel.text =
            "\(appointment.postInfo.reservation.date), \(appointment.info.timing)"

        // target action
        appointmentCell.cancelButton.tag = indexPath.row
        appointmentCell.cancelButton.addTarget(
            self,
            action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)

        return appointmentCell

    }

    @objc func cancelButtonTapped(sender: UIButton) {

        let confirmPost = designerConfirmAppointments[sender.tag]

        ref.child("appointments/\(confirmPost.info.appointmentID)").removeValue()

        designerConfirmAppointments.remove(at: sender.tag)

        designerConfirmCollectionView.reloadData()

    }

}

extension DesignerConfirmViewController: UICollectionViewDelegateFlowLayout {

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
