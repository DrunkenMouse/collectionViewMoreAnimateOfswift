//
//  ADBrowserLayout.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/20.
//  Copyright © 2016年 王奥东. All rights reserved.
//

import UIKit

class ADBrowserLayout: UICollectionViewFlowLayout {

    override func prepareLayout() {
        super.prepareLayout()
        
        itemSize = UIScreen.mainScreen().bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        
        scrollDirection = .Horizontal
        collectionView?.showsHorizontalScrollIndicator = false;
        collectionView?.pagingEnabled = true
    }
    
}
