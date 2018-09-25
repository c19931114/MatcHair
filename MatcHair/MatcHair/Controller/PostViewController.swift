//
//  PostViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/21.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    var picture: UIImage?

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

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var timeIntervalStack: UIStackView!
    @IBOutlet weak var morningButton: UIButton!
    @IBOutlet weak var afternoonButton: UIButton!
    @IBOutlet weak var nightButton: UIButton!

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!

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

        hideOptions()

        let tapGestureRecognizer =
            UITapGestureRecognizer(
                target: self,
                action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)

        postImage.image = picture

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

        timeLabel.isHidden = false
        calendarButton.isHidden = false
        timeIntervalStack.isHidden = false
        locationLabel.isHidden = false
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
        timeLabel.isHidden = true
        calendarButton.isHidden = true
        timeIntervalStack.isHidden = true
        locationLabel.isHidden = true
        cityTextField.isHidden = true
        cityLabel.isHidden = true
        districtTextField.isHidden = true
        districtLabel.isHidden = true
        addressTextField.isHidden = true

    }
}
