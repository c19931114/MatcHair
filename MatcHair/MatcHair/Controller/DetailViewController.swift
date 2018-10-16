//
//  DetailViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/2.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import KeychainSwift

class DetailViewController: UIViewController {

    var postInfo: PostInfo?
    var myPost: MyPost?
    var categories = [String]()
    let swipcontroller = SwipeController()
    var ref: DatabaseReference!
    let keychain = KeychainSwift()
    var selectedTiming: String?
    let transition = CATransition()

    @IBOutlet weak var moreButton: UIButton!

    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var reservationButton: UIButton!

    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var postImage: UIImageView!

    @IBOutlet weak var descriptionTextView: UITextView!

    @IBAction func moreForPost(_ sender: Any) {

        guard let currentUserUID = Auth.auth().currentUser?.uid else {

            showVisitorAlert()
            return

        }

        if postInfo?.authorUID == currentUserUID {

            showEditAlert(
                editCompletion: { (_) in

                    print("no edit")

                }, deleteCompletion: { (_) in

                    self.deletePost()
                })
        } else {

            showReportAlert()
        }
    }

    @IBAction func moreForMyPost(_ sender: Any) {

        showEditAlert(

            editCompletion: { (_) in

                print("no edit")

            }, deleteCompletion: { (_) in

                self.deleteMyPost()
            })

    }

    @IBAction func goBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func makeReservation(_ sender: Any) {

        guard let currentUserUID = keychain.get("userUID") else {
            showVisitorAlert()
            return
        }

        guard let post = postInfo else { return }

        if post.authorUID != currentUserUID {

            var timingOption = [String]()

            let timing = post.reservation!.time

            if timing.morning {
                timingOption.append("早上")
            }

            if timing.afternoon {
                timingOption.append("下午")
            }

            if timing.night {
                timingOption.append("晚上")
            }

            print(timingOption)

            PickerDialog().show(
                title: "\(post.reservation!.date)",
            options: timingOption) {(value) -> Void in

                print("selected: \(value)")
                self.selectedTiming = value

                self.uploadAppointment(with: post, timing: value)

                // 向右換 tab 頁
                self.transition.duration = 0.5
                self.transition.type = CATransitionType.push
                self.transition.subtype = CATransitionSubtype.fromLeft
                self.transition.timingFunction = CAMediaTimingFunction(
                    name: CAMediaTimingFunctionName.easeInEaseOut)
                self.view.window!.layer.add(self.transition, forKey: kCATransition)

                let tabController = self.view.window!.rootViewController as? UITabBarController
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                tabController?.selectedIndex = 1

            }

        }
        
    }

}

extension DetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        // 向下滑動
        let swipeDown = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.swipeOut))
        swipeDown.direction = .down

        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(swipeDown)

        if let post = postInfo {

            showPostData(for: post)

            if let currentUserUID = keychain.get("userUID") {
                if post.authorUID == currentUserUID {
                    reservationButton.isHidden = true
                }
            }

        } else if let myPost = myPost {
            showMyPostData(for: myPost)
        }

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

    private func uploadAppointment(with postInfo: PostInfo, timing: String) {

        guard let currentUserUID = Auth.auth().currentUser?.uid else {return }

        let createTime = Date().millisecondsSince1970 // 1476889390939

        guard let appointmentID = self.ref.child("appointmentPosts").childByAutoId().key else { return }

        ref.child("appointments/\(appointmentID)").setValue(
            [
                "designerUID": postInfo.authorUID,
                "modelUID": currentUserUID,
                "postID": postInfo.postID,
                "timing": timing,
                "appointmentID": appointmentID,
                "createTime": createTime,
                "statement": "pending"
            ]
        )

        NotificationCenter.default.post(
            name: .reFetchModelPendingAppointments,
            object: nil,
            userInfo: nil
        )

    }

    @objc func swipeOut() {
        self.dismiss(animated: true)
    }

    class func detailForPost(_ post: PostInfo) -> DetailViewController {

        guard let detailVC =
            UIStoryboard
                .detailStoryboard()
                .instantiateInitialViewController() as? DetailViewController else {

                    return DetailViewController()
        }

        detailVC.postInfo = post
        return detailVC

    }

    class func detailForMyPost(_ post: MyPost) -> DetailViewController {

        guard let detailVC =
            UIStoryboard
                .detailStoryboard()
                .instantiateInitialViewController() as? DetailViewController else {

                    return DetailViewController()
        }
        print(post)

        detailVC.myPost = post
        return detailVC

    }

    private func showPostData(for post: PostInfo) {

        locationLabel.text = "\(post.reservation!.location.city), \(post.reservation!.location.district)"
        postImage.kf.setImage(with: URL(string: post.pictureURL))
        descriptionTextView.text = post.content

        if post.category!.shampoo { categories.append("洗髮") }
        if post.category!.haircut { categories.append("剪髮") }
        if post.category!.dye { categories.append("染髮") }
        if post.category!.permanent { categories.append("燙髮") }
        if post.category!.treatment { categories.append("護髮") }
        if post.category!.other { categories.append("其他") }

        categoryLabel.text = categories.joined(separator: ", ")
    }

    private func showMyPostData(for post: MyPost) {
        categoryLabel.isHidden = true
        locationLabel.isHidden = true
        postImage.kf.setImage(with: URL(string: post.pictureURL))
        descriptionTextView.text = post.content
    }

    func showReportAlert() {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let reportAction = UIAlertAction(title: "檢舉此貼文", style: .destructive, handler: showReceivedMessage)
        alertController.addAction(reportAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func showReceivedMessage(alert: UIAlertAction) {

        let alertController = UIAlertController(
            title: nil,
            message: "已傳送檢舉通知",
            preferredStyle: .alert)

        alertController.addAction(
            UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }

    func showEditAlert(
        editCompletion: @escaping (UIAlertAction) -> Void,
        deleteCompletion: @escaping (UIAlertAction) -> Void) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

//        let editAction = UIAlertAction(title: "編輯", style: .default, handler: editCompletion)
//        alertController.addAction(editAction)

        let deleteAction = UIAlertAction(title: "刪除", style: .destructive, handler: deleteCompletion)

        alertController.addAction(deleteAction)

        self.present(alertController, animated: true, completion: nil)

    }

//    func editPost() {
//
//        guard let post = post else { return }
//        let editPost = PostViewController.editPost(post)
//        self.present(editPost, animated: true)
//        editPost.recruitModelSwitch.isOn = true
//
//        editPost.shampooButton.isSelected = post.category!.shampoo
//        editPost.haircutButton.isSelected = post.category!.haircut
//        editPost.dyeButton.isSelected = post.category!.dye
//        editPost.permanentButton.isSelected = post.category!.permanent
//        editPost.treatmentButton.isSelected = post.category!.treatment
//        editPost.otherButton.isSelected = post.category!.other
//
//        if post.payment == "0" {
//            editPost.paymentSegmentControl.selectedSegmentIndex = 0
//        } else {
//            editPost.paymentSegmentControl.selectedSegmentIndex = 1
//            editPost.paymentLabel.text = post.payment!
//        }
//
//        editPost.pickDateButton.setTitle("\(post.reservation!.date)", for: .normal)
//        editPost.dateSelected = true
//        editPost.morningButton.isSelected = post.reservation!.time.morning
//        editPost.afternoonButton.isSelected = post.reservation!.time.afternoon
//        editPost.nightButton.isSelected = post.reservation!.time.night
//        editPost.cityTextField.text = post.reservation!.location.city
//        editPost.districtTextField.text = post.reservation!.location.district
//        editPost.addressTextField.text = post.reservation!.location.address
//        editPost.phoneTextField.text = post.phone
//
//    }

//    func editMyPost() {
//
//        guard let myPost = myPost else { return }
//
//        let post =
//            PostInfo(
//            postID: myPost.postID,
//            category: nil,
//            content: myPost.content,
//            payment: nil,
//            pictureURL: myPost.pictureURL,
//            reservation: nil, authorUID:
//            myPost.authorUID,
//            createTime: myPost.createTime,
//            phone: nil)
//
//        let editPost = PostViewController.editPost(post)
//        self.present(editPost, animated: true)
//        editPost.recruitModelSwitch.isOn = false
//    }

    func deletePost() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let post = postInfo else { return }

        ref.child("usersPosts/\(currentUserUID)/\(post.postID)").removeValue()
        ref.child("allPosts/\(post.postID)").removeValue()
        NotificationCenter.default.post(name: .reFetchAllPosts, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: .reFetchAllPosts, object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)

    }

    func deleteMyPost() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let myPost = myPost else { return }

        ref.child("usersPosts/\(currentUserUID)/\(myPost.postID)").removeValue()
        ref.child("allPosts/\(myPost.postID)").removeValue()
        NotificationCenter.default.post(name: .reFetchMyPosts, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: .reFetchAllPosts, object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
        
    }

}
