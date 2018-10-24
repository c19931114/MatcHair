//
//  ReservationTimeTableViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/24.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import DatePickerDialog

protocol ReservationTimeProtocol: AnyObject {
    func sendReservationDate(data: String)
    func sendReservationTime(data: [String: Bool])
}

class ReservationTimeTableViewCell: UITableViewCell {

    weak var reservationTimeDelegate: ReservationTimeProtocol?

    var reservationTime = [String: Bool]()

    @IBOutlet weak var pickDateButton: UIButton!

    @IBAction func pickDate(_ sender: Any) {
        datePickerTapped()
    }

    @IBAction func morning(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        reservationTime["morning"] = sender.isSelected
        reservationTimeDelegate?.sendReservationTime(data: reservationTime)
    }

    @IBAction func afternoon(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        reservationTime["afternoon"] = sender.isSelected
        reservationTimeDelegate?.sendReservationTime(data: reservationTime)
    }

    @IBAction func night(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        reservationTime["night"] = sender.isSelected
        reservationTimeDelegate?.sendReservationTime(data: reservationTime)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    @objc func datePickerTapped() {

        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = +6
        let threeMonthAfter = Calendar.current.date(byAdding: dateComponents, to: currentDate)

        let datePicker = DatePickerDialog(
            textColor: #colorLiteral(red: 0.8645840287, green: 0.5463376045, blue: 0.5011332035, alpha: 1),
            buttonColor: #colorLiteral(red: 0.8645840287, green: 0.5463376045, blue: 0.5011332035, alpha: 1),
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

                    self.reservationTimeDelegate?.sendReservationDate(
                        data: formatter.string(from: dt))

                }
        }
    }
    
}
