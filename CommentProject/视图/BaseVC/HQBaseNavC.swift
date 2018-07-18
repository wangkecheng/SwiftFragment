//
//  HQBaseNavC.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit

class HQBaseNavC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    self.navigationBar.setBackgroundImage(ImageWithColor(color:UIColorFromRGB(R: 7, G: 113, B: 197)!), for: UIBarMetrics.default)
        
        let titleAttribute:NSMutableDictionary = NSMutableDictionary.init(object: UIColor.white, forKey:NSAttributedStringKey.foregroundColor as NSCopying )
        titleAttribute.setObject(UIFont.systemFont(ofSize: 14), forKey: NSAttributedStringKey.font as NSCopying)
        self.navigationBar.isOpaque = true
        self.navigationBar.isTranslucent = false
        
    }
    override func pushViewController(_ VC: UIViewController?, animated: Bool) {//捕获push方法，重新定义
        self.pushVC(VC: VC as? HQBaseVC, animated: animated)
    }
    
    func pushVC(VC:HQBaseVC?,animated:Bool?) {
        
        if (VC == nil) {
            return//为空的时候不弹出
        }
        if self.childViewControllers.count>0 {// 如果push进来的不是第一个控制器
        
            let btn:UIButton = UIButton.init(type: UIButtonType.custom)
            btn.frame = CGRect.init(x: 0, y: 0, width: 44, height: 44)
            btn.setImage(IMG(name: "back_arrow"), for: UIControlState(rawValue: 0))
            btn.contentHorizontalAlignment =  UIControlContentHorizontalAlignment.left
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 5 * CGFloat(SCREEN_WIDTH)/375.0, 0, 0)
            if !(VC?.isHideSuperBack)! {//如果不屏蔽就加这个方法，屏蔽了， 此控制器就不会响应返回方法
                btn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
            }
            if !(VC?.isHideSuperBack)! {//未屏蔽按钮 就展示出来
                let item:UIBarButtonItem = UIBarButtonItem.init(customView: btn)
                VC?.navigationItem .setLeftBarButton(item, animated: true)
            }
            VC?.hidesBottomBarWhenPushed = true
        }
        // 一旦调用super的pushViewController方法,就会创建子控制器viewController的view并调用viewController的viewDidLoad方法。可以在viewDidLoad方法中重新设置自己想要的左上角按钮样式
        super.pushViewController(VC!, animated: animated!)
    }
    
    @objc func back(){
        self.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
