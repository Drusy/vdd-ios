//
//  WPContent.swift
//  VolantDesDomes
//
//  Created by Drusy on 20/08/2018.
//  Copyright © 2018 Openium. All rights reserved.
//

import UIKit
import ObjectMapper
import RealmSwift

class WPContent: Object, StaticMappable {
    @objc dynamic var id: String?
    @objc dynamic var rendered: String?
    @objc dynamic var protected: Bool = false
    
    class func objectForMapping(map: Map) -> BaseMappable? {
        return WPContent()
    }
    
    override public static func primaryKey() -> String? {
        return #keyPath(WPContent.id)
    }
    
    func mapping(map: Map) {
        rendered <- map["rendered"]
        protected <- map["protected"]
    }
}
