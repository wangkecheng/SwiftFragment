//
//  HQActionSheet.swift
//  CommentProject
//
//  Created by 王帅 on 2018/7/17.
//  Copyright © 2018 王帅. All rights reserved.
//

import Foundation
import UIKit

func SCREEN_ADJUST(value:CGFloat) -> CGFloat {
    return SCREEN_WIDTH * (value) / 375.0
}

let kActionItemHeight = SCREEN_ADJUST(value: 50)
let kLineHeight       =  0.5
let kDividerHeight      =   7.5

let kTitleFontSize      =   SCREEN_ADJUST(value: 15)
let kActionItemFontSize   = SCREEN_ADJUST(value: 17)

let kActionSheetColor      = UIColorFromRGB(R: 245, G: 245, B: 245)
let kTitleColor        = UIColorFromRGB(R: 111, G: 111, B: 111)
let kActionItemHighlightedColor = UIColorFromRGB(R: 242, G: 242, B: 242)
let kDestructiveItemNormalColor = UIColorFromRGB(R: 255, G: 10, B: 10)
let kDividerColor         =  UIColorFromRGB(R: 240, G: 240, B: 240)

enum HQOtherActionItemAlignment:Int {
    case HQOtherActionItemAlignmentLeft = 1
    case HQOtherActionItemAlignmentCenter = 2
}

class HQActionSheet:UIView{
    var cancelBtnBackColor:UIColor?  = UIColor.white
    var dissMissBlock:(()->())? = nil
    var didSelectSheetBlock:((_ index:NSInteger,_ actionSheet:HQActionSheet)->())? = nil
    
    var  cover:UIView? = nil
    var  actionSheet:UIView? = nil
    
    var  title:NSString? = nil
    var cancelTitle:NSString? = nil
    var destructiveTitle:NSString? = nil
    var otherTitles:NSArray? = nil
    var otherImages:NSArray? = nil//字符串或者UIImage
    
    var offsetY:CGFloat? = nil
    var actionSheetHeight:CGFloat? = nil
    
    lazy var otherActionItems:NSMutableArray? = {
        
        return NSMutableArray.init()
    }()
    
    lazy var normalImage:UIImage? = {
        return ImageWithColor(color: UIColor.white)
    }()
    lazy var highlightedImage:UIImage? = {
        return ImageWithColor(color: kActionItemHighlightedColor!)
    }()
    
    var alignment:HQOtherActionItemAlignment? = .HQOtherActionItemAlignmentCenter
    var otherActionItemAlignment:HQOtherActionItemAlignment?{
        set{
            self.alignment = newValue
            switch  newValue {
            case .HQOtherActionItemAlignmentLeft?:do {
                for actionItem in self.otherActionItems!{
                    let title = (actionItem as! UIView).viewWithTag(1) as! UILabel
                    title.textAlignment = NSTextAlignment.left
                    var newFrame:CGRect  = (actionItem as! UIView).frame
                    newFrame.origin.x = 10
                    (actionItem as! UIView).frame = newFrame
                }
                break
                }
            default:do {
                for actionItem in self.otherActionItems!{
                    let title:UILabel = (actionItem as! UIView).viewWithTag(1) as! UILabel
                    title.textAlignment = NSTextAlignment.center
                    var newFrame:CGRect  = (actionItem as! UIView).frame
                    newFrame.origin.x = self.frame.size.width * 0.5 - newFrame.size.width * 0.5
                    (actionItem as! UIView).frame = newFrame
                }
                break
                }
            }
        }
        get{
            return self.alignment
        }
    } //Default is SROtherActionItemAlignmentCenter when no images. SROtherActionItemAlignmentLeft when there are images.
    class func actionSheet(title:NSString?,
                           cancelTitle:NSString?,
                           cancelBtnBackColor:UIColor?,
                           destructiveTitle:NSString?,
                           otherTitles: NSArray?,
                           otherImages:NSArray?,
                           selectSheetBlock:@escaping ((_ index:NSInteger,_ actionSheet:HQActionSheet)->()),dissMissBlock:@escaping (()->()))->HQActionSheet{
        let sheet:HQActionSheet = HQActionSheet()
        sheet.title             = title
        sheet.cancelTitle       = cancelTitle
        sheet.destructiveTitle  = destructiveTitle
        sheet.otherTitles       = otherTitles
        sheet.otherImages       = otherImages
        sheet.didSelectSheetBlock  = selectSheetBlock
        sheet.dissMissBlock = dissMissBlock
        sheet.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        sheet.setupCover()
        sheet.setupActionSheet()
        sheet.backgroundColor = UIColor.clear
        sheet.actionSheet?.frame =  CGRect.init(x: 0, y: sheet.frame.maxY, width: sheet.frame.width, height: sheet.offsetY!)
        sheet.actionSheetHeight = sheet.offsetY
        return sheet
    }
    func setupCover() {
        let cover:UIView = UIView.init()
        cover.frame = self.bounds;
        cover.backgroundColor =  UIColor.black
        cover.alpha = 0.1
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(cancelSheet(button:)))
        cover.addGestureRecognizer(tap)
        self.cover = cover;
        self.addSubview(self.cover!)
    }
    
    func setupActionSheet() {
        
        let actionSheet:UIView = UIView.init()
        actionSheet.backgroundColor = kActionSheetColor
        self.actionSheet = actionSheet;
        self.addSubview(self.actionSheet!)
        
        self.setupTitleLabel()
        self.setupOtherActionItems()
        self.setupDestructiveActionItem()
        
        //    [_actionSheet addSubview:({
        //        UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, _offsetY, self.frame.size.width, kDividerHeight)];
        //        dividerView.backgroundColor = kDividerColor;
        //        dividerView;
        //    })];
        
        self.setupCancelActionItem()
    }
    
    func setupTitleLabel()   {
        if (self.title?.length ?? 0 > 0) {
            let titleLabel:UILabel     = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: kActionItemHeight))
            titleLabel.backgroundColor = UIColor.white
            titleLabel.textColor       = kTitleColor
            titleLabel.textAlignment   = NSTextAlignment.center
            titleLabel.font            = UIFont.systemFont(ofSize: kTitleFontSize)
            titleLabel.numberOfLines   = 0
            titleLabel.text            = self.title! as String
            self.actionSheet?.addSubview(titleLabel)
            self.offsetY = kActionItemHeight + CGFloat(kLineHeight) + (self.offsetY ?? 0.0)
        }
    }
    
    func setupOtherActionItems() {
        
        for i in 0..<(self.otherTitles?.count ?? 0)  {
            
            let otherBtn:UIButton  = UIButton.init(frame: CGRect.init(x: 0, y: self.offsetY!, width:  self.frame.size.width, height: kActionItemHeight))
            otherBtn.backgroundColor = UIColor.white
            otherBtn.tag = i
            otherBtn.setBackgroundImage(self.normalImage, for: UIControlState(rawValue: UIControlState.normal.rawValue))
            otherBtn.setBackgroundImage(self.normalImage, for: UIControlState(rawValue: UIControlState.highlighted.rawValue))
            otherBtn.addTarget(self, action: #selector(didSelectSheet(button:)), for: UIControlEvents(rawValue: UIControlEvents.touchUpInside.rawValue))
            self.actionSheet?.addSubview(otherBtn)
            
            let otherItem:UIView  = UIView.init()
            otherItem.backgroundColor = UIColor.clear
            let maxTitleSize:CGSize  = self.maxSizeInStrings(strings: self.otherTitles!)
            if (self.otherImages?.count ?? 0) > 0{
                let icon   = UIImageView.init()
                icon.frame = CGRect.init(x: 0, y: 0, width: kActionItemHeight, height: kActionItemHeight)
                if (self.otherImages?.count ?? 0) > i{
                    let image = self.otherImages?[i]
                    if image is UIImage{
                        icon.image = (self.otherImages?[i] as! UIImage)
                    }else if image is String{
                        icon.image = UIImage.init(named: image as! String)
                    }
                }
                icon.contentMode = UIViewContentMode.center
                icon.tag = 2
                otherItem.addSubview(icon)
                
                let title:UILabel  = UILabel.init(frame: CGRect.init(x: icon.frame.maxX, y: 0, width: maxTitleSize.width, height: kActionItemHeight))
                
                title.font = UIFont.systemFont(ofSize: kActionItemFontSize)
                title.textColor = UIColor.black
                title.text = (self.otherTitles?[i] as! String)
                title.tag = 1
                otherItem.addSubview(title)
                
                otherItem.frame = CGRect.init(x: 10, y: 0, width: kActionItemHeight + maxTitleSize.width, height: kActionItemHeight)
                
            } else {
                let title:UILabel  = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: maxTitleSize.width, height: kActionItemHeight))
                title.font = UIFont.systemFont(ofSize: kActionItemFontSize)
                title.textColor = UIColor.black
                title.text = (self.otherTitles?[i] as! String)
                title.tag = 1
                otherItem.addSubview(title)
                otherItem.frame = CGRect.init(x: self.frame.size.width * 0.5 - maxTitleSize.width * 0.5, y: 0, width: maxTitleSize.width, height: kActionItemHeight)
            }
            
            self.otherActionItems?.add(otherItem)
            otherBtn.addSubview(otherItem)
            otherItem.isUserInteractionEnabled = false
            if i == (self.otherTitles?.count ?? 0) - 1 {
                self.offsetY  = kActionItemHeight +  self.offsetY!
            } else {
                self.offsetY  = kActionItemHeight + CGFloat(kLineHeight) + self.offsetY!
            }
        }
    }
    func setupDestructiveActionItem() {
        if (self.destructiveTitle?.length ?? 0) > 0 {
            self.offsetY  = CGFloat(kLineHeight) + self.offsetY!
            let destructiveButton:UIButton  = UIButton.init()
            destructiveButton.frame = CGRect.init(x: 0, y: self.offsetY ?? 0, width: self.frame.size.width, height: kActionItemHeight)
            destructiveButton.tag = 0
            if (self.otherTitles?.count ?? 0) > 0{
                destructiveButton.tag = self.otherTitles?.count ?? 0
            }
            destructiveButton.backgroundColor = UIColor.white
            destructiveButton.titleLabel?.font = UIFont.systemFont(ofSize: kActionItemFontSize)
            destructiveButton.setTitleColor(kDestructiveItemNormalColor, for: UIControlState(rawValue: UIControlState.normal.rawValue))
            destructiveButton.setTitle((self.destructiveTitle! as String), for: UIControlState(rawValue: UIControlState.normal.rawValue))
            destructiveButton.setBackgroundImage(self.normalImage, for: UIControlState(rawValue: UIControlState.normal.rawValue))
            destructiveButton.setBackgroundImage(self.highlightedImage, for: UIControlState(rawValue: UIControlState.highlighted.rawValue))
            destructiveButton.addTarget(self, action: #selector(didSelectSheet(button:)), for: UIControlEvents(rawValue: UIControlEvents.touchUpInside.rawValue))
            self.actionSheet?.addSubview(destructiveButton)
            self.offsetY  = CGFloat(kActionItemHeight) + self.offsetY!
        }
    }
    
    func setupCancelActionItem() {
        if self.cancelTitle != nil
        {
            self.offsetY = CGFloat(kLineHeight) + self.offsetY!// kDividerHeight;//不要大分割
            let cancelBtn:UIButton  = UIButton.init()
            cancelBtn.frame = CGRect.init(x: 0, y: self.offsetY!, width: self.frame.size.width, height: kActionItemHeight)
            cancelBtn.tag = -1
            cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: kActionItemFontSize)
            cancelBtn.setTitleColor(UIColorFromHX(rgbValue: 0x999999), for: UIControlState(rawValue: UIControlState.normal.rawValue))
            
            cancelBtn.setTitle(self.cancelTitle! as String, for: UIControlState(rawValue: UIControlState.normal.rawValue))
            
            //            [cancelBtn setBackgroundImage:self.normalImage forState:UIControlStateNormal];
            //            [cancelBtn setBackgroundImage:self.highlightedImage forState:UIControlStateHighlighted];
            cancelBtn.backgroundColor = self.cancelBtnBackColor
            cancelBtn.addTarget(self, action: #selector(cancelSheet(button:)), for: UIControlEvents.touchUpInside)
            self.offsetY  = kActionItemHeight +  self.offsetY!
            self.actionSheet?.addSubview(cancelBtn)
        }
    }
    
    func maxSizeInStrings(strings:NSArray) -> CGSize{
        
        var maxSize:CGSize  = CGSize.zero
        var maxWith:CGFloat  = 0.0
        for var string in strings {
            let size:CGSize  =  self.sizeOfString(string: string as! NSString, font: UIFont.systemFont(ofSize: kActionItemFontSize))
            if (maxWith < size.width) {
                maxWith = size.width
                maxSize = size
            }
        }
        return maxSize
    }
    func sizeOfString(string:NSString, font:UIFont) -> CGSize{
        
        let attrs:NSMutableDictionary   = NSMutableDictionary.init()
        attrs.setValue(font, forKey: NSAttributedStringKey.font.rawValue)
        let maxSize:CGSize  = CGSize.init(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT))
        return  string.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: (attrs as! [NSAttributedStringKey : Any]), context: Optional.none).size
    }
    
    @objc func cancelSheet(button:UIButton){
        if self.dissMissBlock != nil{
            self.dissMissBlock!()
        }
        self.dismiss()
    }
    @objc func didSelectSheet(button:UIButton){
        if self.didSelectSheetBlock != nil{
            self.didSelectSheetBlock!(button.tag,self)
        }
        self.dismiss()
    }
    func show()  {
        self.showWithSuperVC(VC: ((UIApplication.shared.delegate?.window)!)!)
    }
    func showWithSuperVC(VC:AnyObject) {
        
        if VC is UIWindow{
            let window:UIWindow =  VC as! UIWindow
            window.addSubview(self)
            window.bringSubview(toFront: self)
        }
        else{
            (VC as! UIViewController).view.addSubview(self)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations: { [unowned self] in
            self.cover?.alpha = 0.33
            self.actionSheet!.transform =
                CGAffineTransform.init(translationX: 0, y: -self.actionSheetHeight!)
            }, completion: nil)
    }
    @objc func dismiss(){
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseOut, animations: {[unowned self] in
            self.cover?.alpha = 0.0;
            self.backgroundColor = UIColor.clear
            self.actionSheet!.transform = CGAffineTransform.identity
        }) {[unowned self] (finished:Bool) in
            if self != nil{
                self.removeFromSuperview()
            }
        }
    }
}

