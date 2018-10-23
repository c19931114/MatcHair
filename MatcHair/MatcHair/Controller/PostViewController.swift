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

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var recruitLabel: UIView!

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!

    @IBOutlet weak var shareToFacebookSwitch: UISwitch!
    @IBOutlet weak var recruitModelSwitch: UISwitch!

    @IBOutlet weak var categoryLabel: UILabel!
//    @IBOutlet weak var categoryStack: UIStackView!
    @IBOutlet weak var shampooButton: UIButton!
    @IBOutlet weak var haircutButton: UIButton!
    @IBOutlet weak var dyeButton: UIButton!
    @IBOutlet weak var permanentButton: UIButton!
    @IBOutlet weak var treatmentButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!

    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var paymentSegmentControl: UISegmentedControl!
    @IBOutlet weak var dolarSignLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!

    @IBOutlet weak var reservationTimeLabel: UILabel!
    @IBOutlet weak var pickDateButton: UIButton!

    @IBOutlet weak var morningButton: UIButton!
    @IBOutlet weak var afternoonButton: UIButton!
    @IBOutlet weak var nightButton: UIButton!

    @IBOutlet weak var reservationLocationLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!

    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!

    @IBAction func post(_ sender: Any) {

        //先判斷有無缺項 //TODO

        if recruitModelSwitch.isOn {

            guard shampooButton.isSelected ||
                    haircutButton.isSelected ||
                    dyeButton.isSelected ||
                    permanentButton.isSelected ||
                    treatmentButton.isSelected ||
                    otherButton.isSelected,
                dateSelected,
                morningButton.isSelected
                    || afternoonButton.isSelected
                    || nightButton.isSelected,
                cityTextField != nil
                    && districtTextField != nil
                    && addressTextField != nil,
                phoneTextField != nil else {

                    print("please complete")
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
            showOptions()
        default:
            hideOptions()
        }
    }

    @IBAction func shampoo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        shampooButton.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }

    @IBAction func haircut(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func dye(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func perm(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func treate(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func other(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func pay(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {

        case 1:
            dolarSignLabel.isHidden = false
            priceTextField.isHidden = false
            priceTextField.text = "0"

        default:
            dolarSignLabel.isHidden = true
            priceTextField.isHidden = true
            priceTextField.text = "0"
        }
    }

    @IBAction func pickDate(_ sender: Any) {
        datePickerTapped()
    }

    @IBAction func morning(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func afternoon(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func night(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()

        descriptionTextField.delegate = self

//        view1.isHidden = true
//        shareLabel.isHidden = true
        recruitLabel.isHidden = true
//        shareToFacebookSwitch.isHidden = true

        ref = Database.database().reference()

        hideOptions()

        let tapGestureRecognizer =
            UITapGestureRecognizer(
                target: self,
                action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)

        postImage.image = picture

    }

    func setLayout() {
//        otherButton.layer.borderWidth = 1
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

    func showOptions() {

        categoryLabel.isHidden = false
        shampooButton.isHidden = false
        haircutButton.isHidden = false
        dyeButton.isHidden = false
        permanentButton.isHidden = false
        treatmentButton.isHidden = false
        otherButton.isHidden = false

        paymentLabel.isHidden = false
        paymentSegmentControl.isHidden = false

        reservationTimeLabel.isHidden = false
        pickDateButton.isHidden = false
        morningButton.isHidden = false
        afternoonButton.isHidden = false
        nightButton.isHidden = false

        reservationLocationLabel.isHidden = false
        cityTextField.isHidden = false
        cityLabel.isHidden = false
        districtTextField.isHidden = false
        districtLabel.isHidden = false
        addressTextField.isHidden = false
        phoneLabel.isHidden = false
        phoneTextField.isHidden = false

    }
    func hideOptions() {

        categoryLabel.isHidden = true
        shampooButton.isHidden = true
        haircutButton.isHidden = true
        dyeButton.isHidden = true
        permanentButton.isHidden = true
        treatmentButton.isHidden = true
        otherButton.isHidden = true

        paymentLabel.isHidden = true
        paymentSegmentControl.isHidden = true
        dolarSignLabel.isHidden = true

        priceTextField.isHidden = true
        reservationTimeLabel.isHidden = true
        pickDateButton.isHidden = true
        morningButton.isHidden = true
        afternoonButton.isHidden = true
        nightButton.isHidden = true

        reservationLocationLabel.isHidden = true
        cityTextField.isHidden = true
        cityLabel.isHidden = true
        districtTextField.isHidden = true
        districtLabel.isHidden = true
        addressTextField.isHidden = true
        phoneLabel.isHidden = true
        phoneTextField.isHidden = true

    }

    @objc func datePickerTapped() {
        
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = +6
        let threeMonthAfter = Calendar.current.date(byAdding: dateComponents, to: currentDate)

        let datePicker = DatePickerDialog(
            textColor: #colorLiteral(red: 0.5098039216, green: 0.5450980392, blue: 0.6274509804, alpha: 1),
            buttonColor: #colorLiteral(red: 0.5098039216, green: 0.5450980392, blue: 0.6274509804, alpha: 1),
            font: UIFont.boldSystemFont(ofSize: 17),
            showCancelButton: true)
        
        datePicker.show(
            "限六個月內",
            doneButtonTitle: "Done",
            cancelButtonTitle: "Cancel",
            minimumDate: currentDate,
            maximumDate: threeMonthAfter,
            datePickerMode: .date) { (date) in
                if let dt = date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
//                    print(dt)
                    self.pickDateButton.setTitle(formatter.string(from: dt), for: .normal)
                    self.dateSelected = true
                }
        }
    }

    func share() {

        guard let postPicture = picture,
            let uploadData = postPicture.jpegData(compressionQuality: 0.1) else {
                print("no image")
                return
        }

//        if shareToFacebookSwitch.isOn {
//            shareToFacebook()
//        }

        let fileName = NSUUID().uuidString

        storageRef.child("\(fileName).jpeg").putData(uploadData, metadata: nil) { (metadata, error) in

            guard metadata != nil else {
                // Uh-oh, an error occurred!
                return
            }

            self.storageRef.child("\(fileName).jpeg").downloadURL { (url, error) in

                guard let downloadURL = url else { return }

                guard let authorUID = Auth.auth().currentUser?.uid else { return }

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
                            "category":
                                [
                                    "shampoo": self.shampooButton.isSelected,
                                    "haircut": self.haircutButton.isSelected,
                                    "dye": self.dyeButton.isSelected,
                                    "permanent": self.permanentButton.isSelected,
                                    "treatment": self.treatmentButton.isSelected,
                                    "other": self.otherButton.isSelected
                                ],
                            "payment": self.priceTextField.text!,
                            "reservation":
                                [
                                    "date": "\(self.pickDateButton.titleLabel!.text!)",
                                    "time":
                                        [
                                            "morning": self.morningButton.isSelected,
                                            "afternoon": self.afternoonButton.isSelected,
                                            "night": self.nightButton.isSelected
                                        ],
                                    "location":
                                        [
                                            "city": self.cityTextField.text,
                                            "district": self.districtTextField.text,
                                            "address": self.addressTextField.text
                                        ]
                                ],
                            "phone": self.phoneTextField.text!,
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

extension PostViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionTextField.text = ""
    }

}
