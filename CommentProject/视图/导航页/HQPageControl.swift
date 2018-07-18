//
//  HQPageControl.swift
//  ToastDemo
//
//  Created by 王帅 on 2018/7/18.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit
enum HQPageControlStyle:Int {
    case  HQPageControlStyleDefaoult = 1
    case  HQPageControlStyleSquare
}

class HQPageControl: UIView {
    var numberPags: NSInteger? = 0
    var pageStyle:HQPageControlStyle? = HQPageControlStyle.HQPageControlStyleDefaoult
    
    init(frame: CGRect,pageStyle:HQPageControlStyle) {
        self.pageStyle = pageStyle
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func setNumberPags(numberPags:NSInteger)  {
        if self.numberPags != numberPags{
            self.numberPags = numberPags;
            
            let marger:CGFloat  =  10
            
            let width:CGFloat  = self.frame.size.width - CGFloat(numberPags - 1) * marger
            let pointWidth:CGFloat  = width/CGFloat(numberPags)
            for index in 0..<numberPags{
                let aView:UIView = UIView.init()
                aView.frame = CGRect.init(x: (marger + pointWidth) * CGFloat(index), y: 0, width: pointWidth, height: pointWidth)
                aView.backgroundColor = self.backageColor
                aView.layer.borderWidth = 0.2
                aView.layer.borderColor = UIColor.lightGray.cgColor
                switch (self.pageStyle) {
                case .HQPageControlStyleDefaoult?:
                    aView.layer.cornerRadius = pointWidth/2.0
                    aView.layer.masksToBounds = true
                    break;
                case .HQPageControlStyleSquare?:
                    break;
                default:
                    break;
                }
                self.addSubview(aView)
                /**
                 *  设置cuurrentPag
                 */
                if index == 0{
                    if self.selectionColor != nil{
                        aView.backgroundColor = self.selectionColor
                    }
                    else  {
                        aView.backgroundColor = UIColor.white
                    }
                }
            }
        }
    }
    
    var selectColor:UIColor? = UIColor.white
    var selectionColor:UIColor?{
        set{
            if self.selectColor != newValue{
                self.selectColor = newValue
                if self.subviews.count > 0{
                    let aimg:UIView = self.subviews[self.currentPag!]
                    aimg.backgroundColor = self.selectColor
                }
            }
        }
        get{
            return self.selectColor
        }
    }
    var currentPage:NSInteger? = 0
    var currentPag:NSInteger?{
        set{
            if(newValue != self.currentPage){
                self.currentPage = newValue
                if self.subviews.count > 0 {
                    for dImg:UIView in self.subviews{
                        dImg.backgroundColor = self.backageColor
                        dImg.layer.borderColor = UIColor.gray.cgColor
                    }
                    let eImg:UIView   = self.subviews[self.currentPag!]
                    eImg.backgroundColor = self.selectionColor
                    eImg.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
        get{
            return self.currentPage
        }
    }
    
      var backColor: UIColor? = UIColor.darkGray
      var backageColor: UIColor?{
        set{
            self.backColor = newValue
            if self.subviews.count != 0{
                for aimg:UIView in self.subviews{
                    aimg.backgroundColor = self.backageColor
                }
                let bImg:UIView = self.subviews[self.currentPag!]
                bImg.backgroundColor = self.selectionColor
            }
        }
        get{
            return self.backColor
        }
    }
}
