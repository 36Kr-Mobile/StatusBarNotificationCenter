//
//  StatusBarNotificationCenter+Public Interface.swift
//  StatusBarNotification
//
//  Created by Shannon Wu on 9/17/15.
//  Copyright © 2015 Shannon Wu. All rights reserved.
//

import UIKit

// MARK: - Notification center logic
extension StatusBarNotificationCenter {    
    //MARK: - Notification Management
    /**
    Show a status bar notification with custom view, and dismiss it automatically
    
    - parameter view:                            the custom view of the notification
    - parameter duration:                        the showing time of the notification
    - parameter notificationCenterConfiguration: the notification configuration
    */
    public class func showStatusBarNotificationWithView(view: UIView, forDuration duration: NSTimeInterval, withNotificationCenterConfiguration notificationCenterConfiguration: SBNNotificationCenterConfiguration) {
         StatusBarNotificationCenter.center.viewSource = .CustomView
        StatusBarNotificationCenter.center.notificationCenterConfiguration = notificationCenterConfiguration
        StatusBarNotificationCenter.center.showStatusBarNotificationWithView(view, forDuration: duration)
    }
    
    /**
    Show a status bar notification with custom view, you can pass a completion hander to be invoked when the notification is showed, but you must dismiss it yourself
    
    - parameter view:                            the custom view of the notification
    - parameter notificationCenterConfiguration: the notification configuration
    - parameter completionHandler:               the block to be invoked when the notification is being showed
    */
    public class func showStatusBarNotificationWithView(view: UIView, withNotificationCenterConfiguration notificationCenterConfiguration: SBNNotificationCenterConfiguration, whenComplete completionHandler: Void -> Void) {
        StatusBarNotificationCenter.center.viewSource = .CustomView
        StatusBarNotificationCenter.center.notificationCenterConfiguration = notificationCenterConfiguration
        StatusBarNotificationCenter.center.showStatusBarNotificationWithView(view, completion: completionHandler)
    }

    /**
     Show a status bar notification with a label, and dismiss it automatically
    
    - parameter message:                           the message to be showed
    - parameter duration:                          the showing time of the notification
    - parameter notificationCenterConfiguration:   the notification configuration
    - parameter andNotificationLabelConfiguration: the label configuration
    */
    public class func showStatusBarNotificationWithMessage(message: String?, forDuration duration: NSTimeInterval, withNotificationCenterConfiguration notificationCenterConfiguration: SBNNotificationCenterConfiguration, andNotificationLabelConfiguration notificationLabelConfiguration: SBNNotificationLabelConfiguration) {
        StatusBarNotificationCenter.center.viewSource = .Label
        StatusBarNotificationCenter.center.notificationCenterConfiguration = notificationCenterConfiguration
        StatusBarNotificationCenter.center.notificationLabelConfiguration = notificationLabelConfiguration
        StatusBarNotificationCenter.center.showStatusBarNotificationWithMessage(message, forDuration: duration)
    }
    
    /**
    Show a status bar notification with a label, you can pass a completion hander to be invoked when the notification is showed, but you must dismiss it yourself
    
    - parameter message:                           the message to be showed
    - parameter notificationCenterConfiguration:   the notification configuration
    - parameter andNotificationLabelConfiguration: the label configuration
    - parameter completionHandler:               the block to be invoked when the notification is being showed
    */
    public class func showStatusBarNotificationWithMessage(message: String?, withNotificationCenterConfiguration notificationCenterConfiguration: SBNNotificationCenterConfiguration, andNotificationLabelConfiguration notificationLabelConfiguration: SBNNotificationLabelConfiguration, whenComplete completionHandler: Void -> Void) {
        StatusBarNotificationCenter.center.viewSource = .Label
        StatusBarNotificationCenter.center.notificationCenterConfiguration = notificationCenterConfiguration
        StatusBarNotificationCenter.center.notificationLabelConfiguration = notificationLabelConfiguration
        StatusBarNotificationCenter.center.showStatusBarNotificationWithMessage(message, completion: completionHandler)
    }

    
    func showStatusBarNotificationWithMessage(message: String?,completion: (() -> Void)?) {
        viewSource = .Label
        
        if !isShowing {
            isShowing = true
            
            notificationWindow.configureWindowWithBounds(notificationViewFrame)
            createMessageLabelWithMessage(message)
            createSnapshotView()
            
            if let messageLabel = messageLabel {
                notificationWindow.rootViewController?.view.addSubview(messageLabel)
                notificationWindow.rootViewController?.view.bringSubviewToFront(messageLabel)
            }
            notificationWindow.hidden = false
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenOrientationChanged", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
            
            UIView.animateWithDuration(animateInLength, animations: { () -> Void in
                self.animateInFrameChange()
                }, completion: { (finished) -> Void in
                    let delayInSeconds = self.messageLabel.scrollTime
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                        if completion != nil {
                            completion!()
                        }
                    })
            })
        } //else {
//            dismissNotificationWithCompletion({ () -> Void in
//                self.showStatusBarNotificationWithMessage(message, completion: completion)
//            })
//        }
    }
    
    func showStatusBarNotificationWithMessage(message: String?, forDuration duration: NSTimeInterval) {
        showStatusBarNotificationWithMessage(message) { () -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(duration) * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                self.dismissNotification()
            })
        }
    }
    
    func showStatusBarNotificationWithView(view: UIView, completion: () -> Void) {
        if !isShowing {
            isShowing = true
            
            notificationWindow.configureWindowWithBounds(notificationViewFrame)
            
            notificationWindow.hidden = false
            
            customView = view
            notificationWindow.rootViewController?.view.addSubview(view)
            notificationWindow.rootViewController?.view.bringSubviewToFront(view)
            createSnapshotView()
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenOrientationChanged", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
            
            UIView.animateWithDuration(animateInLength, animations: { () -> Void in
                self.animateInFrameChange()
                }, completion: { (finished) -> Void in
                    completion()
            })
        } //else {
//            dismissNotificationWithCompletion({ () -> Void in
//                self.showStatusBarNotificationWithView(view, completion: completion)
//            })
//        }
    }
    
    func showStatusBarNotificationWithView(view: UIView, forDuration duration: NSTimeInterval) {
        showStatusBarNotificationWithView(view) { () -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(duration) * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                self.dismissNotification()
            })
        }
    }
    
    /**
    Dismiss the currently showing notification, and you can pass a completion handler, if you want to dismiss the currently showing notification
    
    - parameter completion: completion handler to invoke when the dismiss procedure finished
    */
    public class func dismissNotificationWithCompletion(completion: (() -> Void)?) {
        StatusBarNotificationCenter.center.dismissNotificationWithCompletion(completion)
    }
    
    func dismissNotificationWithCompletion(completion: (() -> Void)?) {
        if isDismissing && isShowing { return }
        isDismissing = true
        
        self.middleFrameChange()
        UIView.animateWithDuration(animateOutLength, animations: { () -> Void in
            self.animateOutFrameChange()
            }, completion: { (finished) -> Void in
                self.notificationWindow.hidden = true
                self.messageLabel = nil
                self.snapshotView = nil
                self.customView = nil
                
                self.isShowing = false
                self.isDismissing = false
                
                self.notificationLabelConfiguration = nil
                self.notificationCenterConfiguration = nil
                
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
                
                if let completion = completion {
                    completion()
                }
        })
    }
    
    func dismissNotification() {
        if dismissible {
            dismissNotificationWithCompletion(nil)
        }
    }
    
    
    //MARK: - Handle Change
    
    func notificationTapped(tapGesture: UITapGestureRecognizer) {
        dismissNotification()
    }
    
    func screenOrientationChanged() {
        switch viewSource {
        case .Label:
            messageLabel?.frame = notificationViewFrame
        case .CustomView:
            customView?.frame = notificationViewFrame
        }
    }
    
    //MARK: - Helper animation state
    
    func animateInFrameChange() {
        let view: UIView?
        switch viewSource {
        case .Label:
            view = messageLabel
        case .CustomView:
            view = customView
        }
        
        view?.frame = notificationViewFrame
        
        switch animateInDirection {
        case .Top:
            snapshotView?.frame = notificationViewBottomFrame
        case .Left:
            snapshotView?.frame = notificationViewRightFrame
        case .Right:
            snapshotView?.frame = notificationViewLeftFrame
        case .Bottom:
            snapshotView?.frame = notificationViewTopFrame
        }
    }
    
    func middleFrameChange() {
        switch animateOutDirection {
        case .Top:
            snapshotView?.frame = notificationViewBottomFrame
        case .Left:
            snapshotView?.frame = notificationViewRightFrame
        case .Right:
            snapshotView?.frame = notificationViewLeftFrame
        case .Bottom:
            snapshotView?.frame = notificationViewTopFrame
        }
    }
    
    func animateOutFrameChange() {
        let view: UIView?
        switch viewSource {
        case .Label:
            view = messageLabel
        case .CustomView:
            view = customView
        }
        
        snapshotView?.frame = notificationViewFrame
        switch animateOutDirection {
        case .Top:
            view?.frame = notificationViewTopFrame
        case .Left:
            view?.frame = notificationViewLeftFrame
        case .Right:
            view?.frame = notificationViewRightFrame
        case .Bottom:
            view?.frame = notificationViewBottomFrame
        }
    }
    
    //MARK: - Helper view creation
    
    func createMessageLabelWithMessage(message: String?) {
        messageLabel = SBNScrollLabel()
        messageLabel?.text = message
        messageLabel?.textAlignment = .Center
        messageLabel?.font = messageLabelFont
        messageLabel?.numberOfLines = messageLabelMultiline ? 0 : 1
        messageLabel?.textColor = messageLabelTextColor
        messageLabel?.backgroundColor = messageLabelBackgroundColor
        messageLabel?.scrollable = messageLabelScrollable
        messageLabel?.scrollSpeed = messageLabelScrollSpeed
        messageLabel?.scrollDelay = messageLabelScrollDelay
        messageLabel?.padding = messageLabelPadding
        if let messageLabelAttributedText = messageLabelAttributedText {
            messageLabel?.attributedText = messageLabelAttributedText
        }
        setupNotificationView(messageLabel)
    }
    
    func setupNotificationView(view: UIView?) {
        view?.clipsToBounds = true
        view?.userInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "notificationTapped:")
        view?.addGestureRecognizer(tapGesture)
        
        switch animateInDirection {
        case .Top:
            view?.frame = notificationViewTopFrame
        case .Left:
            view?.frame = notificationViewLeftFrame
        case .Right:
            view?.frame = notificationViewRightFrame
        case .Bottom:
            view?.frame = notificationViewBottomFrame
        }
    }

    func createSnapshotView() {
        if animationType != .Replace { return }
        
        snapshotView = UIView(frame: notificationViewFrame)
        snapshotView!.clipsToBounds = true
        snapshotView!.backgroundColor = UIColor.clearColor()
        
        let view = baseWindow.snapshotViewAfterScreenUpdates(true)
        snapshotView!.addSubview(view)
        notificationWindow.rootViewController?.view.addSubview(snapshotView!)
        notificationWindow.rootViewController?.view.sendSubviewToBack(snapshotView!)
    }
}
