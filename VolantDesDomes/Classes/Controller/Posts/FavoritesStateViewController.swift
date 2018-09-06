//
//  PostsStateViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 27/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import StateViewController

enum FavoritesState: Equatable {
    case empty
    case ready
}

class FavoritesStateViewController: AbstractStateViewController<FavoritesState> {

    lazy var loadingViewController: StateLoadingViewController = {
        return StateLoadingViewController(string: "Chargement des articles en cours")
    }()
    lazy var emptyViewController: StateEmptyViewController = {
        let emptyViewController = StateEmptyViewController(
            title: "Aucun favoris",
            subtitle: "Ajoutez des favoris depuis le détail d'un article")
        return emptyViewController
    }()
    lazy var contentViewController: FavoritesViewController = {
        return FavoritesViewController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Favoris"
    }
    
    // MARK: - State
    
    override func loadAppearanceState() -> FavoritesState {
        if contentViewController.posts.isEmpty {
            return .empty
        } else {
            return .ready
        }
    }
    
    override func contentViewControllers(for state: FavoritesState) -> [UIViewController] {
        switch state {
        case .ready:
            return [contentViewController]
        case .empty:
            return [emptyViewController]
        }
    }
    
    override func willTransition(to nextState: FavoritesState, animated: Bool) {
        
    }
    
    override func didTransition(from previousState: FavoritesState?, animated: Bool) {

    }
}

