//
//  BlockTest.swift
//  CommentProject
//
//  Created by 王帅 on 2018/7/17.
//  Copyright © 2018 王帅. All rights reserved.
//

import Foundation
import UIKit
class BlockTest: HQBaseVC {
    
    var textView:UITextView? = nil
    var ID:String? = nil
    // 简单传值 1
    /*
     getHomeInfoBlock:对象
     ((_ getHomeInfo:String) -> ()):对象的值， getHomeInfo外部参数名，String:block返回值的类型  -> 后面的括号， 如果在闭包方法执行完后还需要再返回调用处，那面这里是返回值得类型
     */
    var getHomeInfoBlock:((_ getHomeInfo:String) -> ())?
    
    //传值2 闭包传值到 首页 没有返回值调用回来
    var getAgeBlock:((_ ID:String) -> ())?
    func getAge(ID:String, getAgeBlock:@escaping (_ age:String) -> ()) -> Void {
        self.getAgeBlock = getAgeBlock
        self.ID = ID
    }
    
    var loginBlock:((_ request:String) -> (String))?
    
    /*
     ID : 传入参数
     block: 传入block的值 block:@escaping(_ placeInputPass:String) -> (String)) placeInputPass 外部参数名 类型是String， ->后面的String是闭包执行完后的返回值
     Void:函数返回值
     */
    func login(ID:String,block:@escaping(_ placeInputPass:String) -> (String)) -> Void {
        self.ID = ID
        self.loginBlock = block
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let method1:UIButton = UIButton.init(frame: CGRect.init(x: 20, y: 80, width: 60, height: 60))
        method1.setTitle("方式1", for: UIControlState.normal)
        method1.titleLabel?.textColor = UIColor.red
        method1.backgroundColor = UIColor.green
        method1.addTarget(self, action: #selector(methodOne), for: UIControlEvents.touchUpInside)
        self.view.addSubview(method1)
        
        let method2:UIButton = UIButton.init(frame: CGRect.init(x: 20, y: 150, width: 60, height: 60))
        method2.setTitle("方式2", for: UIControlState.normal)
        method2.titleLabel?.textColor = UIColor.red
        method2.backgroundColor = UIColor.green
        method2.addTarget(self, action: #selector(methodTwo), for: UIControlEvents.touchUpInside)
        self.view.addSubview(method2)
        
        let method3:UIButton = UIButton.init(frame: CGRect.init(x: 20, y: 260, width: 60, height: 60))
        method3.setTitle("方式3", for: UIControlState.normal)
        method3.titleLabel?.textColor = UIColor.red
        method3.backgroundColor = UIColor.green
        method3.addTarget(self, action: #selector(methodThree), for: UIControlEvents.touchUpInside)
        self.view.addSubview(method3)
        
        self.textView = UITextView.init(frame: CGRect.init(x: 0, y:330 , width: SCREEN_WIDTH, height: 70))
        self.view.addSubview(self.textView!)
    }
    @objc func methodOne() {
        if self.getHomeInfoBlock != nil{
            self.getHomeInfoBlock!("欢迎学习闭包")
        }
    }
    @objc func methodTwo() {
        if self.getAgeBlock != nil{
            let str = self.ID! + " 的 年龄是 24"
            self.getAgeBlock!(str)
            self.textView?.text = (self.textView?.text)! + str + "\n"
        }
    }
    @objc func methodThree() {
        if self.loginBlock != nil{
            let str = "密码是:" + self.loginBlock!(self.ID! + "请输入密码!")
            self.textView?.text = (self.textView?.text)! + str + "\n"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
