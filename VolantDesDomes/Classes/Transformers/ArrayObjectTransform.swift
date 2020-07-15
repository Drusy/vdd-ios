//
//  ArrayObjectTransform.swift
//  VolantDesDomes
//
//  Created by Drusy on 15/03/2019.
//  Copyright © 2019 Openium. All rights reserved.
//

import UIKit
import RealmSwift
import ObjectMapper

class ArrayObjectTransform<T: RealmSwift.Object>: TransformType where T: StaticMappable {
    typealias Object = List<T>
    typealias JSON = [Any]
    
    let object: Object

    required init(list: Object? = nil) {
        self.object = list ?? Object()
    }
    
    func transformFromJSON(_ value: Any?) -> Object? {
        guard let value = value as? [Any] else { return nil }
        
        let mapper = Mapper<T>()
        
        object.removeAll()
        for entry in value {
            if let model: T = mapper.map(JSONObject: entry) {
                object.append(model)
            }
        }
        
        return object
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        var results = [AnyObject]()
        let mapper = Mapper<T>()
        if let value = value {
            for obj in value {
                let json = mapper.toJSON(obj)
                results.append(json as AnyObject)
            }
        }
        return results
    }
}
