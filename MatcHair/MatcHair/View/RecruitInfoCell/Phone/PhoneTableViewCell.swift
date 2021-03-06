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

    weak var phoneDelegate: PhoneProtocol?

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

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {

        if let text = textField.text,
            let textRange = Range(range, in: text) {

            let updatedText = text.replacingCharacters(in: textRange, with: string)
            phoneDelegate?.sendPhone(data: updatedText)
        }
        return true
    }
}
