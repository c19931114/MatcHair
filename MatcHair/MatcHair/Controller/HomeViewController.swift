//
//  HomeViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/26.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class HomeViewController: UIViewController {
    
    let decoder = JSONDecoder()

    var ref: DatabaseReference!
    var homePosts = [Post]()
    let fullScreenSize = UIScreen.main.bounds.size

    @IBOutlet weak var homePostCollectionView: UICollectionView!

}

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homePosts.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = homePostCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: PostCollectionViewCell.self),
            for: indexPath)

        guard let postCell = cell as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let homePost = homePosts[indexPath.row]

        postCell.postImage.kf.setImage(with: URL(string: homePost.pictureURL))
        postCell.userImage.kf.setImage(with: URL(string: homePost.user.image))
        postCell.userNameLabel.text = homePost.user.name
        postCell.locationLabel.text = "\(homePost.reservation.location.city), \(homePost.reservation.location.district)"

        return postCell

    }

}

extension HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setupCollectionView()

        loadHomePosts()

    }

    private func setupCollectionView() {

        homePostCollectionView.dataSource = self

        let identifier = String(describing: PostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        homePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

        guard let layout = homePostCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumLineSpacing = 20

        let width = fullScreenSize.width - 30
        let height = width * 27 / 25
        layout.itemSize = CGSize(width: width, height: height)
    }

    func loadHomePosts() {

        ref.child("posts").observe(.childAdded) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let postData = try self.decoder.decode(Post.self, from: postJSONData)
                self.homePosts.append(postData)
            } catch {
                print(error)
            }

           self.homePostCollectionView.reloadData()

        }

    }

}
