//
//  ModelPendingViewController.swift
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

class ModelPendingViewController: UIViewController {

    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()
    let fullScreenSize = UIScreen.main.bounds.size

    var modelPendingAppointments = [Appointment]() // [(AppointmentInfo, User, URL, PostInfo)]

    @IBOutlet weak var modelPendingCollectionView: UICollectionView!

}

extension ModelPendingViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()
        loadModelPendingAppointments()
        observeDeleteAction()

    }

    private func setupCollectionView() {

        modelPendingCollectionView.dataSource = self
        modelPendingCollectionView.delegate = self

        let pendingIdentifier = String(describing: ModelPendingCollectionViewCell.self)
        let pendingXib = UINib(nibName: pendingIdentifier, bundle: nil)
        modelPendingCollectionView.register(pendingXib, forCellWithReuseIdentifier: pendingIdentifier)

    }
    // observe .childRemove
    func observeDeleteAction() {

        ref.child("appointments/pending").observe(.childRemoved) { (snapshot) in
            // print(snapshot)
            self.loadModelPendingAppointments()
            self.modelPendingCollectionView.reloadData()

        }
    }

    func loadModelPendingAppointments() {

        modelPendingAppointments = []

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("appointments/pending")
            .queryOrdered(byChild: "modelUID")
            .queryEqual(toValue: currentUserUID)
            .observe(.childAdded) { (snapshot) in

                print("---------")

                print(snapshot)

                print("---------")

                print(self.modelPendingAppointments.count)

                guard let value = snapshot.value else { return }

                guard let appointmentJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

                do {
                    let appointmentInfo = try self.decoder.decode(AppointmentInfo.self, from: appointmentJSON)

                    print(appointmentInfo.postID)

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

                self.modelPendingAppointments.insert(appointment, at: 0)

                print("YA")
                print(self.modelPendingAppointments.count)


            } catch {
                print(error)
            }

            self.modelPendingAppointments.sort(by: { $0.info.createTime > $1.info.createTime })
            self.modelPendingCollectionView.reloadData()

        }
    }

}

extension ModelPendingViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return modelPendingAppointments.count
        

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var categories = [String]()

        let cell = modelPendingCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ModelPendingCollectionViewCell.self),
            for: indexPath)

        guard let postCell = cell as? ModelPendingCollectionViewCell else {
            return UICollectionViewCell()
        }

        let appointment = modelPendingAppointments[indexPath.row]
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

    }

    @objc func cancelButtonTapped(sender: UIButton) {

        let pendingPost = modelPendingAppointments[sender.tag]

        ref.child("appointments/pending/\(pendingPost.info.appointmentID)").removeValue()


        modelPendingAppointments.remove(at: sender.tag)

        print("---------")

        print("tag: \(sender.tag)")

        print(modelPendingAppointments.count)

        print("---------")


        modelPendingCollectionView.reloadData()

    }

}

extension ModelPendingViewController: UICollectionViewDelegateFlowLayout {

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
