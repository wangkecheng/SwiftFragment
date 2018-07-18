//
//  MSHomeVC.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit

class MSHomeVC: HQBaseVC {
    
    var textView:UITextView? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let method1:UIButton = UIButton.init(frame: CGRect.init(x: 20, y: 80, width: 120, height: 60))
        method1.setTitle("前往下级界面", for: UIControlState.normal)
        method1.titleLabel?.textColor = UIColor.red
        method1.backgroundColor = UIColor.green
        method1.addTarget(self, action: #selector(methodOne), for: UIControlEvents.touchUpInside)
        self.view.addSubview(method1)
        
        self.textView = UITextView.init(frame: CGRect.init(x: 0, y: 180, width: SCREEN_WIDTH, height: 100))
        self.view.addSubview(self.textView!)
     
    }
    
    @objc func methodOne(){
        let VC:BlockTest = BlockTest()
        VC.title = "闭包学习"
        //1.简单方式'
        
        VC.getHomeInfoBlock = {[unowned self](str:String) -> () in
//            [unowned self] in //检查列表，有in 就不用加了 没有in 就加在[unowned self]之后
            self.textView?.text = (self.textView?.text)! + str + "\n"
        }
        
        //2.传值过去 ，获取值回来
        VC.getAge(ID : "184") {[unowned self] (age:String) in
            
            self.textView?.text = (self.textView?.text)! + age + "\n"
        }
        
        //3.传值过去 ，获取值回来，再 返回值过去
        VC.login(ID: "18408246301") {[unowned self] (placeInputPass:String) -> (String) in
            
            self.textView?.text = (self.textView?.text)! + placeInputPass + "\n"
            return "123456"
        }
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }  
}
