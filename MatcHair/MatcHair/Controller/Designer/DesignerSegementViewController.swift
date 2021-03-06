//
//  AppointmentViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/30.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import KeychainSwift

class DesignerSegementViewController: UIViewController {

    let keychain = KeychainSwift()

    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var completeView: UIView!
    @IBOutlet weak var emptyPage: UIView!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBAction func switchStament(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            print("0")
            NotificationCenter.default.post(name: .reFetchDesignerPendingAppointments, object: nil, userInfo: nil)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.pendingView.alpha = 1
                self.confirmView.alpha = 0
                self.completeView.alpha = 0
            })
        case 1:
            print("1")
            NotificationCenter.default.post(name: .reFetchDesignerConfirmAppointments, object: nil, userInfo: nil)

            UIView.animate(withDuration: 0.2, animations: {
                self.pendingView.alpha = 0
                self.confirmView.alpha = 1
                self.completeView.alpha = 0
            })
        default:
            print("2")
            NotificationCenter.default.post(name: .reFetchDesignerCompleteAppointments, object: nil, userInfo: nil)

            UIView.animate(withDuration: 0.2, animations: {
                self.pendingView.alpha = 0
                self.confirmView.alpha = 0
                self.completeView.alpha = 1
            })
        }
    }

    @IBAction private func goToChatRoom(_ sender: Any) {
        guard keychain.get("userUID") != nil else {
            showVisitorAlert()
            return
        }
        let messageController = MessageController()
        let navController = NavigationController(rootViewController: messageController)
        present(navController, animated: true, completion: nil)
    }

}

extension DesignerSegementViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard keychain.get("userUID") != nil else {
            emptyPage.isHidden = false
            return
        }

        emptyPage.isHidden = true

    }

    func showVisitorAlert() {

        let alertController = UIAlertController(
            title: "Oppps!!",
            message: "\n請先登入才能使用完整功能喔",
            preferredStyle: .alert)

        alertController.addAction(
            UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }

}
