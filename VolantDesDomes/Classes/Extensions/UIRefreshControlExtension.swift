//
//  UIRefreshControlExtension.swift
//  VolantDesDomes
//
//  Created by Drusy on 06/09/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    func forceRefresh(in tableView: UITableView) {
        let offset = CGPoint.init(x: 0, y: -frame.size.height)
        
        beginRefreshing()
        sendActions(for: .valueChanged)
        tableView.setContentOffset(offset, animated: true)
    }
}
