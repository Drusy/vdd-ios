//
//  PostsViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 24/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift
import RxRealm
import RxCocoa
import RealmSwift
import Alamofire
import ObjectMapper
import SwiftyUserDefaults

class PostsViewController: AbstractViewController {

    static let postsPerPage = 10
    
    @IBOutlet var errorFooterView: UIView?
    @IBOutlet var loadingFooterView: UIView?
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let cells: [CellIdentifiable.Type] = [PostTableViewCell.self]
            cells.forEach {
                tableView.register($0.nib, forCellReuseIdentifier: $0.identifier)
            }
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 280
            
            if canRefresh {
                tableView.addSubview(refreshControl)
            }
        }
    }
    
    var dataSourceDisposable: Disposable?
    var category: WPCategory?
    var filteredPosts: [WPPost] {
        var results: Results<WPPost> = posts
        
        if let searchQuery = searchQuery {
            results = results.filter("%K CONTAINS[cd] %@ || %K CONTAINS[cd] %@",
                                     #keyPath(WPPost.title.rendered), searchQuery,
                                     #keyPath(WPPost.content.rendered), searchQuery)
        }
        
        if let category = category {
            return results.filter { $0.categoriesIds.contains(category.id) }
        } else {
            return Array(results)
        }
    }
    var searchQuery: String? {
        didSet {
            if isViewLoaded {
                self.update()
            }
        }
    }
    var posts: Results<WPPost> {
        return self.realm
            .objects(WPPost.self)
            .sorted(byKeyPath: #keyPath(WPPost.date), ascending: false)
    }
    var canRefresh: Bool {
        return true
    }
    var isPaginating = false
    var shouldPaginage = true
    var page: Int = 2 {  // `DownloadManager` already did the first page fetch
        didSet {
            if page == 1 {
                shouldPaginage = true
            }
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    init(category: WPCategory? = nil) {
        self.category = category
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = category?.name ?? "Articles"
        
        errorFooterView?.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.changeTableViewFooter(with: self?.loadingFooterView)
                self?.paginate()
            })
            .disposed(by: disposeBag)
        
        setupTableView()
        if canRefresh {
            setupRefreshControl()
            
            if Defaults[.forceCategoryLoading] == false {
                refresh()
            }
        }
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    // MARK: -
    
    func canPaginate() -> Bool {
        return shouldPaginage &&
            isPaginating == false &&
            tableView.tableFooterView != errorFooterView &&
            refreshControl.isRefreshing == false
    }
    
    override func themeUpdated() {
        super.themeUpdated()

        view.backgroundColor = StyleManager.shared.backgroundColor
    }
    
    override func update() {
        super.update()
        
        // https://github.com/realm/realm-cocoa/issues/5334
        dataSourceDisposable?.dispose()
        dataSourceDisposable = Observable<[WPPost]>
            .just(filteredPosts)
            .bind(to: tableView.rx.items(cellIdentifier: PostTableViewCell.identifier)) { index, model, cell in
                if let postCell = cell as? PostTableViewCell {
                    postCell.configure(with: model)
                }
            }
        
        tableView.reloadData()
    }
    
    func setupTableView() {
        Observable.collection(from: posts)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.update()
                },
                onError: { error in
                    print(error)
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(WPPost.self)
            .subscribe(onNext: { [weak self] post in
                self?.show(post: post)
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func request() -> DataRequest {
        var request: DataRequest

        if let category = category {
            request = ApiRequest.request(with: WPPost.Router.getCategoryPage(category: category,
                                                                             page: page,
                                                                             count: PostsViewController.postsPerPage))
        } else {
            request = ApiRequest.request(with: WPPost.Router.getPage(page: page,
                                                                     count: PostsViewController.postsPerPage))
        }
        
        return request
    }
    
    func onDataRefreshed(posts: [WPPost]) {
        try? realm.write {
            realm.add(posts, update: true)
        }
        
        page += 1
        tableView.allowsSelection = true
        refreshControl.endRefreshing()
    }
    
    func setupRefreshControl() {
        refreshControl.rx.controlEvent(.valueChanged)
            .map { self.refreshControl.isRefreshing }
            .filter { $0 == true }
            .flatMapLatest { [weak self] _ -> Observable<([WPPost])> in
                guard let strongSelf = self else { return Observable.just([]) }
                
                strongSelf.page = 1
                strongSelf.tableView.allowsSelection = false
                
                return strongSelf.request().rx.objectArray()
            }
            .flatMap { (posts: [WPPost]) -> Observable<[WPPost]> in
                return ApiRequest.mediasRequestObservable(for: posts).map { _ in posts }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (posts: [WPPost]) in
                    self?.onDataRefreshed(posts: posts)
                },
                onError: { [weak self] error in
                    print(error)
                    self?.tableView.allowsSelection = true
                    self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    func show(post: WPPost) {
        let postDetailViewController = PostDetailViewController(post: post)
        navigationController?.pushViewController(postDetailViewController, animated: true)
    }
    
    func refresh() {
        page = 1
        
        request().rx
            .objectArray()
            .flatMap { (posts: [WPPost]) -> Observable<[WPPost]> in
                return ApiRequest.mediasRequestObservable(for: posts).map { _ in posts }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (posts: [WPPost]) in
                    self?.onDataRefreshed(posts: posts)
                },
                onError: { error in
                    print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func paginate() {
        guard canPaginate() else { return }
        
        isPaginating = true
        changeTableViewFooter(with: loadingFooterView)
        
        request().rx
            .objectArray()
            .flatMap { (posts: [WPPost]) -> Observable<[WPPost]> in
                return ApiRequest.mediasRequestObservable(for: posts).map { _ in posts }
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (posts: [WPPost]) in
                    try? self?.realm.write {
                        self?.realm.add(posts, update: true)
                    }
                    
                    self?.page += 1
                    self?.shouldPaginage = posts.count == PostsViewController.postsPerPage
                    
                    self?.changeTableViewFooter(with: nil)
                    self?.isPaginating = false
                },
                onError: { [weak self] error in
                    print(error)
                    
                    if case AFError.responseValidationFailed(.unacceptableStatusCode(let code)) = error, code == 400 {
                        self?.changeTableViewFooter(with: nil)
                        self?.shouldPaginage = false
                    } else {
                        self?.changeTableViewFooter(with: self?.errorFooterView)
                    }
                    
                    self?.isPaginating = false
            })
            .disposed(by: disposeBag)
    }
    
    func changeTableViewFooter(with footerView: UIView?, animated: Bool = false) {
        guard tableView.tableFooterView != footerView else { return }
        
        let block: () -> Void = { [weak self] in
            self?.tableView.tableFooterView = footerView
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.allowUserInteraction],
                animations: block,
                completion: nil)
        } else {
            block()
        }
    }
}

// MARK: - UISearchResultsUpdating

extension PostsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchQuery = text
        } else {
            searchQuery = nil
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension PostsViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let pointConverted = tableView.convert(location, from: view)
        
        if let indexPath = tableView.indexPathForRow(at: pointConverted) {
            previewingContext.sourceRect = view.convert(tableView.rectForRow(at: indexPath), from: tableView)
            return PostDetailViewController(post: filteredPosts[indexPath.row])
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension PostsViewController: UITableViewDelegate {
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        let offsetShouldPaginate = (maximumOffset - currentOffset) <= (maximumOffset * 0.15)
        let heightShouldPaginate = maximumOffset <= 0
        
        if offsetShouldPaginate || heightShouldPaginate {
            paginate()
        }
    }
}
