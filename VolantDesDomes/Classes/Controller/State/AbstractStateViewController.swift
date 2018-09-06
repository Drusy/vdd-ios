//
//  AbstractStateViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 27/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RealmSwift
import RxSwift
import StateViewController

class AbstractStateViewController<State: Equatable>: StateViewController<State> {
    let disposeBag = DisposeBag()
    var didLoadOnce: Bool = false
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
