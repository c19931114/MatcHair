//
//  ProfileViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/20.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import KeychainSwift

class ProfileViewController: UIViewController {

    let decoder = JSONDecoder()
    let keychain = KeychainSwift()
    let fullScreenSize = UIScreen.main.bounds.size
    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()
    var refreshControl: UIRefreshControl!

    let emptyImageView = UIImageView(image: #imageLiteral(resourceName: "two_polaroid_pictures"))
    let emptyMessageLabel = UILabel()

    var myPosts: [MyPost] = []
    var currentUserImageURL: URL?
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    @IBOutlet weak var profileCollectionView: UICollectionView!

    @IBAction private func goToChatRoom(_ sender: Any) {
        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}

extension ProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard keychain.get("userUID") != nil else {
            showVisitorAlert()
            return
        }

        ref = Database.database().reference()

        setRefreshControl()

        setupCollectionView()

        getUserImage()

        loadMyPosts()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadMyPosts),
            name: .reFetchMyPosts,
            object: nil)

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

    private func setRefreshControl() {

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(
            red: 234/255.0, green: 222/255.0, blue: 212/255.0, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(
            string: "重新整理中",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(
                red: 209/255.0, green: 143/255.0, blue: 131/255.0, alpha: 1)])

        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        profileCollectionView.addSubview(refreshControl)
    }

    func emptyPage() {

        emptyImageView.image = emptyImageView.image?.withRenderingMode(.alwaysTemplate)
        emptyImageView.tintColor = #colorLiteral(red: 0.7568627451, green: 0.8274509804, blue: 0.8274509804, alpha: 1)

        emptyImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        emptyImageView.center = CGPoint(x: fullScreenSize.width / 2, y: fullScreenSize.height * 0.55)
        emptyImageView.contentMode = .scaleAspectFill
        view.addSubview(emptyImageView)

        emptyMessageLabel.text = "還沒有新增作品唷"
        emptyMessageLabel.textColor = UIColor(red: 169/255.0, green: 185/255.0, blue: 192/255.0, alpha: 1)
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.font = emptyMessageLabel.font.withSize(15)
        emptyMessageLabel.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width, height: 20)
        emptyMessageLabel.center = CGPoint(x: fullScreenSize.width / 2, y: fullScreenSize.height * 0.65)
        view.addSubview(emptyMessageLabel)
    }

    private func setupCollectionView() {

        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self

        let profileCellIdentifier = String(describing: ProfileCollectionViewCell.self)
        let profileXib = UINib(nibName: profileCellIdentifier, bundle: nil)
        profileCollectionView.register(profileXib, forCellWithReuseIdentifier: profileCellIdentifier)

        let postCellIdentifier = String(describing: MyPostCollectionViewCell.self)
        let postXib = UINib(nibName: postCellIdentifier, bundle: nil)
        profileCollectionView.register(postXib, forCellWithReuseIdentifier: postCellIdentifier)

    }

    func getUserImage() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        let fileName = currentUserUID

        self.storageRef.child(fileName).downloadURL(completion: { (url, error) in

            if let url = url {
                self.currentUserImageURL = url
            } else {
                print(error as Any)
            }
            self.profileCollectionView.reloadData()

        })
    }

    @objc func loadMyPosts() {

        guard let currnetUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("usersPosts/\(currnetUserUID)").observeSingleEvent(of: .value) { (snapshot) in

            self.myPosts = []

            guard let value = snapshot.value as? NSDictionary else {

                self.profileCollectionView.reloadData()
                return

            }

            for value in value.allValues {

                guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

                do {
                    let postData = try self.decoder.decode(MyPost.self, from: postJSONData)
                    self.myPosts.insert(postData, at: 0)

                } catch {
                    print(error)
                }

                self.myPosts.sort(by: { $0.createTime > $1.createTime })

                self.profileCollectionView.reloadData()
            }
        }
    }

    @objc func reloadData() {

        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {

            self.loadMyPosts()
            self.refreshControl.endRefreshing()

        }

    }

}

extension ProfileViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1

        default:

            if myPosts.count == 0 {
                emptyPage()
            } else {
                emptyImageView.removeFromSuperview()
                emptyMessageLabel.removeFromSuperview()
            }

            return myPosts.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        switch indexPath.section {
        case 0:

            let cell = profileCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: ProfileCollectionViewCell.self),
                for: indexPath)

            guard let profileCell = cell as? ProfileCollectionViewCell else {
                return UICollectionViewCell()
            }

            if let userName = Auth.auth().currentUser?.displayName {
                profileCell.userNameLabel.text = userName
            }

            profileCell.userImage.kf.setImage(with: currentUserImageURL)

            profileCell.postsCountLabel.text = "\(myPosts.count) 則貼文"

            return profileCell

        default:

            let cell = profileCollectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MyPostCollectionViewCell.self),
                for: indexPath)

            guard let postCell = cell as? MyPostCollectionViewCell else {
                return UICollectionViewCell()
            }

            let post = myPosts[indexPath.row]

            postCell.postImage.kf.setImage(with: URL(string: post.pictureURL))

            return postCell
        }

    }

}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0) // 每個 section 的邊界(?
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 1 // 上下
    }
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1 // 左右
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        switch indexPath.section {
        case 0:

            let width = fullScreenSize.width
            let height = CGFloat(112.0)
            return CGSize(width: width, height: height)

        default:

            let width = (fullScreenSize.width - 2) / 3
            let height = width
            return CGSize(width: width, height: height)
        }

    }

}

extension ProfileViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            let selectedPost = myPosts[indexPath.row]
            let detailForPost = DetailViewController.detailForMyPost(selectedPost)
            self.present(detailForPost, animated: true)
            detailForPost.moreButton.isHidden = true
            detailForPost.editButton.isHidden = false
            detailForPost.reservationButton.isHidden = true
        }

    }
}
