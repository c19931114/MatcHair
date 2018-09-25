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

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!

    @IBOutlet weak var shareToFacebookSwitch: UISwitch!
    @IBOutlet weak var recruitModelSwitch: UISwitch!

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryStack: UIStackView!
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
    @IBOutlet weak var pickDateLabel: UILabel!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var timeIntervalStack: UIStackView!
    @IBOutlet weak var morningButton: UIButton!
    @IBOutlet weak var afternoonButton: UIButton!
    @IBOutlet weak var nightButton: UIButton!

    @IBOutlet weak var reservationLocationLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!

    @IBAction func post(_ sender: Any) {
        share()
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
        print(sender.isSelected)
        switch sender.isSelected {
        case true:
            print("yes shampoo")
        default:
            print("no shampoo")
        }
    }

    @IBAction func haircut(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            print("yes haircut")
        default:
            print("no haircut")
        }
    }

    @IBAction func dye(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            print("yes dye")
        default:
            print("no dye")
        }
    }

    @IBAction func perm(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            print("yes perm")
        default:
            print("no perm")
        }
    }
    @IBAction func treate(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            print("yes treate")
        default:
            print("no treate")
        }
    }

    @IBAction func other(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            print("yes other")
        default:
            print("no other")
        }
    }

    @IBAction func pay(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {

        case 1:
            dolarSignLabel.isHidden = false
            priceTextField.isHidden = false
        default:
            dolarSignLabel.isHidden = true
            priceTextField.isHidden = true
            priceTextField.text = nil
        }
    }
    @IBAction func pickDate(_ sender: Any) {

        datePickerTapped()

    }

    @IBAction func morning(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            print("yes morning")
        default:
            print("no morning")
        }
    }

    @IBAction func afternoon(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            print("yes afternoon")
        default:
            print("no afternoon")
        }
    }

    @IBAction func night(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender.isSelected {
        case true:
            print("yes night")
        default:
            print("no night")
        }
    }

}

extension PostViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        hideOptions()

        let tapGestureRecognizer =
            UITapGestureRecognizer(
                target: self,
                action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)

        postImage.image = picture

        descriptionTextField.text = "test"

        cityTextField.text = "台北市"
        districtTextField.text = "信義區"
        addressTextField.text = "基隆路一段180號"

    }



    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {

        print("tap")

    }
    func showOptions() {

        categoryLabel.isHidden = false
        categoryStack.isHidden = false
        paymentLabel.isHidden = false
        paymentSegmentControl.isHidden = false
        reservationTimeLabel.isHidden = false
        pickDateLabel.isHidden = false
        calendarButton.isHidden = false
        timeIntervalStack.isHidden = false
        reservationLocationLabel.isHidden = false
        cityTextField.isHidden = false
        cityLabel.isHidden = false
        districtTextField.isHidden = false
        districtLabel.isHidden = false
        addressTextField.isHidden = false

    }
    func hideOptions() {

        categoryLabel.isHidden = true
        categoryStack.isHidden = true
        paymentLabel.isHidden = true
        paymentSegmentControl.isHidden = true
        dolarSignLabel.isHidden = true
        priceTextField.isHidden = true
        reservationTimeLabel.isHidden = true
        pickDateLabel.isHidden = true
        calendarButton.isHidden = true
        timeIntervalStack.isHidden = true
        reservationLocationLabel.isHidden = true
        cityTextField.isHidden = true
        cityLabel.isHidden = true
        districtTextField.isHidden = true
        districtLabel.isHidden = true
        addressTextField.isHidden = true

    }

    func datePickerTapped() {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = +6
        let threeMonthAfter = Calendar.current.date(byAdding: dateComponents, to: currentDate)

        let datePicker = DatePickerDialog(
            textColor: UIColor(
                red: 3 / 255.0,
                green: 121 / 255.0,
                blue: 200 / 255.0,
                alpha: 1.0),
            buttonColor: UIColor(
                red: 3 / 255.0,
                green: 121 / 255.0,
                blue: 200 / 255.0,
                alpha: 1.0),
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
                    self.pickDateLabel.text = formatter.string(from: dt)
                }
        }
    }

    func share() {

        guard let image = picture,
            let uploadData = image.jpegData(compressionQuality: 0.1) else {
                print("no image")
                return
        }

        let fileName = NSUUID().uuidString

        storageRef.child("\(fileName).jpeg").putData(uploadData, metadata: nil) { (metadata, error) in

            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            print(metadata)

            self.storageRef.child("\(fileName).jpeg").downloadURL { (url, error) in

                guard let downloadURL = url else { return }
                guard let userID = UserManager.shared.getUserUID() else { return }

                guard let postId = self.ref.child("users/\(userID)/posts").childByAutoId().key else { return }

                self.ref.child("users/\(userID)/posts/\(postId)").setValue(
                    ["pictureURL": "\(downloadURL)", "content": "\(self.descriptionTextField.text!)"])

            }
        }

    }
}
