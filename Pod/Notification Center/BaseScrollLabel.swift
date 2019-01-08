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
    var scrollDelay: TimeInterval = 1.0
    var padding: CGFloat = 10.0
    
    var fullWidth: CGFloat {
        guard let message = text else { return 0 }
        return (message as NSString).size(withAttributes: [NSAttributedString.Key.font : font]).width
    }
    
    var scrollOffset: CGFloat {
        if (numberOfLines != 1) || !scrollable { return 0 }
        let insetRect = bounds.insetBy(dx: padding, dy: 0)
        return max(0, fullWidth - insetRect.width)
    }
    
    var scrollTime: TimeInterval {
        return (scrollOffset > 0) ? TimeInterval(scrollOffset / scrollSpeed) + scrollDelay : 0
    }
    
    override func drawText(in rect: CGRect) {
        var rect = rect
        if scrollOffset > 0 {
            rect.size.width = fullWidth + padding * 2
            
            UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
            super.drawText(in: rect)
            messageImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            messageImage.sizeToFit()
            addSubview(messageImage)
            
            UIView.animate(withDuration: scrollTime - scrollDelay, delay: scrollDelay, options: [.beginFromCurrentState, .curveEaseIn, .curveEaseOut], animations: { () -> Void in
                self.messageImage.transform = CGAffineTransform(translationX: -self.scrollOffset, y: 0)
            }, completion: { (finished) -> Void in
                //
            })
            
        } else {
            messageImage.removeFromSuperview()
            super.drawText(in: rect.insetBy(dx: padding, dy: padding))
        }
    }
}
