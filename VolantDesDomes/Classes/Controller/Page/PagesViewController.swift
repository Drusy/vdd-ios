//
//  PageViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 29/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift

class PagesViewController: AbstractViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let cells: [CellIdentifiable.Type] = [PageCollectionViewCell.self]
            cells.forEach {
                collectionView.register($0.nib, forCellWithReuseIdentifier: $0.identifier)
            }
        }
    }
    
    lazy var items: [PageItem] = {
       return PageItem.items()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        navigationItem.title = "Pages"
        navigationItem.searchController = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "tabbar-web"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onWebsiteTouched))
        
        setupCollectionView()
    }
    
    // MARK: -
    
    override func update() {
        super.update()
    }
    
    func setupCollectionView() {
        Observable<[PageItem]>.just(items)
            .bind(to: collectionView.rx.items(cellIdentifier: PageCollectionViewCell.identifier)) { index, item, cell in
                if let cell = cell as? PageCollectionViewCell {
                    cell.configure(with: item)
                }
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(PageItem.self)
            .subscribe(onNext: { [weak self] item in
                self?.select(item: item)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func select(item: PageItem) {
        var viewController: UIViewController?

        switch item.type {
        case .calendar:
            viewController = CalendarPageViewController()
            
        case .home, .tournaments, .contact, .club, .price, .shop, .stats:
            if let stringUrl = item.url, let url = URL(string: stringUrl) {
                viewController = PageDetailViewController(title: item.title, url: url)
            }
        case .interclubs:
            viewController = InterclubsPageViewController()
        }

        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc func onWebsiteTouched() {
        showSafariViewController(for: AlamofireService.hostURL)
    }
}

// MARK: - UICollectionViewDelegate

extension PagesViewController: UICollectionViewDelegateFlowLayout {
    
    func sectionInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var offset: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = PageItem.cellHeight
        let item = items[indexPath.row]
        let insetForSection = sectionInsets()
        
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            offset = flowLayout.minimumInteritemSpacing + insetForSection.left + insetForSection.right
        }
        
        if item.isFullWidth {
            width = collectionView.frame.size.width - offset
            
            if let customHeight = item.customHeight {
                height = customHeight
            } else {
                height = PageItem.fullWidthCellHeight
            }
        } else {
            width = ((collectionView.frame.size.width - offset) / 2)
        }
        
        return CGSize(width: width, height: height)
    }
    
}
