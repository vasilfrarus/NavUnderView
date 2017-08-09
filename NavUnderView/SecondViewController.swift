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
    
    @IBOutlet weak var underviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        installGestureRecognizer()
        
        scrollView.delegate = self
        (scrollView as! UITableView).dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        bottomLabelConstraint.isActive = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setHideNavigationBarShadowView(true)
        
        let consentHeight = underView.bounds.height + UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.bounds.height ?? 0)
        let edgeInsets = UIEdgeInsetsMake(consentHeight, 0, 0, 0)
        
        scrollView.contentInset = edgeInsets
        scrollView.scrollIndicatorInsets = edgeInsets
        
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
