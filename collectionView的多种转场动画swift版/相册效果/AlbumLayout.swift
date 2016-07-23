//
//  AlbumLayout.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/19.
//  Copyright © 2016年 王奥东. All rights reserved.
//

import UIKit

enum AlbumType {
    case Vertical
    case Horizontal
}

class AlbumLayout: UICollectionViewFlowLayout {
    
    var albumType : AlbumType = AlbumType.Horizontal
    
    //重写父类的约束准备方法
    //会在生成约束前调用此方法
    override func prepareLayout() {
        super.prepareLayout()
        
        //通过滚动方式来调用对应的自定义方法添加约束
        if albumType == .Horizontal {
            layouHorizontal()
        }else{
            layoutVertical()
            
        }
        
        collectionView?.showsHorizontalScrollIndicator = false;
        collectionView?.showsVerticalScrollIndicator = false;
    }
}




extension AlbumLayout{
    class func identifier() -> String{
        
        return "AlbumCell"
    }
}



extension AlbumLayout{
    
    //封装父类获取可视区域的所有控件属性方法
    //根据横向或竖向滚动,返回自己对父类方法封装后的控件属性
    //注意是父类的,super.而不是自身的方法
    //于是调用自身的此方法会通过判断水平或垂直方向调用封装好的自定义方法
    //自定义方法里通过封装好的父类方法来获取控件属性
    //在修改之后返回
    //修改内容为控价的xy方向缩放，距离中心越近缩放越小
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        if albumType == .Horizontal {
            return layoutHorizontalAttributesForElementsInRect(rect)
        }
        
        return layoutVerticalAttributesForElemetsInRect(rect)
        
    }
    
    //界面滚动时的动画效果
    //为了让控件滚动后居中显示
    //仅仅是修改了滚动结束后x的偏移值
    //若向左滑动则X+离屏幕中间最近的cell其中心距离屏幕中间的距离
    //若向右滑动的范围超过最小距离则X为0
    //最小距离：离屏幕中间最近的cell其中心距离屏幕中间的距离
    //仅限于水平滚动居中
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        
    
        
        //获取当前CollectionView在滚动结束时坐标x,y
        //以滚动结束时的坐标点x开始
        //获取collectionView中可视的控件属性
        //也就是横向滚动时，滚动结束后可视化的控件属性
        guard let arr = super.layoutAttributesForElementsInRect(CGRect(origin: CGPoint(x: proposedContentOffset.x, y: 0),size:collectionView!.bounds.size)) else {return CGPointZero}
        
        var lesserDis = CGFloat(MAXFLOAT)
        //保存屏幕滚动结束后的偏移量x值
        var proposedContentOffsetX = proposedContentOffset.x
        for cellAttr in arr {
            
            //获取离屏幕中间最近的cell中心其距离屏幕中间的距离
            let cellDistance = cellAttr.center.x - (collectionView!.bounds.width * 0.5 + proposedContentOffset.x)
            if fabs(cellDistance) < fabs(lesserDis) {
                lesserDis = cellDistance
                
            }
        }
        
        proposedContentOffsetX += lesserDis
        //有时会出现小于0的Bug
        if proposedContentOffsetX < 0 {
            proposedContentOffsetX = 0
        }
        
        
        return CGPoint(x: proposedContentOffsetX, y: proposedContentOffset.y)
    }
    
    //collectionView滚动时可修改控件的大小
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
}


extension AlbumLayout{
    
    //如果是横向滚动
    func layouHorizontal(){
        
        let itemWH : CGFloat = 150
        itemSize = CGSize(width:  itemWH, height: itemWH)
        scrollDirection = .Horizontal
        minimumLineSpacing = 50
        let margin = (UIScreen.mainScreen().bounds.width - itemWH) * 0.5
        sectionInset = UIEdgeInsetsMake(0, margin, 0, margin)
        
    }
    
 
    //如果是垂直滚动
    func layoutVertical(){
        
        let itemWH : CGFloat = UIScreen.mainScreen().bounds.width - 20
        itemSize = CGSize(width: itemWH, height: itemWH)
        scrollDirection = .Vertical
        minimumInteritemSpacing = 10
        
    }
    
    //以下是对父类方法，获取CollectionView中可视控件的所有属性 进行的封装
    //分为横向滚动与竖直滚动
    //分别通过不同的判断修改scale值
    //距离屏幕越近则scale值越大
    
    //通过父类方法来修改横向滚动时范围内的所有控件属性的scale设置
    func layoutHorizontalAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?{

        //获取collectionView内当前可以看到的控件属性
        guard let arr = super.layoutAttributesForElementsInRect(collectionView!.bounds) else{
            return nil
        }
        //将数组转变成属性数组
        let cellAttrs = NSArray.init(array: arr, copyItems: true) as! [UICollectionViewLayoutAttributes]
        //遍历每个控件的属性
        for cellAttr in cellAttrs {
           
            let offsetX = collectionView!.contentOffset.x
            
            //越靠近屏幕中间则cellDistance越小
            let cellDistance = fabs(cellAttr.center.x - ((collectionView?.bounds.width)!*0.5 + offsetX))
            
            //cellDistance越小则scale越大
            let scale = 1 - cellDistance / ((collectionView?.bounds.width)!*0.5) * 0.25
            
            //则缩放的越小
            cellAttr.transform = CGAffineTransformMakeScale(scale, scale)
        }
        
        return cellAttrs;
    }
    
    //通过父类方法来修改垂直滚动时范围内所有控件属性的scale设置
    func layoutVerticalAttributesForElemetsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?{
        
        guard let arr = super.layoutAttributesForElementsInRect(collectionView!.bounds) else {return nil}
        
        let cellAttrs = NSArray.init(array: arr,copyItems: true) as![UICollectionViewLayoutAttributes]
        
        for cellAttr in cellAttrs {
            
            let offsetY = collectionView!.contentOffset.y
            
            let cellDistance = fabs(cellAttr.center.y - ((collectionView?.bounds.height)! * 0.5 + offsetY))
            
            let scale = 1 - cellDistance / ((collectionView?.bounds.height)! * 0.5) * 0.25
            
            cellAttr.transform = CGAffineTransformMakeScale(scale, scale)
        }
        return cellAttrs
        
    }
    
}


