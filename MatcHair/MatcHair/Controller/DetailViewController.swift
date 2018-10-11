//
//  DetailViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/2.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var post: PostInfo?
    var myPost: MyPost?
    var categories = [String]()
    let swipcontroller = SwipeController()

    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var postImage: UIImageView!

    @IBOutlet weak var descriptionTextView: UITextView!

    @IBAction func more(_ sender: Any) {

        buttomAlert()

    }

    @IBAction func goBackButton(_ sender: Any) {

        self.dismiss(animated: true)

    }

}

extension DetailViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        print(post)

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

    func buttomAlert() {

        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)

        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)

        // 建立[確認]按鈕
        let reportAction = UIAlertAction(
            title: "檢舉此貼文",
            style: .destructive,
            handler: showReceivedMessage)

        alertController.addAction(reportAction)

        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
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
}
