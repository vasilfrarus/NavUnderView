//
//  SecondViewController.swift
//  NavUnderView
//
//  Created by Admin on 09/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit
import LoremIpsum

class SecondViewController: UIViewController {

    static var transitionIsOn: Bool = false
    
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    var swipeToBackInteractor : UIPercentDrivenInteractiveTransition?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var underView: UIView!
    fileprivate var orientationChanged: Bool = true
    
    @IBOutlet weak var underviewHeightConstraint: NSLayoutConstraint!
    let underviewCollapsedHeight: CGFloat = 0.5
    var underviewHeightConstraintConstantDefault: CGFloat!
    var scrollViewDefaultTopInset: CGFloat!
    var scrollViewDefaultYOffset: CGFloat!
    var underviewHeightDefault: CGFloat?
    
    @IBOutlet weak var bottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var underLabel: UILabel!
    
    public var underLabelText: String?
    
    fileprivate let animator = SecondViewControllerAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = UIColor.white
        
        underviewHeightConstraintConstantDefault = underviewHeightConstraint.constant
        
        installGestureRecognizer()
        
        scrollView.delegate = self
        (scrollView as! UITableView).dataSource = self
        
        // relocate shadowView
        
        let lineView = UIView(frame: CGRect.zero)
        lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        underView.addSubview(lineView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.bottomAnchor.constraint(equalTo: underView.bottomAnchor).isActive = true
        lineView.leftAnchor.constraint(equalTo: underView.leftAnchor).isActive = true
        lineView.rightAnchor.constraint(equalTo: underView.rightAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: underviewCollapsedHeight).isActive = true
        
        if let underLabelText = underLabelText {
            underLabel.text = underLabelText
        }
        
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
            scrollViewDefaultTopInset = consentHeight
            scrollViewDefaultYOffset = -1.0 * scrollView.contentInset.top
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
        
        navigationController?.navigationBar.setHideShadowView(true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
            SecondViewController.transitionIsOn = true
            
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
            SecondViewController.transitionIsOn = false
            
        default:
            print("Swift switch must be exhaustive, thus the default")
        }
    }
    
}

extension SecondViewController : UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop {
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
        guard !SecondViewController.transitionIsOn else { return } // do not work at transition
        
        let navStatusHeight = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.bounds.height ?? 0)
        
        let yoffset = scrollView.contentOffset.y + navStatusHeight
        
        underviewHeightConstraint.constant = (yoffset >= 0.0) ? underviewCollapsedHeight : abs(yoffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !SecondViewController.transitionIsOn else { return } // do not work at transition

        guard let underviewHeightDefault = underviewHeightDefault else { return }
        
        let actualHeight = underView.bounds.height // underviewHeightConstraint.constant
        guard actualHeight > underviewCollapsedHeight && actualHeight < underviewHeightDefault  else { return }
        
        let scrollToTop = actualHeight < underviewHeightDefault/2.0
        underviewHeightConstraint.constant = scrollToTop ? underviewCollapsedHeight : underviewHeightDefault
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            let strongSelf = self!
            
            strongSelf.view.layoutIfNeeded()
            let yoffset = strongSelf.scrollView.contentOffset.y
            strongSelf.scrollView.contentOffset.y = scrollToTop ? yoffset + actualHeight : yoffset - (underviewHeightDefault - actualHeight)
            }, completion: nil
        )
    }

}

extension SecondViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TableCell\(arc4random_uniform(3)+1)")!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
}


extension SecondViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newVC = (storyboard.instantiateViewController(withIdentifier: "SecondVC") as! SecondViewController)
        newVC.underLabelText = LoremIpsum.words(withNumber: Int(arc4random_uniform(15)) + 3)
        self.navigationController?.pushViewController(newVC, animated: true)
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(40)
    }
}
