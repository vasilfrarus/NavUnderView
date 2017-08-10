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
    
    static var transitionNavUnderView: UIView?
    
    override init() {
        super.init()
        
        if SecondViewControllerAnimator.transitionNavUnderView == nil {
            SecondViewControllerAnimator.transitionNavUnderView = UIView()
            SecondViewControllerAnimator.transitionNavUnderView?.clipsToBounds = true
            
            let navBar = UINavigationBar()
            SecondViewControllerAnimator.transitionNavUnderView!.addSubview(navBar)
            
            navBar.heightAnchor.constraint(equalToConstant: 2000).isActive = true
            navBar.topAnchor.constraint(equalTo: SecondViewControllerAnimator.transitionNavUnderView!.topAnchor).isActive = true
            navBar.leftAnchor.constraint(equalTo: SecondViewControllerAnimator.transitionNavUnderView!.leftAnchor).isActive = true
            navBar.rightAnchor.constraint(equalTo: SecondViewControllerAnimator.transitionNavUnderView!.rightAnchor).isActive = true
            navBar.translatesAutoresizingMaskIntoConstraints = false

            let lineView = UIView()
            lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            
            SecondViewControllerAnimator.transitionNavUnderView!.addSubview(lineView)
            
            lineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            lineView.bottomAnchor.constraint(equalTo: SecondViewControllerAnimator.transitionNavUnderView!.bottomAnchor).isActive = true
            lineView.leftAnchor.constraint(equalTo: SecondViewControllerAnimator.transitionNavUnderView!.leftAnchor).isActive = true
            lineView.rightAnchor.constraint(equalTo: SecondViewControllerAnimator.transitionNavUnderView!.rightAnchor).isActive = true
            lineView.translatesAutoresizingMaskIntoConstraints = false
        }
        
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from)  as? SecondViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let transitionToStandardNavBar = !(toVC is SecondViewController)
        
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
        
        var transitionToStandardNavIsActive = false

        if transitionToStandardNavBar, let transitionNavUnderView = SecondViewControllerAnimator.transitionNavUnderView {
            transitionNavUnderView.frame = underView.frame
            transitionNavUnderView.layoutIfNeeded()
            
            toView.addSubview(transitionNavUnderView)
            
            transitionToStandardNavIsActive = true
        }
        
        UIView.animate(withDuration: duration, animations: {
            
            toView.frame = finalFrameTo
            fromView.frame = offsetFrame
            
            scrollView.contentOffset.y = scrollViewContentOffset + underViewHeight
            
            if transitionToStandardNavIsActive {
                SecondViewControllerAnimator.transitionNavUnderView!.frame.size.height = fromVC.underviewCollapsedHeight
                SecondViewControllerAnimator.transitionNavUnderView!.layoutIfNeeded()
                
            }
            
            fromView.layoutIfNeeded()
            
        }, completion: { result in
            if transitionToStandardNavIsActive {
                SecondViewControllerAnimator.transitionNavUnderView?.removeFromSuperview()
            }
            
            if let navBar = toVC.navigationController?.navigationBar {
                navBar.setHideShadowView(false)
            }
            
            fromVCHeightConstraint!.constant = fromVCHeightConstraintConst
             
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}

