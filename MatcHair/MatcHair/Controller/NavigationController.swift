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

        UINavigationBar.appearance().shadowImage = UIImage()
//        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

        setBarGradient()
        //addShadowToBar()

        let titleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 18)]
        self.navigationBar.titleTextAttributes = titleAttributes as [NSAttributedString.Key : Any]

        let leftButtonAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 17)]
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(leftButtonAttributes as [NSAttributedString.Key : Any], for: .normal)

    }

    func setBarGradient() {

        let gradient = CAGradientLayer()
        var bounds = navigationBar.bounds
        bounds.size.height += UIApplication.shared.statusBarFrame.size.height
        gradient.frame = bounds

        gradient.colors = [UIColor(red: 164/255.0, green: 215/255.0, blue: 215/255.0, alpha: 1.0).cgColor,
                           UIColor(red: 234/255.0, green: 188/255.0, blue: 171/255.0, alpha: 1.0).cgColor]

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
