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
import Lottie
import KeychainSwift

class DesignerConfirmViewController: UIViewController {

    let decoder = JSONDecoder()
    let keychain = KeychainSwift()
    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    let fullScreenSize = UIScreen.main.bounds.size
    var refreshControl: UIRefreshControl!
    let animationView = LOTAnimationView(name: "no_appointment")
    let emptyMessageLabel = UILabel()

    var designerConfirmAppointments = [Appointment]() // [(AppointmentInfo, User, URL, PostInfo)]

    @IBOutlet weak var designerConfirmCollectionView: UICollectionView!

}

extension DesignerConfirmViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setRefreshControl()

        setupCollectionView()
        
        loadDesignerConfirmAppointments()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadDesignerConfirmAppointments),
            name: .reFetchDesignerConfirmAppointments,
            object: nil)

    }

    private func setRefreshControl() {

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(
            red: 234/255.0, green: 222/255.0, blue: 212/255.0, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(
            string: "重新整理中",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(
                red: 209/255.0, green: 143/255.0, blue: 131/255.0, alpha: 1)])

        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        designerConfirmCollectionView.addSubview(refreshControl)
    }

    func noAppointmentAnimate() {

        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = CGPoint(x: fullScreenSize.width / 2, y: fullScreenSize.height * 0.4)
        animationView.contentMode = .scaleAspectFill
        view.addSubview(animationView)
        animationView.play()

        emptyMessageLabel.text = "還沒有已確認訂單唷"
        emptyMessageLabel.textColor = UIColor(red: 169/255.0, green: 185/255.0, blue: 192/255.0, alpha: 1)
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.font = emptyMessageLabel.font.withSize(15)
        emptyMessageLabel.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width, height: 20)
        emptyMessageLabel.center = CGPoint(x: fullScreenSize.width / 2, y: fullScreenSize.height * 0.5)
        view.addSubview(emptyMessageLabel)

    }
    
    private func setupCollectionView() {

        designerConfirmCollectionView.dataSource = self
        designerConfirmCollectionView.delegate = self

        let confirmIdentifier = String(describing: DesignerConfirmCollectionViewCell.self)
        let confirmXib = UINib(nibName: confirmIdentifier, bundle: nil)
        designerConfirmCollectionView.register(confirmXib, forCellWithReuseIdentifier: confirmIdentifier)

    }

    @objc func loadDesignerConfirmAppointments() {

        guard let currentUserUID = keychain.get("userUID") else { return }

        ref.child("appointments")
            .queryOrdered(byChild: "designerUID")
            .queryEqual(toValue: currentUserUID)
            .observeSingleEvent(of: .value) { (snapshot) in

                self.designerConfirmAppointments = []

                guard let value = snapshot.value as? NSDictionary else {
                    
                    self.designerConfirmCollectionView.reloadData()
                    return

                }

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

    @objc func reloadData() {

        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {

            self.loadDesignerConfirmAppointments()
            self.refreshControl.endRefreshing()

        }

    }
}

extension DesignerConfirmViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if designerConfirmAppointments.count == 0 {
            noAppointmentAnimate()
        } else {
            animationView.removeFromSuperview()
            emptyMessageLabel.removeFromSuperview()
        }

        return designerConfirmAppointments.count

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var categories = [String]()

        let cell = designerConfirmCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: DesignerConfirmCollectionViewCell.self),
            for: indexPath)

        guard let appointmentCell = cell as? DesignerConfirmCollectionViewCell else {
            return UICollectionViewCell()
        }

        let appointment = designerConfirmAppointments[indexPath.row]

        appointmentCell.postImage.kf.setImage(with: URL(string: appointment.postInfo.pictureURL))
        appointmentCell.modelImage.kf.setImage(with: appointment.modelImageURL)
        appointmentCell.modelNameButton.setTitle(appointment.model?.name, for: .normal)
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
        appointmentCell.cancelButton.tag = indexPath.row
        appointmentCell.cancelButton.addTarget(
            self,
            action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)

        appointmentCell.modelImageButton.tag = indexPath.row
        appointmentCell.modelImageButton.addTarget(
            self,
            action: #selector(modelTapped(sender:)),
            for: .touchUpInside)

        appointmentCell.modelNameButton.tag = indexPath.row
        appointmentCell.modelNameButton.addTarget(
            self,
            action: #selector(modelTapped(sender:)),
            for: .touchUpInside)

        return appointmentCell

    }

    @objc func modelTapped(sender: UIButton) {

        let selectedModelUID = designerConfirmAppointments[sender.tag].info.modelUID
        let profileForModel = ProfileViewController.profileForDesigner(selectedModelUID)
        self.navigationController?.pushViewController(profileForModel, animated: true)

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
