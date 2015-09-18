//
//  ViewController.swift
//  StatusBarNotification
//
//  Created by Shannon Wu on 9/16/15.
//  Copyright © 2015 Shannon Wu. All rights reserved.
//

import UIKit
import StatusBarNotificationCenter

class ViewController: UIViewController {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var notificationTextField: UITextField!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var segFromStyle: UISegmentedControl!
    @IBOutlet weak var segToStyle: UISegmentedControl!
    @IBOutlet weak var segNotificationType: UISegmentedControl!
    @IBOutlet weak var segAnimationType: UISegmentedControl!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var multiLine: UISwitch!
    @IBOutlet weak var isCustomView: UISwitch!
    
    var notificationCenter: StatusBarNotificationCenter!

    override func viewDidLoad() {
        updateDurationLabel()
        notificationTextField.text = "The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!The world is waiting for your ideas. Are you ready? Then let's get started building your business!"
    }
    
    @IBAction func durationValueChanged(sender: UISlider) {
        updateDurationLabel()
    }
    
    @IBAction func heightValueChanged(sender: UISlider) {
        updateHeightLabel()
    }


    @IBAction func showNotification(sender: UIButton) {
        var notificationCenterConfiguration = SBNNotificationCenterConfiguration(baseWindow: view.window!)
        notificationCenterConfiguration.animateInDirection = StatusBarNotificationCenter.AnimationDirection(rawValue: segFromStyle.selectedSegmentIndex)!
        notificationCenterConfiguration.animateOutDirection = StatusBarNotificationCenter.AnimationDirection(rawValue: segToStyle.selectedSegmentIndex)!
        notificationCenterConfiguration.animationType = StatusBarNotificationCenter.AnimationType(rawValue: segAnimationType.selectedSegmentIndex)!
        notificationCenterConfiguration.style = StatusBarNotificationCenter.Style(rawValue: segNotificationType.selectedSegmentIndex)!
        notificationCenterConfiguration.height = (UIScreen.mainScreen().bounds.height * CGFloat(heightSlider.value))
        notificationCenterConfiguration.animateInLength = 0.25
        notificationCenterConfiguration.animateOutLength = 0.75
        notificationCenterConfiguration.style = StatusBarNotificationCenter.Style(rawValue: segNotificationType.selectedSegmentIndex)!
        
        if isCustomView.on {
            let nibContents = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: self, options: nil)
            let view = nibContents.first as! UIView
            view.frame = CGRectMake(100, 100, 300, 300)
            StatusBarNotificationCenter.showStatusBarNotificationWithView(view, forDuration: NSTimeInterval(durationSlider.value), withNotificationCenterConfiguration: notificationCenterConfiguration)
        } else {
            var notificationLabelConfiguration = SBNNotificationLabelConfiguration()
            notificationLabelConfiguration.font = UIFont.systemFontOfSize(14.0)
            notificationLabelConfiguration.multiline = multiLine.on
            notificationLabelConfiguration.backgroundColor = view.tintColor
            notificationLabelConfiguration.textColor = UIColor.blackColor()
            StatusBarNotificationCenter.showStatusBarNotificationWithMessage(notificationTextField.text, forDuration: NSTimeInterval(durationSlider.value), withNotificationCenterConfiguration: notificationCenterConfiguration, andNotificationLabelConfiguration: notificationLabelConfiguration)
        }
    }
        
    func updateDurationLabel() {
        let labelText = "\(durationSlider.value) seconds"
        durationLabel.text = labelText
    }
    
    func updateHeightLabel() {
        let labelText = heightSlider.value == 0 ? "Standard Height" : "\(heightSlider.value) of the screen height"
        heightLabel.text = labelText
    }
}

