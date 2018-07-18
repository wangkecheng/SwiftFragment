//
//  HQFactory.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit
import Foundation

class HQFactory: NSObject {

   static public func createClassByPlistName(name:String) -> NSArray {
         
        let filePath = Bundle.main.path(forResource: name, ofType: "plist")//取出plist文件路径
        let dataArr:[NSDictionary] =  NSArray.init(contentsOfFile: filePath!) as! [NSDictionary]//知道filePath是文件路径，感叹号是强制解析
        let  arrItemVC:NSMutableArray = []
        for dict in dataArr {
            let dictItem:NSMutableDictionary = NSMutableDictionary.init()
            
            let className:String  = dict[ClassClass] as! String
            var nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            nameSpace = nameSpace.replacingOccurrences(of: "-", with: "_")
            let classControl =  NSClassFromString(nameSpace + "." + className)//获取到类名
            
            let obj = classControl as! HQBaseVC.Type //强制转为HQBaseVC
            dictItem[ClassClass] = obj.init()//将视图放在字典中
            
            dictItem[TitleVC] = dict[TitleVC]//将标题放在字典中
            if dict[SelectImage] != nil {
                dictItem[SelectImage] = dict[SelectImage]
            }
            if dict[ClassImageName] != nil {
                dictItem[ClassImageName] = dict[ClassImageName]
            }
            if dict[AttachInfo] != nil{
                  dictItem[AttachInfo] = dict[AttachInfo]
            }
            arrItemVC.add(dictItem)
        }
        return arrItemVC
    }
    
}
