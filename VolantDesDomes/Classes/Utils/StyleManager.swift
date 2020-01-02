//
//  StyleManager.swift
//  VolantDesDomes
//
//  Created by Drusy on 28/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation
import SwiftiumKit

class StyleManager {
    static let shared = StyleManager()
    
    private init() {
        
    }
    
    // MARK: -
    
    func setupApplicationAppearance() {
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: tintColor
        ]
        
        UINavigationBar.appearance().tintColor = tintColor
        UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
        UITabBar.appearance().tintColor = tintColor
        
        // Navigation bar iOS 13 fix
        // https://sarunw.com/posts/uinavigationbar-changes-in-ios13/
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    lazy var tintColor: UIColor = {
        return UIColor(rgb: 0x209BD6)
    }()
}
