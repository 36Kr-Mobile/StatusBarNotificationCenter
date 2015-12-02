//
//  BaseScrollLabel.swift
//  StatusBarNotification
//
//  Created by Shannon Wu on 9/17/15.
//  Copyright © 2015 Shannon Wu. All rights reserved.
//

import UIKit

/// A subclass of UILabel to implement the scrolling trait
class BaseScrollLabel: UILabel {    
    //MARK: - Properties
    
    var messageImage = UIImageView()
    var scrollable: Bool = true
    var scrollSpeed: CGFloat = 40.0
    var scrollDelay: NSTimeInterval = 1.0
    var padding: CGFloat = 10.0
    
    var fullWidth: CGFloat {
        guard let message = text else { return 0 }
        return (message as NSString).sizeWithAttributes([NSFontAttributeName : font]).width
    }
    
    var scrollOffset: CGFloat {
        if (numberOfLines != 1) || !scrollable { return 0 }
        let insetRect = CGRectInset(bounds, padding, 0)
        return max(0, fullWidth - CGRectGetWidth(insetRect))
    }
    
    var scrollTime: NSTimeInterval {
        return (scrollOffset > 0) ? NSTimeInterval(scrollOffset / scrollSpeed) + scrollDelay : 0
    }
    
    override func drawTextInRect(rect: CGRect) {
        var rect = rect
        if scrollOffset > 0 {
            rect.size.width = fullWidth + padding * 2
            
            UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
            super.drawTextInRect(rect)
            messageImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            messageImage.sizeToFit()
            addSubview(messageImage)
            
            UIView.animateWithDuration(scrollTime - scrollDelay, delay: scrollDelay, options: [.BeginFromCurrentState, .CurveEaseInOut], animations: { () -> Void in
                self.messageImage.transform = CGAffineTransformMakeTranslation(-self.scrollOffset, 0)
            }, completion: { (finished) -> Void in
                //
            })
            
        } else {
            messageImage.removeFromSuperview()
            super.drawTextInRect(CGRectInset(rect, padding, padding))
        }
    }
}
