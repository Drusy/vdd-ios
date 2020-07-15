//
//  RealmTypeCastTransform.swift
//  VolantDesDomes
//
//  Created by Drusy on 23/07/2019.
//  Copyright © 2019 Openium. All rights reserved.
//

import RealmSwift
import ObjectMapper

/// Transforms Swift Arrays to Realm Arrays. E.g. [String] to List<String>.
/// Additionally, it will type cast value if type mismatches. E.g. "123" String to 123 Int.
public class RealmTypeCastTransform<T: RealmCollectionValue>: TransformType {
    public typealias Object = List<T>
    public typealias JSON = [Any]
    
    let object: Object
    
    required init(list: Object? = nil) {
        self.object = list ?? Object()
    }
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        guard let array = value as? [Any] else { return nil }
        
        let typeCastTransform = TypeCastTransform<T>()
        let realmValues: [T] = array.compactMap { typeCastTransform.transformFromJSON($0) }
        
        object.removeAll()
        object.append(objectsIn: realmValues)
        
        return object
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        guard let value = value else { return nil }
        
        return Array(value)
    }
}
