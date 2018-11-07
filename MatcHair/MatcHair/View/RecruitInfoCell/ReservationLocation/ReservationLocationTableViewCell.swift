//
//  ReservationLocationTableViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/24.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

protocol ReservationLocationProtocol: AnyObject {
    func sendReservationLocationCity(data: String)
    func sendReservationLocationDistrict(data: String)
    func sendReservationLocationAddress(data: String)
}

class ReservationLocationTableViewCell: UITableViewCell {

    weak var reservationLocationDelegate: ReservationLocationProtocol?

    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        cityTextField.delegate = self
        cityTextField.placeholder = "縣市"
        districtTextField.delegate = self
        districtTextField.placeholder = "鄉鎮市區"
        addressTextField.delegate = self
        addressTextField.placeholder = "完整地址"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension ReservationLocationTableViewCell: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {

        switch textField {

        case cityTextField:

            if let text = textField.text,
                let textRange = Range(range, in: text) {

                let updatedText = text.replacingCharacters(in: textRange, with: string)

                reservationLocationDelegate?
                    .sendReservationLocationCity(data: updatedText)
            }

        case districtTextField:

            if let text = textField.text,
                let textRange = Range(range, in: text) {

                let updatedText = text.replacingCharacters(in: textRange, with: string)
                reservationLocationDelegate?
                    .sendReservationLocationDistrict(data: updatedText)
            }

        default:

            if let text = textField.text,
                let textRange = Range(range, in: text) {

                let updatedText = text.replacingCharacters(in: textRange, with: string)

                reservationLocationDelegate?
                    .sendReservationLocationAddress(data: updatedText)
            }

        }
        return true
    }

}
