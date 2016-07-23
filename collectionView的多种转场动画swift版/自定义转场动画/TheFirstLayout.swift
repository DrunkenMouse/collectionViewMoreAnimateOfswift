//
//  TheFirstLayout.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/20.
//  Copyright © 2016年 王奥东. All rights reserved.
//

import UIKit

class TheFirstLayout: UICollectionViewFlowLayout {
    
    
    override func prepareLayout() {
        
        super.prepareLayout()
        
        
        let margin : CGFloat = 10
        let row : CGFloat = 3
        
        let itemWH = (UIScreen.mainScreen().bounds.width - (row + 1) * margin) * 0.33
        
        collectionView?.contentInset = UIEdgeInsets(top: margin + 64, left :margin, bottom: margin, right: margin)
        
        itemSize = CGSize(width: itemWH, height: itemWH)
        minimumLineSpacing = margin
        minimumInteritemSpacing = margin
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

}
