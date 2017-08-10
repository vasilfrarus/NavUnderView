//
//  UINavigationBar+setHideNavigationBarShadowView.swift
//  NavUnderView
//
//  Created by Admin on 10/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
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
    
    func setHideShadowView(_ hide: Bool) {
        if let view = findShadowImage(under: self) {
            view.isHidden = hide
        }
    }
    
}
