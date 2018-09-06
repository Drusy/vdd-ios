//
//  WPPost.swift
//  VolantDesDomes
//
//  Created by Drusy on 20/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift
import Alamofire
import ObjectMapperAdditionsRealm

// https://developer.wordpress.org/rest-api/reference/posts/
class WPPost: Object, StaticMappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var date: Date?
    @objc dynamic var modified: Date?
    @objc dynamic var slug: String?
    @objc dynamic var status: String?
    @objc dynamic var type: String?
    @objc dynamic var title: WPContent?
    @objc dynamic var link: String?
    @objc dynamic var content: WPContent?
    @objc dynamic var excerpt: WPContent?
    @objc dynamic var authorId: Int = 0
    @objc dynamic var featuredMediaId: Int = 0
    @objc dynamic var commentStatus: String?
    @objc dynamic var pingStatus: String?
    @objc dynamic var sticky: Bool = false
    @objc dynamic var favorite: Bool = false

    var categoriesIds = List<Int>()
    var categories: Results<WPCategory>? {
        let realm = try? Realm()
        return realm?.objects(WPCategory.self).filter("%K in %@", #keyPath(WPCategory.id), categoriesIds)
    }
    var author: WPUser? {
        let realm = try? Realm()
        return realm?.object(ofType: WPUser.self, forPrimaryKey: authorId)
    }
    var featuredMedia: WPMedia? {
        let realm = try? Realm()
        return realm?.object(ofType: WPMedia.self, forPrimaryKey: featuredMediaId)
    }
    var excerptHtmlStripped: String? {
        let hasExcerpt: Bool = excerpt?.rendered?.isEmpty == false ? true : false
        
        if let preview = hasExcerpt ? excerpt?.rendered : content?.rendered {
            return String(preview.htmlStripped.htmlDecoded.prefix(300))
        } else {
            return nil
        }
    }
    var titleHtmlStripped: String? {
        return title?.rendered?.htmlStripped.htmlDecoded
    }
    
    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPPost()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPPost.id)
    }
    
    func mapping(map: Map) {
        let dateFormatTransform = CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss")
        
        id <- map["id"]
        date <- (map["date"], dateFormatTransform)
        modified <- (map["modified"], dateFormatTransform)
        slug <- map["slug"]
        status <- map["status"]
        type <- map["type"]
        title <- map["title"]
        content <- map["content"]
        link <- map["link"]
        excerpt <- map["excerpt"]
        authorId <- map["author"]
        featuredMediaId <- map["featured_media"]
        commentStatus <- map["comment_status"]
        pingStatus <- map["ping_status"]
        sticky <- map["sticky"]
        categoriesIds <- (map["categories"], RealmTypeCastTransform())

        title?.id = "\(id).title"
        content?.id = "\(id).content"
        excerpt?.id = "\(id).excerpt"
        
        let realm = try? Realm()
        if let old = realm?.object(ofType: WPPost.self, forPrimaryKey: id) {
            favorite = old.favorite
        }
    }
    
    // MARK: - Servive
    
    static func fromURL(_ url: URL) -> WPPost? {
        guard let realm = try? Realm() else { return nil }
        
        let slug = url.path.lowercased()
            .replace(regex: "\\d{4}/\\d{2}/\\d{2}/", with: "") // Handle legacy permalinks
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        return realm.objects(WPPost.self).filter("slug == %@", slug).first
    }
}

extension WPPost {
    enum Router: URLRequestConvertible, Queryable {
        case getAll
        case getPage(page: Int, count: Int)
        case getCategory(WPCategory)
        case getCategoryPage(category: WPCategory, page: Int, count: Int)

        var method: HTTPMethod {
            switch self {
            case .getCategory, .getAll, .getPage, .getCategoryPage:
                return .get
            }
        }
        
        // MARK: - Queryable
        
        var isSecured: Bool {
            return false
        }
        
        var lastSegmentPath: String {
            switch self {
            case .getCategory, .getAll, .getPage, .getCategoryPage:
                return "/posts"
            }
        }
        
        var encoding: ParameterEncoding {
            switch self {
            case .getCategory, .getAll, .getPage, .getCategoryPage:
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
            case .getCategory(let category):
                let parameters: [String: Any] = [
                    "categories": category.id
                ]
                urlRequest = try encoding.encode(urlRequest, with: parameters)
                
            case .getCategoryPage(let category, let page, let count):
                let parameters: [String: Any] = [
                    "categories": category.id,
                    "per_page": count,
                    "page": page
                ]
                urlRequest = try encoding.encode(urlRequest, with: parameters)
                
            case .getAll:
                let parameters: [String: Any] = [
                    "per_page": 100
                ]
                urlRequest = try encoding.encode(urlRequest, with: parameters)
                
            case .getPage(let page, let count):
                let parameters: [String: Any] = [
                    "per_page": count,
                    "page": page
                ]
                urlRequest = try encoding.encode(urlRequest, with: parameters)
            }
            
            return urlRequest
        }
    }
}
