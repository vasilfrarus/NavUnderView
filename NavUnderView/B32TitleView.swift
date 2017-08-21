//
//  B32TitleView.swift
//  NavUnderView
//
//  Created by Admin on 21/08/2017.
//  Copyright © 2017 1C Rarus. All rights reserved.
//

import UIKit

class B32TitleView: UIView {
    
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        
        self.backgroundColor = UIColor.blue
        self.clipsToBounds = false
        
        titleLabel = UILabel()
        
        addSubview(titleLabel)
    }
    
    var title: String? {
        get {
            return titleLabel.text
        }
        
        set {
            titleLabel.text = newValue
        }
    }

    
    func setLabelCopyOf(_ label: UILabel, withRect rect: CGRect, withPointSize size: CGFloat) {

        titleLabel.textColor = UIColor.green // label.textColor
        titleLabel.numberOfLines = label.numberOfLines
        titleLabel.font = label.font
        titleLabel.text = label.text

        titleLabel.frame = label.superview!.convert(label.frame, to: self)
        titleLabel.transform = label.transform
//        titleLabel.sizeToFit()
        
        
//        let frameInThisView = label.superview!.convert(rect, to: self)
//        titleLabel.frame = frameInThisView
//        titleLabel.font = label.font.withSize(size)
        
    }
    
}
