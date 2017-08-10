//
//  FirstViewController.swift
//  NavUnderView
//
//  Created by Admin on 09/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


class SecondViewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.25
    var presenting: Bool = true
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from)  as? SecondViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let finalFrameTo : CGRect = transitionContext.finalFrame(for: toVC)
        let offsetFrame : CGRect = finalFrameTo.offsetBy(dx: UIScreen.main.bounds.width, dy: 0)
        
        containerView.insertSubview(toView, belowSubview: fromView)
        
        fromView.frame = finalFrameTo
        toView.frame = finalFrameTo
        
        let fromVCHeightConstraint = fromVC.underviewHeightConstraint
        let fromVCHeightConstraintConst = fromVCHeightConstraint!.constant
        fromVCHeightConstraint!.constant = fromVC.underviewCollapsedHeight
        
        let underView = fromVC.underView!
        let underViewHeight = underView.bounds.height
        
        let scrollView = fromVC.scrollView!
        let scrollViewContentOffset = scrollView.contentOffset.y
        
        UIView.animate(withDuration: duration, animations: {
            
            toView.frame = finalFrameTo
            fromView.frame = offsetFrame
            
            scrollView.contentOffset.y = scrollViewContentOffset + underViewHeight
            
            fromView.layoutIfNeeded()
            
        }, completion: { result in
            
            fromVCHeightConstraint!.constant = fromVCHeightConstraintConst
             
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}

