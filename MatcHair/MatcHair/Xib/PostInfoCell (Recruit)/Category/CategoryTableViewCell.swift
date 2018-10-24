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
    
    var category = [String: Bool]()

    @IBAction func shampoo(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        category["shampoo"] = sender.isSelected
        categoryDelegate?.sendCategory(data: category)
        //        shampooButton.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }

    @IBAction func haircut(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        category["haircut"] = sender.isSelected
        categoryDelegate?.sendCategory(data: category)
    }

    @IBAction func dye(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        category["dye"] = sender.isSelected
        categoryDelegate?.sendCategory(data: category)
    }

    @IBAction func perm(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        category["permanent"] = sender.isSelected
        categoryDelegate?.sendCategory(data: category)
    }
    @IBAction func treat(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        category["treatment"] = sender.isSelected
        categoryDelegate?.sendCategory(data: category)
    }

    @IBAction func other(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        category["other"] = sender.isSelected
        categoryDelegate?.sendCategory(data: category)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
