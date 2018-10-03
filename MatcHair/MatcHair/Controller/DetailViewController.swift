//
//  DetailViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/2.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var post: Post?
    var myPost: MyPost?
    var categories = [String]()
    let swipcontroller = SwipeController()

    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var postImage: UIImageView!

    @IBOutlet weak var descriptionTextView: UITextView!

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

    class func detailForPost(_ post: Post) -> DetailViewController {

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

    private func showPostData(for post: Post) {

//        categoryLabel.text =
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
}
