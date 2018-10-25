//
//  CategoryTableViewCell.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/24.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

protocol CategoryProtocol: AnyObject {
    func sendCategory(data: [String: Bool])
}

class CategoryTableViewCell: UITableViewCell {

    weak var categoryDelegate: CategoryProtocol?
    
    var categories = [String: Bool]()

    @IBAction func shampoo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categories["shampoo"] = sender.isSelected
        categoryDelegate?.sendCategory(data: categories)
    }

    @IBAction func haircut(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categories["haircut"] = sender.isSelected
        categoryDelegate?.sendCategory(data: categories)
    }

    @IBAction func dye(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categories["dye"] = sender.isSelected
        categoryDelegate?.sendCategory(data: categories)
    }

    @IBAction func perm(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categories["permanent"] = sender.isSelected
        categoryDelegate?.sendCategory(data: categories)
    }
    @IBAction func treat(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categories["treatment"] = sender.isSelected
        categoryDelegate?.sendCategory(data: categories)
    }

    @IBAction func other(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        categories["other"] = sender.isSelected
        categoryDelegate?.sendCategory(data: categories)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
