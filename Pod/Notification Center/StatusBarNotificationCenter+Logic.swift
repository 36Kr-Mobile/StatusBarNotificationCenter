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
    public class func showStatusBarNotificationWithView(_ view: UIView, forDuration duration: TimeInterval, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration) {
        let notification = Notification(view: view, message:nil, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .customView, notificationLabelConfiguration: nil, duration: duration, completionHandler: nil)
        StatusBarNotificationCenter.center.processNotification(notification)
    }
    
    /**
    Show a status bar notification with custom view, you can pass a completion hander to be invoked when the notification is showed, but you must dismiss it yourself
    
    - parameter view:                            the custom view of the notification
    - parameter notificationCenterConfiguration: the notification configuration
    - parameter completionHandler:               the block to be invoked when the notification is being showed
    */
    public class func showStatusBarNotificationWithView(_ view: UIView, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, whenComplete completionHandler: ((Void) -> Void)? = nil) {
        let notification = Notification(view: view, message:nil, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .customView, notificationLabelConfiguration: nil, duration: nil, completionHandler: completionHandler)
        StatusBarNotificationCenter.center.processNotification(notification)
    }

    /**
     Show a status bar notification with a label, and dismiss it automatically
    
    - parameter message:                           the message to be showed
    - parameter duration:                          the showing time of the notification
    - parameter notificationCenterConfiguration:   the notification configuration
    - parameter andNotificationLabelConfiguration: the label configuration
    */
    public class func showStatusBarNotificationWithMessage(_ message: String?, forDuration duration: TimeInterval, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, andNotificationLabelConfiguration notificationLabelConfiguration: NotificationLabelConfiguration) {
        let notification = Notification(view: nil, message:message, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .label, notificationLabelConfiguration: notificationLabelConfiguration, duration: duration, completionHandler: nil)
        StatusBarNotificationCenter.center.processNotification(notification)
    }
    
    /**
    Show a status bar notification with a label, you can pass a completion hander to be invoked when the notification is showed, but you must dismiss it yourself
    
    - parameter message:                           the message to be showed
    - parameter notificationCenterConfiguration:   the notification configuration
    - parameter andNotificationLabelConfiguration: the label configuration
    - parameter completionHandler:               the block to be invoked when the notification is being showed
    */
    public class func showStatusBarNotificationWithMessage(_ message: String?, withNotificationCenterConfiguration notificationCenterConfiguration: NotificationCenterConfiguration, andNotificationLabelConfiguration notificationLabelConfiguration: NotificationLabelConfiguration, whenComplete completionHandler: ((Void) -> Void)? = nil) {
        let notification = Notification(view: nil, message:message, notificationCenterConfiguration: notificationCenterConfiguration, viewSource: .label, notificationLabelConfiguration: notificationLabelConfiguration, duration: nil, completionHandler: completionHandler)
        StatusBarNotificationCenter.center.processNotification(notification)
    }
    
    /**
    A helper method to precess the notification
    
    - parameter notification: the notification to be processed
    */
    func processNotification(_ notification: Notification) {
      notificationQ.async { () -> Void in
        StatusBarNotificationCenter.center.notifications.append(notification)
        StatusBarNotificationCenter.center.showNotification()
      }
    }
  
    /**
    This is the hub of all notifications, just use a semaphore to manage the showing process
    */
    func showNotification() {
        if (self.notificationSemaphore.wait(timeout: DispatchTime.distantFuture) == .success) {
            DispatchQueue.main.sync(execute: { () -> Void in
              if self.notifications.count > 0 {
                let currentNotification = self.notifications.removeFirst()
                
                self.notificationCenterConfiguration = currentNotification.notificationCenterConfiguration
                self.notificationLabelConfiguration = currentNotification.notificationLabelConfiguration
                    self.notificationWindow.resetRootViewController()
                    switch currentNotification.viewSource {
                    case .customView:
                        self.viewSource = .customView
                        
                        if let duration = currentNotification.duration {
                            self.showStatusBarNotificationWithView(currentNotification.view, forDuration: duration)
                        } else {
                            self.showStatusBarNotificationWithView(currentNotification.view, completion: currentNotification.completionHandler)
                        }
                    case .label:
                        self.viewSource = .label
                        
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
  
    func showStatusBarNotificationWithMessage(_ message: String?,completion: (() -> Void)?) {
        
        self.createMessageLabelWithMessage(message)
        self.createSnapshotView()
        notificationWindow.windowLevel = notificationCenterConfiguration.level
        
        if let messageLabel = self.messageLabel {
            self.notificationWindow.rootViewController?.view.addSubview(messageLabel)
            self.notificationWindow.rootViewController?.view.bringSubview(toFront: messageLabel)
        }
        self.notificationWindow.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(StatusBarNotificationCenter.screenOrientationChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        UIView.animate(withDuration: self.animateInLength, animations: { () -> Void in
            self.animateInFrameChange()
            }, completion: { (finished) -> Void in
                let delayInSeconds = self.messageLabel.scrollTime
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    if let completion = completion {
                        completion()
                    }
                })
        })
        
    }
  
    func showStatusBarNotificationWithMessage(_ message: String?, forDuration duration: TimeInterval) {
        self.showStatusBarNotificationWithMessage(message) { () -> Void in
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(duration) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.dismissNotification()
          })
        }
    }
    
    func showStatusBarNotificationWithView(_ view: UIView, completion: ((Void) -> Void)?) {
        
        self.notificationWindow.isHidden = false
        
        self.customView = view
        self.notificationWindow.rootViewController?.view.addSubview(view)
        self.notificationWindow.rootViewController?.view.bringSubview(toFront: view)
        self.createSnapshotView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(StatusBarNotificationCenter.screenOrientationChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        UIView.animate(withDuration: self.animateInLength, animations: { () -> Void in
            self.animateInFrameChange()
            }, completion: { (finished) -> Void in
                completion?()
        })
        
    }
  
    func showStatusBarNotificationWithView(_ view: UIView, forDuration duration: TimeInterval) {
        self.showStatusBarNotificationWithView(view) { () -> Void in
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(duration) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
            self.dismissNotification()
          })
        }
    }
  
    /**
    Dismiss the currently showing notification, and you can pass a completion handler, if you want to dismiss the currently showing notification
    
    - parameter completion: completion handler to invoke when the dismiss procedure finished
    */
    public class func dismissNotificationWithCompletion(_ completion: (() -> Void)?) {
        StatusBarNotificationCenter.center.dismissNotificationWithCompletion(completion)
    }
    
    func dismissNotificationWithCompletion(_ completion: (() -> Void)?) {
        guard notificationCenterConfiguration != nil else { return }
		
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
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
            
            if let completion = completion {
              completion()
            }
            
            self.notificationSemaphore.signal()
        })
    }
  
    func dismissNotification() {
        if self.dismissible {
            self.dismissNotificationWithCompletion(nil)
        }
    }
    
    
    //MARK: - Handle Change
    
    func notificationTapped(_ tapGesture: UITapGestureRecognizer) {
        dismissNotification()
    }
    
    func screenOrientationChanged() {
        switch viewSource {
        case .label:
            messageLabel?.frame = notificationViewFrame
        case .customView:
            customView?.frame = notificationViewFrame
        }
    }
    
    //MARK: - Helper animation state
    
    func animateInFrameChange() {
        let view: UIView?
        switch viewSource {
        case .label:
            view = messageLabel
        case .customView:
            view = customView
        }
        
        view?.frame = notificationViewFrame
        
        switch animateInDirection {
        case .top:
            snapshotView?.frame = notificationViewBottomFrame
        case .left:
            snapshotView?.frame = notificationViewRightFrame
        case .right:
            snapshotView?.frame = notificationViewLeftFrame
        case .bottom:
            snapshotView?.frame = notificationViewTopFrame
        }
    }
    
    func middleFrameChange() {
        switch animateOutDirection {
        case .top:
            snapshotView?.frame = notificationViewBottomFrame
        case .left:
            snapshotView?.frame = notificationViewRightFrame
        case .right:
            snapshotView?.frame = notificationViewLeftFrame
        case .bottom:
            snapshotView?.frame = notificationViewTopFrame
        }
    }
    
    func animateOutFrameChange() {
        let view: UIView?
        switch viewSource {
        case .label:
            view = messageLabel
        case .customView:
            view = customView
        }
        
        snapshotView?.frame = notificationViewFrame
        switch animateOutDirection {
        case .top:
            view?.frame = notificationViewTopFrame
        case .left:
            view?.frame = notificationViewLeftFrame
        case .right:
            view?.frame = notificationViewRightFrame
        case .bottom:
            view?.frame = notificationViewBottomFrame
        }
    }
    
    //MARK: - Helper view creation
    
    func createMessageLabelWithMessage(_ message: String?) {
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
        setupNotificationView(messageLabel)
    }
    
    func setupNotificationView(_ view: UIView?) {
        view?.clipsToBounds = true
        view?.isUserInteractionEnabled = true
		
		if self.dismissible {
			let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StatusBarNotificationCenter.notificationTapped(_:)))
			view?.addGestureRecognizer(tapGesture)
		}
		
        switch animateInDirection {
			case .top:
				view?.frame = notificationViewTopFrame
			case .left:
				view?.frame = notificationViewLeftFrame
			case .right:
				view?.frame = notificationViewRightFrame
			case .bottom:
				view?.frame = notificationViewBottomFrame
        }
    }

    func createSnapshotView() {
        if animationType != .replace { return }
        
        snapshotView = UIView(frame: notificationViewFrame)
        snapshotView!.clipsToBounds = true
        snapshotView!.backgroundColor = UIColor.clear
        
        let view = baseWindow.snapshotView(afterScreenUpdates: true)
        snapshotView!.addSubview(view!)
        notificationWindow.rootViewController?.view.addSubview(snapshotView!)
        notificationWindow.rootViewController?.view.sendSubview(toBack: snapshotView!)
    }
}
