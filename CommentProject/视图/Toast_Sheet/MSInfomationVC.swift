//
//  MSInfomationVC.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit

class MSInfomationVC: HQBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.makeToast(message: "abc", duration: 5, position: CSToastPositionCenter as AnyObject, title: "可以", image: UIImage.init(named: "bg_zhlyjg"), style: CSToastStyle()) { (finish: Bool) in //这个方法是带图片的弹框
            
            self.view.makeToast(message: "完成")//只带文字弹框
        }
        //        otherTitles otherImages:可已有值 ，不传值时 传Optional.none
        let sheet:HQActionSheet =  HQActionSheet.actionSheet(title: "提示", cancelTitle: "取消", cancelBtnBackColor: UIColor.white, destructiveTitle: "cdf", otherTitles: ["abc","cdf"], otherImages:[UIImage.init(named: "bg_zhlyjg"),UIImage.init(named: "bg_zhlyjg")], selectSheetBlock: {[unowned self]  (index:NSInteger, sheet:HQActionSheet) in
            //选择回调
        }) { [unowned self] in // 检查列表
            //取消回调 点按背景 或者取消按钮
        }
        sheet.otherActionItemAlignment = .HQOtherActionItemAlignmentCenter//可加可不加，这里用计算属性来调用
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            sheet.show()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning() 
    }  
}
