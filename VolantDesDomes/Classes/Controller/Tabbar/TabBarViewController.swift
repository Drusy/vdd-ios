//
//  TabBarViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 29/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyUserDefaults

class TabBarViewController: UITabBarController {
    
    lazy var favoritesViewController: FavoritesStateViewController = {
        return FavoritesStateViewController()
    }()
    lazy var articlesViewController: PostsStateViewController = {
        return PostsStateViewController()
    }()
    lazy var homeViewController: CategoriesViewController = {
        return CategoriesViewController()
    }()
    lazy var pagesViewController: PagesViewController = {
        return PagesViewController()
    }()
    lazy var settingsViewController: SettingsViewController = {
        return SettingsViewController()
    }()
    
    lazy var favoritesNavigationController: NavigationController = {
        return NavigationController(rootViewController: favoritesViewController)
    }()
    lazy var articlesNavigationController: NavigationController = {
        return NavigationController(rootViewController: articlesViewController)
    }()
    lazy var homeNavigationController: NavigationController = {
        return NavigationController(rootViewController: homeViewController)
    }()
    lazy var pagesNavigationController: NavigationController = {
        return NavigationController(rootViewController: pagesViewController)
    }()
    lazy var settingsNavigationController: NavigationController = {
        return NavigationController(rootViewController: settingsViewController)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationUtils.shared.registerForLocalNotifications()
        setupTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if  Defaults[.appOpenCount] >= 5 {
            if #available(iOS 10.3, *){
                Defaults[.appOpenCount] = 0
                
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    // MARK: -
    
    func setupTabBar() {
        favoritesViewController.tabBarItem = UITabBarItem(
            title: "Favoris",
            image: #imageLiteral(resourceName: "tabbar-favorite"),
            tag: 0)
        articlesNavigationController.tabBarItem = UITabBarItem(
            title: "Articles",
            image: #imageLiteral(resourceName: "tabbar-list"),
            tag: 1)
        homeNavigationController.tabBarItem = UITabBarItem(
            title: "Catégories",
            image: #imageLiteral(resourceName: "tabbar-home"),
            tag: 2)
        pagesNavigationController.tabBarItem = UITabBarItem(
            title: "Pages",
            image: #imageLiteral(resourceName: "tabbar-web"),
            tag: 3)
        settingsNavigationController.tabBarItem = UITabBarItem(
            title: "Paramètres",
            image: #imageLiteral(resourceName: "tabbar-settings"),
            tag: 4)
    
        delegate = self
        tabBar.isTranslucent = true
        
        viewControllers = [
            favoritesNavigationController,
            articlesNavigationController,
            homeNavigationController,
            pagesNavigationController,
            settingsNavigationController
        ]
        
        if let index = viewControllers?.index(of: homeNavigationController) {
            selectedIndex = index
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarViewController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }
        
        if fromView != toView {
            UIView.setAnimationsEnabled(false)
            UIView.transition(
                from: fromView,
                to: toView,
                duration: 0.2,
                options: [.transitionCrossDissolve],
                completion: { _ in
                    UIView.setAnimationsEnabled(true)
            })
        }
        
        return true
    }
}
