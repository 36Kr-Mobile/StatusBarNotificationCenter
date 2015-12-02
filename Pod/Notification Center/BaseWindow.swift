//
//  BaseWindow.swift
//  StatusBarNotification
//
//  Created by Shannon Wu on 9/17/15.
//  Copyright © 2015 Shannon Wu. All rights reserved.
//

import UIKit

/// The window of the notification center
class BaseWindow: UIWindow {
    weak var notificationCenter: StatusBarNotificationCenter!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = true
        hidden = true
        windowLevel = UIWindowLevelNormal
        rootViewController = BaseViewController()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetRootViewController() {
      if let rootViewController = rootViewController as? BaseViewController {
        for view in rootViewController.view.subviews {
          view.removeFromSuperview()
        }
      }
    }

    override func hitTest(pt: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if pt.y > 0 && pt.y < (notificationCenter.internalnotificationViewHeight) {
                return super.hitTest(pt, withEvent: event)
        }
        return nil
    }
}
