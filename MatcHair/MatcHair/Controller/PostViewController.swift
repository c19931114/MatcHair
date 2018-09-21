//
//  PostViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/21.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    var picture: UIImage?

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextView!

}

extension PostViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)

        postImage.image = picture

    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {

        print("tap")


    }
}
