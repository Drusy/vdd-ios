//
//  WPCategory.swift
//  VolantDesDomes
//
//  Created by Drusy on 20/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import Alamofire

// https://developer.wordpress.org/rest-api/reference/categories/
class WPCategory: Object, StaticMappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var count: Int = 0
    @objc dynamic var desc: String?
    @objc dynamic var link: String?
    @objc dynamic var name: String?
    @objc dynamic var slug: String?
    @objc dynamic var taxonomy: String?
    @objc dynamic var parent: Int = 0
    
    var posts: [WPPost]? {
        guard let realm = try? Realm() else { return nil }
        
        return Array(
            realm
                .objects(WPPost.self)
                .sorted(byKeyPath: #keyPath(WPPost.date), ascending: false)
                .filter { $0.categoriesIds.contains(self.id) }
        )
    }
    var featuredMedia: WPMedia? {
        return posts?.first(where: { $0.featuredMedia?.large != nil })?.featuredMedia
    }
    
    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPCategory()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPCategory.id)
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        desc <- map["description"]
        slug <- map["slug"]
        name <- map["name"]
        taxonomy <- map["taxonomy"]
        count <- map["count"]
        parent <- map["parent"]
    }
}

extension WPCategory {
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
                return "/categories"
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
            let url = try AlamofireService.hostURL.asURL().appendingPathComponent(apiPath).appendingPathComponent(lastSegmentPath)
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            urlRequest.allHTTPHeaderFields = AlamofireService.headers
            
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
