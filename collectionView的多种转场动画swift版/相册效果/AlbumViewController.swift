//
//  AlbumViewController.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/19.
//  Copyright © 2016年 王奥东. All rights reserved.
//

import UIKit


//滚动方向通过一个枚举值来声明
//不同的滚动方向item大小、边距不同
//横向滚动设置行间距与组Inset，垂直滚动设置item间距
//初始化Layout时滚局
//
//可通过对Collection的枚举变量修改来改变滚动方向
//默认为水平，所以水平方向不做修改即可
//若改为垂直，则在添加Collection时会通过get方法获取一个滚动方向为垂直的collection
//具体修改在layout中，而后通过注册flowLayout，在修改layout的滚动方向达到不同方向的滚动
//layout中的方法会在滚动时自己去调用
//通过shouldInvalidate方法返回true表示允许滚动时修改控件的属性
//对于方法layoutAttributesForElementsInRect内部

//封装父类获取可视区域的所有控件属性方法
//根据横向或竖向滚动,返回自己对父类方法封装后的控件属性
//注意是父类的,super.而不是自身的方法
//于是调用自身的此方法会通过判断水平或垂直方向调用封装好的自定义方法
//自定义方法里通过封装好的父类方法来获取控件属性
//在修改之后返回
//修改内容为控价的xy方向缩放，距离中心越近缩放越小

//页面滚动时会调用targetContentOffsetForProposedContentOffset
//此界面滚动时的动画效果
//为了让控件滚动后居中显示
//仅仅是修改了预估滚动结束后x的偏移
//通过对偏移量增加一个最小距离让控件居中
//最小距离：离屏幕中间最近的cell其中心距离屏幕中间的距离
//有时候偏移量会小于0导致Bug，此时让偏移量为0即可
//最后返回修改好的x与默认Y




class AlbumViewController: UIViewController{
    
    private let W = UIScreen.mainScreen().bounds.size.width
    private let H = UIScreen.mainScreen().bounds.size.height
    

    
    var albumType : AlbumType = AlbumType.Horizontal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建collectionView
        setUpUI()
        
        view.backgroundColor = UIColor.orangeColor()
        
    }
    
    private func setUpUI(){
        
        let collectionView = self.collectionView()
        
        view.addSubview(collectionView)
    
        collectionView.registerClass(AlbumCell.self, forCellWithReuseIdentifier: AlbumLayout.identifier())
        
        
        collectionView.dataSource = self
        //两种方式设置背景颜色，任选一种
        collectionView.backgroundColor = UIColor.whiteColor()
//        collectionView.backgroundColor = UIColor.init(patternImage: UIImage(named: "back.png")!)
    }
    
}


extension AlbumViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AlbumLayout.identifier(), forIndexPath: indexPath) as! AlbumCell
        
        let image = UIImage(named: "\(indexPath.row + 1)")
        
        cell.image = image
        
        return cell
    }
    
    
}



extension AlbumViewController {
    
    func collectionView() -> UICollectionView {
        
        if albumType == .Horizontal {
            
            let collectionView = UICollectionView(frame: CGRect(origin: CGPointZero, size: CGSize(width: W, height:300 )),collectionViewLayout: AlbumLayout())
            
            collectionView.center = view.center
            
            return collectionView
        }
        
        let albumLayout : AlbumType = albumType
        let collectionLayout = AlbumLayout()
        collectionLayout.albumType = albumLayout
        
        let collectionView = UICollectionView(frame: CGRect(x: 0,y: 0,width: W,height: H),collectionViewLayout:collectionLayout)
        
        return collectionView
    }
    
    
    
    
    
    
}


















