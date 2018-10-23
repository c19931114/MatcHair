//
//  ModelAppointmentViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/30.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import KeychainSwift
import BTNavigationDropdownMenu

class ModelSegementController: UIViewController {

    let keychain = KeychainSwift()
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var completeView: UIView!
    @IBOutlet weak var emptyPage: UIView!
    @IBOutlet weak var chatButton: UIButton!

    @IBAction func switchStament(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            print("0")
            NotificationCenter.default.post(name: .reFetchModelPendingAppointments, object: nil, userInfo: nil)

            UIView.animate(withDuration: 0.2, animations: {
                self.pendingView.alpha = 1
                self.confirmView.alpha = 0
                self.completeView.alpha = 0
            })
        case 1:
            print("1")
            NotificationCenter.default.post(name: .reFetchModelConfirmAppointments, object: nil, userInfo: nil)

            UIView.animate(withDuration: 0.2, animations: {
                self.pendingView.alpha = 0
                self.confirmView.alpha = 1
                self.completeView.alpha = 0
            })
        default:
            print("2")
            NotificationCenter.default.post(name: .reFetchModelCompleteAppointments, object: nil, userInfo: nil)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.pendingView.alpha = 0
                self.confirmView.alpha = 0
                self.completeView.alpha = 1
            })
        }
    }
    @IBAction private func goToChatRoom(_ sender: Any) {
        self.present(chatRoomViewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        let items = ["Model", "Designer"]
//
//        let menuView = BTNavigationDropdownMenu(
//            navigationController: self.navigationController,
//            containerView: self.navigationController!.view,
//            title: BTTitle.title("Model"),
//            items: items)
//
//        self.navigationItem.titleView = menuView
//
//        menuView.didSelectItemAtIndexHandler = { [weak self] (indexPath: Int) -> () in
//
//            print("Did select item at index: \(indexPath)")
//        }

        chatButton.isHidden = true

        guard keychain.get("userUID") != nil else {
            emptyPage.isHidden = false
            return
        }

        emptyPage.isHidden = true
    }

}
