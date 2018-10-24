//
//  PhoneTableViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/24.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

protocol PhoneProtocol: AnyObject {
    func sendPhone(data: String)
}

class PhoneTableViewCell: UITableViewCell {

    weak var phoneDelegate : PhoneProtocol?

    @IBOutlet weak var phoneTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        phoneTextField.delegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

extension PhoneTableViewCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        phoneDelegate?.sendPhone(data: textField.text ?? "")
    }
}
