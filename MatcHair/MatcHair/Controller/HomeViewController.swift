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

class HomeViewController: UIViewController {
    
    let decoder = JSONDecoder()
    lazy var storageRef = Storage.storage().reference()
    var ref: DatabaseReference!
    var refreshControl: UIRefreshControl!

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

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(
            red: 255/255.0, green: 249/255.0, blue: 91/255.0, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(
            string: "重新整理中...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(
                red: 4/255.0, green: 71/255.0, blue: 28/255.0, alpha: 1)])

        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        homePostCollectionView.addSubview(refreshControl)

        setupCollectionView()

        loadAllPosts()
//        loadLikePosts()

//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        homePostCollectionView.collectionViewLayout = layout

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadAllPosts),
            name: .reFetchAllPosts,
            object: nil)

    }

    private func setupCollectionView() {

        homePostCollectionView.dataSource = self
        homePostCollectionView.delegate = self

        let identifier = String(describing: PostCollectionViewCell.self)
        let xib = UINib(nibName: identifier, bundle: nil)
        homePostCollectionView.register(xib, forCellWithReuseIdentifier: identifier)

    }

    @objc func loadAllPosts() {   //   要新增下拉更新

        ref.child("allPosts").observeSingleEvent(of: .value) { (snapshot) in

            self.allPosts = []

            guard let value = snapshot.value as? NSDictionary else { return }

            for value in value.allValues {

                guard let postJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }

                do {
                    let postData = try self.decoder.decode(PostInfo.self, from: postJSONData)
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

    func loadLikePosts() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        ref.child("likePosts/\(currentUserUID)").observe(.value) { (snapshot) in

            guard let value = snapshot.value as? NSDictionary else { return }
            guard let likePostIDs = value.allKeys as? [String] else { return }
            self.likePostIDs = likePostIDs

//            self.homePostCollectionView.reloadData()

        }
    }

    @objc func reloadData() {

        refreshControl.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {

            self.loadAllPosts()
            self.refreshControl.endRefreshing()

//            self.homePostCollectionView.scrollToItem(at: [0, 0], at: .top, animated: true)
        }

    }

}

extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

        postCell.userNameLabel.text = post.author.name
        postCell.userImage.kf.setImage(with: post.authorImageURL)

        postCell.postImage.kf.setImage(with: URL(string: post.info.pictureURL))
        postCell.locationLabel.text =
            "\(post.info.reservation.location.city), \(post.info.reservation.location.district)"

        // target action
        postCell.likeButton.tag = indexPath.row
        postCell.likeButton.addTarget(
            self,
            action: #selector(self.likeButtonTapped(sender:)), for: .touchUpInside)

        postCell.reservationButton.tag = indexPath.row
        postCell.reservationButton.addTarget(
            self,
            action: #selector(reservationButtonTapped(sender:)),
            for: .touchUpInside)

        return postCell

    }

    @objc func likeButtonTapped(sender: UIButton) {

        NotificationCenter.default.post(name: .reFetchLikePosts, object: nil, userInfo: nil)

        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }

        let likePost = allPosts[sender.tag]

        sender.isSelected = !sender.isSelected
        if sender.isSelected {

//            sender.setImage(#imageLiteral(resourceName: "btn_like_selected"), for: .normal)
            ref.child("likePosts/\(currentUserUID)/\(likePost.info.postID)").setValue(true)

        } else {

//            sender.setImage(#imageLiteral(resourceName: "btn_like_normal"), for: .normal)
            ref.child("likePosts/\(currentUserUID)/\(likePost.info.postID)").removeValue()

        }

    }

    @objc func reservationButtonTapped(sender: UIButton) {

        var timingOption = [String]()

        let reservationPost = allPosts[sender.tag]
        let timing = reservationPost.info.reservation.time

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
            title: "\(reservationPost.info.reservation.date)",
            options: timingOption) {(value) -> Void in

                print("selected: \(value)")
                self.selectedTiming = value

                self.uploadAppointment(with: reservationPost.info, timing: value)

                NotificationCenter.default.post(name: .reFetchModelPendingAppointments, object: nil, userInfo: nil)

                // 向右換 tab 頁
                self.transition.duration = 0.5
                self.transition.type = CATransitionType.push
                self.transition.subtype = CATransitionSubtype.fromRight
                self.transition.timingFunction = CAMediaTimingFunction(
                    name: CAMediaTimingFunctionName.easeInEaseOut)
                self.view.window!.layer.add(self.transition, forKey: kCATransition)

                self.tabBarController?.selectedIndex = 1

        }

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
            userInfo: nil)

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
