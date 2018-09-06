//
//  Queryable.swift
//  VolantDesDomes
//
//  Created by Drusy on 04/04/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RealmSwift

protocol Queryable {
    var complementaryHeaders: [String: String] { get }
    var encoding: ParameterEncoding { get }
    var isSecured: Bool { get }
    var shouldUseBearerRetrierIfSecured: Bool { get }
    var lastSegmentPath: String { get }
    var apiPath: String { get }

    func parameters() -> [String: AnyObject]?
}

extension Queryable {
    var complementaryHeaders: [String: String] {
        return [:]
    }
    
    var apiPath: String {
        return "/index.php/wp-json/wp/v2"
    }
    
    var isSecured: Bool {
        return false
    }
    
    var shouldUseBearerRetrierIfSecured: Bool {
        return true
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var lastSegmentPath: String {
        preconditionFailure("This method must be overridden")
    }
    
    func parameters() -> [String: AnyObject]? {
        return nil
    }
}
