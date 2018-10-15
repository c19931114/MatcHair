//
//  LikeViewController.swift
//  MatcHair
//
//  Created by Crystal on 2018/9/27.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import Lottie
import KeychainSwift

class LikeViewController: UIViewController {

    let decoder = JSONDecoder()
    var refreshControl: UIRefreshControl!
    let keychain = KeychainSwift()
    var ref: DatabaseReference!
    lazy var storageRef = Storage.storage().reference()

    var likePosts = [Post]() // [(PostInfo, User, URL)]
    let fullScreenSize = UIScreen.main.bounds.size
    let animationView = LOTAnimationView(name: "empty_box")
    let chatRoomViewController = UIStoryboard.chatRoomStoryboard().instantiateInitialViewController()!
    var selectedTiming: String?
    let transition = CATransition()

    @IBOutlet weak var likePostCollectionView: UICollectionView!

    @IBAction private func goToChatRoom(_ sender: Any) {
        self.present(chatRoomViewController, animated: true, completion: nil)
    }

}
extension LikeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        guard currentUserUID == keychain.get("userUID") else {
            showVisitorAlert()
            return
        }

        ref = Database.database().reference()

        setRefreshControl()

        setupCollectionView()

        loadLikePosts()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadLikePosts),
            name: Notification.Name.reFetchLikePosts,
            object: nil)
    }
    
    func showVisitorAlert() {

        let alertController = UIAlertController(
            title: nil,
            message: "請先登入",
            preferredStyle: .alert)

        alertController.addAction(
            UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }

    private func setRefreshControl() {

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(
            red: 255/255.0, green: 249/255.0, blue: 91/255.0, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(
            string: "重新整理中...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(
                red: 4/255.0, green: 71/255.0, blue: 28/255.0, alpha: 1)])

        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        likePostCollectionView.addSubview(refreshControl)
    }

    func emptyAnimate() {

        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
//        animationView.animationSpeed = 1.5
        view.addSubview(animationView)
        animationView.play()

    }

    private func setupCollectionView() {

        likePostCollectionView.dataSource = self
        likePostCollectionView.delegate = self

        let identifier = String(describing: LikePostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        likePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

    }

    @objc func loadLikePosts() {

        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        ref.child("likePosts/\(currentUserID)").observeSingleEvent(of: .value) { (snapshot) in

            self.likePosts = []

            guard let value = snapshot.value as? NSDictionary else {

                self.likePostCollectionView.reloadData()
                return

            }

            for postID in value.allKeys {

                self.ref
                    .child("allPosts")
                    .queryOrderedByKey()
                    .queryEqual(toValue: postID)
                    .observeSingleEvent(of: .value) { (snapshot) in

                        guard let value = snapshot.value as? NSDictionary else { return }

                        guard let postJSONData =
                            try? JSONSerialization.data(withJSONObject: value.allValues[0]) else { return }

                        do {
                            let postData = try self.decoder.decode(PostInfo.self, from: postJSONData)
                            self.getAuthorInfo(with: postData)
                        } catch {
                            print(error)
                        }
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
                self.likePosts.insert(post, at: 0)

            } else {
                print(error as Any)
            }

            self.likePosts.sort(by: { $0.info.createTime > $1.info.createTime }) // 應該是加入最愛的時間
            self.likePostCollectionView.reloadData()

        })

    }

    @objc func reloadData() {

        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {

            self.loadLikePosts()
            self.refreshControl.endRefreshing()

        }

    }

}

extension LikeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if likePosts.count == 0 {
            emptyAnimate()
        } else {
            animationView.removeFromSuperview()
        }
        
        return likePosts.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = likePostCollectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: LikePostCollectionViewCell.self),
            for: indexPath)

        guard let postCell = cell as? LikePostCollectionViewCell else {
            return UICollectionViewCell()
        }

        let post = likePosts[indexPath.row]

        postCell.userNameLabel.text = post.author.name
        postCell.userImage.kf.setImage(with: post.authorImageURL)

        postCell.postImage.kf.setImage(with: URL(string: post.info.pictureURL))
        postCell.locationLabel.text =
            "\(post.info.reservation!.location.city), \(post.info.reservation!.location.district)"

        // target action
        postCell.likeButton.tag = indexPath.row
        postCell.likeButton.addTarget(
            self,
            action: #selector(self.unlikeButtonTapped(sender:)), for: .touchUpInside)

        postCell.reservationButton.tag = indexPath.row
        postCell.reservationButton.addTarget(
            self,
            action: #selector(reservationButtonTapped(sender:)),
            for: .touchUpInside)

        return postCell

    }

    @objc func unlikeButtonTapped(sender: UIButton) {

        print(sender.tag)
        print(sender.isSelected) // false

        guard let userID = Auth.auth().currentUser?.uid else { return }

        let likePost = likePosts[sender.tag]

        ref.child("likePosts/\(userID)/\(likePost.info.postID)").removeValue()

        likePosts.remove(at: sender.tag)

        likePostCollectionView.reloadData()

        NotificationCenter.default.post(name: .reFetchAllPosts, object: nil, userInfo: nil)
    }

    @objc func reservationButtonTapped(sender: UIButton) {

        var timingOption = [String]()

        let reservationPost = likePosts[sender.tag]
        let timing = reservationPost.info.reservation!.time

        if timing.morning {
            timingOption.append("早上")
        }

        if timing.afternoon {
            timingOption.append("下午")
        }

        if timing.night {
            timingOption.append("晚上")
        }
        print(timing)
        print(timingOption)

        PickerDialog().show(
            title: "\(reservationPost.info.reservation!.date)",
        options: timingOption) {(value) -> Void in

            print("selected: \(value)")
            self.selectedTiming = value

            self.uploadAppointment(post: reservationPost.info, with: value)

            // 向左換 tab 頁
            self.transition.duration = 0.5
            self.transition.type = CATransitionType.push
            self.transition.subtype = CATransitionSubtype.fromLeft
            self.transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.view.window!.layer.add(self.transition, forKey: kCATransition)

            self.tabBarController?.selectedIndex = 1

        }

    }

    private func uploadAppointment(post: PostInfo, with timing: String) {

        guard let currentUserUID = UserManager.shared.getUserUID() else { return }

        let createTime = Date().millisecondsSince1970 // 1476889390939

        guard let appointmentID = self.ref.child("appointmentPosts").childByAutoId().key else { return }

        ref.child("appointmentPosts/\(appointmentID)").setValue(
            [
                "designerUID": post.authorUID,
                "modelUID": currentUserUID,
                "postID": post.postID,
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

    // TODO
    func removeLikeAlert(title: String = "移除最愛", message: String) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in

        }

        let cancle = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancle)

        present(alertController, animated: true, completion: nil)
    }

}

extension LikeViewController: UICollectionViewDelegateFlowLayout {

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

extension LikeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedPost = likePosts[indexPath.row].info
        let detailForPost = DetailViewController.detailForPost(selectedPost)
        self.present(detailForPost, animated: true)
        detailForPost.editButton.isHidden = true
        detailForPost.moreButton.isHidden = false
    }
}
