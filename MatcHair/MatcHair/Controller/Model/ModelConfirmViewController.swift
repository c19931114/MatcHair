//
//  ModelConfirmViewController.swift
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

class ModelConfirmViewController: UIViewController {

    let decoder = JSONDecoder()
    let keychain = KeychainSwift()
    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()
    let fullScreenSize = UIScreen.main.bounds.size
    var refreshControl: UIRefreshControl!
    let animationView = LOTAnimationView(name: "no_appointment")
    let emptyMessageLabel = UILabel()

    var modelConfirmAppointments = [Appointment]() // [(AppointmentInfo, User, URL, PostInfo)]

    @IBOutlet weak var modelConfirmCollectionView: UICollectionView!

}

extension ModelConfirmViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setRefreshControl()

        setupCollectionView()
        
        loadModelConfirmAppointments()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadModelConfirmAppointments),
            name: .reFetchModelConfirmAppointments,
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
        modelConfirmCollectionView.addSubview(refreshControl)
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

        modelConfirmCollectionView.dataSource = self
        modelConfirmCollectionView.delegate = self

        let confirmIdentifier = String(describing: ModelConfirmCollectionViewCell.self)
        let confirmXib = UINib(nibName: confirmIdentifier, bundle: nil)
        modelConfirmCollectionView.register(confirmXib, forCellWithReuseIdentifier: confirmIdentifier)

    }

    @objc func loadModelConfirmAppointments() {

        guard let currentUserUID = keychain.get("userUID") else { return }

        ref.child("appointments")
            .queryOrdered(byChild: "modelUID")
            .queryEqual(toValue: currentUserUID)
            .observeSingleEvent(of: .value) { (snapshot) in

                self.modelConfirmAppointments = []

                guard let value = snapshot.value as? NSDictionary else {

                    self.modelConfirmCollectionView.reloadData()
                    return
                }

                for value in value.allValues {

                    guard let appointmentJSON = try? JSONSerialization.data(withJSONObject: value) else { return }

                    do {
                        let appointmentInfo = try self.decoder.decode(AppointmentInfo.self, from: appointmentJSON)

                        if appointmentInfo.statement == "confirm" {

                            self.getDesignerImageURLWith(appointmentInfo)
                        } else {

                            self.modelConfirmCollectionView.reloadData()
                        }

                    } catch {
                        print(error)
                    }
                }
        }

    }

    func getDesignerImageURLWith(_ appointmentInfo: AppointmentInfo) {

        let fileName = appointmentInfo.designerUID

        self.storageRef.child("user-images").child(fileName).downloadURL(completion: { (url, error) in

            if let designerImageURL = url {

                self.getDesignerInfoWith(appointmentInfo, designerImageURL)

            } else {
                print(error as Any)
            }

        })

    }

    func getDesignerInfoWith(_ appointmentInfo: AppointmentInfo, _ designerImageURL: URL) {

        self.ref.child("users/\(appointmentInfo.designerUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {

                self.modelConfirmCollectionView.reloadData()
                return
            }

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

            guard let value = snapshot.value as? NSDictionary else {
                
                self.modelConfirmCollectionView.reloadData()
                return
            }

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

                self.modelConfirmAppointments.insert(appointment, at: 0)

            } catch {
                print(error)
            }

            print("------------------")
            print(self.modelConfirmAppointments.count)
            print("------------------")

            self.modelConfirmAppointments.sort(by: { $0.info.createTime > $1.info.createTime })
            self.modelConfirmCollectionView.reloadData()

        }
    }

    @objc func reloadData() {

        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {

            self.loadModelConfirmAppointments()
            self.refreshControl.endRefreshing()

        }

    }

}

extension ModelConfirmViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if modelConfirmAppointments.count == 0 {
            noAppointmentAnimate()
        } else {
            animationView.removeFromSuperview()
            emptyMessageLabel.removeFromSuperview()
        }
        return modelConfirmAppointments.count

    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var categories = [String]()

        let cell = modelConfirmCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ModelConfirmCollectionViewCell.self),
            for: indexPath)

        guard let appointmentCell = cell as? ModelConfirmCollectionViewCell else {
            return UICollectionViewCell()
        }

        let appointment = modelConfirmAppointments[indexPath.row]
        // (appointment, designerData, postData)

        appointmentCell.postImage.kf.setImage(with: URL(string: appointment.postInfo.pictureURL))
        appointmentCell.designerImage.kf.setImage(with: appointment.designerImageURL)
        appointmentCell.designerNameButton.setTitle(appointment.designer?.name, for: .normal)
        appointmentCell.reservationTimeLabel.text =
            "\(appointment.postInfo.reservation!.date), \(appointment.info.timing)"
        appointmentCell.addressLabel.text =
            "\(appointment.postInfo.reservation!.location.city), " +
            " \(appointment.postInfo.reservation!.location.district), " +
            "\(appointment.postInfo.reservation!.location.address)"
        appointmentCell.phoneLabel.text = appointment.postInfo.phone

        if appointment.postInfo.category!.shampoo { categories.append("洗髮") }
        if appointment.postInfo.category!.haircut { categories.append("剪髮") }
        if appointment.postInfo.category!.dye { categories.append("染髮") }
        if appointment.postInfo.category!.permanent { categories.append("燙髮") }
        if appointment.postInfo.category!.treatment { categories.append("護髮") }
        if appointment.postInfo.category!.other { categories.append("其他") }

        appointmentCell.categoryLabel.text = categories.joined(separator: ", ")

        if appointment.postInfo.payment == "" {
            appointmentCell.priceLabel.text = "$ 0"
        } else {
            appointmentCell.priceLabel.text = "$ \(appointment.postInfo.payment!)"
        }

        // target action
        appointmentCell.completeButton.tag = indexPath.row
        appointmentCell.completeButton.addTarget(
            self,
            action: #selector(completeButtonTapped(sender:)), for: .touchUpInside)

        appointmentCell.designerImageButton.tag = indexPath.row
        appointmentCell.designerImageButton.addTarget(
            self,
            action: #selector(designerTapped(sender:)),
            for: .touchUpInside)

        appointmentCell.designerNameButton.tag = indexPath.row
        appointmentCell.designerNameButton.addTarget(
            self,
            action: #selector(designerTapped(sender:)),
            for: .touchUpInside)

        return appointmentCell

    }

    @objc func completeButtonTapped(sender: UIButton) {

        let confirmPost = modelConfirmAppointments[sender.tag]

        modelConfirmAppointments.remove(at: sender.tag)

        modelConfirmCollectionView.reloadData()

        let completeTime = Date().millisecondsSince1970

        ref.child("appointments/\(confirmPost.info.appointmentID)").updateChildValues(
            [
                "statement": "complete",
                "createTime": completeTime
            ]
        )

    }

    @objc func designerTapped(sender: UIButton) {

        let selectedDesignerUID = modelConfirmAppointments[sender.tag].info.designerUID
        let profileForDesigner = ProfileViewController.profileForDesigner(selectedDesignerUID)
        self.navigationController?.pushViewController(profileForDesigner, animated: true)

    }

}

extension ModelConfirmViewController: UICollectionViewDelegateFlowLayout {

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
