//
//  WPAvatar.swift
//  VolantDesDomes
//
//  Created by Drusy on 20/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class WPAvatar: Object, StaticMappable {
    @objc dynamic var id: Int = 0
    @objc dynamic var small: String?
    @objc dynamic var medium: String?
    @objc dynamic var large: String?
    
    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPAvatar()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPAvatar.id)
    }
    
    func mapping(map: Map) {
        small <- map["24"]
        medium <- map["48"]
        large <- map["96"]
    }
}
