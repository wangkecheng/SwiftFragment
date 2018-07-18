//
//  HQBaseVC.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit
 
class HQBaseVC: UIViewController {
     
    let isHideSuperBack:Bool? = false //隐藏返回按钮
    let isHideSuperBackAction:Bool? = false ;//隐藏返回按钮的响应方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(R: 245, G: 245, B: 245)

        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let navigationBar:UINavigationBar? = self.navigationController?.navigationBar
        navigationBar?.setBackgroundImage(ImageWithColor(color: UIColor.clear), for: UIBarPosition.bottom, barMetrics: UIBarMetrics.compactPrompt)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

