//
//  RequestExtension.swift
//  VolantDesDomes
//
//  Created by Drusy on 03/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Alamofire
import RxSwift

extension DataRequest {
    public func debugLog() -> Self {
        #if DEBUG
        cURLDescription { curl in
            print(curl)
        }
        #endif
        return self
    }
}

extension ObservableType where Element == DataRequest {
    public func debugLog() -> Observable<Element> {
        return map { $0.debugLog() }
    }
}
