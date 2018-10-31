//
//  PostViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/21.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import DatePickerDialog
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class PostViewController: UIViewController {

    var picture: UIImage?
    let storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    var dateSelected: Bool = false
    var myPost: MyPost?

    var categories = [String: Bool]()
    var categorySelected = false
    var payment: String? = "0"
    var reservationDate: String?
    var reservationTimes = [String: Bool]()
    var reservationTimeSelected = false
    var reservationCity: String?
    var reservationDistrict: String?
    var reservationAddress: String?
    var phone: String?

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var seperateView: UIView!
    @IBOutlet weak var recruitModelSwitch: UISwitch!
    @IBOutlet weak var recruitTableView: UITableView!

    @IBAction func post(_ sender: Any) {

        //判斷有無缺項
        categorySelected = false
//        for value in categories.values {
//            if value {
//                categorySelected = true
//            }
//        }

        for value in categories.values where value {
            categorySelected = true
        }
        print("categorySelected", categorySelected)

        reservationTimeSelected = false
        for value in reservationTimes.values where value {
            reservationTimeSelected = true
        }
        print("reservationTimeSelected", reservationTimeSelected)

        if recruitModelSwitch.isOn {

            guard categorySelected, reservationDate != nil, reservationTimeSelected,
                reservationCity != nil, reservationDistrict != nil, reservationAddress != nil,
                phone != nil else {

                    print("please complete")
                    print(">>>>>>>>>>>>>>>>>>>>>>>")

                    showAlert()
                    return
            }

            share()

        } else {
            
            share()
        }

        self.navigationController?.popToRootViewController(animated: false)

        let tabController = self.view.window!.rootViewController as? UITabBarController
        tabController?.selectedIndex = 4

    }

    @IBAction func recruitModel(_ sender: UISwitch) {
        switch sender.isOn {
        case true:
            recruitTableView.isHidden = false
        default:
            recruitTableView.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()

        descriptionTextField.delegate = self

        ref = Database.database().reference()

        recruitTableView.isHidden = true

        let tapGestureRecognizer =
            UITapGestureRecognizer(
                target: self,
                action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)

        postImage.image = picture

    }

    private func setupTableView() {

        recruitTableView.dataSource = self
        recruitTableView.delegate = self

        let categoryCellIdentifier = String(describing: CategoryTableViewCell.self)
        let categoryXib = UINib(
            nibName: categoryCellIdentifier,
            bundle: nil)
        recruitTableView.register(
            categoryXib,
            forCellReuseIdentifier: categoryCellIdentifier)

        let paymentCellIdentifier = String(describing: PaymentTableViewCell.self)
        let paymentXib = UINib(
            nibName: paymentCellIdentifier,
            bundle: nil)
        recruitTableView.register(
            paymentXib,
            forCellReuseIdentifier: paymentCellIdentifier)

        let reservationTimeCellIdentifier = String(describing: ReservationTimeTableViewCell.self)
        let reservationTimeXib = UINib(
            nibName: reservationTimeCellIdentifier,
            bundle: nil)
        recruitTableView.register(
            reservationTimeXib,
            forCellReuseIdentifier: reservationTimeCellIdentifier)

        let reservationLocationCellIdentifier = String(describing: ReservationLocationTableViewCell.self)
        let reservationLocationXib = UINib(nibName: reservationLocationCellIdentifier, bundle: nil)
        recruitTableView.register(reservationLocationXib, forCellReuseIdentifier: reservationLocationCellIdentifier)

        let phoneCellIdentifier = String(describing: PhoneTableViewCell.self)
        let phoneXib = UINib(nibName: phoneCellIdentifier, bundle: nil)
        recruitTableView.register(phoneXib, forCellReuseIdentifier: phoneCellIdentifier)

    }

//    class func editPost(_ post: PostInfo) -> PostViewController {
//
//        let postStoryboard = UIStoryboard.postStoryboard()
//        guard let postVC = postStoryboard.instantiateViewController(
//            withIdentifier: "post") as? PostViewController else {
//
//                    return PostViewController()
//        }
//
////        postVC.myPost = post
//        return postVC
//
//    }

    func showAlert() {

        let alertController = UIAlertController(
            title: "貼心提醒",
            message: "\n徵求髮膜請填寫完整資訊唷",
            preferredStyle: .alert)

        alertController.addAction(
            UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {

        print("tap")

    }

    private func share() {

        guard let postPicture = picture,
            let uploadData = postPicture.jpegData(compressionQuality: 0.1) else {
                print("no image")
                return
        }

        let fileName = NSUUID().uuidString

        storageRef.child("\(fileName).jpeg").putData(uploadData, metadata: nil) { (metadata, error) in

            guard metadata != nil else {
                // Uh-oh, an error occurred!
                return
            }

            self.storageRef.child("\(fileName).jpeg").downloadURL { (url, error) in

                guard let downloadURL = url else { return }

                guard let authorUID = Auth.auth().currentUser?.uid else { return } // TODO keychain

                guard let postID = self.ref.child("usersPosts").childByAutoId().key else { return }

                let postTime = Date().millisecondsSince1970 // 1476889390939

                if self.recruitModelSwitch.isOn {

                    self.ref.child("allPosts/\(postID)").setValue(
                        [
                            "postID": "\(postID)",
                            "createTime": postTime,
                            "authorUID": "\(authorUID)",
                            "pictureURL": "\(downloadURL)",
                            "content": "\(self.descriptionTextField.text!)",
                            "category": self.categories,
                            "payment": self.payment!,
                            "reservation":
                                [
                                    "date": self.reservationDate!,
                                    "time": self.reservationTimes,
                                    "location":
                                        [
                                            "city": self.reservationCity,
                                            "district": self.reservationDistrict,
                                            "address": self.reservationAddress
                                        ]
                                ],
                            "phone": self.phone!,
                            "isLiked": false
                        ]
                    )

                    self.ref.child("usersPosts/\(authorUID)/\(postID)").setValue(
                        [
                            "pictureURL": "\(downloadURL)",
                            "createTime": postTime,
                            "content": "\(self.descriptionTextField.text!)",
                            "authorUID": "\(authorUID)",
                            "postID": postID
                        ]
                    )

                } else {

                    self.ref.child("usersPosts/\(authorUID)/\(postID)").setValue(
                        [
                            "pictureURL": "\(downloadURL)",
                            "createTime": postTime,
                            "content": "\(self.descriptionTextField.text!)",
                            "authorUID": "\(authorUID)",
                            "postID": postID
                        ]
                    )
                }

                NotificationCenter.default.post(name: .reFetchAllPosts, object: nil, userInfo: nil)
                NotificationCenter.default.post(name: .reFetchMyPosts, object: nil, userInfo: nil)
            }
        }
    }
}

extension PostViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:

            let cell = recruitTableView.dequeueReusableCell(
                withIdentifier: String(describing: CategoryTableViewCell.self),
                for: indexPath)

            guard let categoryCell = cell as? CategoryTableViewCell else {
                return cell
            }

            categoryCell.categoryDelegate = self

            return categoryCell

        case 1:

            let cell = recruitTableView.dequeueReusableCell(
                withIdentifier: String(describing: PaymentTableViewCell.self),
                for: indexPath)

            guard let paymentCell = cell as? PaymentTableViewCell else {
                return cell
            }

            paymentCell.paymentDelegate = self

            return paymentCell

        case 2:

            let cell = recruitTableView.dequeueReusableCell(
                withIdentifier: String(describing: ReservationTimeTableViewCell.self),
                for: indexPath)

            guard let reservationTimeCell = cell as? ReservationTimeTableViewCell else {
                return cell
            }

            reservationTimeCell.reservationTimeDelegate = self

            return reservationTimeCell

        case 3:

            let cell = recruitTableView.dequeueReusableCell(
                withIdentifier: String(describing: ReservationLocationTableViewCell.self),
                for: indexPath)

            guard let reservationLocationCell = cell as? ReservationLocationTableViewCell else {
                return cell
            }

            reservationLocationCell.reservationLocationDelegate = self

            return reservationLocationCell

        default:

            let cell = recruitTableView.dequeueReusableCell(
                withIdentifier: String(describing: PhoneTableViewCell.self),
                for: indexPath)

            guard let phoneCell = cell as? PhoneTableViewCell else { return cell }

            phoneCell.phoneDelegate = self

            return phoneCell
        }
    }
}

extension PostViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PostViewController: CategoryProtocol, PaymentProtocol, ReservationTimeProtocol, ReservationLocationProtocol, PhoneProtocol {

    func sendCategory(data: [String: Bool]) {
        categories = data
    }

    func sendPayment(data: String) {
        payment = data
    }

    func sendReservationDate(data: String) {
        reservationDate = data
    }

    func sendReservationTime(data: [String: Bool]) {
        reservationTimes = data
    }

    func sendReservationLocationCity(data: String) {
        reservationCity = data
    }

    func sendReservationLocationDistrict(data: String) {
        reservationDistrict = data
    }

    func sendReservationLocationAddress(data: String) {
        reservationAddress = data
    }

    func sendPhone(data: String) {
        phone = data
    }
}

extension PostViewController: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        if textView.text == "作品介紹..." {
            descriptionTextField.text = ""
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            descriptionTextField.text = "作品介紹..."
        }
    }
}
