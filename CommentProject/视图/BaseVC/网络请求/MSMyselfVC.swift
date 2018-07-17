//
//  MSMyselfVC.swift
//  CommentProject
//
//  Created by 王帅 on 2018/6/25.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit
import HandyJSON

class MSMyselfVC: HQBaseVC {
    
    var arrModel:NSMutableArray? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arrModel = NSMutableArray()
        let model:HQModel = HQModel()
        model.username = "warron"
        model.age = "23"
        HQBaseServer.postObjc(objc: model, path: "/dishonesty/list", isShowHud: false, isShowSuccessHud: false, attachObjc:AnyObject.self as AnyObject, successBlock: { (result:NSDictionary) -> (Void) in
          
            let data = result["data"] as! NSDictionary
            let arr  = data["rows"] as! NSArray
            for  dict in  arr {
                let model = JSONDeserializer<TestModel>.deserializeFrom(dict: dict as? NSDictionary)
                if (model != nil){
                 self.arrModel?.add(model)
              }
            }
        }) { (error:NSError) -> (Void) in
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }  
}

////字典转 json
//if (!JSONSerialization.isValidJSONObject(dict)) {
//    print("无法解析出JSONString")
//    return
//}
//let data : NSData! = try? JSONSerialization.data(withJSONObject: dict, options: []) as NSData!
//let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)

