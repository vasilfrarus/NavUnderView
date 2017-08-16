//
//  B32UnderView.swift
//  NavUnderView
//
//  Created by Vasiliy Fedotov on 12/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit

class B32UnderView: UIView {

    private var _navigationBar: UINavigationBar!
    private var _lineView: UIView!
    private var _labelView: UILabel!
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        clipsToBounds = true
        
        _navigationBar = UINavigationBar()
        insertSubview(_navigationBar, at: 0)
        
        _navigationBar.translatesAutoresizingMaskIntoConstraints = false
        _navigationBar.heightAnchor.constraint(equalToConstant: 2000).isActive = true
        _navigationBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        _navigationBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _navigationBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        _labelView = UILabel()
        addSubview(_labelView)

        let topLabelInset: CGFloat = 10.0
        let bottomLabelInset: CGFloat = topLabelInset
        let leftLabelInset: CGFloat = 30.0
        let rightLabelInset: CGFloat = leftLabelInset
        
        _labelView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = _labelView.topAnchor.constraint(equalTo: topAnchor, constant: topLabelInset)
        topConstraint.priority = 1
        topConstraint.isActive = true

        let bottomConstraint = _labelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0*bottomLabelInset)
//        bottomConstraint.priority = 1
        bottomConstraint.isActive = true
        
        _labelView.leftAnchor.constraint(equalTo: leftAnchor, constant: leftLabelInset).isActive = true
        _labelView.rightAnchor.constraint(equalTo: rightAnchor, constant: -1.0*rightLabelInset).isActive = true
        
        
        _lineView = UIView()
        _lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        addSubview(_lineView)
        
        _lineView.translatesAutoresizingMaskIntoConstraints = false
        _lineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        _lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        _lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        _lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    var barTintColor: UIColor? {
        get {
            return _navigationBar.barTintColor
        }
        
        set {
            _navigationBar.barTintColor = newValue
        }
    }
    
    var label: UILabel {
        return _labelView
    }
    
    
    
}
