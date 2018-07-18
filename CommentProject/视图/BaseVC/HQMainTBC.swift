//
//  HQMainTBC.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.

import UIKit

class HQMainTBC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTabBarBackColor()
        self.addTabBarItems()
        
    }
    
    func setTabBarBackColor ()  {
        self.tabBar.backgroundImage = ImageWithColor(color: UIColor.white)
        self.tabBar.shadowImage = IMG(name: "tabbar_shadow")
        self.tabBar.isOpaque = true
        self.tabBar.tintColor = UIColorFromHX(rgbValue: 0x1393fc)
        self.tabBar.isTranslucent = false
    }
   
    func addTabBarItems() {
        for dict in HQFactory.createClassByPlistName(name:"TabBarItem") as![NSDictionary] {
            let VC =  dict[ClassClass] as! HQBaseVC
            let navc = HQBaseNavC(rootViewController: VC)
            navc.tabBarItem.image = IMG(name: dict[ClassImageName] as! String)
            navc.tabBarItem.selectedImage = IMG(name: dict[SelectImage] as! String)
            navc.tabBarItem.title = dict[TitleVC] as? String
            VC.title = dict[TitleVC] as? String
           
            self.addChildViewController(navc)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
