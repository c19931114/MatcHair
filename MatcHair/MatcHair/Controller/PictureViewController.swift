//
//  StoryViewController.swift
//  Voyage
//
//  Created by Crystal on 2018/9/6.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import KeychainSwift

class PictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let cameraController = CameraController()
    let transition = CATransition()
    let keychain = KeychainSwift()

    @IBOutlet weak var emptyPage: UIView!
    @IBOutlet fileprivate var captureButton: UIButton!
    @IBOutlet weak var captureButtonBackgroundView: UIView!

    @IBOutlet fileprivate var capturePreviewView: UIView!
    
    // Allows the user to put the camera in photo mode.
    @IBOutlet fileprivate var toggleFlashButton: UIButton!
    @IBOutlet fileprivate var toggleCameraButton: UIButton!
    
    @IBOutlet weak var cameraModeButton: UIButton!
    
    // Allows the user to put the camera in video mode.
    @IBOutlet fileprivate var videoModeButton: UIButton!
    
//    override var prefersStatusBarHidden: Bool { return true }
    
    // 閃光燈開關
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        } else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }
    
    // 切換前後鏡頭
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        } catch {
            print(error)
        }

    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        
        cameraController.captureImage { (image, error) in
            
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
                        
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } // 把照片存進手機

            self.performSegue(withIdentifier: "showPicture", sender: image)

        }
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        
        let picker: UIImagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
//            picker.allowsEditing = true // 可對照片作編輯
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
    }
    // 取得選取後的照片
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        picker.dismiss(animated: false, completion: nil) // 關掉

        self.performSegue(
            withIdentifier: "showPicture",
            sender: info[UIImagePickerController.InfoKey.originalImage] as? UIImage)

        //self.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage // 從Dictionary取出原始圖檔
    }
    
    // 圖片picker控制器任務結束回呼
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyPage.isHidden = true

//        cameraModeButton.isHidden = true
//        videoModeButton.isHidden = true

        guard keychain.get("userUID") != nil else {
            emptyPage.isHidden = false
            toggleFlashButton.isHidden = true
            toggleCameraButton.isHidden = true
            return
        }

        configureCameraController()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        styleButton()
//        configureCameraController() // 相機會一直當掉

    }
    
    func configureCameraController() {
        cameraController.prepare {(error) in

            if let error = error {
                print(error)
            }

            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }
    
    func styleButton() {

        captureButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        captureButton.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        captureButton.layer.borderWidth = 2
        captureButton.layer.cornerRadius = min(
            captureButton.frame.width,
            captureButton.frame.height) / 2

        captureButtonBackgroundView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        captureButtonBackgroundView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        captureButtonBackgroundView.layer.borderWidth = 2
        captureButtonBackgroundView.layer.cornerRadius = min(
            captureButtonBackgroundView.frame.width,
            captureButtonBackgroundView.frame.height) / 2

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let image = sender as? UIImage else { return }
        
        guard let showPictureViewController = segue.destination as? ShowPictureViewController else { return }
                
        showPictureViewController.picture = image // 為什麼不能馬上show照片Ｑ
        
    }
    
}
