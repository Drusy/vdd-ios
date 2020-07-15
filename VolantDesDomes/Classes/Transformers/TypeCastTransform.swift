//
//  TypeCastTransform.swift
//  VolantDesDomes
//
//  Created by Drusy on 23/07/2019.
//  Copyright © 2019 Openium. All rights reserved.
//

import Foundation
import ObjectMapper

/// Transforms value of type Any to Bool. Tries to typecast if possible.
public class BoolTransform: TransformType {
    public typealias Object = Bool
    public typealias JSON = Bool
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        if value == nil {
            return nil
        } else if let bool = value as? Bool {
            return bool
        } else if let int = value as? Int {
            return (int != 0)
        } else if let double = value as? Double {
            return (double != 0)
        } else if let string = value as? String {
            return Bool(string)
        } else if let number = value as? NSNumber {
            return number.boolValue
        } else {
            #if DEBUG
            print("Can not cast value \(value!) of type \(type(of: value!)) to type \(Object.self)")
            #endif
            
            return nil
        }
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}

/// Transforms value of type Any to Double. Tries to typecast if possible.
public class DoubleTransform: TransformType {
    public typealias Object = Double
    public typealias JSON = Double
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        if value == nil {
            return nil
        } else if let double = value as? Double {
            return double
        } else if let int = value as? Int {
            return Double(int)
        } else if let bool = value as? Bool {
            return (bool ? 1.0 : 0.0)
        } else if let string = value as? String {
            return Double(string)
        } else if let number = value as? NSNumber {
            return number.doubleValue
        } else {
            #if DEBUG
            print("Can not cast value \(value!) of type \(type(of: value!)) to type \(Object.self)")
            #endif
            
            return nil
        }
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}

/// Transforms value of type Any to String. Tries to typecast if possible.
public class StringTransform: TransformType {
    public typealias Object = String
    public typealias JSON = String
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        if value == nil {
            return nil
        } else if let string = value as? String {
            return string
        } else if let int = value as? Int {
            return String(int)
        } else if let double = value as? Double {
            return String(double)
        } else if let bool = value as? Bool {
            return (bool ? "true" : "false")
        } else if let number = value as? NSNumber {
            return number.stringValue
        } else {
            #if DEBUG
            print("Can not cast value \(value!) of type \(type(of: value!)) to type \(Object.self)")
            #endif
            
            return nil
        }
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}

/// Transforms value of type Any to Int. Tries to typecast if possible.
public class IntTransform: TransformType {
    public typealias Object = Int
    public typealias JSON = Int
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        if value == nil {
            return nil
        } else if let int = value as? Int {
            return int
        } else if let double = value as? Double {
            return Int(double)
        } else if let bool = value as? Bool {
            return (bool ? 1 : 0)
        } else if let string = value as? String {
            return Int(string)
        } else if let number = value as? NSNumber {
            return number.intValue
        } else {
            #if DEBUG
            print("Can not cast value \(value!) of type \(type(of: value!)) to type \(Object.self)")
            #endif
            
            return nil
        }
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}

/// Transforms value of type Any to generic type. Tries to typecast if possible.
public class TypeCastTransform<T>: TransformType {
    public typealias Object = T
    public typealias JSON = T
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Object? {
        if value == nil {
            return nil
        } else if let value = value as? T {
            return value
        } else if T.self == Int.self {
            return IntTransform().transformFromJSON(value) as? T
        } else if T.self == Double.self {
            return DoubleTransform().transformFromJSON(value) as? T
        } else if T.self == Bool.self {
            return BoolTransform().transformFromJSON(value) as? T
        } else if T.self == String.self {
            return StringTransform().transformFromJSON(value) as? T
        } else {
            print("ObjectMapperAdditions. Can not cast value \(value!) of type \(type(of: value!)) to type \(T.self)")
            
            return nil
        }
    }
    
    public func transformToJSON(_ value: Object?) -> JSON? {
        return value
    }
}
