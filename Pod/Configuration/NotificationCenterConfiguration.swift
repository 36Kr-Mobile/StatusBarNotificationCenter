//
//  NotificationCenterConfiguration.swift
//  StatusBarNotification
//
//  Created by Shannon Wu on 9/18/15.
//  Copyright © 2015 Shannon Wu. All rights reserved.
//

import Foundation

/**
*    Customize the overall configuration information of the notification, most of the property's default value is OK for most circumstance, but you can customize it if you want
*/
public struct NotificationCenterConfiguration {
    /// The window below the notification window, you must set this property, or the notification will not work correctly
    var baseWindow: UIWindow
    /// The style of the notification, default to status bar notification
    public var style = StatusBarNotificationCenter.Style.StatusBar
    /// The animation type of the notification, default to overlay
    public var animationType = StatusBarNotificationCenter.AnimationType.Overlay
    /// The animate in direction of the notification, default to top
    public var animateInDirection = StatusBarNotificationCenter.AnimationDirection.Top
    /// The animate out direction of the notification, default to top
    public var animateOutDirection = StatusBarNotificationCenter.AnimationDirection.Top
    /// Whether the user can tap on the notification to dismiss the notification, default to true
    public var dismissible = true
    /// The animate in time of the notification
    public var animateInLength: NSTimeInterval = 0.25
    /// The animate out time of the notification
    public var animateOutLength: NSTimeInterval = 0.25
    /// The height of the notification view, if you want to use a custom height, set the style of the notification to custom, or it will use the status bar and navigation bar height
    public var height: CGFloat = 0
    /// If the status bar is hidden, if it is hidden, the hight of the navigation style notification height is the height of the navigation bar, default to false
    public var statusBarIsHidden: Bool = false
    /// The height of the navigation bar, default to 44.0 points
    public var navigationBarHeight: CGFloat = 44.0
    /// Should allow the user to interact with the content outside the notification
    public var userInteractionEnabled = true
    /// The window level of the notification window
    public var level: CGFloat = UIWindowLevelNormal
  
    /**
    Initializer
    
    - parameter baseWindow: the base window of the notification
    
    - returns: a default NotificationCenterConfiguration instance
    */
    public init(baseWindow: UIWindow) {
        self.baseWindow = baseWindow
    }
}
