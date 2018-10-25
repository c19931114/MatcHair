//
//  PaymentTableViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/24.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

protocol PaymentProtocol: AnyObject {
    func sendPayment(data: String)
}

class PaymentTableViewCell: UITableViewCell {

    weak var paymentDelegate: PaymentProtocol?

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

    }

    override func awakeFromNib() {
        super.awakeFromNib()

        dolarSignLabel.isHidden = true
        priceTextField.isHidden = true

        priceTextField.delegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

extension PaymentTableViewCell: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {

        paymentDelegate?.sendPayment(data: textField.text ?? "0")
        return true
    }
}
