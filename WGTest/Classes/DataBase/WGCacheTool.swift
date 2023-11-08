//
//  WGCacheTool.swift
//  DianBo
//
//  Created by 耿文康 on 2023/7/25.
//  Copyright © 2023 微光. All rights reserved.
//

import Foundation

@objcMembers
class WGCacheTool: NSObject {
    static var shared: WGCacheTool = WGCacheTool()

    var memoryCache: WGMemoryCache?
    var diskCache: WGDiskCache?
    var spaceInstanceDic: [String: WGCacheSpace]
    private var core: WGCache?
    private let lock = NSLock()

    override private init() {
        spaceInstanceDic = [:]
    }

    func initialize(path: String?) {
        if core == nil {
            core = WGCache(path: path)
            memoryCache = core!.memoryCache
            diskCache = core!.diskCache
            spaceInstanceDic["defaultCacheSpace"] = WGCacheSpace(cacheCore: core!, name: nil)
        }
    }

    func defaultCacheSpace() -> WGCacheSpace {
        return spaceInstanceDic["defaultCacheSpace"]!
    }

    func cacheSpace(name: String?) -> WGCacheSpace {
        if let tempName = name {
            lock.lock()
            defer {
                lock.unlock()
            }
            if let space = spaceInstanceDic[tempName] {
                return space
            }
            let space = WGCacheSpace(cacheCore: core!, name: name)
            spaceInstanceDic[tempName] = space
            return space

        } else {
            return defaultCacheSpace()
        }
    }
}
