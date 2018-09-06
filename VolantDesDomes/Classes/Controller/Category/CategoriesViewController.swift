//
//  CategoriesViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 21/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift
import RxRealm
import RxCocoa
import RxGesture
import RealmSwift
import SwiftyUserDefaults

class CategoriesViewController: AbstractViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let cells: [CellIdentifiable.Type] = [CategoryTableViewCell.self]
            cells.forEach {
                tableView.register($0.nib, forCellReuseIdentifier: $0.identifier)
            }
            
            tableView.contentInset = UIEdgeInsets(top: 12,
                                                  left: 0,
                                                  bottom: 12,
                                                  right: 0)
            tableView.addSubview(refreshControl)
        }
    }
    
    var collectionDisposable: Disposable?
    var searchQuery: String? {
        didSet {
            self.update()
        }
    }
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.searchBar.delegate = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Rechercher une catégorie"
        return controller
    }()
    lazy var refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    var categories: Results<WPCategory> {
        var results = self.realm
            .objects(WPCategory.self)
            .filter("%K > 0", #keyPath(WPCategory.count))
        
        if let searchQuery = searchQuery {
            results = results.filter("%K CONTAINS[cd] %@ || %K CONTAINS[cd] %@",
                                     #keyPath(WPCategory.name), searchQuery,
                                     #keyPath(WPCategory.desc), searchQuery)
        }
        
        return results.sorted(byKeyPath: #keyPath(WPCategory.id), ascending: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        navigationItem.title = "Volant des Dômes"
        navigationItem.searchController = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                            target: self,
                                                            action: #selector(onSearchTouched))
        
        setupTableView()
        setupRefreshControl()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    // MARK: -
    
    override func update() {
        super.update()
        
        collectionDisposable?.dispose()
        collectionDisposable = Observable.collection(from: categories)
            .bind(to: tableView.rx.items) { tableView, index, category in
                let indexPath = IndexPath(row: index, section: 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as! CategoryTableViewCell

                cell.configure(with: category)

                return cell
            }
    }
    
    func setupTableView() {
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(WPCategory.self)
            .subscribe(onNext: { [weak self] category in
                self?.show(category: category)
            })
            .disposed(by: disposeBag)
    }
    
    func setupRefreshControl() {
        refreshControl.rx.controlEvent(.valueChanged)
            .map { self.refreshControl.isRefreshing }
            .filter { $0 == true }
            .flatMapLatest { [weak self] _ -> Observable<([WPCategory])> in
                self?.tableView.allowsSelection = false
                
                return ApiRequest.request(with: WPCategory.Router.getAll).rx.objectArray()
            }
            .observeOn(MainScheduler.instance)
            .do(onError: { [weak self] error in
                print(error)
                self?.refreshControl.endRefreshing()
                self?.tableView.allowsSelection = true
            })
            .subscribe(onNext: { [weak self] (categories: [WPCategory]) in
                try? self?.realm.write {
                    self?.realm.add(categories, update: true)
                }
                
                self?.tableView.allowsSelection = true
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    func show(category: WPCategory) {
        let postsViewController = PostsStateViewController(category: category)
        navigationController?.pushViewController(postsViewController, animated: true)
    }
    
    func setCellOffset(_ cell: CategoryTableViewCell, at indexPath: IndexPath) {
        guard Defaults[.categoryParallax] else { return }
        
        let cellFrame = tableView.rectForRow(at: indexPath)
        let cellFrameInTable = tableView.convert(cellFrame, from: view)
        let cellOffset = cellFrameInTable.origin.y + cellFrameInTable.size.height
        let tableHeight = tableView.bounds.size.height + cellFrameInTable.size.height
        let cellOffsetFactor = cellOffset / tableHeight
        
        cell.setBackground(offset: cellOffsetFactor)
    }
    
    // MARK: - Actions
    
    @objc func onSearchTouched() {
        navigationItem.searchController = searchController
        searchController.isActive = true
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    @objc func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    @objc func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CategoryTableViewCell else { return }
        setCellOffset(cell, at: indexPath)
    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            guard let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell else { return }
            setCellOffset(cell, at: indexPath)
        }
    }
}

// MARK: - UISearchResultsUpdating / UISearchBarDelegate

extension CategoriesViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        navigationItem.searchController = nil
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchQuery = text
        } else {
            searchQuery = nil
        }
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension CategoriesViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let pointConverted = tableView.convert(location, from: view)
        
        if let indexPath = tableView.indexPathForRow(at: pointConverted) {
            previewingContext.sourceRect = view.convert(tableView.rectForRow(at: indexPath), from: tableView)
            return PostsStateViewController(category: categories[indexPath.row])
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
