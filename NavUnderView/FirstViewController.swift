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
    
    static var transitionNavUnderView: UIView?
    static var anotherTransitionNavUnderView: UIView?
    
    override init() {
        super.init()
        
        
        if SecondViewControllerAnimator.transitionNavUnderView == nil ||
            SecondViewControllerAnimator.anotherTransitionNavUnderView == nil {
            
            let getView: ((Void) -> UIView) = {
                let additionalView = UIView()
                additionalView.clipsToBounds = true
                
                let navBar = UINavigationBar()
                additionalView.addSubview(navBar)
                
                navBar.translatesAutoresizingMaskIntoConstraints = false
                navBar.heightAnchor.constraint(equalToConstant: 2000).isActive = true
                navBar.topAnchor.constraint(equalTo: additionalView.topAnchor).isActive = true
                navBar.leftAnchor.constraint(equalTo: additionalView.leftAnchor).isActive = true
                navBar.rightAnchor.constraint(equalTo: additionalView.rightAnchor).isActive = true
                
                let lineView = UIView()
                lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                
                additionalView.addSubview(lineView)
                
                lineView.translatesAutoresizingMaskIntoConstraints = false
                lineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                lineView.bottomAnchor.constraint(equalTo: additionalView.bottomAnchor).isActive = true
                lineView.leftAnchor.constraint(equalTo: additionalView.leftAnchor).isActive = true
                lineView.rightAnchor.constraint(equalTo: additionalView.rightAnchor).isActive = true
                
                additionalView.layoutIfNeeded()
                
                return additionalView
            }
            
            SecondViewControllerAnimator.transitionNavUnderView = getView()
            SecondViewControllerAnimator.anotherTransitionNavUnderView = getView()
            
        }
        
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
            
            SecondViewControllerAnimator.transitionNavUnderView!.layoutIfNeeded()
        }
        
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let duration = self.transitionDuration(using: transitionContext)
        
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from)  as? SecondViewController else { return }
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let transitionToNoNavBar = (toVC.navigationController == nil)
        let transitionToStandardNavBar = !(toVC is SecondViewController)
        
        let finalFrameTo : CGRect = transitionContext.finalFrame(for: toVC)
        let offsetFrame : CGRect = finalFrameTo.offsetBy(dx: UIScreen.main.bounds.width, dy: 0)
        
        containerView.insertSubview(toView, belowSubview: fromView)
        
        fromView.frame = finalFrameTo
        toView.frame = finalFrameTo
        
        
        let fromVCHeightConstraint = fromVC.underviewHeightConstraint
        let fromVCHeightConstraintConst = fromVCHeightConstraint!.constant
        
        let fromVCUnderView = fromVC.underView!
        var fromVCUnderViewHeight = fromVCUnderView.bounds.height
        
        let fromVCUnderLabel = fromVC.underLabel!
        
        let fromVCScrollView = fromVC.scrollView!
        let fromVCScrollViewContentOffset = fromVCScrollView.contentOffset.y
        
        let transitionNavUnderView = SecondViewControllerAnimator.transitionNavUnderView!
        transitionNavUnderView.frame = fromVCUnderView.frame
        transitionNavUnderView.layoutIfNeeded()

        // animation to VC without NavigationController
        let animateToNoNavigationBarViewController = {

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
        
        // animation to VC with standart NavigationController
        let animateToStandartNavigationBarViewController = { (collapsed: Bool) -> Void in
            
            toView.addSubview(transitionNavUnderView)
            
            fromVCHeightConstraint!.constant = fromVC.underviewCollapsedHeight

            let toNavVCScrollView: UIScrollView? = collapsed ? (toVC as! SecondViewController).scrollView : nil
            let toNavVCScrollViewOffset: CGFloat? = collapsed ? toNavVCScrollView!.contentOffset.y : nil
            if collapsed {
                let transitionNavUnderViewHeight = transitionNavUnderView.frame.height
                toNavVCScrollView!.contentOffset.y -= (transitionNavUnderViewHeight <= fromVC.underviewCollapsedHeight) ? 0.0 : transitionNavUnderViewHeight
            }

            transitionNavUnderView.layoutIfNeeded()
            
            UIView.animate(withDuration: duration, animations: {
                
                toView.frame = finalFrameTo
                fromView.frame = offsetFrame
                
                fromVCScrollView.contentOffset.y = fromVCScrollViewContentOffset + fromVCUnderViewHeight
                
                transitionNavUnderView.frame.size.height = fromVC.underviewCollapsedHeight
                transitionNavUnderView.layoutIfNeeded()
                
                fromView.layoutIfNeeded()
                
                if let toNavVCScrollViewOffset = toNavVCScrollViewOffset {
                    toNavVCScrollView!.contentOffset.y = toNavVCScrollViewOffset
                }
                
            }, completion: { result in
                transitionNavUnderView.removeFromSuperview()
                
                if let navBar = toVC.navigationController?.navigationBar, !collapsed {
                    navBar.setHideShadowView(false)
                }
                
                fromVCHeightConstraint!.constant = fromVCHeightConstraintConst
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        }
        
        
        // animation to VC with SecondViewController NavigationController
        let animateToCustomNavigationBarViewController = {

            let toNavVC = toVC as! SecondViewController
            
            let toNavVCHeightConstraint = toNavVC.underviewHeightConstraint
            let toNavVCHeightConstraintConst = toNavVCHeightConstraint!.constant
            
            let toNavVCUnderView = toNavVC.underView!
            var toNavVCUnderViewHeight = toNavVCUnderView.bounds.height
            let toNavVCUnderLabel = toNavVC.underLabel!
            
            let toNavVCScrollView = toNavVC.scrollView!
            
            if toNavVCUnderViewHeight <= fromVC.underviewCollapsedHeight {
                animateToStandartNavigationBarViewController(true)
                return
            }
            
            let fromVCUnderviewDefaultHeight = fromVC.underviewHeightDefault!
            let toNavVCUnderviewDefaultHeight = toNavVC.underviewHeightDefault!
            
            if (fromVCUnderviewDefaultHeight > toNavVCUnderviewDefaultHeight) {
                // 1
                toView.addSubview(transitionNavUnderView)
                
                toNavVCUnderView.isHidden = true
                toNavVCScrollView.contentOffset.y = fromVCScrollView.contentOffset.y
                
                let labelSnapshot = toNavVCUnderLabel.snapshotView(afterScreenUpdates: true)!
                labelSnapshot.frame = toNavVCUnderLabel.frame
                transitionNavUnderView.addSubview(labelSnapshot)
                
                let defaultXCoordinate = transitionNavUnderView.center.x
                
                transitionNavUnderView.center.x -= toView.bounds.width
                
                fromVCHeightConstraint!.constant = toNavVC.underviewHeightConstraintConstantDefault
                
                fromVC.underLabel.isHidden = (fromVCUnderViewHeight == fromVC.underviewCollapsedHeight)
                
                transitionNavUnderView.layoutIfNeeded()

                UIView.animate(withDuration: duration, animations: {
                    
                    toView.frame = finalFrameTo
                    fromView.frame = offsetFrame
                    
                    fromVCScrollView.contentOffset.y = toNavVC.scrollViewDefaultYOffset
                    fromView.layoutIfNeeded()
                    
                    transitionNavUnderView.center.x = defaultXCoordinate
                    transitionNavUnderView.frame.size.height = toNavVC.underviewHeightDefault!
                    transitionNavUnderView.layoutIfNeeded()
                    
                    toNavVCScrollView.contentOffset.y = toNavVC.scrollViewDefaultYOffset
                    
                }, completion: { result in
                    toNavVCUnderView.isHidden = false
                    fromVC.underLabel.isHidden = false
                    
                    labelSnapshot.removeFromSuperview()
                    transitionNavUnderView.removeFromSuperview()
                    
                    fromVCHeightConstraint!.constant = fromVCHeightConstraintConst
                    
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
                
                
            } else {
                // 2

                // fromView preparation
                fromView.addSubview(transitionNavUnderView)

                fromVCUnderView.isHidden = true
                
                let labelSnapshot = fromVCUnderLabel.snapshotView(afterScreenUpdates: false)!
                labelSnapshot.frame = fromVCUnderLabel.frame
                transitionNavUnderView.addSubview(labelSnapshot)
                
                let fromVCCurrentContentOffset = fromVCScrollView.contentOffset.y
                let fromVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                
                if fromVCUnderViewHeight <= fromVC.underviewCollapsedHeight {
                    fromVCUnderLabel.isHidden = true
                }
                
                
                // toView preparation
                let anotherTransitionNavUnderView = SecondViewControllerAnimator.anotherTransitionNavUnderView!
                anotherTransitionNavUnderView.frame = transitionNavUnderView.frame
                anotherTransitionNavUnderView.layoutIfNeeded()
                toView.addSubview(anotherTransitionNavUnderView)
                
                let labelSnapshot2 = toNavVCUnderLabel.snapshotView(afterScreenUpdates: true)!
                labelSnapshot2.frame = toNavVCUnderLabel.frame
                anotherTransitionNavUnderView.addSubview(labelSnapshot2)

                toNavVCUnderView.isHidden = true

                let toVCCurrentContentOffset = toNavVCScrollView.contentOffset.y
                let toVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                toNavVCScrollView.contentOffset.y += toVCContentOffsetDiff
                
                let toVCUnderLabelCenterX = anotherTransitionNavUnderView.center.x
                anotherTransitionNavUnderView.center.x -= toView.bounds.width

                transitionNavUnderView.layoutIfNeeded()
                anotherTransitionNavUnderView.layoutIfNeeded()

                UIView.animate(withDuration: duration, animations: {

                    toView.frame = finalFrameTo
                    fromView.frame = offsetFrame
                    
                    // fromView animation
                    transitionNavUnderView.frame.size.height = toNavVCUnderViewHeight
                    transitionNavUnderView.layoutIfNeeded()
                    
                    fromVCScrollView.contentOffset.y -= fromVCContentOffsetDiff

                    fromVCUnderLabel.isHidden = false
                    
                    // toView animation
                    anotherTransitionNavUnderView.center.x = toVCUnderLabelCenterX
                    anotherTransitionNavUnderView.frame.size.height = toNavVCUnderView.bounds.height
                    anotherTransitionNavUnderView.layoutIfNeeded()
                    
                    toNavVCScrollView.contentOffset.y = toVCCurrentContentOffset
                    
                    
                }, completion: { result in
                    // fromView restoration
                    fromVCUnderView.isHidden = false

                    labelSnapshot.removeFromSuperview()
                    transitionNavUnderView.removeFromSuperview()
                    
                    fromVCScrollView.contentOffset.y = fromVCCurrentContentOffset

                    // toView restoration
                    toNavVCUnderView.isHidden = false

                    labelSnapshot2.removeFromSuperview()
                    anotherTransitionNavUnderView.removeFromSuperview()
                    
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            }
        
        }
 
        
        if transitionToNoNavBar {
            animateToNoNavigationBarViewController()
        } else {
            if transitionToStandardNavBar {
                animateToStandartNavigationBarViewController(false)
            } else {
                animateToCustomNavigationBarViewController()
            }
        }
        
        
    }
    
}

