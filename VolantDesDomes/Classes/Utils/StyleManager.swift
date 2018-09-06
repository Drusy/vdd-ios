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
    }
    
    lazy var tintColor: UIColor = {
        return UIColor(rgb: 0x1e77b2)
    }()
}
