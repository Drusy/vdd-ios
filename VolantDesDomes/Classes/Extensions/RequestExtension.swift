//
//  RequestExtension.swift
//  VolantDesDomes
//
//  Created by Drusy on 03/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Alamofire

extension Request {
    @discardableResult
    public func debugLog() -> Self {
        #if DEBUG
            debugPrint(self)
        #endif
        
        return self
    }
}
