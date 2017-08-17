//
//  SecondViewController.swift
//  NavUnderView
//
//  Created by Admin on 09/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit
import LoremIpsum


fileprivate let navItemPlaceHolder = "   "

fileprivate enum B32UnderviewStatus {
    case hidden
    case shownPartially
    case shownFully
}

class SecondViewController: UIViewController {

    fileprivate static var transitionIsOn: Bool = false
    
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    fileprivate var swipeToBackInteractor : UIPercentDrivenInteractiveTransition?

    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    
    fileprivate var scrollUnderView: UIScrollView! {
        return scrollView
    }
    
    fileprivate var underView: B32UnderView!
    private var orientationChanged: Bool = false
    private var firstAppearance: Bool = true

    fileprivate var underviewWasCollapsed: Bool = false
    
    fileprivate var underviewHeightConstraint: NSLayoutConstraint!
    fileprivate static let underviewCollapsedHeight: CGFloat = 0.5
    fileprivate var underviewHeightConstraintConstantDefault: CGFloat = 100
    fileprivate var underviewHeightDefault: CGFloat!
    fileprivate var scrollViewInsetDefault: CGFloat!
    
    fileprivate var underLabel: UILabel! {
        return underView.label
    }
    
    public var underLabelText: String?
    
    fileprivate static let animator = SecondViewControllerAnimator()
    
    
    var cellColor: [Int] = []
    var cellHeight: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = UIColor.white
        
        installGestureRecognizer()

        createUnderView()
        underView.barTintColor = navigationController?.navigationBar.barTintColor
        if let underLabelText = underLabelText {
            underLabel.text = underLabelText
        }
        underView.layoutIfNeeded()
        

        
        scrollUnderView.delegate = self
        (scrollUnderView as! UITableView).dataSource = self
        
        
        for i in 0..<20 {
            cellColor.append(Int(arc4random_uniform(3)+1))
            cellHeight.append(CGFloat(arc4random_uniform(40)+30))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.delegate = self
    }
    
    func didRotated() {
        let orientation = UIDevice.current.orientation
        guard orientation == .landscapeLeft ||
            orientation == .landscapeRight ||
            orientation == .portrait ||
            orientation == .portraitUpsideDown
            else { return }
        
        orientationChanged = true
        
        underviewHeightConstraint.constant = underviewHeightConstraintConstantDefault
        
        if (isViewLoaded && view.window != nil) {
            print("Rotated visible")
            
            recalcUnderViewPropertiesIfOrientationChanged()
            
        } else {
            print("Rotated invisible")
        }
        
    }
    
    func getStandartNavigationBarHeight() -> CGFloat {
        let statusBarHeight = UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height
        let navBarHeight = (navigationController?.navigationBar.bounds.height ?? 0)
        
        return statusBarHeight + navBarHeight
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setHideShadowView(true)
        
        if firstAppearance {
            firstAppearance = false

            let underViewHeight = underView.frame.height
            let standartNavigationBarHeight = getStandartNavigationBarHeight()

            underviewHeightDefault = underViewHeight
            scrollViewInsetDefault = standartNavigationBarHeight + underviewHeightDefault
            
            let edgeInsets = UIEdgeInsetsMake(scrollViewInsetDefault, 0, 0, 0)
            
            scrollUnderView.contentInset = edgeInsets
            scrollUnderView.scrollIndicatorInsets = edgeInsets
            
            scrollUnderView.setContentOffset(CGPoint(x: 0, y: -1.0 * scrollViewInsetDefault), animated: false)
            
        }
    }
    
    func recalcUnderViewPropertiesIfOrientationChanged() {
        
        guard orientationChanged else { return }
        
        scrollUnderView.delegate = nil
        
        orientationChanged = false

        let oldUnderviewHeightDefault = underviewHeightDefault!
        let oldScrollViewInsetDefault = scrollViewInsetDefault!
        let oldScrollViewOffset = scrollUnderView.contentOffset.y
        
        view.layoutIfNeeded()
        
        let underViewHeight = underView.frame.height
        let standartNavigationBarHeight = getStandartNavigationBarHeight()
        
        underviewHeightDefault = underViewHeight
        scrollViewInsetDefault = standartNavigationBarHeight + underviewHeightDefault
        
        let edgeInsets = UIEdgeInsetsMake(scrollViewInsetDefault, 0, 0, 0)
        
        scrollUnderView.contentInset = edgeInsets
        scrollUnderView.scrollIndicatorInsets = edgeInsets
        
        let oldStandartNavigationBarHeight = oldScrollViewInsetDefault - oldUnderviewHeightDefault
        
        let standartNavigationBarDiff = oldStandartNavigationBarHeight - standartNavigationBarHeight
        let underviewHeightDiff = oldUnderviewHeightDefault - underviewHeightDefault
        let navBarDiff = (standartNavigationBarDiff + underviewHeightDiff)
        
        if (oldScrollViewInsetDefault != -1.0 * oldScrollViewOffset)
        {
            let additional = oldStandartNavigationBarHeight + oldScrollViewOffset
            scrollUnderView.contentOffset.y = (-1 * standartNavigationBarHeight + additional)
            
        } else {
            scrollUnderView.contentOffset.y = (-1 * scrollViewInsetDefault)
        }
        
        recalcUnderviewHeightConstraint()
        
        scrollUnderView.delegate = self
    }
    
    func installGestureRecognizer() {
        screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeToBackPan))
        screenEdgePanGestureRecognizer.edges = .left

        view.addGestureRecognizer(screenEdgePanGestureRecognizer)
    }
    
    func createUnderView() {
        underView = B32UnderView()
        
        view.addSubview(underView)
        
        underView.translatesAutoresizingMaskIntoConstraints = false
        underView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        underView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        underView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        underviewHeightConstraint = underView.heightAnchor.constraint(lessThanOrEqualToConstant: underviewHeightConstraintConstantDefault)
        
        underView.label.numberOfLines = 4
        
        underviewHeightConstraint.isActive = true
    }
    
    func rewindScrollView(animated: Bool) {
        let actualHeight = underviewHeightConstraint.constant
        guard actualHeight > SecondViewController.underviewCollapsedHeight && actualHeight < underviewHeightDefault  else { return }
        
        let scrollToTop = actualHeight < underviewHeightDefault/2.0
        underviewHeightConstraint.constant = scrollToTop ? SecondViewController.underviewCollapsedHeight : underviewHeightDefault
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                let strongSelf = self!
                
                strongSelf.view.layoutIfNeeded()
                let yoffset = strongSelf.scrollUnderView.contentOffset.y
                strongSelf.scrollUnderView.contentOffset.y = scrollToTop ? yoffset + actualHeight : yoffset - (strongSelf.underviewHeightDefault - actualHeight)
                }, completion: nil
            )
            
        } else {
            let yoffset = scrollUnderView.contentOffset.y
            scrollUnderView.contentOffset.y = scrollToTop ? yoffset + actualHeight : yoffset - (underviewHeightDefault - actualHeight)

        }
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
            return SecondViewController.animator
        }
        
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeToBackInteractor
    }
    
}

extension SecondViewController : UIScrollViewDelegate {
    
    fileprivate func getUnderviewStatus() -> B32UnderviewStatus {
        let underviewHeight = underView.bounds.height
        
        if underviewHeight <= SecondViewController.underviewCollapsedHeight {
            return .hidden
        } else if underviewHeight >= underviewHeightDefault {
            return .shownFully
        }
        
        return .shownPartially
        
    }
    
    fileprivate func setTitleBarShown(_ shown: Bool, animated: Bool = true) {

        navigationItem.title = underLabel.text ?? navItemPlaceHolder
        
        if let label = navigationController?.navigationBar.getTitleLabel() {
            
            label.clipsToBounds = true
            
            let from = CGFloat(shown ? 0 : 1)
            let to = CGFloat(shown ? 1 : 0)
            
            if animated {
                label.alpha = from
                UIView.animate(withDuration: shown ? 0.5 : 0.125 , animations: {
                    label.alpha = to
                }, completion: { res in
                    label.alpha = to
                })
            } else {
                label.alpha = to
            }
        }
    }
    
    fileprivate func refreshNavigationBarTitle(animated: Bool = true) {
        
        let underviewStatus = getUnderviewStatus()
        
        if underviewStatus == .hidden && !underviewWasCollapsed {
            // was hidden now
            underviewWasCollapsed = true
            setTitleBarShown(true, animated: animated)
            
        } else if underviewStatus == .shownFully && underviewWasCollapsed {
            // was shown now
            underviewWasCollapsed = false
            setTitleBarShown(false, animated: animated)
            
        }
    }
    
    fileprivate func recalcUnderviewHeightConstraint() {
        let navStatusHeight = getStandartNavigationBarHeight()
        
        let yoffset = scrollView.contentOffset.y + navStatusHeight
        
        underviewHeightConstraint.constant = (yoffset >= 0.0) ? SecondViewController.underviewCollapsedHeight : abs(yoffset)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !SecondViewController.transitionIsOn else { return } // do not work at transition
        
        recalcUnderviewHeightConstraint()
        
        refreshNavigationBarTitle()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !SecondViewController.transitionIsOn else { return } // do not work at transition
        rewindScrollView(animated: true)
    }
    
    

}

extension SecondViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TableCell\(cellColor[indexPath.row])")!
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
        
        return CGFloat(cellHeight[indexPath.row])
    }
}


//-----


class SecondViewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    static var transitionNavUnderView: B32UnderView?
    static var anotherTransitionNavUnderView: B32UnderView?
    
    override init() {
        super.init()
        
        if SecondViewControllerAnimator.transitionNavUnderView == nil ||
            SecondViewControllerAnimator.anotherTransitionNavUnderView == nil {
            
            SecondViewControllerAnimator.transitionNavUnderView = B32UnderView()
            SecondViewControllerAnimator.anotherTransitionNavUnderView = B32UnderView()
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
        let fromVCUnderViewHeight = fromVCUnderView.bounds.height
        
        let fromVCUnderLabel = fromVC.underLabel!
        
        let fromVCScrollView = fromVC.scrollUnderView!
        let fromVCScrollViewContentOffset = fromVCScrollView.contentOffset.y
        
        let transitionNavUnderView = SecondViewControllerAnimator.transitionNavUnderView!
        transitionNavUnderView.frame = fromVCUnderView.frame
        transitionNavUnderView.layoutIfNeeded()
        
        let underviewCollapsedHeight = SecondViewController.underviewCollapsedHeight
        
        // animation to VC without NavigationController
        let animateToNoNavigationBarViewController = {
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
        
        // animation to VC with standart NavigationController
        let animateToStandartNavigationBarViewController = { (collapsed: Bool) -> Void in

            print("last transition to Standart \(collapsed ? "Collapsed" : ""), fromVCUnderview is small = \(fromVCUnderView.bounds.height == underviewCollapsedHeight)")
            
            toView.addSubview(transitionNavUnderView)
            transitionNavUnderView.barTintColor = toVC.navigationController?.navigationBar.barTintColor
            let transitionNavUnderViewHeightBefore = transitionNavUnderView.frame.size.height
            
            fromVCHeightConstraint!.constant = underviewCollapsedHeight
            
            let toNavVCScrollView: UIScrollView? = collapsed ? (toVC as! SecondViewController).scrollUnderView : nil
            let toNavVCScrollViewOffset: CGFloat? = collapsed ? toNavVCScrollView!.contentOffset.y : nil
            if collapsed {
                let transitionNavUnderViewHeight = transitionNavUnderView.frame.height
                toNavVCScrollView!.contentOffset.y -= (transitionNavUnderViewHeight <= underviewCollapsedHeight) ? 0.0 : transitionNavUnderViewHeight
            }
            
            transitionNavUnderView.layoutIfNeeded()
            
            UIView.animate(withDuration: duration, animations: {
                
                toView.frame = finalFrameTo
                fromView.frame = offsetFrame
                
                fromVCScrollView.contentOffset.y = fromVCScrollViewContentOffset + fromVCUnderViewHeight
                

                transitionNavUnderView.bounds.size.height = underviewCollapsedHeight
                transitionNavUnderView.center.y += (underviewCollapsedHeight - transitionNavUnderViewHeightBefore)/2.0
                transitionNavUnderView.layoutIfNeeded()
                
                fromVCUnderLabel.alpha = 0
                fromView.layoutIfNeeded()
                
                if let toNavVCScrollViewOffset = toNavVCScrollViewOffset {
                    toNavVCScrollView!.contentOffset.y = toNavVCScrollViewOffset
                }
                
            }, completion: { result in
                transitionNavUnderView.removeFromSuperview()
                
                if let navBar = toVC.navigationController?.navigationBar, !collapsed {
                    navBar.setHideShadowView(false)
                }

                fromVCUnderLabel.alpha = 1
                
                fromVCHeightConstraint!.constant = fromVCHeightConstraintConst
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        }
        
        
        // animation to VC with SecondViewController NavigationController
        let animateToCustomNavigationBarViewController = {

            let toNavVC = toVC as! SecondViewController
            
            let toNavVCUnderView = toNavVC.underView!
            let toNavVCUnderViewHeight = toNavVCUnderView.bounds.height
            let toNavVCUnderLabel = toNavVC.underLabel!
            
            let toNavVCScrollView = toNavVC.scrollUnderView!
            
            toNavVC.recalcUnderViewPropertiesIfOrientationChanged()
            if toNavVCUnderViewHeight <= underviewCollapsedHeight {
                animateToStandartNavigationBarViewController(true)
                return
            }

            let fromVCUnderviewDefaultHeight: CGFloat = fromVC.underviewHeightDefault
            let toNavVCUnderviewDefaultHeight: CGFloat = toNavVC.underviewHeightDefault!
            
            print("fromVCUnderviewDefaultHeight: \(fromVCUnderviewDefaultHeight), toNavVCUnderviewDefaultHeight: \(toNavVCUnderviewDefaultHeight)")
            
            if (fromVCUnderviewDefaultHeight > toNavVCUnderviewDefaultHeight) {
                // 1
                print("last transition #1, fromVCUnderview is small = \(fromVCUnderView.bounds.height == underviewCollapsedHeight)")
                
                // fromView preparation
                fromVCHeightConstraint!.constant = toNavVCUnderViewHeight
                fromVC.underLabel.isHidden = (fromVCUnderViewHeight == underviewCollapsedHeight)
                
                let fromVCCurrentContentOffset = fromVCScrollView.contentOffset.y
                let fromVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                
                // toView preparation
                toView.addSubview(transitionNavUnderView)
                transitionNavUnderView.barTintColor = toVC.navigationController?.navigationBar.barTintColor
                
                let labelSnapshot = toNavVCUnderLabel.snapshotView(afterScreenUpdates: true)!
                labelSnapshot.frame = toNavVCUnderLabel.frame
                labelSnapshot.alpha = 0
                transitionNavUnderView.addSubview(labelSnapshot)
                transitionNavUnderView.layoutIfNeeded()
                
                let defaultXCoordinate = transitionNavUnderView.center.x
                transitionNavUnderView.center.x -= toView.bounds.width
                let transitionNavUnderViewHeightBefore = transitionNavUnderView.bounds.size.height
                
                toNavVCUnderView.isHidden = true
                
                let toVCCurrentContentOffset = toNavVCScrollView.contentOffset.y
                let toVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                toNavVCScrollView.contentOffset.y += toVCContentOffsetDiff

                
                UIView.animate(withDuration: duration, animations: {
                    
                    toView.frame = finalFrameTo
                    fromView.frame = offsetFrame
                    
                    // fromView animation
                    fromVCScrollView.contentOffset.y -= fromVCContentOffsetDiff
                    fromView.layoutIfNeeded()

                    fromVCUnderLabel.alpha = 0
                    
                    // toView animation
                    
                    let newCenter = CGPoint(x: defaultXCoordinate, y: transitionNavUnderView.center.y + (toNavVCUnderView.bounds.height - transitionNavUnderViewHeightBefore)/2.0)
                    transitionNavUnderView.bounds.size.height = toNavVCUnderView.bounds.height
                    transitionNavUnderView.center = newCenter
                    transitionNavUnderView.layoutIfNeeded()
                    
                    toNavVCScrollView.contentOffset.y -= toVCContentOffsetDiff

                    labelSnapshot.alpha = 1
                    
                }, completion: { result in
                    // fromView restoration
                    fromVCScrollView.contentOffset.y = fromVCCurrentContentOffset
                    fromVC.underLabel.isHidden = false
                    fromVCHeightConstraint!.constant = fromVCHeightConstraintConst
                    fromVCUnderLabel.alpha = 1
                    
                    // toView restoration
                    toNavVCUnderView.isHidden = false
                    labelSnapshot.removeFromSuperview()
                    transitionNavUnderView.removeFromSuperview()
                    
                    toNavVCScrollView.contentOffset.y = toVCCurrentContentOffset

                    //
                    
                    
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
                
                
            } else {
                // 2
                print("last transition #2, fromVCUnderview is small = \(fromVCUnderView.bounds.height == underviewCollapsedHeight)")
                // fromView preparation
                fromView.addSubview(transitionNavUnderView)
                transitionNavUnderView.barTintColor = fromVC.navigationController?.navigationBar.barTintColor
                let transitionNavUnderViewHeightBefore = transitionNavUnderView.bounds.size.height
                
                let labelSnapshot = fromVCUnderLabel.snapshotView(afterScreenUpdates: false)!
                labelSnapshot.frame = fromVCUnderLabel.frame
                transitionNavUnderView.addSubview(labelSnapshot)
                
                let fromVCCurrentContentOffset = fromVCScrollView.contentOffset.y
                let fromVCContentOffsetDiff = toNavVCUnderViewHeight - fromVCUnderViewHeight
                
                if fromVCUnderViewHeight <= underviewCollapsedHeight {
                    fromVCUnderLabel.isHidden = true
                }
                
                if fromVCUnderViewHeight <= underviewCollapsedHeight {
                    labelSnapshot.isHidden = true
                }
                
                // toView preparation
                let anotherTransitionNavUnderView = SecondViewControllerAnimator.anotherTransitionNavUnderView!
                anotherTransitionNavUnderView.frame = transitionNavUnderView.frame
                anotherTransitionNavUnderView.layoutIfNeeded()
                toView.addSubview(anotherTransitionNavUnderView)
                anotherTransitionNavUnderView.barTintColor = toVC.navigationController?.navigationBar.barTintColor
                let anotherTransitionNavUnderViewHeightBefore = anotherTransitionNavUnderView.bounds.size.height
                
                let labelSnapshot2 = toNavVCUnderLabel.snapshotView(afterScreenUpdates: true)!
                labelSnapshot2.frame = toNavVCUnderLabel.frame
                labelSnapshot2.alpha = 0
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
                    let newCenter = CGPoint(x: transitionNavUnderView.center.x, y: transitionNavUnderView.center.y + (toNavVCUnderViewHeight - transitionNavUnderViewHeightBefore)/2.0)
                    transitionNavUnderView.bounds.size.height = toNavVCUnderViewHeight
                    transitionNavUnderView.center = newCenter
                    transitionNavUnderView.layoutIfNeeded()
                    
                    fromVCScrollView.contentOffset.y -= fromVCContentOffsetDiff
                    
                    fromVCUnderLabel.isHidden = false
                    labelSnapshot.alpha = 0
                    
                    // toView animation
                    let anotherNewCenter = CGPoint(x: toVCUnderLabelCenterX, y: anotherTransitionNavUnderView.center.y + (toNavVCUnderView.bounds.height - anotherTransitionNavUnderViewHeightBefore)/2.0)
                    anotherTransitionNavUnderView.bounds.size.height = toNavVCUnderView.bounds.height
                    anotherTransitionNavUnderView.center = anotherNewCenter
                    anotherTransitionNavUnderView.layoutIfNeeded()
                    
                    toNavVCScrollView.contentOffset.y = toVCCurrentContentOffset
                    
                    labelSnapshot2.alpha = 1
                    
                }, completion: { result in
                    // fromView restoration
                    fromVCUnderView.isHidden = false
                    
                    labelSnapshot.removeFromSuperview()
                    transitionNavUnderView.removeFromSuperview()
                    
                    fromVCScrollView.contentOffset.y = fromVCCurrentContentOffset
                    
                    // toView restoration
                    toNavVCUnderView.isHidden = false
                    toNavVCScrollView.contentOffset.y = toVCCurrentContentOffset
                    
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



