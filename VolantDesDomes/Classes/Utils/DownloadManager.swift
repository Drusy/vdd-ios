//
//  DownloadManager.swift
//  VolantDesDome
//
//  Created by Drusy on 04/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import RealmSwift
import ObjectMapper

class DownloadManager {
    static let shared = DownloadManager()
    
    lazy var alamofireService = AlamofireService()
    
    private init() {
    }
    
    // MARK: -
    
    func refresh() -> Completable {
        let realm = try! Realm()
        
        let categories = alamofireService.session.rx
            .objectArray(WPCategory.Router.getAll)
            .retry(.exponentialDelayed(maxCount: 3, initial: 1, multiplier: 1))
            .observeOn(MainScheduler.instance)
            .do(onNext: { (items: [WPCategory]) in
                try! realm.write {
                    realm.add(items, update: .all)
                }
            })
            .flatMap { categories -> Observable<[[WPPost]]> in
                let observables = categories
                    .filter { $0.count > 0 }
                    .filter { $0.posts?.isEmpty ?? true }
                    .map { category in
                        return self.alamofireService.session.rx
                            .objectArray(WPPost.Router.getCategoryPage(categoryId: category.id, page: 1, count: 5))
                            .retry(.exponentialDelayed(maxCount: 3, initial: 1, multiplier: 1))
                            .observeOn(MainScheduler.instance)
                            .do(onNext: { (items: [WPPost]) in
                                try! realm.write {
                                    realm.add(items, update: .all)
                                }
                            })
                }
                
                return Observable.zip(observables)
            }
            .flatMap { (postsByCategory: [[WPPost]]) -> Observable<[WPMedia]> in
                return self.alamofireService
                    .mediasRequestObservable(for: postsByCategory.flatMap { $0 })
        }
        
        let users = alamofireService.session.rx
            .objectArray(WPUser.Router.getAll)
            .retry(.exponentialDelayed(maxCount: 3, initial: 1, multiplier: 1))
            .observeOn(MainScheduler.instance)
            .do(onNext: { (items: [WPUser]) in
                try! realm.write {
                    realm.add(items, update: .all)
                }
            })

        return Observable.zip(users, categories)
            .ignoreElements()
            .observeOn(MainScheduler.instance)
            .do(onCompleted: {
                NotificationCenter.default.post(name: Notification.Name.downloadManagerRefreshedData, object: nil)
            })
    }
}
