//
//  Header.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.
//
import UIKit 
import Foundation
////这部分用于从plist文件中解析控制器
let POST_HOST  = "https://120.79.169.197:3000"
let ClassClass = "classClass";
let TitleVC = "classNavigationTitle"//控制器标题
let ClassImageName  = "classImageName"//控制器是tabBar的图片
let SelectImage  = "classSelectedImageName"//控制器是tabBar的图片
let AttachInfo  = "classSelectedImageName"//控制器 的附加信息

let SCREEN_HEIGHT =  UIScreen.main.bounds.size.height
let SCREEN_WIDTH = UIScreen.main.bounds.size.width

let DidPaySuccessMessage = "didPaySuccessMessage"//支付成功通知标志
let DidPayFailedMessage = "didPayFailedMessage"//失败通知标志

let CurrentAppDelegate =  UIApplication.shared.delegate// 当前应用AppDelegate

func IMG(name:String) -> UIImage? {//通过图片名快速生成图片
    let image:UIImage? = UIImage.init(named: name)
    return image
}

func UIColorFromHX(rgbValue:Int) -> UIColor?{//通过16进制颜色值生成颜色
   
    return UIColor.init(red:CGFloat(((Float)((rgbValue & 0xFF0000) >> 16))/255.0) , green: CGFloat(((Float)((rgbValue & 0xFF00) >> 8))/255.0) , blue: CGFloat(((Float)(rgbValue & 0xFF))/255.0) , alpha: 1.0)
}
func UIColorFromRGB(R:Int,G:Int,B:Int) -> UIColor?{//通过RGB生成颜色
    return UIColor.init(red: CGFloat(R)/255.0, green: CGFloat(G)/255.0, blue: CGFloat(B)/255.0, alpha: 1.0)
}

func UIFontPFSC(fontSize:Int) ->UIFont?{//平方字体
    
    return UIFont.init(name: "PingFang SC", size: CGFloat(fontSize))
}

func ImageWithColor(color:UIColor) -> UIImage? {//颜色转图片
    let rect:CGRect = CGRect.init(x: 0.0, y: 0.0, width:  1.0, height:  1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(color.cgColor)
    context?.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}


