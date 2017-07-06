//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by officeWanPlus on 2017/7/5.
//  Copyright © 2017年 Strawberry. All rights reserved.
//

import UIKit

class FadeOutAnimationControlller: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if let fromView = transitionContext.view(forKey: .from) {
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, animations: {
                fromView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
