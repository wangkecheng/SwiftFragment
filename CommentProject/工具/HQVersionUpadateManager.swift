//
//  VersionUpadateManager.swift
//  CommentProject
//
//  Created by 王帅 on 2018/7/16.
//  Copyright © 2018 王帅. All rights reserved.
//

import Foundation
import StoreKit
let REQUEST_SUCCEED = 200

let CURRENT_VERSION:NSString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! NSString
let BUNDLE_IDENTIFIER:NSString = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! NSString
let SYSTEM_VERSION_8_OR_ABOVE = (UIDevice.current.systemVersion as NSString).intValue >= 8 ? true:false
let TRACK_ID  = "TRACKID"
let APP_LAST_VERSION  = "APPLastVersion"
let APP_RELEASE_NOTES = "APPReleaseNotes"
let APP_TRACK_VIEW_URL = "APPTRACKVIEWURL"
let SPECIAL_MODE_CHECK_URL = "https://itunes.apple.com/lookup?country=%@&bundleId=%@"
let NORMAL_MODE_CHECK_URL = "https://itunes.apple.com/lookup?bundleId=%@"
let SKIP_CURRENT_VERSION  = "SKIPCURRENTVERSION"
let SKIP_VERSION = "SKIPVERSION"
class  HQVersionUpadateManager:NSObject,UIAlertViewDelegate,SKStoreProductViewControllerDelegate{
    var nextTimeTitle:NSString? = "下次提示"
    var confimTitle:NSString? = "前往更新"
    var alertTitle:NSString? = "发现新版本"
    var skipVersionTitle:NSString?
    var openAPPStoreInsideAPP:Bool?
    //  if you can't get the update info of your APP. Set countryAbbreviation of the sale area. like `countryAbbreviation = @"cn"`,`countryAbbreviation = @"us"`.General, you don't need to set this property.
    var countryAbbreviation:NSString?
    
     static let instance:HQVersionUpadateManager = HQVersionUpadateManager()
     static func shareManger() -> HQVersionUpadateManager  {
        return instance
    }
    func checkVersion()  {
        
        self.checkVersionWithAlertTitle(alertTitle: self.alertTitle!,nextTimeTitle:self.nextTimeTitle!,confimTitle:self.confimTitle!)
    }
    func checkVersionWithAlertTitle(alertTitle:NSString,nextTimeTitle:NSString,confimTitle: NSString) {
        self.checkVersionWithAlertTitle(alertTitle: alertTitle, nextTimeTitle: nextTimeTitle, confimTitle: confimTitle, skipVersionTitle: "跳过当前版本")
    }
    func checkVersionWithAlertTitle(alertTitle:NSString,nextTimeTitle:NSString,confimTitle: NSString,skipVersionTitle:NSString) {
        let isSkip:Bool! = (UserDefaults.standard.object(forKey: SKIP_CURRENT_VERSION) ?? false) as! Bool
        if isSkip {
            return //跳过版本下边的就不执行了
        }
        self.alertTitle = alertTitle
        self.nextTimeTitle = nextTimeTitle
        self.confimTitle = confimTitle
        self.skipVersionTitle = skipVersionTitle
        self.getInfoFromAppStore()
    }
    func getInfoFromAppStore() {
    
        var requestURL:NSURL
        if let _ = self.countryAbbreviation{//可选绑定，如果有值再赋值 然后走if
              requestURL = NSURL.init(string:NSString.init(format: "%@%@", SPECIAL_MODE_CHECK_URL,self.countryAbbreviation!,BUNDLE_IDENTIFIER) as String)!
        }
        else{
            requestURL = NSURL.init(string:NSString.init(format:  NORMAL_MODE_CHECK_URL as NSString,BUNDLE_IDENTIFIER) as String)!
        }
        let request: URLRequest  = URLRequest.init(url: requestURL as URL)
        let session:URLSession = URLSession.shared
       
        let dataTask:URLSessionDataTask = session.dataTask(with: request,
                                                           completionHandler: {(data, response, error) -> Void in
            let urlResponse:HTTPURLResponse  =  response as! HTTPURLResponse
            if data == nil {
                return
            }
            if urlResponse.statusCode == REQUEST_SUCCEED {
               
                let responseDic:NSDictionary  = try!JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: JSONSerialization.ReadingOptions.allowFragments.rawValue)) as! NSDictionary
                let userDefault:UserDefaults = UserDefaults.standard
                let resultCount:NSNumber = responseDic["resultCount"] as! NSNumber
                if resultCount.intValue == 1 {
                    
                    let results:NSArray = responseDic["results"] as! NSArray
                    let resultDic:NSDictionary = results.firstObject as! NSDictionary
                    userDefault.set(resultDic["version"], forKey: APP_LAST_VERSION)
                    userDefault.set(resultDic["releaseNotes"], forKey: APP_RELEASE_NOTES)
                    userDefault.set(resultDic["trackViewUrl"], forKey: APP_TRACK_VIEW_URL)
                    userDefault.set(resultDic["trackId"], forKey: TRACK_ID)
                    
                    let version:NSString = resultDic["version"] as! NSString
                    if (version == CURRENT_VERSION || userDefault.object(forKey: SKIP_VERSION) as? NSString  != version) {
                        userDefault.set(false, forKey: SKIP_CURRENT_VERSION)
                    }
                    userDefault.synchronize()
                    DispatchQueue.main.async {
                        if self.isEqualByCompareLastVersion(lastVersion: resultDic["version"] as! NSString, currentVersion: CURRENT_VERSION){
                            self.compareWithCurrentVersion()
                        }
                    }
                }
            }

        })
        
       dataTask.resume()
    }
    
    /**
     * 比较当前版本号是否与沙盒中的版本号相同
     */
    func isEqualByCompareLastVersion(lastVersion:NSString,currentVersion:NSString) ->Bool {
        let lastVersionArray:NSArray  = lastVersion.components(separatedBy: ".") as NSArray
        let currentVersionArray:NSArray  = currentVersion.components(separatedBy: ".") as NSArray
        for index in 0..<lastVersionArray.count{
            let currentVersionItem = ((currentVersionArray.object(at: index) ) as! NSString).intValue
            let lastVersionItem = ((currentVersionArray.object(at: index) ) as! NSString).intValue
            if currentVersionItem < lastVersionItem  {
                return false
            }
        }
        return true
    }
    func floatForVersion(version:NSString) ->Double {
        let versionArray:NSArray = version.components(separatedBy: ".") as NSArray
        let versionString:NSMutableString = NSMutableString.init()
        
        for index in 0..<versionArray.count {
            versionString.append(versionArray.object(at: index) as! String)
            if index != 0 {
                versionString.append(".")
            }
        }
        return versionString.doubleValue
    }
    func compareWithCurrentVersion() {
        
        let userDefault:UserDefaults = UserDefaults.standard
        
        let updateMessage:NSString = userDefault.object(forKey: APP_RELEASE_NOTES) as! NSString
        if (userDefault.object(forKey: APP_LAST_VERSION) as! NSString) != CURRENT_VERSION  {
            
            if SYSTEM_VERSION_8_OR_ABOVE {
                
                let alertControler:UIAlertController = UIAlertController.init(title: (self.alertTitle ?? "") as String, message: updateMessage as String as String, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction:UIAlertAction   = UIAlertAction.init(title: (self.nextTimeTitle! as String), style: UIAlertActionStyle.default, handler: Optional.none)
                let confimAction: UIAlertAction   =  UIAlertAction.init(title: (self.confimTitle! as String), style:  UIAlertActionStyle.default, handler: {[unowned self] (action:UIAlertAction) in
                    self.openAPPStore()
                })
                alertControler.addAction(confimAction)
                alertControler.addAction(cancelAction)
                
                if self.skipVersionTitle != nil {
                    let skipVersionAction:UIAlertAction   = UIAlertAction.init(title: (self.skipVersionTitle! as String), style: UIAlertActionStyle.cancel, handler: {(action:UIAlertAction) in
                         let userDefault:UserDefaults = UserDefaults.standard
                        userDefault.set(true, forKey: SKIP_CURRENT_VERSION)
                        userDefault.set(userDefault.object(forKey: APP_LAST_VERSION), forKey: SKIP_VERSION)
                        userDefault.synchronize()
                    })
                    alertControler.addAction(skipVersionAction)
                }
                UIApplication.shared.keyWindow?.rootViewController?.present(alertControler, animated: true, completion: Optional.none)
                
            } else {
                
                let alertView: UIAlertView  = UIAlertView.init(title: self.alertTitle! as String, message: updateMessage as String, delegate: self, cancelButtonTitle: (self.nextTimeTitle! as String), otherButtonTitles: self.confimTitle! as String, self.skipVersionTitle!  as String)
                alertView.show()
            }
        }
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != 0 {
            
            self.openAPPStore()
        }
    }
    func openAPPStore() {
        
        let userDefault: UserDefaults = UserDefaults.standard
        if self.openAPPStoreInsideAPP == nil {
            UIApplication.shared.openURL(NSURL.init(string: userDefault.object(forKey: APP_TRACK_VIEW_URL) as! String)! as URL)
        } else {
            let storeVC: SKStoreProductViewController = SKStoreProductViewController.init()
            storeVC.delegate = self
            
            let parametersDic: NSDictionary   =  [SKStoreProductParameterITunesItemIdentifier:userDefault.object(forKey: TRACK_ID) as Any]
            storeVC.loadProduct(withParameters: parametersDic as! [String : Any], completionBlock: ({ (result:Bool, error:Error) in
                if result {
                    UIApplication.shared.keyWindow?.rootViewController?.present(storeVC, animated: true, completion: Optional.none)
                }
                } as! (Bool, Error?) -> Void))
          }
     }
    func productViewControllerDidFinish(_ viewController:SKStoreProductViewController) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion:  Optional.none)
    }
}





