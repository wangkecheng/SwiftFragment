//
//  HQBaseServer.swift
//  CommentProject
//
//  Created by oldDevil on 2018/6/27.
//  Copyright © 2018年 王帅. All rights reserved.
//

import UIKit
import Alamofire
 var manager:SessionManager? = nil

/*
 model:参数列表
 path ：接口，注意 Header.swift有个接口前缀
 isShowHud:是否显示请求hud暂时没有做
 isShowSuccessHud:是否显示成功hud暂时没有做
 attachObjc:附带值，先设置按钮不可点 比如可以传个按钮过去，请求成功后 ，又返回来 设置可点 successBlock 成功block
 successBlock:成功回调
 faultBlock:失败回调
 */
class HQBaseServer: NSObject {
    static  func postObjc(objc: HQModel,path:String,isShowHud:Bool,isShowSuccessHud:Bool,attachObjc:AnyObject, successBlock:@escaping (_ result:NSDictionary)->(Void),faultBlock:@escaping (_ error:NSError) -> (Void)) {
        let url:String = POST_HOST + path
        let dict:[String:String]? = objc.toJSON() as? [String : String]
        
        let header:HTTPHeaders = [
            "Accept":"application/json", "Authorization":"eyJhbGciOiJIUzI1NiJ9.eyJtb2JpbGUiOiIxODQwODI0NjMwMSIsInVpZCI6IjVhNTg0ZmVhNzNmN2VmN2UwODIyZWM5NiJ9.4wyZytXgK-JjNMilof4903kP_0x9dY13H464szG2UPg"
        ]
    
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let policies: [String: ServerTrustPolicy] = [
            "api.domian.cn": .disableEvaluation
        ]
        manager = Alamofire.SessionManager(configuration: configuration,serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies))
        manager?.startRequestsImmediately = true
        manager?.delegate.sessionDidReceiveChallenge = {
            session,challenge in
            return    (URLSession.AuthChallengeDisposition.useCredential,URLCredential(trust:challenge.protectionSpace.serverTrust!))
        }
        
        manager?.request(url, method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: header).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
          //这里自己根据项目需求改良 根据code值判断成功与否
             if let json = response.result.value { 
                successBlock(json as! NSDictionary)
            }else{
                faultBlock(NSError.init())
            }
        }
    }
}
