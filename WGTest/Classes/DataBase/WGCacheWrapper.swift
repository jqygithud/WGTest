//
//  WGCacheWrapper.swift
//  DianBo
//
//  Created by 耿文康 on 2023/7/21.
//  Copyright © 2023 微光. All rights reserved.
//

import UIKit
import Foundation

extension WGCacheSpace {
    func set<T: WGCacheStorable>(_ obj: T, key: String) {
        obj.set(self, key: key)
    }

    func get<T: WGCacheStorable>(key: String) -> T? {
        return T.get(self, key: key)
    }
}

protocol WGCacheStorable {
    func set(_ handler: WGCacheSpace, key: String)
    static func get(_ handler: WGCacheSpace, key: String) -> Self?
}

extension Int: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Int? {
        let value: Int32 = handler.int32(forKey: key)
        return Int(value)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: Int32(self), forKey: key)
    }
}

extension Int32: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.int32(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension UInt32: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.uint32(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension Int64: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.int64(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension UInt64: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.uint64(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension Double: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.double(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension Float: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.float(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension Bool: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.bool(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension Date: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.date(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension Data: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.data(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension String: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.string(forKey: key)
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: NSString(string: self), forKey: key)
    }
}

extension Array: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: NSArray.self, forKey: key) as? Array
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: NSArray(array: self), forKey: key)
    }
}

extension Dictionary: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return  handler.object(cls: NSMutableDictionary.self, forKey: key) as? Dictionary
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: NSMutableDictionary(dictionary: self), forKey: key)
    }
}

// MARK: - OC 支持

extension NSArray: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }
    
    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}


extension NSDictionary: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}


extension NSValue: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension NSString: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension NSData: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension NSDate: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension NSURL: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension UIColor: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension UIImage: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}

extension NSAttributedString: WGCacheStorable {
    static func get(_ handler: WGCacheSpace, key: String) -> Self? {
        return handler.object(cls: Self.self, forKey: key) as? Self
    }

    func set(_ handler: WGCacheSpace, key: String) {
        handler.set(value: self, forKey: key)
    }
}
