//
//  HomeViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/26.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import Lottie
import KeychainSwift

class HomeViewController: UIViewController {
    
    let decoder = JSONDecoder()
    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    var refreshControl: UIRefreshControl!
    let keychain = KeychainSwift()
    let animationView = LOTAnimationView(name: "home_loading")
    let emptyMessageLabel = UILabel()

    var allPosts = [Post]() // [(PostInfo, User, URL)]
    var likePostIDs = [String]()
    var likePostIndex: Int?
    var selectedTiming: String?
    let transition = CATransition()

    let fullScreenSize = UIScreen.main.bounds.size
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!

    @IBOutlet weak var homePostCollectionView: UICollectionView!

    @IBAction private func goToChatRoom(_ sender: Any) {

        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}

extension HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        setRefreshControl()

        setupCollectionView()

        loadLikePosts()

//        loadLikePosts()

//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        homePostCollectionView.collectionViewLayout = layout

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadLikePosts),
            name: .reFetchAllPosts,
            object: nil)

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
        homePostCollectionView.addSubview(refreshControl)
    }

    func homeLoadingAnimate() {

        animationView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        animationView.center = CGPoint(x: fullScreenSize.width / 2, y: fullScreenSize.height * 0.5)
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        animationView.animationSpeed = 1.5
        view.addSubview(animationView)

        emptyMessageLabel.text = "loading..."
        emptyMessageLabel.textColor = UIColor(red: 169/255.0, green: 185/255.0, blue: 192/255.0, alpha: 1)
        emptyMessageLabel.textAlignment = .center
        emptyMessageLabel.font = emptyMessageLabel.font.withSize(15)
        emptyMessageLabel.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width, height: 20)
        emptyMessageLabel.center = CGPoint(x: fullScreenSize.width / 2, y: fullScreenSize.height * 0.6)
        view.addSubview(emptyMessageLabel)

        animationView.play()

    }

    private func setupCollectionView() {

        homePostCollectionView.dataSource = self
        homePostCollectionView.delegate = self

        let identifier = String(describing: PostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        homePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

    }

    @objc func loadLikePosts() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            self.loadAllPosts()
        return }

        ref.child("likePosts/\(currentUserUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else {
                self.loadAllPosts()
                return
            }

            guard let likePostIDs = value.allKeys as? [String] else { return }
            self.likePostIDs = likePostIDs

            self.loadAllPosts()

        }
    }

    func loadAllPosts() {

        ref.child("allPosts").observeSingleEvent(of: .value) { (snapshot) in

            self.allPosts = []

            guard let value = snapshot.value as? NSDictionary else {

                self.homePostCollectionView.reloadData()
                return

            }

            for value in value.allValues {

                guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

                do {
                    var postData = try self.decoder.decode(PostInfo.self, from: postJSONData)

                    for likedPostID in self.likePostIDs {
                        if postData.postID == likedPostID {
                            postData.isLiked = true
                        }
                    }
                    self.getAuthorInfo(with: postData)

                } catch {
                    print(error)
                }
            }

        }

    }

    func getAuthorInfo(with postData: PostInfo) {

        self.ref.child("users/\(postData.authorUID)").observeSingleEvent(of: .value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }

            guard let userJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

            do {
                let userData = try self.decoder.decode(User.self, from: userJSONData)
                self.getAuthorImageURL(with: postData, userData)

            } catch {
                print(error)
            }

        }
    }

    func getAuthorImageURL(with postData: PostInfo, _ userData: User) {
        
        let fileName = postData.authorUID

        self.storageRef.child(fileName).downloadURL(completion: { (url, error) in

            if let authorImageURL = url {
                
                let post = Post(info: postData, author: userData, authorImageURL: authorImageURL)
                self.allPosts.insert(post, at: 0)

            } else {
                print(error as Any)
            }

//            self.allPosts.sort(by: { (firstItem, secondItem) -> Bool in
//                return firstItem.info.createTime > secondItem.info.createTime
//            })

            self.allPosts.sort(by: { $0.info.createTime > $1.info.createTime })

            self.homePostCollectionView.reloadData()
            
        })

    }

    @objc func reloadData() {

        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {

            self.loadAllPosts()
            self.refreshControl.endRefreshing()

//            self.homePostCollectionView.scrollToItem(at: [0, 0], at: .top, animated: true) // 要停在哪格
        }

    }

}

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if allPosts.count == 0 {
            homeLoadingAnimate()
        } else {
            animationView.removeFromSuperview()
            emptyMessageLabel.removeFromSuperview()
        }

        return allPosts.count
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

        let post = allPosts[indexPath.row]

        postCell.userNameButton.setTitle(post.author.name, for: .normal)

//        postCell.userImageButton.kf.setImage(with: post.authorImageURL, for: .normal)
        postCell.userImage.kf.setImage(with: post.authorImageURL)

        postCell.postImage.kf.setImage(with: URL(string: post.info.pictureURL))
        postCell.locationLabel.text =
            "\(post.info.reservation!.location.city), \(post.info.reservation!.location.district)"

        postCell.likeButton.isSelected = post.info.isLiked
        if postCell.likeButton.isSelected {
            postCell.likeButton.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
        } else {
            postCell.likeButton.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
        }

        // target action
        postCell.likeButton.tag = indexPath.row
        postCell.likeButton.addTarget(
            self,
            action: #selector(self.likeButtonTapped(sender:)), for: .touchUpInside)

        postCell.userImageButton.tag = indexPath.row
        postCell.userImageButton.addTarget(
            self,
            action: #selector(userTapped(sender:)),
            for: .touchUpInside)

        postCell.userNameButton.tag = indexPath.row
        postCell.userNameButton.addTarget(
            self,
            action: #selector(userTapped(sender:)),
            for: .touchUpInside)

        return postCell

    }

    @objc func likeButtonTapped(sender: UIButton) {

//        guard keychain.get("userUID") != nil else {
//            showVisitorAlert()
//            return
//        }

        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            showVisitorAlert()
            return
        }

        NotificationCenter.default.post(name: .reFetchLikePosts, object: nil, userInfo: nil)

        let likePost = allPosts[sender.tag]

        sender.isSelected = !sender.isSelected
        if sender.isSelected {

            sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
            ref.child("likePosts/\(currentUserUID)/\(likePost.info.postID)").setValue(true)

        } else {

            sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
            ref.child("likePosts/\(currentUserUID)/\(likePost.info.postID)").removeValue()

        }

    }

    @objc func userTapped(sender: UIButton) {

        let selectedDesignerUID = allPosts[sender.tag].info.authorUID
        let profileForDesigner = ProfileViewController.profileForDesigner(selectedDesignerUID)
        self.navigationController?.pushViewController(profileForDesigner, animated: true)

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

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20) // 每個 section 的邊界(?
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 20 // 上下
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // 左右
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = fullScreenSize.width - 40
        let height = width * 27 / 25
        return CGSize(width: width, height: height)

    }

}

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedPostInfo = allPosts[indexPath.row].info
        let detailForPost = DetailViewController.detailForPost(selectedPostInfo)
        self.present(detailForPost, animated: true)
        detailForPost.editButton.isHidden = true
        detailForPost.moreButton.isHidden = false

    }
}
