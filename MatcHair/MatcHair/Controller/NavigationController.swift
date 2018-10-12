//
//  NavigationController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/21.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setBarGradient()
        //addShadowToBar()

    }

    func setBarGradient() {
        let gradient = CAGradientLayer()
        var bounds = navigationBar.bounds
        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds
//        gradient.colors = [UIColor(red: 3/255.0, green: 121/255.0, blue: 200/255.0, alpha: 1.0).cgColor,
//                           UIColor(red: 0/255.0, green: 50/255.0, blue: 78/255.0, alpha: 1.0).cgColor]

        gradient.colors = [UIColor(red: 4/255.0, green: 71/255.0, blue: 28/255.0, alpha: 1.0).cgColor,
                           UIColor(red: 13/255.0, green: 40/255.0, blue: 24/255.0, alpha: 1.0).cgColor]

        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)

        if let image = getImageFrom(gradientLayer: gradient) {
            navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        }
    }

    func getImageFrom(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(
                withCapInsets: UIEdgeInsets.zero,
                resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }

    func addShadowToBar() {
        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.layer.shadowColor = UIColor(
            red: 151/255.0,
            green: 151/255.0,
            blue: 151/255.0,
            alpha: 1.0).cgColor
        self.navigationBar.layer.shadowOpacity = 0.8
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    }

}
