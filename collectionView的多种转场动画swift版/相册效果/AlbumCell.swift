//
//  AlbumCell.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/19.
//  Copyright © 2016年 王奥东. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
//    lazy var imageView = UIImageView()
//    
    lazy var imageView = UIImageView()
//    
//    
//    var image : UIImage?{
//        didSet{
//            guard let image = image else{return}
//            
//            imageView.image = image
//        }
//    }
//    
    var image: UIImage?{
        didSet{
            
            guard let image = image else {return}
            
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

    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
}
