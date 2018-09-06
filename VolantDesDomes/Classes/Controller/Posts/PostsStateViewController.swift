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
import Alamofire
import StateViewController
import SwiftyUserDefaults

enum PostsState: Equatable {
    case loading
    case ready
    case error
}

class PostsStateViewController: AbstractStateViewController<PostsState>, UISearchBarDelegate {

    lazy var loadingViewController: StateLoadingViewController = {
        return StateLoadingViewController(string: "Chargement des articles en cours")
    }()
    lazy var errorViewController: StateErrorViewController = {
        let errorViewController = StateErrorViewController(
            title: "Une erreur est survenue lors du chargement des articles",
            subtitle: "Touchez pour réessayer")
        errorViewController.touchHandler = { [weak self] in
            self?.load()
        }
        return errorViewController
    }()
    lazy var contentViewController: PostsViewController = {
        return PostsViewController(category: self.category)
    }()
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = contentViewController
        controller.searchBar.delegate = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Rechercher un article"
        return controller
    }()
    
    var category: WPCategory?
    
    init(category: WPCategory? = nil) {
        self.category = category
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        navigationItem.title = category?.name ?? "Articles"
        navigationItem.searchController = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                            target: self,
                                                            action: #selector(onSearchTouched))
    }
    
    // MARK: -
    
    func load() {
        var request: DataRequest
        
        if let category = category {
            request = ApiRequest.request(with: WPPost.Router.getCategoryPage(category: category,
                                                                             page: 1,
                                                                             count: PostsViewController.postsPerPage))
        } else {
            request = ApiRequest.request(with: WPPost.Router.getPage(page: 1,
                                                                     count: PostsViewController.postsPerPage))
        }
        
        request.rx
            .objectArray()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (posts: [WPPost]) in
                    try? self?.realm.write {
                        self?.realm.add(posts, update: true)
                    }
                    self?.didLoadOnce = true
                    self?.setNeedsStateTransition(to: .ready, animated: true)
                },
                onError: { [weak self] error in
                    print(error)
                    self?.setNeedsStateTransition(to: .error, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @objc func onSearchTouched() {
        navigationItem.searchController = searchController
        searchController.isActive = true
    }

    // MARK: - State
    
    override func loadAppearanceState() -> PostsState {
        if didLoadOnce && contentViewController.posts.isEmpty == false {
            return .ready
        } else if category != nil {
            if Defaults[.forceCategoryLoading] == false && contentViewController.posts.isEmpty == false {
                return .ready
            } else {
                return .loading
            }
        } else {
            return .loading
        }
    }
    
    override func contentViewControllers(for state: PostsState) -> [UIViewController] {
        switch state {
        case .loading:
            return [loadingViewController]
        case .ready:
            return [contentViewController]
        case .error:
            return [errorViewController]
        }
    }
    
    override func willTransition(to nextState: PostsState, animated: Bool) {
        
    }
    
    override func didTransition(from previousState: PostsState?, animated: Bool) {
        switch currentState {
        case .loading:
            load()
            navigationItem.rightBarButtonItem?.isEnabled = false
            
        case .error:
            navigationItem.rightBarButtonItem?.isEnabled = false

        case .ready:
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        navigationItem.searchController = nil
    }
}

