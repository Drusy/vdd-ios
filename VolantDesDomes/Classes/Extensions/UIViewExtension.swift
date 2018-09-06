//
//  UIViewExtension.swift
//  VolantDesDomes
//
//  Created by Drusy on 05/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

// MARK: - Gradient

extension UIView {
    enum GradientDirection {
        case vertical
        case horizontal
    }
    
    @discardableResult
    func applyGradiant(withStartingColor start: UIColor, endingColor end: UIColor, direction: GradientDirection) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        gradient.colors = [
            start.cgColor,
            end.cgColor
        ]
        
        switch direction {
        case .horizontal:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.locations = [0.0, 1.0]
            
        case .vertical:
            gradient.startPoint = CGPoint(x: 0.5, y: 1)
            gradient.endPoint = CGPoint(x: 0.5, y: 0)
            gradient.locations = [0.0, 1.0]
        }
        
        layer.insertSublayer(gradient, at: 0)
        
        return gradient
    }
}

// MARK: - Autolayout

extension UIView {

    func fit(toSubview subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        let views: [String: UIView] = ["subview": subview]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|",
                                                                 options: NSLayoutFormatOptions(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|",
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: views)
        addConstraints(verticalConstraints)
        addConstraints(horizontalConstraints)
    }
    
    func horizontalFit(toSubview subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        let views: [String: UIView] = ["subview": subview]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[subview]|",
                                                                   options: NSLayoutFormatOptions(rawValue: 0),
                                                                   metrics: nil,
                                                                   views: views)
        addConstraints(horizontalConstraints)
    }
    
    func topFit(toSubview subview: UIView, constant: CGFloat = 0) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = NSLayoutConstraint(item: subview,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: self,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: 0)
        
        addConstraint(topConstraint)
    }
    
    func verticalFit(toSubview subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        let views: [String: UIView] = ["subview": subview]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[subview]|",
                                                                 options: NSLayoutFormatOptions(rawValue: 0),
                                                                 metrics: nil,
                                                                 views: views)
        addConstraints(verticalConstraints)
    }
}
