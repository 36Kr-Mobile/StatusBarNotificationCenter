//
//  File.swift
//  StatusBarNotification
//
//  Created by Shannon Wu on 9/16/15.
//  Copyright © 2015 Shannon Wu. All rights reserved.
//

import UIKit

/// This is the base class of the notification center object, mainly to define properties
open class StatusBarNotificationCenter: NSObject {
    //MARK: - Initializers
    
    fileprivate override init() {
        super.init()

        notificationWindow.notificationCenter = self
    }
    
    /// The single status bar notification center
    class var center: StatusBarNotificationCenter {
        struct SingletonWrapper {
            static let singleton = StatusBarNotificationCenter()
        }
        return SingletonWrapper.singleton
    }
    
    //MARK: - Snapshoot View
    var snapshotView: UIView?
        
    //MARK: Message Label
    var messageLabel: BaseScrollLabel!
    var messageLabelScrollable: Bool {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.scrollabel
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var messageLabelBackgroundColor: UIColor {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.backgroundColor
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var messageLabelTextColor: UIColor {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.textColor
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var messageLabelMultiline: Bool {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.multiline
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var messageLabelFont: UIFont {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.font
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var messageLabelScrollSpeed: CGFloat {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.scrollSpeed
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var messageLabelScrollDelay: TimeInterval {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.scrollDelay
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var messageLabelPadding: CGFloat {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.padding
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var messageLabelAttributedText: NSAttributedString? {
        if let notificationLabelConfiguration = notificationLabelConfiguration {
            return notificationLabelConfiguration.attributedText
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    /// The default message label font size, default to 14.0 points, if you want to use the default label and want to change its font size, you can use this property to configure it
    static var defaultMessageLabelFontSize: CGFloat = 14
    
    //MARK: Notification View
    var notificationViewWidth: CGFloat {
        return baseWindow.bounds.width
    }
    
    var notificationViewHeight: CGFloat {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.height
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var internalnotificationViewHeight: CGFloat {
        switch notificationStyle {
        case .statusBar:
            return statusBarHeight
        case .navigationBar:
            if statusBarIsHidden {
                return navigationBarHeight
            } else {
                return statusBarHeight + navigationBarHeight
            }
        case .custom:
            return notificationViewHeight
        }
    }

    var notificationViewFrame: CGRect {
        return CGRect(x: 0, y: 0, width: notificationViewWidth, height: internalnotificationViewHeight)
    }
    var notificationViewTopFrame: CGRect {
        return CGRect(x: 0, y: -internalnotificationViewHeight, width: notificationViewWidth, height: internalnotificationViewHeight)
    }
    var notificationViewLeftFrame: CGRect {
        return CGRect(x: -notificationViewWidth, y: 0, width: notificationViewWidth, height: internalnotificationViewHeight)
    }
    var notificationViewRightFrame: CGRect {
        return CGRect(x: notificationViewWidth, y: 0, width: notificationViewWidth, height: internalnotificationViewHeight)
    }
    var notificationViewBottomFrame: CGRect {
        return CGRect(x: 0, y: internalnotificationViewHeight, width: notificationViewWidth, height: 0)
    }
        
    //MARK: Custom View
    var viewSource: ViewSource = .label
    var customView: UIView? {
        didSet {
            if customView != nil {
                setupNotificationView(customView)
            }
        }
    }

    //MARK: Status Bar
    var statusBarIsHidden: Bool = false
    var statusBarHeight: CGFloat {
        return 20.0
    }
    
    //MARK: Navigation Bar
    var navigationBarHeight: CGFloat {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.navigationBarHeight
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    
    //MARK: Animation Parameter
    var notificationStyle: Style {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.style
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var animateInDirection: AnimationDirection {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.animateInDirection
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var animateOutDirection: AnimationDirection {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.animateOutDirection
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var animationType: AnimationType {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.animationType
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    
    //MARK: - Window
    let notificationWindow = BaseWindow(frame: UIScreen.main.bounds)
    
    var baseWindow: UIWindow {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.baseWindow
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    
    //MARK: - Notification
    var notificationCenterConfiguration: NotificationCenterConfiguration!
    var notificationLabelConfiguration: NotificationLabelConfiguration!

    var dismissible: Bool {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.dismissible
        } else {
            return false
        }
    }
    var animateInLength: TimeInterval {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.animateInLength
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    var animateOutLength: TimeInterval {
        if let notificationCenterConfiguration = notificationCenterConfiguration {
            return notificationCenterConfiguration.animateOutLength
        } else {
            fatalError("Cannot reach this branch")
        }
    }
    
    //MARK: - Notification Queue Management
    /// A notification array
    var notifications = [Notification]()
    /// Create a notification Queue to track the notifications
    let notificationQ = DispatchQueue(label: "notificationQueue", attributes: [])
    /// Create a semaphore to show the notification in a one-after one basis
    let notificationSemaphore = DispatchSemaphore(value: 1)


    //MARK: - User Interaction

    var userInteractionEnabled: Bool {
        return notificationCenterConfiguration.userInteractionEnabled
    }
}
