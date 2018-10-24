//
//  ReservationLocationTableViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/24.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class ReservationLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
