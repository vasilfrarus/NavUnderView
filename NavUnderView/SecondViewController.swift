//
//  SecondViewController.swift
//  NavUnderView
//
//  Created by Admin on 09/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    var swipeToBackInteractor : UIPercentDrivenInteractiveTransition?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var underView: UIView!
    fileprivate var orientationChanged: Bool = true
    
    @IBOutlet weak var underviewHeightConstraint: NSLayoutConstraint!
    var underviewHeightConstraintConstantDefault: CGFloat!
    var underviewHeightDefault: CGFloat?
    @IBOutlet weak var bottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var underLabel: UILabel!
    
    fileprivate let animator = SecondViewControllerAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        underviewHeightConstraintConstantDefault = underviewHeightConstraint.constant
        
        installGestureRecognizer()
        
        scrollView.delegate = self
        (scrollView as! UITableView).dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if orientationChanged {
            orientationChanged = false
            
            // get new insets
            let statusBarHeight = UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height
            let underViewHeight = underView.frame.height
            let navBarHeight = (navigationController?.navigationBar.bounds.height ?? 0)
            let consentHeight = underViewHeight + statusBarHeight + navBarHeight
            let edgeInsets = UIEdgeInsetsMake(consentHeight, 0, 0, 0)
            
            let scrollToTop = (scrollView.contentInset.top == abs(scrollView.contentOffset.y))
            scrollView.contentInset = edgeInsets
            scrollView.scrollIndicatorInsets = edgeInsets
            
            if scrollToTop {
                scrollView.setContentOffset(CGPoint(x: 0, y: -1.0 * scrollView.contentInset.top), animated: false)
            }
            
            scrollViewDidScroll(self.scrollView)
            
            underviewHeightDefault = underViewHeight
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.delegate = self
    }
    
    func didRotated() {
        orientationChanged = true
        
        underviewHeightConstraint.constant = underviewHeightConstraintConstantDefault
        
        view.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setHideNavigationBarShadowView(true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setHideNavigationBarShadowView(false)
    }
    
    func setHideNavigationBarShadowView(_ hide: Bool) {
        
        func findShadowImage(under view: UIView) -> UIImageView? {
            if view is UIImageView && view.bounds.size.height <= 3 {
                return (view as! UIImageView)
            }
            
            for subview in view.subviews {
                if let imageView = findShadowImage(under: subview) {
                    return imageView
                }
            }
            return nil
        }
        
        if let navBar = navigationController?.navigationBar, let view = findShadowImage(under: navBar) {
            
            view.isHidden = hide
        }
    
    }
    
    func installGestureRecognizer() {
        screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeToBackPan))
        screenEdgePanGestureRecognizer.edges = .left

        view.addGestureRecognizer(screenEdgePanGestureRecognizer)
    }
    
    func handleSwipeToBackPan(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        let viewTranslation = gestureRecognizer.translation(in: view)
        let progress = viewTranslation.x / view.bounds.width
        
        switch gestureRecognizer.state {
            
        case .began:
            swipeToBackInteractor = UIPercentDrivenInteractiveTransition()
            
            navigationController!.popViewController(animated: true)
            
        case .changed:
            
            swipeToBackInteractor?.update(progress)

        case .cancelled, .ended:
            
            if progress > 0.5 {
                swipeToBackInteractor?.finish()
            } else {
                swipeToBackInteractor?.cancel()
            }
            
            swipeToBackInteractor = nil
            
        default:
            print("Swift switch must be exhaustive, thus the default")
        }
    }
    
}

extension SecondViewController : UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop {
            animator.presenting = false
            return animator
        }
        
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeToBackInteractor
    }
    
    
}

extension SecondViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let navStatusHeight = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.bounds.height ?? 0)

        let yoffset = scrollView.contentOffset.y + navStatusHeight
        
        underviewHeightConstraint.constant = (yoffset > 0.0) ? 0.0 : abs(yoffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let underviewHeightDefault = underviewHeightDefault else { return }
        
        let actualHeight = underviewHeightConstraint.constant
        guard actualHeight > 0.0 && actualHeight < underviewHeightDefault  else { return }
        
        let scrollToTop = actualHeight < underviewHeightDefault/2.0
        underviewHeightConstraint.constant = scrollToTop ? 0 : underviewHeightDefault
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            let strongSelf = self!
            
            strongSelf.view.layoutIfNeeded()
            let yoffset = strongSelf.scrollView.contentOffset.y
            strongSelf.scrollView.contentOffset.y = scrollToTop ? yoffset + actualHeight : yoffset - (underviewHeightDefault - actualHeight)
        })
        
    }

}

extension SecondViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TableCell")!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
}
