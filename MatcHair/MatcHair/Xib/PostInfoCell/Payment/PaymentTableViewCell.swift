//
//  PaymentTableViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/24.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {

    var payment: String? = "0"

    @IBOutlet weak var dolarSignLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!

    @IBAction func pay(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {

        case 0:
            dolarSignLabel.isHidden = true
            priceTextField.isHidden = true
            priceTextField.text = "0"

        default:
            dolarSignLabel.isHidden = false
            priceTextField.isHidden = false
            priceTextField.text = ""
        }

        if priceTextField.text == "" {
            payment = "0"
        } else {
            payment = priceTextField.text
        }

    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
