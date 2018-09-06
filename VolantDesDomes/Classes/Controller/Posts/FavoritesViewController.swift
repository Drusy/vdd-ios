//
//  FavoritesViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 29/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RealmSwift

class FavoritesViewController: PostsViewController {

    override var posts: Results<WPPost> {
        return super.posts.filter("%K = true", #keyPath(WPPost.favorite))
    }
    
    override var canRefresh: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldPaginage = false
    }
}
