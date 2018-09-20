//
//  WPMedia.swift
//  VolantDesDomes
//
//  Created by Drusy on 28/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import RealmSwift
import Alamofire

// https://developer.wordpress.org/rest-api/reference/media/
class WPMedia: Object, StaticMappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var date: Date?
    @objc dynamic var modified: Date?
    @objc dynamic var slug: String?
    @objc dynamic var status: String?
    @objc dynamic var type: String?
    @objc dynamic var link: String?
    @objc dynamic var title: WPContent?
    @objc dynamic var authorId: Int = 0
    @objc dynamic var desc: WPContent?
    @objc dynamic var caption: WPContent?
    @objc dynamic var alt: String?
    @objc dynamic var mediaType: String?
    @objc dynamic var mimeType: String?
    @objc dynamic var details: WPMediaDetails?
    @objc dynamic var post: Int = -1
    @objc dynamic var sourceURL: String?
    
    var author: WPUser? {
        let realm = try? Realm()
        return realm?.object(ofType: WPUser.self, forPrimaryKey: authorId)
    }
    var large: String? {
        return self.details?.sizes?.large?.sourceURL ?? sourceURL
    }

    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPMedia()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPMedia.id)
    }
    
    func mapping(map: Map) {
        let dateFormatTransform = CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss")
        
        id <- map["id"]
        date <- (map["date"], dateFormatTransform)
        modified <- (map["modified"], dateFormatTransform)
        slug <- map["slug"]
        status <- map["status"]
        type <- map["type"]
        link <- map["link"]
        title <- map["title"]
        authorId <- map["author"]
        desc <- map["description"]
        caption <- map["caption"]
        alt <- map["alt_text"]
        mediaType <- map["media_type"]
        mimeType <- map["mime_type"]
        details <- map["media_details"]
        post <- map["post"]
        sourceURL <- map["source_url"]
        
        title?.id = "\(id).title"
        desc?.id = "\(id).desc"
        caption?.id = "\(id).caption"
    }
}

extension WPMedia {
    enum Router: URLRequestConvertible, Queryable {
        case getAll
        case getPage(Int, Int)
        case get(Int)
        case getUIDs([Int])
        
        var method: HTTPMethod {
            switch self {
            case .get, .getAll, .getPage, .getUIDs:
                return .get
            }
        }
        
        // MARK: - Queryable
        
        var isSecured: Bool {
            return false
        }
        
        var lastSegmentPath: String {
            switch self {
            case .get, .getAll, .getPage, .getUIDs:
                return "/media"
            }
        }
        
        var encoding: ParameterEncoding {
            switch self {
            case .get, .getAll, .getPage, .getUIDs:
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
            case .getUIDs(let uids):
                let parameters: [String: Any] = [
                    "include": uids,
                    "per_page": min(uids.count, 100)
                ]
                urlRequest = try encoding.encode(urlRequest, with: parameters)
                
            case .get(let parent):
                let parameters: [String: Any] = [
                    "parent": parent
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
