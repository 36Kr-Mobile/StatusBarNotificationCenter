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
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var multiLine: UISwitch!
    @IBOutlet weak var isCustomView: UISwitch!
    @IBOutlet weak var concurrentNotificationNumberLabel: UILabel!
    @IBOutlet weak var concurrentNotificationNumberSlider: UISlider!
    
    @IBOutlet weak var heightSlider: UISlider!

    let notificationQ = dispatch_queue_create("ViewControllerNotificationQ", DISPATCH_QUEUE_CONCURRENT)
    
    var notificationCenter: StatusBarNotificationCenter!

    override func viewDidLoad() {
        let labelText = "\(durationSlider.value) seconds"
        durationLabel.text = labelText
        notificationTextField.text = "Hello, Programmer"
    }
    
    @IBAction func durationValueChanged(sender: UISlider) {
        let labelText = "\(sender.value) seconds"
        durationLabel.text = labelText
    }
    
    @IBAction func heightValueChanged(sender: UISlider) {
        let labelText = sender.value == 0 ? "Standard Height" : "\(sender.value) of the screen height"
        heightLabel.text = labelText
    }

    @IBAction func notificationNumberChanged(sender: UISlider) {
        let labelText = "\(Int(concurrentNotificationNumberSlider.value))"
        concurrentNotificationNumberLabel.text = labelText
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
        dispatch_async(notificationQ) { () -> Void in
            for i in 1...Int(self.concurrentNotificationNumberSlider.value) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(i) * drand48() * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                    if self.isCustomView.on {
                        let nibContents = NSBundle.mainBundle().loadNibNamed("NotificationView", owner: self, options: nil)
                        let view = nibContents.first as! UIView
                        StatusBarNotificationCenter.showStatusBarNotificationWithView(view, forDuration: NSTimeInterval(self.durationSlider.value), withNotificationCenterConfiguration: notificationCenterConfiguration)
                    } else {
                        var notificationLabelConfiguration = SBNNotificationLabelConfiguration()
                        notificationLabelConfiguration.font = UIFont.systemFontOfSize(14.0)
                        notificationLabelConfiguration.multiline = self.multiLine.on
                        notificationLabelConfiguration.backgroundColor = self.view.tintColor
                        notificationLabelConfiguration.textColor = UIColor.blackColor()
                        StatusBarNotificationCenter.showStatusBarNotificationWithMessage(self.notificationTextField.text! + "\(i)", forDuration: NSTimeInterval(self.durationSlider.value), withNotificationCenterConfiguration: notificationCenterConfiguration, andNotificationLabelConfiguration: notificationLabelConfiguration)
                    }
                    
                })

            }
        }
    }
}

