//
//  SBNWindow.swift
//  StatusBarNotification
//
//  Created by Shannon Wu on 9/17/15.
//  Copyright © 2015 Shannon Wu. All rights reserved.
//

import UIKit

/// The window of the notification center
class SBNWindow: UIWindow {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        userInteractionEnabled = true
        windowLevel = UIWindowLevelStatusBar
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWindowWithBounds(bounds: CGRect) {
        rootViewController = SBNViewController()
        rootViewController?.view.clipsToBounds = true
        rootViewController?.view.bounds = bounds
    }
}
