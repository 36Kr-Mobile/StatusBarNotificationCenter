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

    let notificationQ = DispatchQueue(label: "ViewControllerNotificationQ", attributes: DispatchQueue.Attributes.concurrent)
    
    var notificationCenter: StatusBarNotificationCenter!

    override func viewDidLoad() {
        let labelText = "\(durationSlider.value) seconds"
        durationLabel.text = labelText
        notificationTextField.text = "Hello, Programmer"
    }
    
    @IBAction func durationValueChanged(_ sender: UISlider) {
        let labelText = "\(sender.value) seconds"
        durationLabel.text = labelText
    }
    
    @IBAction func heightValueChanged(_ sender: UISlider) {
        let labelText = sender.value == 0 ? "Standard Height" : "\(sender.value) of the screen height"
        heightLabel.text = labelText
    }

    @IBAction func notificationNumberChanged(_ sender: UISlider) {
        let labelText = "\(Int(concurrentNotificationNumberSlider.value))"
        concurrentNotificationNumberLabel.text = labelText
    }
    

    @IBAction func showNotification(_ sender: UIButton) {
        var notificationCenterConfiguration = NotificationCenterConfiguration(baseWindow: view.window!)
        notificationCenterConfiguration.animateInDirection = StatusBarNotificationCenter.AnimationDirection(rawValue: segFromStyle.selectedSegmentIndex)!
        notificationCenterConfiguration.animateOutDirection = StatusBarNotificationCenter.AnimationDirection(rawValue: segToStyle.selectedSegmentIndex)!
        notificationCenterConfiguration.animationType = StatusBarNotificationCenter.AnimationType(rawValue: segAnimationType.selectedSegmentIndex)!
        notificationCenterConfiguration.style = StatusBarNotificationCenter.Style(rawValue: segNotificationType.selectedSegmentIndex)!
        notificationCenterConfiguration.height = (UIScreen.main.bounds.height * CGFloat(heightSlider.value))
        notificationCenterConfiguration.animateInLength = 0.25
        notificationCenterConfiguration.animateOutLength = 0.75
        notificationCenterConfiguration.style = StatusBarNotificationCenter.Style(rawValue: segNotificationType.selectedSegmentIndex)!
        notificationQ.async { () -> Void in
            for i in 1...Int(self.concurrentNotificationNumberSlider.value) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(i) * drand48() * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    if self.isCustomView.isOn {
                        let nibContents = Bundle.main.loadNibNamed("NotificationView", owner: self, options: nil)
                        let view = nibContents?.first as! UIView
                        StatusBarNotificationCenter.showStatusBarNotificationWithView(view, forDuration: TimeInterval(self.durationSlider.value), withNotificationCenterConfiguration: notificationCenterConfiguration)
                    } else {
                        var notificationLabelConfiguration = NotificationLabelConfiguration()
                        notificationLabelConfiguration.font = UIFont.systemFont(ofSize: 14.0)
                        notificationLabelConfiguration.multiline = self.multiLine.isOn
                        notificationLabelConfiguration.backgroundColor = self.view.tintColor
                        notificationLabelConfiguration.textColor = UIColor.black
                        StatusBarNotificationCenter.showStatusBarNotificationWithMessage(self.notificationTextField.text! + "\(i)", forDuration: TimeInterval(self.durationSlider.value), withNotificationCenterConfiguration: notificationCenterConfiguration, andNotificationLabelConfiguration: notificationLabelConfiguration)
                    }
                    
                })

            }
        }
    }
}

