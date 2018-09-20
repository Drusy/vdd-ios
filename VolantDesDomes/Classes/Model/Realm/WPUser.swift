//
//  WPUser.swift
//  VolantDesDomes
//
//  Created by Drusy on 20/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import Alamofire

// https://developer.wordpress.org/rest-api/reference/users/
class WPUser: Object, StaticMappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String?
    @objc dynamic var url: String?
    @objc dynamic var desc: String?
    @objc dynamic var link: String?
    @objc dynamic var slug: String?
    @objc dynamic var avatars: WPAvatar?
    
    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPUser()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPUser.id)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        url <- map["url"]
        desc <- map["url"]
        link <- map["link"]
        slug <- map["slug"]
        avatars <- map["avatar_urls"]
        
        avatars?.id = id
    }
}

extension WPUser {
    enum Router: URLRequestConvertible, Queryable {
        case getAll
        
        var method: HTTPMethod {
            switch self {
            case .getAll:
                return .get
            }
        }
        
        // MARK: - Queryable
        
        var isSecured: Bool {
            return false
        }
        
        var lastSegmentPath: String {
            switch self {
            case .getAll:
                return "/users"
            }
        }
        
        var encoding: ParameterEncoding {
            switch self {
            case .getAll:
                return URLEncoding.default
            }
        }
        
        // MARK: - URLRequestConvertible
        
        func asURLRequest() throws -> URLRequest {
            let url = try ApiRequest.hostURL.asURL().appendingPathComponent(apiPath).appendingPathComponent(lastSegmentPath)
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            urlRequest.allHTTPHeaderFields = ApiRequest.headers
            
            switch self {
            case .getAll:
                let parameters: [String: Any] = [
                    "per_page": 100
                ]
                urlRequest = try encoding.encode(urlRequest, with: parameters)
            }
            
            return urlRequest
        }
    }
}
