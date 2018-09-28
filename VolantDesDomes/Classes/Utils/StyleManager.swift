//
//  StyleManager.swift
//  VolantDesDomes
//
//  Created by Drusy on 28/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation
import SwiftiumKit
import SwiftyUserDefaults
import RxSwift

class StyleManager {
    static let shared = StyleManager()
    
    private let disposeBag = DisposeBag()
    private var tintColorViews = [UIView]()
    
    private init() {
        NotificationCenter.default.rx
            .notification(Notification.Name.themeUpdated)
            .subscribe(onNext: { [weak self] notification in
                self?.setupApplicationAppearance()
            })
            .disposed(by: disposeBag)
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
    
    var tintColor: UIColor {
        return Defaults[.darkTheme] ?
            UIColor(hex: Defaults[.tintColorDarkTheme]) :
            UIColor(hex: Defaults[.tintColor])
    }
    
    var backgroundColor: UIColor {
        return Defaults[.darkTheme] ?
            UIColor(hex: "2f2f2f") :
            UIColor(hex: "ffffff")
    }
    
    var groupTableViewBackgroundColor: UIColor {
        return Defaults[.darkTheme] ?
            backgroundColor :
            .groupTableViewBackground
    }
    
    var backgroundContentColor: UIColor {
        return Defaults[.darkTheme] ?
            UIColor(hex: "3f3f3f") :
            UIColor(hex: "f7f7f7")
    }
    
    var textColor: UIColor {
        return Defaults[.darkTheme] ?
            UIColor(hex: "e2e2e2") :
            UIColor(hex: "000000")
    }
    
    var subtitleColor: UIColor {
        return Defaults[.darkTheme] ?
            UIColor(hex: "aaaaaa") :
            UIColor(hex: "7c7c7c")
    }
}
