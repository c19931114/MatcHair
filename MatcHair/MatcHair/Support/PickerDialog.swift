//
//  PickerDialog.swift
//  MatcHair
//
//  Created by Crystal on 2018/10/2.
//  Copyright © 2018年 Crystal. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(hex: Int, alpha: Float = 1.0) {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        self.init(red: CGFloat(r / 255.0), green: CGFloat(g / 255.0), blue: CGFloat(b / 255.0), alpha: CGFloat(alpha))
    }
}

class PickerDialog: UIView, UIPickerViewDataSource, UIPickerViewDelegate {

    let fullscreensize = UIScreen.main.bounds.size

    typealias PickerCallback = (_ value: String) -> Void

    /* Constants */
    private let kPickerDialogDefaultButtonHeight: CGFloat = 50
    private let kPickerDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kPickerDialogCornerRadius: CGFloat = 7
    private let kPickerDialogDoneButtonTag: Int = 1

    /* Views */
    private var dialogView: UIView!
    private var titleLabel: UILabel!
    private var picker: UIPickerView!
    private var cancelButton: UIButton!
    private var doneButton: UIButton!

    /* Variables */
    private var pickerData = [String]()
    private var callback: PickerCallback?

    /* Overrides */
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: fullscreensize.width, height: fullscreensize.height))

        setupView()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.dialogView = createContainerView()

        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.main.scale

        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale

        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)

        picker.delegate = self

        self.addSubview(self.dialogView!)
    }

    /* Handle device orientation changes */
    @objc func deviceOrientationDidChange(notification: NSNotification) {
        close() // For now just close it
    }

    /* Required UIPickerView functions */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    /* Create the dialog view, and animate opening the dialog */
    func show(title: String, doneButtonTitle: String = "Done", cancelButtonTitle: String = "Cancel", options: [String], callback: @escaping PickerCallback) {
        self.titleLabel.text = title
        self.pickerData = options
        self.doneButton.setTitle(doneButtonTitle, for: .normal)
        self.cancelButton.setTitle(cancelButtonTitle, for: .normal)
        self.callback = callback

        UIApplication.shared.windows.first!.addSubview(self)
        UIApplication.shared.windows.first!.endEditing(true)

        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationDidChange(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)

        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
        },
            completion: nil
        )
    }

    /* Dialog close animation then cleaning and removing the view from the parent */
    private func close() {
        NotificationCenter.default.removeObserver(self)

        let currentTransform = self.dialogView.layer.transform

        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + .pi * 270 / 180), 0, 0, 0)

        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveLinear /*UIViewAnimationOptions.TransitionNone*/,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
        }) { (finished: Bool) -> Void in
            for v in self.subviews {
                v.removeFromSuperview()
            }

            self.removeFromSuperview()
        }
    }

    /* Creates the container view here: create the dialog, then add the custom content and buttons */
    private func createContainerView() -> UIView {

        let dialogSize = CGSize(
            width: 300,
            height: 230 + kPickerDialogDefaultButtonHeight + kPickerDialogDefaultButtonSpacerHeight)

        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: fullscreensize.width, height: fullscreensize.height)

        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRect(
            x: (fullscreensize.width - dialogSize.width) / 2,
            y: (fullscreensize.height - dialogSize.height) / 2,
            width: dialogSize.width,
            height: dialogSize.height))

        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor,
                           UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor,
                           UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor]

        let cornerRadius = kPickerDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, at: 0)

        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSize(
            width: 0 - (cornerRadius + 5) / 2,
            height: 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.black.cgColor
        dialogContainer.layer.shadowPath = UIBezierPath(
            roundedRect: dialogContainer.bounds,
            cornerRadius: dialogContainer.layer.cornerRadius).cgPath

        // There is a line above the button
        let lineView = UIView(frame: CGRect(
            x: 0,
            y: dialogContainer.bounds.size.height - kPickerDialogDefaultButtonHeight - kPickerDialogDefaultButtonSpacerHeight,
            width: dialogContainer.bounds.size.width,
            height: kPickerDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)

        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 280, height: 30))
        self.titleLabel.textAlignment = NSTextAlignment.center
        self.titleLabel.textColor = UIColor(hex: 0x333333)
        self.titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        dialogContainer.addSubview(self.titleLabel)

        self.picker = UIPickerView(frame: CGRect(x: 0, y: 30, width: 0, height: 0))
        self.picker.setValue(UIColor(hex: 0x333333), forKeyPath: "textColor")
        self.picker.autoresizingMask = UIView.AutoresizingMask.flexibleRightMargin
        self.picker.frame.size.width = 300

        dialogContainer.addSubview(self.picker)

        // Add the buttons
        addButtonsToView(container: dialogContainer)

        return dialogContainer
    }

    /* Add buttons to container */
    private func addButtonsToView(container: UIView) {

        let buttonWidth = container.bounds.size.width / 2

        self.cancelButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
        self.cancelButton.frame = CGRect(
            x: 0,
            y: container.bounds.size.height - kPickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kPickerDialogDefaultButtonHeight
        )
        self.cancelButton.setTitleColor(UIColor(hex: 0x555555), for: UIControl.State.normal)
        self.cancelButton.setTitleColor(UIColor(hex: 0x555555), for: UIControl.State.highlighted)
        self.cancelButton.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 15)
        self.cancelButton.layer.cornerRadius = kPickerDialogCornerRadius
        self.cancelButton.addTarget(
            self,
            action: #selector(self.buttonTapped(sender:)),
            for: .touchUpInside)

        container.addSubview(self.cancelButton)

        self.doneButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
        self.doneButton.frame = CGRect(
            x: buttonWidth,
            y: container.bounds.size.height - kPickerDialogDefaultButtonHeight,
            width: buttonWidth,
            height: kPickerDialogDefaultButtonHeight
        )

        self.doneButton.tag = kPickerDialogDoneButtonTag
        self.doneButton.setTitleColor(UIColor(hex: 0x555555), for: UIControl.State.normal)
        self.doneButton.setTitleColor(UIColor(hex: 0x555555), for: UIControl.State.highlighted)
        self.doneButton.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 15)
        self.doneButton.layer.cornerRadius = kPickerDialogCornerRadius
        self.doneButton.addTarget(
            self,
            action: #selector(self.buttonTapped(sender:)),
            for: .touchUpInside)

        container.addSubview(self.doneButton)
    }

    @objc func buttonTapped(sender: UIButton!) {

        if sender.tag == kPickerDialogDoneButtonTag {
            let selectedIndex = self.picker.selectedRow(inComponent: 0)
            let selectedValue = self.pickerData[selectedIndex]
            self.callback?(selectedValue)
        }

        close()

    }

}
