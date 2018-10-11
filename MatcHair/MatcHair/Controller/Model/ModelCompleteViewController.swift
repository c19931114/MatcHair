//
//  ModelCompleteViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/9.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class ModelCompleteViewController: UIViewController {

    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()
    let fullScreenSize = UIScreen.main.bounds.size

    var modelCompleteAppointments = [Appointment]() // [(AppointmentInfo, User, URL, PostInfo)]

    @IBOutlet weak var modelCompleteCollectionView: UICollectionView!

}

extension ModelCompleteViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()
        loadModelCompleteAppointments()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadModelCompleteAppointments),
            name: .reFetchModelAppointments,
            object: nil)
    }

    private func setupCollectionView() {

        modelCompleteCollectionView.dataSource = self
        modelCompleteCollectionView.delegate = self

        let completeIdentifier = String(describing: ModelCompleteCollectionViewCell.self)
        let completeXib = UINib(nibName: completeIdentifier, bundle: nil)
        modelCompleteCollectionView.register(completeXib, forCellWithReuseIdentifier: completeIdentifier)

    }

    @objc func loadModelCompleteAppointments() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("appointments")
            .queryOrdered(byChild: "modelUID")
            .queryEqual(toValue: currentUserUID)
            .observeSingleEvent(of: .value) { (snapshot) in

                self.modelCompleteAppointments = []

                guard let value = snapshot.value as? NSDictionary else { return }

                for value in value.allValues {

                    guard let appointmentJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

                    do {
                        let appointmentInfo = try self.decoder.decode(AppointmentInfo.self, from: appointmentJSON)

                        if appointmentInfo.statement == "complete" {

                            self.getDesignerImageURLWith(appointmentInfo)
                        } else {

                            self.modelCompleteCollectionView.reloadData()
                        }

                    } catch {
                        print(error)
                    }
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

                self.modelCompleteAppointments.insert(appointment, at: 0)

            } catch {
                print(error)
            }

            print("------------------")
            print(self.modelCompleteAppointments.count)
            print("------------------")

            self.modelCompleteAppointments.sort(by: { $0.info.createTime > $1.info.createTime })
            self.modelCompleteCollectionView.reloadData()

        }
    }

}

extension ModelCompleteViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return modelCompleteAppointments.count

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var categories = [String]()

        let cell = modelCompleteCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ModelCompleteCollectionViewCell.self),
            for: indexPath)

        guard let appointmentCell = cell as? ModelCompleteCollectionViewCell else {
            return UICollectionViewCell()
        }

        let appointment = modelCompleteAppointments[indexPath.row]
        // (appointment, designerData, postData)

        appointmentCell.postImage.kf.setImage(with: URL(string: appointment.postInfo.pictureURL))
        appointmentCell.designerImage.kf.setImage(with: appointment.designerImageURL)
        appointmentCell.designerNameLabel.text = appointment.designer?.name
        appointmentCell.reservationTimeLabel.text =
        "\(appointment.postInfo.reservation.date), \(appointment.info.timing)"

        if appointment.postInfo.category.shampoo { categories.append("洗髮") }
        if appointment.postInfo.category.haircut { categories.append("剪髮") }
        if appointment.postInfo.category.dye { categories.append("染髮") }
        if appointment.postInfo.category.permanent { categories.append("燙髮") }
        if appointment.postInfo.category.treatment { categories.append("護髮") }
        if appointment.postInfo.category.other { categories.append("其他") }

        appointmentCell.categoryLabel.text = categories.joined(separator: ", ")

        // target action
        appointmentCell.scoreButton.tag = indexPath.row
        appointmentCell.scoreButton.addTarget(
            self,
            action: #selector(scoreButtonTapped(sender:)), for: .touchUpInside)

        return appointmentCell

    }

    @objc func scoreButtonTapped(sender: UIButton) {

        let completePost = modelCompleteAppointments[sender.tag]



    }

}

extension ModelCompleteViewController: UICollectionViewDelegateFlowLayout {

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

