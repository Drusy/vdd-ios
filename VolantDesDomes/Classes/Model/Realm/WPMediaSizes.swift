//
//  WPMediaSizes.swift
//  VolantDesDomes
//
//  Created by Drusy on 28/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class WPMediaSize: Object, StaticMappable {
    @objc dynamic var file: String?
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var mimeType: String?
    @objc dynamic var sourceURL: String?

    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPMediaSize()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPMediaSize.file)
    }
    
    func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
        file <- map["file"]
        mimeType <- map["mime_type"]
        sourceURL <- map["source_url"]
    }
}

class WPMediaSizes: Object, StaticMappable {
    @objc dynamic var id: String?
    @objc dynamic var thumbnail: WPMediaSize?
    @objc dynamic var medium: WPMediaSize?
    @objc dynamic var mediumLarge: WPMediaSize?
    @objc dynamic var large: WPMediaSize?
    @objc dynamic var full: WPMediaSize?

    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPMediaSizes()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPMediaSizes.id)
    }
    
    func mapping(map: Map) {
        thumbnail <- map["thumbnail"]
        medium <- map["medium"]
        mediumLarge <- map["medium_large"]
        large <- map["large"]
        full <- map["full"]
    }
}
