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
    
    private init() {
    }
    
    // MARK: -
    
    func refresh() -> Completable {
        let realm = try! Realm()
        
        let categories = ApiRequest.request(with: WPCategory.Router.getAll).rx
            .objectArray()
            .retry(.exponentialDelayed(maxCount: 3, initial: 1, multiplier: 1))
            .observeOn(MainScheduler.instance)
            .do(onNext: { (items: [WPCategory]) in
                try! realm.write {
                    realm.add(items, update: true)
                }
            })
            .flatMap { categories -> Observable<[[WPPost]]> in
                let observables = categories
                    .filter { $0.count > 0 }
                    .filter { $0.posts?.isEmpty ?? true }
                    .map { category in
                        return ApiRequest.request(with: WPPost.Router.getCategoryPage(category: category, page: 1, count: 5)).rx
                            .objectArray()
                            .retry(.exponentialDelayed(maxCount: 3, initial: 1, multiplier: 1))
                            .observeOn(MainScheduler.instance)
                            .do(onNext: { (items: [WPPost]) in
                                try! realm.write {
                                    realm.add(items, update: true)
                                }
                            })
                }
                
                return Observable.zip(observables)
            }
            .flatMap { (postsByCategory: [[WPPost]]) -> Observable<[WPMedia]> in
                return ApiRequest.mediasRequestObservable(for: postsByCategory.flatMap { $0 })
        }
        
        let users = ApiRequest.request(with: WPUser.Router.getAll).rx
            .objectArray()
            .retry(.exponentialDelayed(maxCount: 3, initial: 1, multiplier: 1))
            .observeOn(MainScheduler.instance)
            .do(onNext: { (items: [WPUser]) in
                try! realm.write {
                    realm.add(items, update: true)
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
