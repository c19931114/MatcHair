//
//  UILabel+Crystal.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/20.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

extension UILabel {

    @IBInspectable
    var letterSpace: CGFloat {
        set {
            let attributedString: NSMutableAttributedString!
            if let currentAttrString = attributedText {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else {
                attributedString = NSMutableAttributedString(string: text ?? "")
                text = nil
            }

            attributedString.addAttribute(NSAttributedString.Key.kern,
                                          value: newValue,
                                          range: NSRange(location: 0, length: attributedString.length))

            attributedText = attributedString
        }

        get {
            if let currentLetterSpace =
                attributedText?.attribute(
                    NSAttributedString.Key.kern,
                    at: 0, effectiveRange: .none) as? CGFloat {
                
                return currentLetterSpace
            }
            else {
                return 0
            }
        }
    }
}
