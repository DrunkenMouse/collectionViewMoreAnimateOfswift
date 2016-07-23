//
//  ADBrowserAnimator.swift
//  collectionView的多种转场动画swift版
//
//  Created by 王奥东 on 16/7/20.
//  Copyright © 2016年 王奥东. All rights reserved.
//

import UIKit

/**
 
 
 UIViewControllerTransitioningDelegate
 上下文转场代理方法
 
 UIViewControllerAnimatedTransitioning上下文转场动画
 (可用来告诉系统modal时的present、dismiss由自己负责)
 
 UIViewControllerContextTransitioning?
 上下文转场类，可获取转场动画的舞台

 自定义转场动画就是通过UIViewControllerTransitioningDelegate
 上下文转场代理方法
 UIViewControllerAnimatedTransitioning上下文转场动画
 
 UIViewControllerContextTransitioning?
 上下文转场类，可获取转场动画的舞台 自定义设置

 
 自定义转场时，要签UIViewControllerTransitioningDelegate协议
 
 需要在初始化自定义转场动画类（swift中,class 类名 ：）就重写animationControllerForPresent\ForDismiss方法，告诉系统modal动画由自己负责。
 想要重写animation方法就需要签UIViewControllerAnimatedTransitioning协议，可重写上下文转场动画的时间与具体的动画
 
 声明一个UIViewControllerContextTransitioning的对象transitionContext.
 transitionContext.containerView()获取转场舞台
 
 transitionContext.viewForKey(UITransitionContextToViewKey)获取modal出来的view
 to是modal出来的View from是modal之前的View

 
 */



/**
 
 animator通过保存的indexPath与present代理方法获取到present时当前点击的cell上的image
 与点击的cell位于keyWindow的Rect
 cell上的Image转换成屏幕大小时的rect
 与结束时的Cell
 
 */
protocol presentedProtocol : class {
    
    func getImageView(indexPath : NSIndexPath) -> UIImageView
    func getStartRect(indexPath : NSIndexPath) -> CGRect
    func getEndRect(indexPath : NSIndexPath) -> CGRect
    func getEndCell(indexPath : NSIndexPath) -> TheFirstCell?

}


protocol dismissProtocol : class {
    
    func getImageView() -> UIImageView
    func getEndRect() -> NSIndexPath
    
}

class ADBrowserAnimator: NSObject,UIViewControllerTransitioningDelegate {
 
    weak var presentDelegate : presentedProtocol?
    weak var dismissDelegate : dismissProtocol?
    var indexPath : NSIndexPath?
    var isPresent : Bool = false
    var isMask : Bool = false
    var transitionContext : UIViewControllerContextTransitioning?
    
   
    
    //告诉系统modal动画由Animator负责
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //UIViewControllerAnimatedTransitioning
        isPresent = true;
        return self
    }

    
     //告诉系统dismiss动画有Animator负责
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
       
        isPresent = false
        return self
    }
    
}


extension ADBrowserAnimator : UIViewControllerAnimatedTransitioning{
    
    
    //返回动画的执行时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }
    
    
    //用来做具体的动画
    //isMask是否为圆形
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if isPresent{
            
            if isMask {
                maskPresentAnimate(transitionContext)
            }else{
                presentAnimate(transitionContext)
            }
            
        }else{
            if isMask {
                maskDismissAnimate(transitionContext)
            }else{
                dismissAnimate(transitionContext)
            }
        }
        
    }
    
}


 // MARK: - 非圆形的modal情形
extension ADBrowserAnimator{
  
    func presentAnimate(transitionContext: UIViewControllerContextTransitioning) {
        
        //获取用来做转场动画的“舞台”
        let containerView = transitionContext.containerView()
        containerView?.backgroundColor = UIColor.blackColor()
        
        //获取modal出来的View
//           present时先将modal出来的View加到转场舞台上并设置为透明,alpha = 0
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        toView?.alpha = 0
        containerView?.addSubview(toView!)
        
        //拿到delegate给的ImageView
        guard let presentDelegate = presentDelegate else{
            return
        }
//         而后通过代理方法获取到点击的cell所在的位置与Image设置给一个imageView
        let imageView = presentDelegate.getImageView(indexPath!)
//          将imageView添加到舞台上
        containerView?.addSubview(imageView)
        
//         而后通过UIView动画设置一定时间后imageView的frame
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
//        此frame是通过代理方法getEndRect获取到的
            imageView.frame = presentDelegate.getEndRect(self.indexPath!)
        }){(_) -> Void in
//              imageView的frame设置完成后令modal出来的view显示，alpha = 1
            toView?.alpha = 1
//             而后移除ImageView，关闭上下文动画
            imageView.removeFromSuperview()
            
        
            transitionContext.completeTransition(true)
        }
        
    }
}





extension ADBrowserAnimator{
    func dismissAnimate(transitionContext : UIViewControllerContextTransitioning) {
        //判断代理对象是否存在，不存在就不必继续执行了
        guard let dismissDelegate = dismissDelegate, presentDelegate = presentDelegate else {
            return
        }
        
        //dissmiss时先获取转场舞台，背景颜色设置为透明，
        let containerView = transitionContext.containerView()
        containerView?.backgroundColor = UIColor.clearColor()
        
        //并将modal前的view从父视图移除（也就是从舞台移除）
        //  modal前的view
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        fromView?.removeFromSuperview()
//        通过代理方法，获取dismiss时的view(BrowserView里获取)添加到舞台上
        let imageView = dismissDelegate.getImageView()
        containerView?.addSubview(imageView)
        
//        获取present时点击的cell与cell位于window的rect
        //注意：这里是present时的代理，所以present时有个Cell为空的判断
        //因为点击之后在滚动的时候,屏幕外的Cell就为空。
        //此时Rect为空就好，而如果cell为空就先让CollectionView滚动到相应indexPath
        //再取cell的值就好。dimiss的代理方法其实就是获取屏幕显示的那个Cell是第几组几行
        //因为放大显示时,cell的宽为屏幕宽,高是根据原比例计算所以只能显示一个cell
        //也就是结束时的Cell
        let startRect = presentDelegate.getStartRect(dismissDelegate.getEndRect())
        
        guard let homeCell = presentDelegate.getEndCell(dismissDelegate.getEndRect()) else {
//            如果cell不存在就直接令ImageView隐藏，关闭舞台,操作结束
        UIView .animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                            imageView.alpha = 0
                        }) { (_) -> Void in
                            transitionContext.completeTransition(true)
                        }
                        return
                    }
//        如果cell存在就令cell隐藏，alpha=0
        homeCell.alpha = 0
        
//        随后通过UiView动画，在一定时间之内令舞台上imageView的frame = present时cell位于window的rect，
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
//            如果cell的rect为Zero就令imageView的alpha = 0 而后显示cell关闭舞台
            if startRect == CGRectZero{
                imageView.alpha = 0
            }else{
                imageView.frame = startRect
            }
            
        
        
        }){
//            随后显示cell关闭舞台
            (_) -> Void in
            homeCell.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}

 // MARK:圆形的modal情形
extension ADBrowserAnimator{
    
    func maskPresentAnimate(transitionContext : UIViewControllerContextTransitioning) {
        
//        依旧是获取上下文舞台与toView，不过toView不隐藏就添加到舞台上
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView()
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        
        transitionContext.containerView()!.addSubview(toView!)
        
        
        guard let presentDelegate = presentDelegate else{return}
        
        guard let indexPath = indexPath else{return}
        
//        此时modal之前点击的cell的image保存在ImageView中，同时设置ImageView的frame为cell的rect

        let imageView = presentDelegate.getImageView(indexPath)
        imageView.frame = presentDelegate.getStartRect(indexPath)
       
//        结束时的圆形是通过layer来设置，Layer的路径通过贝兹路径设置，显示过程通过核心动画显示。
        
//        开始的圆形是通过代理方法获取到modal之前的cell位于window的rect来设置的
        let startCircle = UIBezierPath(ovalInRect: presentDelegate.getStartRect(indexPath))
        
         // 计算半径
        //通过imageView的中心x、y与屏幕中心的x、y -imageView.center.x、y ，谁大取谁获得底和高

        let x = max(imageView.center.x,UIScreen.mainScreen().bounds.width - imageView.center.x)
        let y = max(imageView.center.y, CGRectGetHeight(UIScreen.mainScreen().bounds) - imageView.center.y)
        //        通过勾股pow获得斜边长即为放大后imageView的半径也就是圆形的半径
        let startRadius = sqrt(pow(x, 2) + pow(y, 2))
        
        
//        结束时的路径UIBezierPath(ovalInRect: CGRectInset(imageView.frame, -startRadius, -startRadius))
        
        let endPath = UIBezierPath(ovalInRect: CGRectInset(imageView.frame, -startRadius, -startRadius))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = endPath.CGPath
        toView?.layer.mask = shapeLayer
      
//        通过给layer添加核心动画与核心动画的fromValue与endValue来显示圆形变大的过程
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startCircle.CGPath
        animation.toValue = endPath.CGPath
        animation.duration = transitionDuration(transitionContext)
//        核心动画结束后通过重写的代理方法，停止上下文平台，取消跳转后的ViewController的layer.mask并让modal前的View移除(dismiss的时候需要)
        
        animation.delegate = self
        shapeLayer.addAnimation(animation, forKey: "")
    }

    
    
    //核心动画的代理方法
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if isMask {
            
            transitionContext?.completeTransition(true)
            
            transitionContext?.viewControllerForKey(UITransitionContextToViewControllerKey)?.view.layer.mask = nil
            transitionContext?.viewForKey(UITransitionContextFromViewKey)?.removeFromSuperview()
        }
    }
    
}



extension ADBrowserAnimator {

    func maskDismissAnimate(transitionContext : UIViewControllerContextTransitioning) {
        
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView()
           //        dismiss的时候先拿到dismiss前的View
        //用于mask操作
        let fromeView = transitionContext.viewForKey(UITransitionContextFromViewKey)

            //拿到要返回的尺寸

    
        let startRect = presentDelegate?.getStartRect((dismissDelegate?.getEndRect())!)
       
//        以rect位置画一个贝兹圆形路径
        let endPath = UIBezierPath(ovalInRect: startRect!)
        
        
//        通过舞台的宽高与勾股定理获取一个圆的直径，而后/2得到半径绘制一个圆
        let radius = sqrt(pow((containerView?.frame.size.height)!,2)+pow((containerView?.frame.size.width)!, 2)) / 2
    
//       以上下文舞台中心为圆点，绘制开始时的大圆
        let startPath = UIBezierPath(arcCenter: containerView!.center,radius: radius,startAngle: 0,endAngle: CGFloat(M_PI * 2), clockwise:true)
        
        //  定义一个layer，Layer的半径为结束时的小圆半径
//        背景色为透明，设置给dismiss前的view.layer.mask
//        而后给Layer添加一个核心动画，动画开始值为大圆路径结束为小圆路径
//        同样设置代理对象为自身，方便通过代理对象移除操作
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = endPath.CGPath
        shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        fromeView!.layer.mask = shapeLayer
        
        let animate = CABasicAnimation(keyPath: "path")
        animate.fromValue = startPath.CGPath
        animate.toValue = endPath.CGPath
        animate.duration = transitionDuration(transitionContext)
        animate.delegate = self
        shapeLayer.addAnimation(animate, forKey: "")
        
    }
}











