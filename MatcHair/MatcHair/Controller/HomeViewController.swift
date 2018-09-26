//
//  HomeViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/26.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HomeViewController: UIViewController {

    var ref: DatabaseReference!
    var post = [Post]()

    @IBOutlet weak var postCollectionView: UICollectionView!

}

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }


}

extension HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

//        setupCollectionView()

        loadPosts()

    }

    private func setupCollectionView() {

        postCollectionView.dataSource = self

        let identifier = String(describing: PostCollectionViewCell.self)

        let xib = UINib(nibName: identifier, bundle: nil)

        postCollectionView.register(xib, forCellWithReuseIdentifier: identifier)
    }

    func loadPosts() {

        ref.child("posts").observe(.childAdded) { (snapshot) in

            let value = snapshot.value as? NSDictionary
            print(value as Any)
        }
    }

}
