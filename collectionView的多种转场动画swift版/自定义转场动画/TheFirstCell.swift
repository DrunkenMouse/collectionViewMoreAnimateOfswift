//
//  TheFirstCell.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/20.
//  Copyright © 2016年 王奥东. All rights reserved.
//

import UIKit

class TheFirstCell: UICollectionViewCell {
 
    lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.frame = self.bounds
        return imageView
        
    }()
    
    
    var image : UIImage?{
        didSet{
            guard let image = image else{return}
            imageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
