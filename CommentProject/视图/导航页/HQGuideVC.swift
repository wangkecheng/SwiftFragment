//
//  HQGuideVC.swift
//  ToastDemo
//
//  Created by 王帅 on 2018/7/18.
//  Copyright © 2018 王帅. All rights reserved.
//

import UIKit
/*这里是要展示的图片，修改即可,当然不止三个  1242 * 2208的分辨率最佳,如果在小屏手机上显示不全，最好要求UI重新设计图片*/
/** pageIndicatorTintColor*/
let pageTintColor = UIColor.white.withAlphaComponent(0.5)
/** currentPageIndicatorTintColor*/
let currentTintColor = UIColor.red
let CollectionView_Tag = 15
let RemoveBtn_tag = 16
let Control_tag = 17
let FIRST_IN_KEY = "FIRST_IN_KEY"
/*
 如果要修改立即体验按钮的样式
 重新- (UIButton*)removeBtn方法即可
 */
class HQGuidViewCell:UICollectionViewCell{
    var imageView:UIImageView? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView =  UIImageView.init(frame: self.bounds)
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView?.isUserInteractionEnabled = true
        self.addSubview(self.imageView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var imgName:NSString? = ""
    var imageName:NSString?{
        set{
            if newValue == nil {
                return
            }
            if self.imgName != newValue {
                self.imgName = newValue
            }
            self.imageView?.image = UIImage.init(named: newValue! as String)
        }
        get{
            return self.imgName
        }
    }
}
class HQGuideVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate {
    let arrImgModel:NSMutableArray  = NSMutableArray.init()
    var guideBlock:((_ isFinish:Bool)->())? = nil
    class func loadWithBlock(guideBlock:@escaping ((_ isFinish:Bool)->())) -> HQGuideVC {
        let VC:HQGuideVC = HQGuideVC()
        VC.guideBlock = guideBlock
        return VC
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0..<3 {
            self.arrImgModel.add(NSString.init(format: "welcome%ld", i))
        }
        self.setupSubViews()
    }
    //初始化视图
    func setupSubViews() {
        //界面样式
        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        flowLayout.itemSize = UIScreen.main.bounds.size
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        let collectionView:UICollectionView   = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.white
        collectionView.register(HQGuidViewCell.classForCoder(), forCellWithReuseIdentifier: "KSGuidViewCell")
        collectionView.tag = CollectionView_Tag
        self.view.addSubview(collectionView)
        collectionView.reloadData()
        self.createView()
    }
    
    
    //这里是退出的按钮
    func createView() {
        //移除按钮样式
        let removeBtn:UIButton = UIButton.init(type: UIButtonType.custom)
        removeBtn.addTarget(self, action: #selector(removeGuidView), for: UIControlEvents.touchUpInside)
        removeBtn.isHidden = (self.arrImgModel.count != 1)
        removeBtn.tag = RemoveBtn_tag//注意这里的tag
        
        let btnW:CGFloat  = 128
        var btnH:CGFloat  = 35
        let btnX:CGFloat  = self.view.frame.midX - btnW / 2.0
        let btnY:CGFloat  = self.view.frame.maxY * 0.85
        let maxYToBottom:CGFloat = self.view.frame.maxY - btnY
        if btnH > maxYToBottom {
            btnH = maxYToBottom - 10//做一个适配
        }
        removeBtn.frame = CGRect.init(x: btnX, y: btnY, width: btnW, height: btnH)
        removeBtn.layer.cornerRadius = btnH/2.0
        removeBtn.backgroundColor = UIColorFromRGB(R: 253, G: 208, B: 54)
        removeBtn.setTitle("立即体验", for: UIControlState.normal)
        removeBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        removeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        removeBtn.alpha = 0
        self.view.addSubview(removeBtn)
        
        let pageControl:HQPageControl = HQPageControl.init(frame: CGRect.init(x: 0, y: 0, width: self.arrImgModel.count*15, height: 30), pageStyle: HQPageControlStyle.HQPageControlStyleDefaoult)
        pageControl.center = CGPoint.init(x: self.view.bounds.size.width/2.0, y:removeBtn.frame.maxY + 10)
        pageControl.backgroundColor = UIColor.clear
        pageControl.backageColor = UIColor.lightGray
        pageControl.selectionColor = UIColorFromRGB(R: 251, G: 205, B: 32)
        pageControl.numberPags = self.arrImgModel.count
        pageControl.tag = Control_tag
        pageControl.alpha = 0
        self.view.addSubview(pageControl)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrImgModel.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:HQGuidViewCell  =  collectionView.dequeueReusableCell(withReuseIdentifier: "KSGuidViewCell", for: indexPath) as! HQGuidViewCell
        cell.imageView?.image = IMG(name: self.arrImgModel[indexPath.row] as! String)
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index:Int  = Int(scrollView.contentOffset.x / self.view.frame.width)
        self.view.viewWithTag(RemoveBtn_tag)?.isHidden = (index != self.arrImgModel.count - 1)
        
        var removeBtn:UIButton?
        for view:UIView in self.view.subviews {
            if view is HQPageControl{
                let pageControl: HQPageControl  =  view as! HQPageControl
                pageControl.currentPag = index
            }
            if view is UIButton {
                removeBtn =  (view as! UIButton)
            }
        }
        if index == self.arrImgModel.count - 1{
            removeBtn?.alpha = 1
        }else{
            removeBtn?.alpha = 0
        }
    }
    
    @objc func removeGuidView() {
        
        let versoin:NSString =   Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! NSString
        UserDefaults.standard.set(versoin, forKey: FIRST_IN_KEY)
        UserDefaults.standard.synchronize()
        self.view.viewWithTag(Control_tag)?.removeFromSuperview()
        self.view.viewWithTag(RemoveBtn_tag)?.removeFromSuperview()
        self.view.viewWithTag(CollectionView_Tag)?.removeFromSuperview()
        if (self.guideBlock) != nil {
            self.guideBlock!(true)
        }
    }
    
    class func hadLoaded() -> Bool{
        let versoin:NSString = Bundle.main.infoDictionary! ["CFBundleShortVersionString"] as! NSString
        let versionCache = UserDefaults.standard.object(forKey: FIRST_IN_KEY)
        if versionCache == nil {
            return false;//没有加载过
        }
        //启动时候首先判断是不是第一次
        if versoin == (versionCache as! NSString){//表示加载过一次了
            return true
        }
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

