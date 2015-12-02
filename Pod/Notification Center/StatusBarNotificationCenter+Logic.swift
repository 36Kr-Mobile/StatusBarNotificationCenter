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
    public class func showStatusBarNotificationWithView(view: UIView, forDuration duration: NSTimeInterval, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration) {
        let notification = Notification(view: view, message:nil, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .CustomView, notificationLabelConfiguration: nil, duration: duration, completionHandler: nil)
        StatusBarNotificationCenter.center.processNotification(notification)
    }
    
    /**
    Show a status bar notification with custom view, you can pass a completion hander to be invoked when the notification is showed, but you must dismiss it yourself
    
    - parameter view:                            the custom view of the notification
    - parameter notificationCenterConfiguration: the notification configuration
    - parameter completionHandler:               the block to be invoked when the notification is being showed
    */
    public class func showStatusBarNotificationWithView(view: UIView, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, whenComplete completionHandler: (Void -> Void)? = nil) {
        let notification = Notification(view: view, message:nil, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .CustomView, notificationLabelConfiguration: nil, duration: nil, completionHandler: completionHandler)
        StatusBarNotificationCenter.center.processNotification(notification)
    }

    /**
     Show a status bar notification with a label, and dismiss it automatically
    
    - parameter message:                           the message to be showed
    - parameter duration:                          the showing time of the notification
    - parameter notificationCenterConfiguration:   the notification configuration
    - parameter andNotificationLabelConfiguration: the label configuration
    */
    public class func showStatusBarNotificationWithMessage(message: String?, forDuration duration: NSTimeInterval, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, andNotificationLabelConfiguration notificationLabelConfiguration: NotificationLabelConfiguration) {
        let notification = Notification(view: nil, message:message, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .Label, notificationLabelConfiguration: notificationLabelConfiguration, duration: duration, completionHandler: nil)
        StatusBarNotificationCenter.center.processNotification(notification)
    }
    
    /**
    Show a status bar notification with a label, you can pass a completion hander to be invoked when the notification is showed, but you must dismiss it yourself
    
    - parameter message:                           the message to be showed
    - parameter notificationCenterConfiguration:   the notification configuration
    - parameter andNotificationLabelConfiguration: the label configuration
    - parameter completionHandler:               the block to be invoked when the notification is being showed
    */
    public class func showStatusBarNotificationWithMessage(message: String?, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, andNotificationLabelConfiguration notificationLabelConfiguration: NotificationLabelConfiguration, whenComplete completionHandler: (Void -> Void)? = nil) {
        let notification = Notification(view: nil, message:message, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .Label, notificationLabelConfiguration: notificationLabelConfiguration, duration: nil, completionHandler: completionHandler)
        StatusBarNotificationCenter.center.processNotification(notification)
    }
    
    /**
    A helper method to precess the notification
    
    - parameter notification: the notification to be processed
    */
    func processNotification(notification: Notification) {
      dispatch_async(notificationQ) { () -> Void in
        StatusBarNotificationCenter.center.notifications.append(notification)
        StatusBarNotificationCenter.center.showNotification()
      }
    }
  
    /**
    This is the hub of all notifications, just use a semaphore to manage the showing process
    */
    func showNotification() {
        if (dispatch_semaphore_wait(self.notificationSemaphore, DISPATCH_TIME_FOREVER) == 0) {
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
              if self.notifications.count > 0 {
                let currentNotification = self.notifications.removeFirst()
                
                self.notificationCenterConfiguration = currentNotification.notificationCenterConfiguration
                self.notificationLabelConfiguration = currentNotification.notificationLabelConfiguration
                    self.notificationWindow.resetRootViewController()
                    switch currentNotification.viewSource {
                    case .CustomView:
                        self.viewSource = .CustomView
                        
                        if let duration = currentNotification.duration {
                            self.showStatusBarNotificationWithView(currentNotification.view, forDuration: duration)
                        } else {
                            self.showStatusBarNotificationWithView(currentNotification.view, completion: currentNotification.completionHandler)
                        }
                    case .Label:
                        self.viewSource = .Label
                        
                        if let duration = currentNotification.duration {
                            self.showStatusBarNotificationWithMessage(currentNotification.message, forDuration: duration)
                        } else {
                            self.showStatusBarNotificationWithMessage(currentNotification.message, completion: currentNotification.completionHandler)
                        }
                    }
              } else {
                return
              }
            })
        }
    }
  
    func showStatusBarNotificationWithMessage(message: String?,completion: (() -> Void)?) {
        
        self.createMessageLabelWithMessage(message)
        self.createSnapshotView()
        notificationWindow.windowLevel = notificationCenterConfiguration.level
        
        if let messageLabel = self.messageLabel {
            self.notificationWindow.rootViewController?.view.addSubview(messageLabel)
            self.notificationWindow.rootViewController?.view.bringSubviewToFront(messageLabel)
        }
        self.notificationWindow.hidden = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenOrientationChanged", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        
        UIView.animateWithDuration(self.animateInLength, animations: { () -> Void in
            self.animateInFrameChange()
            }, completion: { (finished) -> Void in
                let delayInSeconds = self.messageLabel.scrollTime
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                    if let completion = completion {
                        completion()
                    }
                })
        })
        
    }
  
    func showStatusBarNotificationWithMessage(message: String?, forDuration duration: NSTimeInterval) {
        self.showStatusBarNotificationWithMessage(message) { () -> Void in
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(duration) * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            self.dismissNotification()
          })
        }
    }
    
    func showStatusBarNotificationWithView(view: UIView, completion: (Void -> Void)?) {
        
        self.notificationWindow.hidden = false
        
        self.customView = view
        self.notificationWindow.rootViewController?.view.addSubview(view)
        self.notificationWindow.rootViewController?.view.bringSubviewToFront(view)
        self.createSnapshotView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenOrientationChanged", name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
        
        UIView.animateWithDuration(self.animateInLength, animations: { () -> Void in
            self.animateInFrameChange()
            }, completion: { (finished) -> Void in
                completion?()
        })
        
    }
  
    func showStatusBarNotificationWithView(view: UIView, forDuration duration: NSTimeInterval) {
        self.showStatusBarNotificationWithView(view) { () -> Void in
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
        
        self.middleFrameChange()
        UIView.animateWithDuration(self.animateOutLength, animations: { () -> Void in
          self.animateOutFrameChange()
          }, completion: { (finished) -> Void in
            self.notificationWindow.hidden = true
            self.messageLabel = nil
            self.snapshotView = nil
            self.customView = nil
            
            self.notificationLabelConfiguration = nil
            self.notificationCenterConfiguration = nil
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
            
            if let completion = completion {
              completion()
            }
            
            dispatch_semaphore_signal(self.notificationSemaphore)
        })
    }
  
    func dismissNotification() {
        if self.dismissible {
            self.dismissNotificationWithCompletion(nil)
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
        messageLabel = BaseScrollLabel()
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
