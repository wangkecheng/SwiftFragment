//
//  MSTripVC.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit

class MSTripVC: HQBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HQVersionUpadateManager.shareManger().checkVersion()
        //budleID需要填写自己项目  如果线上版本是 1.1.1 当前版本是 1.1.0就会提示更新
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }  
}
