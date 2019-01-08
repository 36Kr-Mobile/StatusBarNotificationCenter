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
    public class func showStatusBarNotificationWithView(view: UIView, forDuration duration: TimeInterval, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration) {
        let notification = Notification(view: view, message:nil, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .CustomView, notificationLabelConfiguration: nil, duration: duration, completionHandler: nil)
        StatusBarNotificationCenter.center.processNotification(notification: notification)
    }
    
    /**
    Show a status bar notification with custom view, you can pass a completion hander to be invoked when the notification is showed, but you must dismiss it yourself
    
    - parameter view:                            the custom view of the notification
    - parameter notificationCenterConfiguration: the notification configuration
    - parameter completionHandler:               the block to be invoked when the notification is being showed
    */
    public class func showStatusBarNotificationWithView(view: UIView, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, whenComplete completionHandler: (() -> Void)? = nil) {
        let notification = Notification(view: view, message:nil, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .CustomView, notificationLabelConfiguration: nil, duration: nil, completionHandler: completionHandler)
        StatusBarNotificationCenter.center.processNotification(notification: notification)
    }

    /**
     Show a status bar notification with a label, and dismiss it automatically
    
    - parameter message:                           the message to be showed
    - parameter duration:                          the showing time of the notification
    - parameter notificationCenterConfiguration:   the notification configuration
    - parameter andNotificationLabelConfiguration: the label configuration
    */
    public class func showStatusBarNotificationWithMessage(message: String?, forDuration duration: TimeInterval, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, andNotificationLabelConfiguration notificationLabelConfiguration: NotificationLabelConfiguration) {
        let notification = Notification(view: nil, message:message, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .Label, notificationLabelConfiguration: notificationLabelConfiguration, duration: duration, completionHandler: nil)
        StatusBarNotificationCenter.center.processNotification(notification: notification)
    }
    
    /**
    Show a status bar notification with a label, you can pass a completion hander to be invoked when the notification is showed, but you must dismiss it yourself
    
    - parameter message:                           the message to be showed
    - parameter notificationCenterConfiguration:   the notification configuration
    - parameter andNotificationLabelConfiguration: the label configuration
    - parameter completionHandler:               the block to be invoked when the notification is being showed
    */
    public class func showStatusBarNotificationWithMessage(message: String?, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, andNotificationLabelConfiguration notificationLabelConfiguration: NotificationLabelConfiguration, whenComplete completionHandler: (() -> Void)? = nil) {
        let notification = Notification(view: nil, message:message, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .Label, notificationLabelConfiguration: notificationLabelConfiguration, duration: nil, completionHandler: completionHandler)
        StatusBarNotificationCenter.center.processNotification(notification: notification)
    }
    
    /**
    A helper method to precess the notification
    
    - parameter notification: the notification to be processed
    */
    func processNotification(notification: Notification) {
      notificationQ.async() { () -> Void in
        StatusBarNotificationCenter.center.notifications.append(notification)
        StatusBarNotificationCenter.center.showNotification()
      }
    }
  
    /**
    This is the hub of all notifications, just use a semaphore to manage the showing process
    */
    func showNotification() {
        if (self.notificationSemaphore.wait(timeout: DispatchTime.distantFuture) == DispatchTimeoutResult.success) {
            DispatchQueue.main.sync{ () -> Void in
              if self.notifications.count > 0 {
                let currentNotification = self.notifications.removeFirst()
                
                self.notificationCenterConfiguration = currentNotification.notificationCenterConfiguration
                self.notificationLabelConfiguration = currentNotification.notificationLabelConfiguration
                    self.notificationWindow.resetRootViewController()
                    switch currentNotification.viewSource {
                    case .CustomView:
                        self.viewSource = .CustomView
                        
                        if let duration = currentNotification.duration {
                            self.showStatusBarNotificationWithView(view:currentNotification.view, forDuration: duration)
                        } else {
                            self.showStatusBarNotificationWithView(view:currentNotification.view, completion: currentNotification.completionHandler)
                        }
                    case .Label:
                        self.viewSource = .Label
                        
                        if let duration = currentNotification.duration {
                            self.showStatusBarNotificationWithMessage(message:currentNotification.message, forDuration: duration)
                        } else {
                            self.showStatusBarNotificationWithMessage(message:currentNotification.message, completion: currentNotification.completionHandler)
                        }
                    }
              } else {
                return
              }
            }
        }
    }
  
    func showStatusBarNotificationWithMessage(message: String?,completion: (() -> Void)?) {
        
        self.createMessageLabelWithMessage(message: message)
        self.createSnapshotView()
        notificationWindow.windowLevel = UIWindow.Level(rawValue: notificationCenterConfiguration.level)
        
        if let messageLabel = self.messageLabel {
            self.notificationWindow.rootViewController?.view.addSubview(messageLabel)
            self.notificationWindow.rootViewController?.view.bringSubviewToFront(messageLabel)
        }
        self.notificationWindow.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(StatusBarNotificationCenter.screenOrientationChanged), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        
        UIView.animate(withDuration: self.animateInLength, animations: { () -> Void in
            self.animateInFrameChange()
            }, completion: { (finished) -> Void in
                let delayInSeconds = self.messageLabel.scrollTime
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(delayInSeconds) * Double(NSEC_PER_SEC)) {
                    if let completion = completion {
                        completion()
                    }
                }
        })
        
    }
  
    func showStatusBarNotificationWithMessage(message: String?, forDuration duration: TimeInterval) {
        self.showStatusBarNotificationWithMessage(message: message) { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration) * Double(NSEC_PER_SEC)) {
                 self.dismissNotification()
            }
        }
    }
    
    func showStatusBarNotificationWithView(view: UIView, completion: (() -> Void)?) {
        
        self.notificationWindow.isHidden = false
        
        self.customView = view
        self.notificationWindow.rootViewController?.view.addSubview(view)
        self.notificationWindow.rootViewController?.view.bringSubviewToFront(view)
        self.createSnapshotView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(StatusBarNotificationCenter.screenOrientationChanged), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        
        UIView.animate(withDuration: self.animateInLength, animations: { () -> Void in
            self.animateInFrameChange()
            }, completion: { (finished) -> Void in
                completion?()
        })
        
    }
  
    func showStatusBarNotificationWithView(view: UIView, forDuration duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration) * Double(NSEC_PER_SEC)) {
            self.dismissNotification()
        }
    }
  
    /**
    Dismiss the currently showing notification, and you can pass a completion handler, if you want to dismiss the currently showing notification
    
    - parameter completion: completion handler to invoke when the dismiss procedure finished
    */
    public class func dismissNotificationWithCompletion(completion: (() -> Void)?) {
        StatusBarNotificationCenter.center.dismissNotificationWithCompletion(completion: completion)
    }
    
    func dismissNotificationWithCompletion(completion: (() -> Void)?) {
        
        self.middleFrameChange()
        UIView.animate(withDuration: self.animateOutLength, animations: { () -> Void in
          self.animateOutFrameChange()
          }, completion: { (finished) -> Void in
            self.notificationWindow.isHidden = true
            self.messageLabel = nil
            self.snapshotView = nil
            self.customView = nil
            
            self.notificationLabelConfiguration = nil
            self.notificationCenterConfiguration = nil
            
            NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
            
            if let completion = completion {
              completion()
            }
            
            self.notificationSemaphore.signal()
        })
    }
  
    func dismissNotification() {
        if self.dismissible {
            self.dismissNotificationWithCompletion(completion: nil)
        }
    }
    
    
    //MARK: - Handle Change
    
    @objc func notificationTapped(tapGesture: UITapGestureRecognizer) {
        dismissNotification()
    }
    
    @objc func screenOrientationChanged() {
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
        messageLabel?.textAlignment = .center
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
        setupNotificationView(view: messageLabel)
    }
    
    func setupNotificationView(view: UIView?) {
        view?.clipsToBounds = true
        view?.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StatusBarNotificationCenter.notificationTapped(tapGesture:)))
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
        snapshotView!.backgroundColor = UIColor.clear
        
        if let view = baseWindow.snapshotView(afterScreenUpdates: true) {
        snapshotView!.addSubview(view)
        notificationWindow.rootViewController?.view.addSubview(snapshotView!)
        notificationWindow.rootViewController?.view.sendSubviewToBack(snapshotView!)
}
    }
}
