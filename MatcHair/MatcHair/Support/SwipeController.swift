//
//  SwipeController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/21.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation
import UIKit

class SwipeController {

    var currentVC: UIViewController?

    func swipeFrom(_ currentVC: UIViewController) {

        self.currentVC = currentVC

        // 向左滑動
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(SwipeController.swipe(recognizer:)))
        swipeDown.direction = .down
        // 幾根指頭觸發 預設為 1
        swipeDown.numberOfTouchesRequired = 1
        // 為視圖加入監聽手勢
        currentVC.view.addGestureRecognizer(swipeDown)

        // 向右滑動
        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(SwipeController.swipe(recognizer:)))
        swipeRight.direction = .right

        // 為視圖加入監聽手勢
        currentVC.view.addGestureRecognizer(swipeRight)

    }

    // 觸發滑動手勢後 執行的動作
    @objc func swipe(recognizer: UISwipeGestureRecognizer) {

//        let postViewController = UIStoryboard.postStoryboard().instantiateInitialViewController()!
//
//        let transition = CATransition()
//        transition.duration = 0.5
//        transition.type = CATransitionType.push
//        transition.subtype = CATransitionSubtype.fromLeft
//        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        switch recognizer.direction {

        case .down:
            print("Go Dowm")
        case .right:
            print("Go Right")

//            currentVC?.view.window!.layer.add(transition, forKey: kCATransition)
//            currentVC?.present(postViewController, animated: false)

        default:
            print("")
        }

    }

}
