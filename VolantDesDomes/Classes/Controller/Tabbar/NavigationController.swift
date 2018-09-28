//
//  NavigationController.swift
//  VolantDesDomes
//
//  Created by Drusy on 29/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyUserDefaults

class NavigationController: UINavigationController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Defaults[.darkTheme] ? enableDarkMode() : disableDarkMode()
        
        NotificationCenter.default.rx
            .notification(Notification.Name.darkModeEnabled)
            .subscribe(onNext: { [weak self] notification in
                self?.enableDarkMode()
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(Notification.Name.darkModeDisabled)
            .subscribe(onNext: { [weak self] notification in
                self?.disableDarkMode()
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(Notification.Name.themeUpdated)
            .startWith(Notification(name: .themeUpdated))
            .subscribe(onNext: { [weak self] notification in
                self?.themeUpdated()
            })
            .disposed(by: disposeBag)

        navigationBar.prefersLargeTitles = true
        navigationBar.isTranslucent = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Defaults[.darkTheme] ? .lightContent : .default
    }
    
    // MARK: -
    
    func enableDarkMode() {
        navigationBar.barStyle = .black
    }
    
    func themeUpdated() {
        navigationBar.tintColor = StyleManager.shared.tintColor
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func disableDarkMode() {
        navigationBar.barStyle = .default
    }
}
