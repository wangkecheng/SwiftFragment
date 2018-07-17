//
//  Toast.swift
//  ToastDemo
//
//  Created by 王帅 on 2018/7/13.
//  Copyright © 2018 王帅. All rights reserved.
//

import Foundation
import UIKit

var CSToastPositionTop  = "CSToastPositionTop"
var CSToastPositionCenter    = "CSToastPositionCenter"
var CSToastPositionBottom    = "CSToastPositionBottom"

// Keys for values associated with toast views
var CSToastTimerKey             = "CSToastTimerKey"
var CSToastDurationKey          = "CSToastDurationKey"
var CSToastPositionKey          = "CSToastPositionKey"
var CSToastCompletionKey        = "CSToastCompletionKey"

// Keys for values associated with self
var CSToastActiveToastViewKey   = "CSToastActiveToastViewKey"
var CSToastActivityViewKey      = "CSToastActivityViewKey"
var CSToastQueueKey             = "CSToastQueueKey"

extension UIView{
    // Queue
    
    func cs_toastQueue() -> NSMutableArray {
        var queue = objc_getAssociatedObject(self, &CSToastQueueKey)
        if  queue == nil {
            queue = NSMutableArray.init()
            objc_setAssociatedObject(self, &CSToastQueueKey, queue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return queue as! NSMutableArray
    }
    
    func makeToast(message:NSString?) -> () {
        self.makeToast(message: message, duration: CSToastManager.shareedManager().defaultDuration, position:CSToastManager.shareedManager().defaultPosition, style: Optional.none)
    }
    func makeToast(message:NSString?,duration:TimeInterval?) {
        self.makeToast(message: message, duration: duration, position: CSToastManager.shareedManager().defaultPosition)
    }
    
    func makeToast(message:NSString?,duration:TimeInterval?,position:AnyObject?) {
        self.makeToast(message: message, duration: duration, position: position, style:Optional.none)
    }
    func makeToast(message:NSString?,duration:TimeInterval?,position:AnyObject?,style:CSToastStyle?) {
        let toast:UIView = self.toastViewForMessage(message: message!, title: Optional.none, image: Optional.none, style: style)
        self.showToast(toast: toast, duration: duration, position: position, completion: nil)
    }
    func makeToast(message:NSString?,duration:TimeInterval?,position:AnyObject?,title:NSString?,image:UIImage?,style:CSToastStyle?,completion: ((_ didTap:Bool)->())?) {
        let toast:UIView = self.toastViewForMessage(message: message, title:Optional.none, image:image, style: style)
        self.showToast(toast: toast, duration: duration, position: position, completion: completion )
    }
    func showToast(toast:UIView?,duration:TimeInterval?,position:AnyObject?,completion: ((_ didTap:Bool)->())?)  {
        if  toast == nil {
            return
        }
        
        // store the completion block on the toast view
        objc_setAssociatedObject(toast!, &CSToastCompletionKey, completion, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if  CSToastManager.shareedManager().queueEnabled! && objc_getAssociatedObject(self, &CSToastActiveToastViewKey) != nil {
            // we're about to queue this toast view so we need to store the duration and position as well
            objc_setAssociatedObject(toast!, &CSToastDurationKey, duration, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(toast!, &CSToastPositionKey, position, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // enqueue
            self.cs_toastQueue().add(toast!)
        } else {
            // present
            self.cs_showToast(toast: toast, duration: duration, position: position)
        }
    }
    
    //View Construction
    func toastViewForMessage(message:NSString?,title:NSString?,image:UIImage?, style:CSToastStyle?) -> UIView {
        // sanity
        var style = style
        if message == nil && title == nil && image == nil{
            return Optional.none!
        }
        if style == nil{
            style = CSToastManager.shareedManager().sharedStyle!
        }
        // dynamically build a toast view with any combination of message, title, & image
        var messageLabel:UILabel? = nil
        let titleLabel:UILabel?   = nil
        var imageView:UIImageView?  = nil
        
        let wrapperView:UIView   = UIView.init()
        wrapperView.autoresizingMask =   UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleLeftMargin.rawValue |
            UIViewAutoresizing.flexibleRightMargin.rawValue |
            UIViewAutoresizing.flexibleTopMargin.rawValue |
            UIViewAutoresizing.flexibleBottomMargin.rawValue)
      
        wrapperView.layer.cornerRadius = (style?.cornerRadius!)!
        
        if (style?.displayShadow)! {
            wrapperView.layer.shadowColor = style?.shadowColor?.cgColor
            wrapperView.layer.shadowOpacity = (style?.shadowOpacity!)!
            wrapperView.layer.shadowRadius = (style?.shadowRadius!)!
            wrapperView.layer.shadowOffset = (style?.shadowOffset!)!
        }
        
        wrapperView.backgroundColor = style?.backgroundColor;
        
        if(image != nil) {
            imageView = UIImageView .init(image: image)
            imageView?.contentMode = UIViewContentMode.scaleAspectFit
            imageView?.frame = CGRect.init(x: (style?.horizontalPadding!)!, y: (style?.verticalPadding!)!, width:(style?.imageSize?.width)!, height:  (style?.imageSize?.height)!)
        }
        
        var imageRect:CGRect  = CGRect.zero
        
        if imageView != nil {
            imageRect.origin.x = (style?.horizontalPadding!)!
            imageRect.origin.y = (style?.verticalPadding!)!
            imageRect.size.width = (imageView?.bounds.size.width)!
            imageRect.size.height = (imageView?.bounds.size.height)!
        }
        
        if title != nil {
            let  titleLabel:UILabel = UILabel.init()
            titleLabel.numberOfLines = (style?.titleNumberOfLines!)!
            titleLabel.font = style?.titleFont
            titleLabel.textAlignment = (style?.titleAlignment!)!
            titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            titleLabel.textColor = style?.titleColor
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.alpha = 1.0
            titleLabel.text = title as String?
            
            // size the title label according to the length of the text
            let maxSizeTitle:CGSize  = CGSize.init(width: (self.bounds.size.width * style!.maxWidthPercentage!) - imageRect.size.width, height: self.bounds.size.height * style!.maxHeightPercentage!)
            var expectedSizeTitle:CGSize  = titleLabel.sizeThatFits(maxSizeTitle)
            // UILabel can return a size larger than the max size when the number of lines is 1
            expectedSizeTitle = CGSize.init(width: min(maxSizeTitle.width, expectedSizeTitle.width), height: expectedSizeTitle.height)
            titleLabel.frame = CGRect.init(x: 0.0, y: 0.0, width: expectedSizeTitle.width, height: expectedSizeTitle.height)
        }
        
        if message != nil {
            messageLabel = UILabel.init()
            messageLabel?.numberOfLines = (style?.messageNumberOfLines!)!
            messageLabel?.font = style?.messageFont
            messageLabel?.textAlignment = (style?.messageAlignment!)!
            messageLabel?.lineBreakMode =  NSLineBreakMode.byTruncatingTail
            messageLabel?.textColor = style?.messageColor
            messageLabel?.backgroundColor =  UIColor.clear
            messageLabel?.alpha = 1.0
            messageLabel?.text = message as? String
            
            let maxSizeMessage:CGSize  = CGSize.init(width: (self.bounds.size.width * style!.maxWidthPercentage!) - imageRect.size.width, height: self.bounds.size.height * style!.maxHeightPercentage!)
            var expectedSizeMessage:CGSize  = (messageLabel?.sizeThatFits(maxSizeMessage))!
            // UILabel can return a size larger than the max size when the number of lines is 1
            expectedSizeMessage = CGSize.init(width: min(maxSizeMessage.width, expectedSizeMessage.width), height: min(maxSizeMessage.height, expectedSizeMessage.height))
            messageLabel?.frame = CGRect.init(x: 0.0, y: 0.0, width: expectedSizeMessage.width, height: expectedSizeMessage.height)
        }
        
        var titleRect:CGRect  = CGRect.zero
        
        if titleLabel != nil {
            titleRect.origin.x = imageRect.origin.x + imageRect.size.width + (style?.horizontalPadding!)!
            titleRect.origin.y = (style?.verticalPadding!)!
            titleRect.size.width = (titleLabel?.bounds.size.width)!
            titleRect.size.height = (titleLabel?.bounds.size.height)!
        }
        
        var messageRect:CGRect  = CGRect.zero
        
        if messageLabel != nil {
            messageRect.origin.x = imageRect.origin.x + imageRect.size.width + (style?.horizontalPadding!)!
            messageRect.origin.y = titleRect.origin.y + titleRect.size.height + (style?.verticalPadding!)!
            messageRect.size.width = (messageLabel?.bounds.size.width)!
            messageRect.size.height = (messageLabel?.bounds.size.height)!
        }
        
        let longerWidth:CGFloat  = max(titleRect.size.width, messageRect.size.width)
        let longerX:CGFloat  = max(titleRect.origin.x, messageRect.origin.x)
        
        // Wrapper width uses the longerWidth or the image width, whatever is larger. Same logic applies to the wrapper height.
        let wrapperWidth:CGFloat  = max((imageRect.size.width + (style!.horizontalPadding! * 2.0)), (longerX + longerWidth + style!.horizontalPadding!))
        let wrapperHeight:CGFloat  = max((messageRect.origin.y + messageRect.size.height + style!.verticalPadding!),(imageRect.size.height + (style!.verticalPadding! * 2.0)))
        
        wrapperView.frame = CGRect.init(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        if titleLabel != nil {
            titleLabel?.frame = titleRect
            wrapperView.addSubview(titleLabel!)
        }
        
        if(messageLabel != nil) {
            messageLabel?.frame = messageRect
            wrapperView.addSubview(messageLabel!)
        }
        
        if(imageView != nil) {
            wrapperView.addSubview(imageView!)
        }
        
        return wrapperView
    }
    func cs_hideToast(toast:UIView?) {
        self.cs_hideToast(toast:toast, fromTap: false)
    }
    func cs_hideToast(toast:UIView?,fromTap:Bool?) {
        UIView.animate(withDuration: (CSToastManager.shareedManager().sharedStyle?.fadeDuration)!, delay: 0.0, options: UIViewAnimationOptions(rawValue: UIViewAnimationOptions.curveEaseIn.rawValue | UIViewAnimationOptions.beginFromCurrentState.rawValue), animations: {
            toast?.alpha = 0.0
        }) { (finished:Bool) in
            toast?.removeFromSuperview()
            // clear the active toast
            objc_setAssociatedObject(self, &CSToastActiveToastViewKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            
            // execute the completion block, if necessary
            var completion:((_ didTap:Bool)->())?
            completion = objc_getAssociatedObject(toast!, &CSToastCompletionKey) as? ((Bool) -> ())
            
            if completion != nil {
                completion!(fromTap!);
            }
            
            if self.cs_toastQueue().count > 0 {
                // dequeue
                
                let nextToast:UIView   = self.cs_toastQueue().firstObject as! UIView
                self.cs_toastQueue().removeObject(at: 0)
                // present the next toast
                let  duration:TimeInterval  =
                    objc_getAssociatedObject(nextToast, &CSToastDurationKey) as! TimeInterval
                let position:AnyObject  = objc_getAssociatedObject(nextToast, &CSToastPositionKey) as AnyObject
                self.cs_showToast(toast: nextToast, duration: duration, position: position)
            }
        }
    }
    
    @objc func cs_handleToastTapped(recognizer:UITapGestureRecognizer) {
        
        let toast:UIView  = recognizer.view!
        let timer:Timer  =  objc_getAssociatedObject(toast, &CSToastTimerKey) as! Timer
        timer.invalidate()
        self.cs_hideToast(toast: toast, fromTap: true)
    }
    
    // Events
    @objc func cs_toastTimerDidFinish(timer:Timer) {
        self.cs_hideToast(toast: (timer.userInfo as! UIView))
    }
    //Private Show/Hide Methods
    func cs_showToast(toast:UIView?,duration:TimeInterval?,position:AnyObject?) {
        toast?.center = self.cs_centerPointForPosition(point: position, withToast: toast)
        toast?.alpha = 0.0;
        if CSToastManager.shareedManager().tapToDismissEnabled! {
            let recognizer:UITapGestureRecognizer  = UITapGestureRecognizer.init(target: self, action: #selector(self.cs_handleToastTapped(recognizer:)))
            
            toast?.addGestureRecognizer(recognizer)
            toast?.isUserInteractionEnabled = true
            toast?.isExclusiveTouch = true
        }
        
        // set the active toast
        objc_setAssociatedObject(self, &CSToastActiveToastViewKey, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.addSubview(toast!)
        
        UIView.animate(withDuration: (CSToastManager.shareedManager().sharedStyle?.fadeDuration)!, delay: 0.0, options:UIViewAnimationOptions(rawValue: UIViewAnimationOptions.curveEaseOut.rawValue|UIViewAnimationOptions.allowUserInteraction.rawValue) , animations: {
            toast?.alpha = 1.0
        }, completion: { (finished:Bool) in
            let timer:Timer = Timer.init(timeInterval: duration!, target: self, selector:#selector(self.cs_toastTimerDidFinish(timer:)), userInfo: toast, repeats: false) //
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            objc_setAssociatedObject(toast!, &CSToastTimerKey, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        })
    }
    
    // Activity Methods
    func makeToastActivity(position:AnyObject?) {
        
        let existingActivityView   =  objc_getAssociatedObject(self, &CSToastActivityViewKey)
        if (existingActivityView != nil){
            return
        }
        let style = CSToastManager.shareedManager().sharedStyle!
        
        let activityView:UIView   =  UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: (style.activitySize?.width)!, height: style.activitySize!.height))
        
        activityView.center = self.cs_centerPointForPosition(point: position, withToast: activityView)
        activityView.backgroundColor = style.backgroundColor
        activityView.alpha = 0.0
        activityView.autoresizingMask =   UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleLeftMargin.rawValue |
            UIViewAutoresizing.flexibleRightMargin.rawValue |
            UIViewAutoresizing.flexibleTopMargin.rawValue |
            UIViewAutoresizing.flexibleBottomMargin.rawValue)
       
        activityView.layer.cornerRadius = style.cornerRadius!;
        
        if style.displayShadow! {
            activityView.layer.shadowColor = style.shadowColor?.cgColor;
            activityView.layer.shadowOpacity = style.shadowOpacity!;
            activityView.layer.shadowRadius = style.shadowRadius!;
            activityView.layer.shadowOffset = style.shadowOffset!;
        }
        
        let activityIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicatorView.center = CGPoint.init(x:activityView.bounds.size.width / 2, y:activityView.bounds.size.height / 2);
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        // associate the activity view with self
        objc_setAssociatedObject (self, &CSToastActivityViewKey, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.addSubview(activityView)
        UIView.animate(withDuration: style.fadeDuration!, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            activityView.alpha = 1.0;
        }, completion: nil)
    }
    
    func hideToastActivity() {
        let existingActivityView = objc_getAssociatedObject(self, &CSToastActivityViewKey)
        if (existingActivityView != nil) {
            UIView.animate(withDuration: (CSToastManager.shareedManager().sharedStyle?.fadeDuration)!, delay: 0.0, options: UIViewAnimationOptions(rawValue:UIViewAnimationOptions.curveEaseIn.rawValue|UIViewAnimationOptions.beginFromCurrentState.rawValue), animations: {
                (existingActivityView as! UIView).alpha = 0.0;
            }, completion: { (finished:Bool) in
                (existingActivityView as! UIView).removeFromSuperview() ;
                objc_setAssociatedObject (self, &CSToastActivityViewKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC);
            })
        }
    }
    //Helpers
    func cs_centerPointForPosition(point:AnyObject?, withToast toast:UIView?) -> CGPoint {
        let style:CSToastStyle =  CSToastManager.shareedManager().sharedStyle!;
        if point is String {
            
            if point?.caseInsensitiveCompare(CSToastPositionTop)  == ComparisonResult.orderedSame{
                return CGPoint.init(x: self.bounds.size.width/2, y: (toast!.frame.size.height / 2) + style.verticalPadding!)
            }
            else if point?.caseInsensitiveCompare(CSToastPositionCenter) == ComparisonResult.orderedSame{
                return CGPoint.init(x:self.bounds.size.width / 2, y:self.bounds.size.height / 2);
            }
        }else if point is NSValue{
            return point!.cgPointValue
        }
        
        // default to bottom
        return CGPoint.init(x: self.bounds.size.width/2.0, y: (self.bounds.size.height - (toast!.frame.size.height / 2)) - style.verticalPadding!)
    }
    
}
class CSToastStyle:NSObject{
    
    /**
     The background color. Default is `[UIColor blackColor]` at 80% opacity.
     */
    var backgroundColor:UIColor? = UIColor.black.withAlphaComponent(0.8);
    
    /**
     The title color. Default is `[UIColor whiteColor]`.
     */
    var titleColor:UIColor?  = UIColor.white;
    
    /**
     The message color. Default is `[UIColor whiteColor]`.
     */
    var messageColor:UIColor? = UIColor.white ;
    
    /**
     A percentage value from 0.0 to 1.0, representing the maximum width of the toast
     view relative to it's superview. Default is 0.8 (80% of the superview's width).
     */
    var maxWidthPercentage: CGFloat? = 0.8 ;
    
    /**
     A percentage value from 0.0 to 1.0, representing the maximum height of the toast
     view relative to it's superview. Default is 0.8 (80% of the superview's height).
     */
    var maxHeightPercentage:CGFloat? = 0.8;
    
    /**
     The spacing from the horizontal edge of the toast view to the content. When an image
     is present, this is also used as the padding between the image and the text.
     Default is 10.0.
     */
    var horizontalPadding:CGFloat? = 10.0 ;
    
    /**
     The spacing from the vertical edge of the toast view to the content. When a title
     is present, this is also used as the padding between the title and the message.
     Default is 10.0.
     */
    var verticalPadding:CGFloat? = 10.0 ;
    
    /**
     The corner radius. Default is 10.0.
     */
    var cornerRadius:CGFloat? = 10.0;
    
    /**
     The title font. Default is `[UIFont boldSystemFontOfSize:16.0]`.
     */
    var titleFont:UIFont? = UIFont.boldSystemFont(ofSize: 16) ;
    
    /**
     The message font. Default is `[UIFont systemFontOfSize:16.0]`.
     */
    var messageFont:UIFont? = UIFont.systemFont(ofSize: 16) ;
    
    /**
     The title text alignment. Default is `NSTextAlignmentLeft`.
     */
    var titleAlignment:NSTextAlignment? = NSTextAlignment.left ;
    
    /**
     The message text alignment. Default is `NSTextAlignmentLeft`.
     *
     */
    var messageAlignment:NSTextAlignment? = NSTextAlignment.left ;
    
    /**
     The maximum number of lines for the title. The default is 0 (no limit).
     */
    var titleNumberOfLines:NSInteger? = 0 ;
    
    /**
     The maximum number of lines for the message. The default is 0 (no limit).
     */
    var messageNumberOfLines:NSInteger? = 0 ;
    
    /**
     Enable or disable a shadow on the toast view. Default is `NO`.
     */
    var displayShadow:Bool? = false ;
    
    /**
     The shadow color. Default is `[UIColor blackColor]`.
     */
    var shadowColor:UIColor? = nil ;
    
    /**
     A value from 0.0 to 1.0, representing the opacity of the shadow.
     Default is 0.8 (80% opacity).
     */
    var shadowOpacity:Float? = 0.8 ;
    
    /**
     The shadow radius. Default is 6.0.
     */
    var shadowRadius:CGFloat? = 6 ;
    
    /**
     The shadow offset. The default is `CGSizeMake(4.0, 4.0)`.
     */
    var shadowOffset:CGSize? = CGSize.init(width: 4.0, height: 4.0) ;
    
    /**
     The image size. The default is `CGSizeMake(80.0, 80.0)`.
     */
    var imageSize:CGSize? = CGSize.init(width: 80, height: 80) ;
    
    /**
     The size of the toast activity view when `makeToastActivity:` is called.
     Default is `CGSizeMake(100.0, 100.0)`.
     */
    var activitySize:CGSize? = CGSize.init(width: 100, height: 100) ;
    
    /**
     The fade in/out animation duration. Default is 0.2.
     */
    var fadeDuration:TimeInterval? = 0.2 ;
    
    func setMaxWidthPercentage(maxWidthPercentage:CGFloat) {
        
        self.maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
    }
    func setMaxHeightPercentage(maxHeightPercentage:CGFloat) {
        
        self.maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
    }
}
class CSToastManager: NSObject {
    
    var sharedStyle:CSToastStyle? = CSToastStyle()
    var tapToDismissEnabled:Bool? = true
    var queueEnabled:Bool? = true
    var defaultDuration:TimeInterval? = 1.2;
    var defaultPosition:AnyObject = CSToastPositionCenter as AnyObject
    static let instance:CSToastManager = CSToastManager()
    static func shareedManager() -> CSToastManager{
        return instance
    }
    
    // Singleton Methods
    func setSharedStyle(sharedStyle:CSToastStyle?)  {
        CSToastManager.shareedManager().sharedStyle = sharedStyle
    }
    func getSharedStyle() -> CSToastStyle {
        return  CSToastManager.shareedManager().sharedStyle!
    }
    
    func setTapToDismissEnabled(tapToDismissEnabled:Bool?) {
        CSToastManager.shareedManager().tapToDismissEnabled = tapToDismissEnabled
    }
    
    func setQueueEnabled(queueEnabled:Bool?) {
        CSToastManager.shareedManager().queueEnabled = queueEnabled
    }
    
    func setDefaultDuration(duration:TimeInterval?) {
        CSToastManager.shareedManager().defaultDuration = duration
    }
    func setDefaultPosition(position:AnyObject?) {
        if position is String || position is NSValue{
            CSToastManager.shareedManager().defaultPosition = position!
        }
    }
}

