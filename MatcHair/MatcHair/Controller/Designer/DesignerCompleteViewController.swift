//
//  DesignerCompleteViewController.swift
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
import Lottie

class DesignerCompleteViewController: UIViewController {

    let decoder = JSONDecoder()
    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()
    let fullScreenSize = UIScreen.main.bounds.size
    var refreshControl: UIRefreshControl!
    let animationView = LOTAnimationView(name: "no_appointment")

    var designerCompleteAppointments = [Appointment]() // [(AppointmentInfo, User, URL, PostInfo)]

    @IBOutlet weak var designerCompleteCollectionView: UICollectionView!

}

extension DesignerCompleteViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setRefreshControl()

        setupCollectionView()
        
        loadModelCompleteAppointments()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadModelCompleteAppointments),
            name: .reFetchDesignerCompleteAppointments,
            object: nil)

    }

    private func setRefreshControl() {

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(
            red: 255/255.0, green: 249/255.0, blue: 91/255.0, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(
            string: "重新整理中...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(
                red: 4/255.0, green: 71/255.0, blue: 28/255.0, alpha: 1)])

        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        designerCompleteCollectionView.addSubview(refreshControl)
    }

    func noAppointmentAnimate() {

        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        view.addSubview(animationView)
        animationView.play()

    }
    
    private func setupCollectionView() {

        designerCompleteCollectionView.dataSource = self
        designerCompleteCollectionView.delegate = self

        let completeIdentifier = String(describing: DesignerCompleteCollectionViewCell.self)
        let completeXib = UINib(nibName: completeIdentifier, bundle: nil)
        designerCompleteCollectionView.register(completeXib, forCellWithReuseIdentifier: completeIdentifier)

    }

    @objc func loadModelCompleteAppointments() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("appointments")
            .queryOrdered(byChild: "designerUID")
            .queryEqual(toValue: currentUserUID)
            .observeSingleEvent(of: .value) { (snapshot) in

                self.designerCompleteAppointments = []

                guard let value = snapshot.value as? NSDictionary else { return }

                for value in value.allValues {

                    guard let appointmentJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

                    do {
                        let appointmentInfo = try self.decoder.decode(AppointmentInfo.self, from: appointmentJSON)

                        if appointmentInfo.statement == "complete" {

                            self.getDesignerImageURLWith(appointmentInfo)
                        } else {

                            self.designerCompleteCollectionView.reloadData()
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

                self.designerCompleteAppointments.insert(appointment, at: 0)

            } catch {
                print(error)
            }

            self.designerCompleteAppointments.sort(by: { $0.info.createTime > $1.info.createTime })
            self.designerCompleteCollectionView.reloadData()

        }
    }

    @objc func reloadData() {

        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {

            self.loadModelCompleteAppointments()
            self.refreshControl.endRefreshing()

        }

    }

}

extension DesignerCompleteViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if designerCompleteAppointments.count == 0 {
            noAppointmentAnimate()
        } else {
            animationView.removeFromSuperview()
        }
        
        return designerCompleteAppointments.count

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var categories = [String]()

        let cell = designerCompleteCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: DesignerCompleteCollectionViewCell.self),
            for: indexPath)

        guard let appointmentCell = cell as? DesignerCompleteCollectionViewCell else {
            return UICollectionViewCell()
        }

        let appointment = designerCompleteAppointments[indexPath.row]
        // (appointment, designerData, postData)

        appointmentCell.postImage.kf.setImage(with: URL(string: appointment.postInfo.pictureURL))
        appointmentCell.designerImage.kf.setImage(with: appointment.designerImageURL)
        appointmentCell.designerNameLabel.text = appointment.designer?.name
        appointmentCell.reservationTimeLabel.text =
        "\(appointment.postInfo.reservation!.date), \(appointment.info.timing)"

        if appointment.postInfo.category!.shampoo { categories.append("洗髮") }
        if appointment.postInfo.category!.haircut { categories.append("剪髮") }
        if appointment.postInfo.category!.dye { categories.append("染髮") }
        if appointment.postInfo.category!.permanent { categories.append("燙髮") }
        if appointment.postInfo.category!.treatment { categories.append("護髮") }
        if appointment.postInfo.category!.other { categories.append("其他") }

        appointmentCell.categoryLabel.text = categories.joined(separator: ", ")

        // target action
        //        postCell.scoreButton.tag = indexPath.row
        //        postCell.scoreButton.addTarget(
        //            self,
        //            action: #selector(scoreButtonTapped(sender:)), for: .touchUpInside)

        return appointmentCell

    }

    @objc func scoreButtonTapped(sender: UIButton) {

        let completePost = designerCompleteAppointments[sender.tag]

        //        modelCompleteCollectionView.reloadData()
        //
        //        let completeTime = Date().millisecondsSince1970
        //
        //        ref.child("appointments/\(completePost.info.appointmentID)").updateChildValues(
        //            [
        //                "statement": "complete",
        //                "createTime": completeTime
        //            ]
        //        )

    }

}

extension DesignerCompleteViewController: UICollectionViewDelegateFlowLayout {

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
