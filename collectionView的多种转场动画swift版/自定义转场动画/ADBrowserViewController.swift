//
//  ADBrowserViewController.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/20.
//  Copyright © 2016年 王奥东. All rights reserved.
//

import UIKit

/**
 
 browserVC初始化时添加一个collectionView用于展示数据
 并调用CollectionView的scrollToItemAtIndexPath显示点击时的cell内容
 在browserVC上通过获取的imageArr展示原cell同样的内容
 browserVC中cell的点击事件是dismissViewController
 跳转到browserVC之前就已经设置自定义转场的dissmiss对象为browserVC
 在dismiss代理方法里获取到当前显示的cell ( collectionView.visibleCells().first )
 用过重定义一个imageView保存了cell上的image与imageView的frame
 并获取了cell的indexPath
 
 
 
 */


private let reuserIdentifier : String = "BroserCell"

class ADBrowserViewController: UIViewController {
    
    lazy var collectionView = UICollectionView(frame: CGRectZero,collectionViewLayout: ADBrowserLayout())

    var indexPath : NSIndexPath?
    lazy var imageArr = [UIImage]()
 

    override func viewDidLoad() {
        super.viewDidLoad()
//        // 设置子控件
        setUpChildView()

        // 注册cell
        
        collectionView.registerClass(ADBrowserCell.self, forCellWithReuseIdentifier: reuserIdentifier)
        
        collectionView.scrollToItemAtIndexPath(indexPath!, atScrollPosition: .Left, animated: false)
        
    }
    
}

extension ADBrowserViewController{

    
    
    func setUpChildView(){
        collectionView.frame = view.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }

}


// MARK: collectionView的代理
extension ADBrowserViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return imageArr.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuserIdentifier, forIndexPath: indexPath) as! ADBrowserCell
        
        cell.image = imageArr[indexPath.row]
        
        return cell
    }
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}




// MARK:- dismiss代理方法
extension ADBrowserViewController : dismissProtocol {
    
    func getImageView() -> UIImageView {
         //获取当前显示的cell
        let cell = collectionView.visibleCells().first as! ADBrowserCell
        
        let imageView = UIImageView()
        
        imageView.image = cell.imageView.image
        
        imageView.contentMode = .ScaleToFill
        imageView.clipsToBounds = true
        imageView.frame = cell.imageView.frame
        
        return imageView
    }
    
    func getEndRect() -> NSIndexPath {
        
        //获取当前显示的cell
        let cell = collectionView.visibleCells().first as! ADBrowserCell
        
        return collectionView.indexPathForCell(cell)!
        
    }
    
}







