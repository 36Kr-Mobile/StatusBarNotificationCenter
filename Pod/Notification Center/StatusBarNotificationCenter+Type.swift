//
//  StatusBarNotification+Type.swift
//  StatusBarNotification
//
//  Created by Shannon Wu on 9/15/15.
//  Copyright © 2015 Shannon Wu. All rights reserved.
//

import UIKit

// MARK: - Notification center types
extension StatusBarNotificationCenter {
    //MARK: - Types
    
    /**
    Notification Style
    - StatusBar:     Covers the status bar portion of the screen
    - NavigationBar: Covers the status bar and navigation bar portions of the screen
    */
    public enum Style: NSInteger {
        /**
        *  Covers the statusbar portion of the screen, if the status bar is hidden, cover the status bar height of the screen
        */
        case statusBar
        /**
        *  Covers the status bar and navigation bar portion of the screen
        */
        case navigationBar
        /**
        *  Cover part of the screen, based on the height of the configuration
        */
        case custom
    }
    
    /**
    The direction of animation for the notification
    
    - Top:    Animate in from the top or animate out to the top
    - Bottom: Animate in from the bottom or animate out to the bottom
    - Left:   Animate in from the left or animate out to the left
    - Right:  Animate in from the right or animate out to the right
    */
    public enum AnimationDirection: NSInteger {
        /**
        *  Animate in from the top or animate out to the top
        */
        case top
        /**
        *  Animate in from the bottom or animate out to the bottom
        */
        case bottom
        /**
        *  Animate in from the left or animate out to the left
        */
        case left
        /**
        *  Animate in from the right or animate out to the right
        */
        case right
    }
    
    /**
    Determines whether the notification moves the existing content out of the way or simply overlays it.
    
    - Replace: Moves existing content out of the way
    - Overlay: Ovelays existing content
    */
    public enum AnimationType: NSInteger {
        /**
        *  Moves existing content out of the way
        */
        case replace
        /**
        *  Ovelays existing content
        */
        case overlay
    }
    
    /**
    The view source of the notification
    
    - CustomView: Use a custom view to show the notification
    - Label:      Use the default label to show the notification
    */
    enum ViewSource: NSInteger {
        /**
        *    Use a custom view to show the notification
        */
        case customView
        /**
        *    Use the default label to show the notification
        */
        case label
    }
    
    /**
    *  This is the base element of the notification queue
    */
    struct Notification {
        /// This is the notification center configuration object
        let notificationCenterConfiguration: NotificationCenterConfiguration
        /// This the notification label configuration object
        let notificationLabelConfiguration: NotificationLabelConfiguration?
        /// This is the duration of the notification
        let duration: TimeInterval?
        /// The view source of the notification
        let viewSource: ViewSource
        /// The view of the notification, if the view  source is a custom view
        let view: UIView!
        /// The completion handler to be called when the show process is done
        let completionHandler: (() -> Void)?
        /// The message of the notification, if the view  source is a label
        let message: String!

      
        /**
        Init a new notification object
        
        - parameter notificationCenterConfiguration: This is the notification center configuration object
        - parameter viewSource:                      The view source of the notification
        - parameter notificationLabelConfiguration:  This the notification label configuration object
        - parameter duration:                        This is the duration of the notification
        - parameter completionHandler:               The completion handler to be called when the show process is done

        - returns: a newly initialtiated notification
        */
        init(view: UIView?, message: String?, notificationCenterConfiguration: NotificationCenterConfiguration, viewSource: ViewSource, notificationLabelConfiguration:NotificationLabelConfiguration?, duration: TimeInterval?, completionHandler: (() -> Void)?) {
            self.view = view
            self.message = message
            self.notificationCenterConfiguration = notificationCenterConfiguration
            self.notificationLabelConfiguration = notificationLabelConfiguration
            self.duration = duration
            self.viewSource = viewSource
            self.completionHandler = completionHandler
        }
  }
}
