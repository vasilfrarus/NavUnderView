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
    private var swipeToBackInteractor : UIPercentDrivenInteractiveTransition?
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var underView: UIView!
    fileprivate var orientationChanged: Bool = true
    
    @IBOutlet weak var underviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var underLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installGestureRecognizer()
        
        scrollView.delegate = self
        (scrollView as! UITableView).dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Do any additional setup after loading the view.
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
            
            print("statusBarHeight: \(statusBarHeight), underViewHeight: \(underViewHeight), navBarHeight: \(navBarHeight)")
            
            
            let scrollToTop = (scrollView.contentInset.top == abs(scrollView.contentOffset.y))
            scrollView.contentInset = edgeInsets
            scrollView.scrollIndicatorInsets = edgeInsets
            
            if scrollToTop {
                scrollView.setContentOffset(CGPoint(x: 0, y: -1.0 * scrollView.contentInset.top), animated: false)
            }
            
            scrollViewDidScroll(self.scrollView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func didRotated() {
        orientationChanged = true
        
        underviewHeightConstraint.constant = 100
        
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

extension SecondViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let navStatusHeight = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.bounds.height ?? 0)

        let yoffset = scrollView.contentOffset.y + navStatusHeight
        
        underviewHeightConstraint.constant = (yoffset > 0.0) ? 0.0 : abs(yoffset)
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
