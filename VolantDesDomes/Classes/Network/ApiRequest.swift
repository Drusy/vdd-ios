//
//  ApiRequest.swift
//  GFors
//
//  Created by Drusy on 04/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RxAlamofire
import RxSwift
import RealmSwift

class AlamofireService {
    static let shared = AlamofireService()
    static var hostURL: String {
        return "https://volantdesdomes.fr"
    }
    
    /// Session Manager
    static let defaultSession = Session.default
    static let headers: [String: String] = [
        "Accept": "application/json",
        "Accept-Encoding": "gzip"
    ]
    
    let session: Session
    
    init(session: Session = AlamofireService.defaultSession) {
        self.session = session
    }
    
    // MARK: -
    
    func mediasRequestObservable(for posts: [WPPost]) -> Observable<[WPMedia]> {
        let realm = try? Realm()
        let ids = posts.compactMap { $0.featuredMediaId > 0 ? $0.featuredMediaId : nil }
        
        if ids.isEmpty {
            return Observable.just([])
        } else {
            return session.rx
                .objectArray(WPMedia.Router.getUIDs(ids))
                .retry(.exponentialDelayed(maxCount: 3, initial: 1, multiplier: 1))
                .observeOn(MainScheduler.instance)
                .do(onNext: { (items: [WPMedia]) in
                    try? realm?.write {
                        realm?.add(items, update: .all)
                    }
                })
        }
    }
}
