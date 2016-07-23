//
//  TheFirstViewController.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/20.
//  Copyright © 2016年 王奥东. All rights reserved.
//


/**
 对于Cell的拖曳
 
 找到点击的cell方法是先获取触摸点位于collectionView上哪个点
 通过collection提供方法根据点找到IndexPath
 再根据indexPath找到Cell
 
 保存cell上的图片可通过新建一个UIImageView的image为Cell上的image来直接保存
 或通过view的对象方法snapshotView获取到view
 移动时让cell隐藏，移动保存image的imageView
 关于cell移动时的移动判断，可直接通过获取移动时的点
 然后获取点对应的indexPath后只要indexPath不为空，就直接移动
 或判断此时的view跟除原cell之外的哪个cell重叠过一半
 （判断方法：返利除自身外的所有Cell计算imageView中心距离其中心的x,y差是否小于等于自身的一半，是则重叠过一半）
 重叠过一半就彼此互换位置，通过cell提供的方法moveItemAtIndexPath
 直接插入到需要插入的位置而后修改数据源
 或先修改数据源再插入位置，这里要注意，不需要reoadLoad
 关于数据源修改，若不在同一组则直接删除cell所在的位置，而后在需要插入那一组insert插入
 若在同一组，则交换cell与下一个或上一个cell之间的位置，直到达到要插入的位置，或也是直接移除cell所在位置，而后直接insert要插入的位置
 （判断数据源是否是数组包含数组的方法，当前的组数不为1或组数为1但array[0]也为数组类型）
 结束时移除临时生成的imageView，不隐藏cell

 */
import UIKit

private let reuseIdentifier = "Cell"

class TheFirstViewController: UICollectionViewController {
    
    
    private let identifier = "firstCell"
    var browserAnimator : ADBrowserAnimator = ADBrowserAnimator()
    
    private lazy var imageArr = [UIImage]()
    
    var isMask : Bool = false
    
    private var curPath : NSIndexPath?
    private var lastPath : NSIndexPath?
    
    private var imageView : UIImageView?
    private var cell : TheFirstCell?

    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        self.collectionView!.registerClass(TheFirstCell.self, forCellWithReuseIdentifier: identifier)
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        //添加长按手势
        let longGest = UILongPressGestureRecognizer(target: self,action: "longGestHandle:")
        collectionView?.addGestureRecognizer(longGest)
        
        
        for i in 1...20 {
            let image = UIImage(named: "\(i)")
            imageArr.append(image!)
        }
        
    }
}


extension TheFirstViewController{
    
    func longGestHandle(longGest : UILongPressGestureRecognizer) {
        
        switch longGest.state {
        case .Began:
            //获取点击的点
            let touchP = longGest.locationInView(collectionView)
            
            //拿到对应的indexPath
            guard let indexPath = collectionView?.indexPathForItemAtPoint(touchP) else {return}
            
            //记录
            curPath = indexPath
            lastPath = indexPath
        
            //拿到indexPath对应的Cell
            let cell = collectionView?.cellForItemAtIndexPath(indexPath) as! TheFirstCell
            self.cell = cell
            
            let imageView = UIImageView()
            imageView.frame = cell.frame
            imageView.image  = cell.image
            imageView.transform = CGAffineTransformMakeScale(1.15, 1.15)
            collectionView?.addSubview(imageView)
            self.imageView = imageView

        case .Changed :
            
            cell?.alpha = 0
            //获取到手指的位置
            let touchP = longGest.locationInView(collectionView)
            imageView?.center = touchP
            
            //根据手指位置获取对应的indexPath
            let indexPath = collectionView?.indexPathForItemAtPoint(touchP)
            
            if indexPath != nil {
                curPath = indexPath
                
                collectionView?.moveItemAtIndexPath(lastPath!, toIndexPath: curPath!)
            }

            //修改数据源
            if lastPath != nil {
                
                let lastImg = imageArr[lastPath!.item]
                imageArr.removeAtIndex(lastPath!.item)
                imageArr.insert(lastImg, atIndex: curPath!.item)
                
                lastPath = curPath
            }

            
        case .Ended:
            
            imageView?.removeFromSuperview()
            
            cell?.alpha = 1
            
            
        default: break
            
        }
        
    }
}





// MARK: - 数据源和代理
extension TheFirstViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! TheFirstCell
        
        cell.image = imageArr[indexPath.row]
        
        return cell
    }
    
    /**
    
     
     cell点击之后其实是跳转到另一个viewController：browserVC
     browserVC保存了当前点击的IndexPath与collectionView的imageArr(图片数组)、isMask(图片打开方式)
     browserVC的modal模式为Custom，但transitioningDelegate（上下文代理）为animator
     animator保存了当前点击的cell的indexPath
     animator的present代理为当前View
     animator的dismiss代理为browserVC
     animator的isMask根据当前View获取
     
     需要注意：点击之后在滚动的时候,屏幕外的Cell就为空。
     */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let browserVC = ADBrowserViewController()
        browserVC.indexPath = indexPath
        browserVC.imageArr = imageArr
        
        browserVC.modalPresentationStyle = .Custom
        browserVC.transitioningDelegate = browserAnimator
        browserAnimator.indexPath = indexPath
        browserAnimator.presentDelegate = self
        browserAnimator.dismissDelegate = browserVC
        browserAnimator.isMask = self.isMask
        
        presentViewController(browserVC, animated: true, completion: nil)
        
    }
}


extension TheFirstViewController : presentedProtocol{
    
    
    func getImageView(indexPath: NSIndexPath) -> UIImageView {
       
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        
        imageView.clipsToBounds = true
        
        let cell = collectionView?.cellForItemAtIndexPath(indexPath) as! TheFirstCell
        imageView.image = cell.imageView.image
        
        return imageView
    }
   
    
    
    func getStartRect(indexPath: NSIndexPath) -> CGRect {
    
        let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? TheFirstCell
        //点击之后在滚动的时候,屏幕外的Cell就为空。
        //此时滚动到屏幕外了，所以返回的时候有个空值就行了
        
        if cell == nil {
            return CGRectZero
        }
        
        let startRect = collectionView!.convertRect(cell!.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
        
        return startRect
    }
    
    func getEndRect(indexPath: NSIndexPath) -> CGRect {
        let cell = collectionView?.cellForItemAtIndexPath(indexPath) as! TheFirstCell
        return calculateWithImage(cell.imageView.image!)
    }

    
    func getEndCell(indexPath: NSIndexPath) -> TheFirstCell? {
        var cell = collectionView?.cellForItemAtIndexPath(indexPath) as? TheFirstCell
        
        //点击之后在滚动的时候,屏幕外的Cell就为空。
        //此时应该让collectionView滑动到此时indexPath
        //而后可获得此时的cell
        if cell == nil {
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Right, animated: false)
            cell = collectionView?.cellForItemAtIndexPath(indexPath) as? TheFirstCell
            
            return cell
            
        }
        return cell
    }
    
}











































