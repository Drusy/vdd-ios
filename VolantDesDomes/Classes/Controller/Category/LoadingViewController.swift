//
//  LoadingViewController.swift
//  VolantDesDomes
//
//  Created by Drusy on 21/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyUserDefaults

class LoadingViewController: AbstractViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Defaults[.appOpenCount] += 1
    }

    // MARK: -
    
    func refresh(handler: @escaping (Error?) -> Void) {
        DownloadManager.shared
            .refresh()
            .subscribe(
                onCompleted: {
                    handler(nil)
            },
                onError: { error in
                    print("An error occured loading data: \(error)")
                    handler(error)
            }).disposed(by: disposeBag)
    }
}
