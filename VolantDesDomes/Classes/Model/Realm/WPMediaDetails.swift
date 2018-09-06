//
//  WPMediaDetails.swift
//  VolantDesDomes
//
//  Created by Drusy on 28/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class WPMediaDetails: Object, StaticMappable {
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var file: String?
    @objc dynamic var sizes: WPMediaSizes?
    
    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPMediaDetails()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPMediaDetails.file)
    }
    
    func mapping(map: Map) {
        width <- map["width"]
        height <- map["height"]
        file <- map["file"]
        sizes <- map["sizes"]
        
        sizes?.id = "\(file ?? UUID().uuidString).sizes"
    }
}
