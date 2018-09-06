//
//  InterclubsPageViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 31/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift

class InterclubsPageViewController: AbstractViewController {
    
    private static let reuseIdentifier = "InterclubCell"

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let cells: [CellIdentifiable.Type] = [DefaultTableViewCell.self]
            cells.forEach {
                tableView.register($0.nib, forCellReuseIdentifier: $0.identifier)
            }
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 80
        }
    }
    
    lazy var items: [InterclubItem] = {
        return InterclubItem.items()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Interclubs"
        
        setupTableView()
    }
    
    // MARK: -
    
    override func update() {
        super.update()
    }
    
    func setupTableView() {
        Observable<[InterclubItem]>.just(items)
            .bind(to: tableView.rx.items(cellIdentifier: DefaultTableViewCell.identifier)) { index, model, cell in
                if let defaultCell = cell as? DefaultTableViewCell {
                    defaultCell.configure(title: model.title, subtitle: model.subtitle)
                }
            }
            .disposed(by: disposeBag)
                
        tableView.rx.modelSelected(InterclubItem.self)
            .subscribe(onNext: { [weak self] item in
                self?.select(item: item)
            })
            .disposed(by: disposeBag)
    }
    
    func select(item: InterclubItem) {
        if let stringUrl = item.url, let url = URL(string: stringUrl) {
            let viewController = PageDetailViewController(title: item.title, url: url)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
