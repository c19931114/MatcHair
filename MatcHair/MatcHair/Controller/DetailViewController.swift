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

class DetailViewController: UIViewController {

    var post: PostInfo?
    var myPost: MyPost?
    var categories = [String]()
    let swipcontroller = SwipeController()
    var ref: DatabaseReference!

    @IBOutlet weak var moreButton: UIButton!

    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var postImage: UIImageView!

    @IBOutlet weak var descriptionTextView: UITextView!

    @IBAction func moreForPost(_ sender: Any) {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        if post?.authorUID == currentUserUID {
            showEditAlert { (_) in
                self.deletePost()
            }
        } else {
            showReportAlert()
        }
    }

    @IBAction func moreForMyPost(_ sender: Any) {

        showEditAlert { (_) in
            self.deleteMyPost()
        }

    }

    @IBAction func goBackButton(_ sender: Any) {
        self.dismiss(animated: true)
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

        if let post = post {
            showPostData(for: post)
        } else if let myPost = myPost {
            showMyPostData(for: myPost)
        }

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

        detailVC.post = post
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

        locationLabel.text = "\(post.reservation.location.city), \(post.reservation.location.district)"
        postImage.kf.setImage(with: URL(string: post.pictureURL))
        descriptionTextView.text = post.content

        print(post.category)

        if post.category.shampoo { categories.append("洗髮") }
        if post.category.haircut { categories.append("剪髮") }
        if post.category.dye { categories.append("染髮") }
        if post.category.permanent { categories.append("燙髮") }
        if post.category.treatment { categories.append("護髮") }
        if post.category.other { categories.append("其他") }

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

    func showEditAlert(completion: @escaping (UIAlertAction) -> Void) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        let editAction = UIAlertAction(title: "編輯", style: .default, handler: nil)
        alertController.addAction(editAction)

        let deleteAction = UIAlertAction(title: "刪除", style: .destructive, handler: completion)

        alertController.addAction(deleteAction)

        self.present(alertController, animated: true, completion: nil)

    }

//    func goEdit()  {
//
//        let editPost = PostViewController.editPost()
//        self.present(detailForPost, animated: true)
//    }

    func deletePost() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let post = post else { return }

        ref.child("usersPosts/\(currentUserUID)/\(post.postID)").removeValue()
        ref.child("allPosts/\(post.postID)").removeValue()
        NotificationCenter.default.post(name: .reFetchAllPosts, object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)

    }

    func deleteMyPost() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let myPost = myPost else { return }

        ref.child("usersPosts/\(currentUserUID)/\(myPost.postID)").removeValue()
        ref.child("allPosts/\(myPost.postID)").removeValue()
        NotificationCenter.default.post(name: .reFetchMyPosts, object: nil, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
        
    }

}
