//
//  MatcHairColor.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/19.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

enum MatcHairColor: String {

    case gradientPurple = "7830B8"

    case gradientBlue = "33A4CC"

    case lightGray = "E7E7E7" // 231, 231, 231

    case darkGray = "CDCDCD"  // 205, 205, 205

    case loadMoreButton = "727272" // 114, 114, 114

    case pictureBackground = "D8D8D8"

    case tabBarTintColor = "7436B9"

    case textColor = "1F1F1F"

    func color() -> UIColor {

        var cString: String = self.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: 3 / 255.0,
            green: 121 / 255.0,
            blue: 156 / 255.0,
            alpha: 1.0
        )

    }

}
