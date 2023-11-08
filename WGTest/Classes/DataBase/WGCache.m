//
//  WGCache.m
//  DianBo
//
//  Created by 耿文康 on 2023/7/17.
//  Copyright © 2023 微光. All rights reserved.
//

#import "WGCache.h"

static inline dispatch_queue_t WGCacheSyncQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}



@implementation WGCache

- (instancetype)init {
    NSLog(@"Use \"initWithName\" or \"initWithPath\" to create YYCache instance.");
    return [self initWithPath:@""];
}

- (instancetype)initWithName:(NSString *)name {
    if (name.length == 0) {
        return nil;
    }

    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheFolder stringByAppendingPathComponent:name];
    return [self initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        WGDiskCache *diskCache = [[WGDiskCache alloc] initWithPath:path];
        WGMemoryCache *memoryCache = [WGMemoryCache new];
        NSString *name;

        if (path) {
            name = [path lastPathComponent];
        }

        memoryCache.name = name?:@"WGCache";

        
        _name = name;
        _diskCache = diskCache;
        _memoryCache = memoryCache;
    }
    return self;
}

- (uint64_t)countForSpace:(NSString *)space {
    uint64_t count = [self memoryCacheCountForSpace:space];

    if (count > 0) {
        return count;
    }

    count = [_diskCache countForSpace:space];
    return count;
}

- (NSArray *)allKeysForSpace:(NSString *)space {
    return [_diskCache allKeysForSpace:space];
}

- (BOOL)containsObjectForSpace:(NSString *)space key:(NSString *)key {
    BOOL memoryContains = [_memoryCache containsObjectForKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    if (memoryContains) {
        return memoryContains;
    }

    return [_diskCache containsObjectForSpace:space key:key];
}

- (void)setObject:(id)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:value forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setObject:value space:space key:key];
}


- (void)setBool:(BOOL)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:[NSNumber numberWithBool:value] forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setBool:value space:space key:key];
}

- (void)setInt32:(int32_t)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:[NSNumber numberWithInt:value] forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setInt32:value space:space key:key];
}

- (void)setUInt32:(uint32_t)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:[NSNumber numberWithUnsignedInt:value] forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setUInt32:value space:space key:key];
}

- (void)setInt64:(int64_t)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:[NSNumber numberWithLongLong:value] forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setInt64:value space:space key:key];
}

- (void)setUInt64:(uint64_t)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:[NSNumber numberWithUnsignedLongLong:value] forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setUInt64:value space:space key:key];
}

- (void)setFloat:(float)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:[NSNumber numberWithFloat:value] forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setFloat:value space:space key:key];
}

- (void)setDouble:(double)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:[NSNumber numberWithDouble:value] forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setDouble:value space:space key:key];
}

- (void)setString:(NSString *)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:value forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setString:value space:space key:key];
}

- (void)setDate:(NSDate *)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:value forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setDate:value space:space key:key];
}

- (void)setData:(NSData *)value space:(NSString *)space key:(NSString *)key {
    [_memoryCache setObject:value forKey:[self memoryCacheKeyWithSpace:space subkey:key]];

    [_diskCache setData:value space:space key:key];
}

- (id)getObjectOfClass:(Class)cls space:(NSString *)space key:(NSString *)key {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];
    id value = [_memoryCache objectForKey:memoryKey];
    if (!value) {
        value = [_diskCache getObjectOfClass:cls space:space key:key];
        if (value) {
            dispatch_async(WGCacheSyncQueue(), ^{
                [_memoryCache setObject:value forKey:memoryKey];
            });
        }
    }
    return value;
}

- (BOOL)getBoolForSpace:(NSString *)space key:(NSString *)key {
    return [self getBoolForSpace:space key:key defaultValue:NO];
}

- (BOOL)getBoolForSpace:(NSString *)space key:(NSString *)key defaultValue:(BOOL)defaultValue {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];
    NSNumber *object = [_memoryCache objectForKey:memoryKey];
    BOOL resultValue = object ? object.boolValue : defaultValue;
    if (!object && [_diskCache containsObjectForSpace:space key:key]) {
        resultValue = [_diskCache getBoolForSpace:space key:key defaultValue:defaultValue];
        dispatch_async(WGCacheSyncQueue(), ^{
            [_memoryCache setObject:@(resultValue) forKey:memoryKey];
        });
        
    }
    return resultValue;
}

- (int32_t)getInt32ForSpace:(NSString *)space key:(NSString *)key {
    return [self getInt32ForSpace:space key:key defaultValue:0];
}

- (int32_t)getInt32ForSpace:(NSString *)space key:(NSString *)key defaultValue:(int32_t)defaultValue {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];
    NSNumber *object = [_memoryCache objectForKey:memoryKey];
    int32_t resultValue = object ? object.intValue : defaultValue;
    if (!object && [_diskCache containsObjectForSpace:space key:key]) {
       resultValue = [_diskCache getInt32ForSpace:space key:key defaultValue:defaultValue];
       dispatch_async(WGCacheSyncQueue(), ^{
           [_memoryCache setObject:@(resultValue) forKey:memoryKey];
       });
        
    }
    return resultValue;
}

- (uint32_t)getUInt32ForSpace:(NSString *)space key:(NSString *)key {
    return [self getUInt32ForSpace:space key:key defaultValue:0];
}

- (uint32_t)getUInt32ForSpace:(NSString *)space key:(NSString *)key defaultValue:(uint32_t)defaultValue {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];
    NSNumber *object = [_memoryCache objectForKey:memoryKey];
    uint32_t resultValue = object ? object.unsignedIntValue : defaultValue;
    if (!object && [_diskCache containsObjectForSpace:space key:key]) {
       resultValue = [_diskCache getUInt32ForSpace:space key:key defaultValue:defaultValue];
       dispatch_async(WGCacheSyncQueue(), ^{
           [_memoryCache setObject:@(resultValue) forKey:memoryKey];
       });
        
    }
    return resultValue;
}

- (int64_t)getInt64ForSpace:(NSString *)space key:(NSString *)key {
    return [self getInt64ForSpace:space key:key defaultValue:0];
}

- (int64_t)getInt64ForSpace:(NSString *)space key:(NSString *)key defaultValue:(int64_t)defaultValue {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];
    NSNumber *object = [_memoryCache objectForKey:memoryKey];
    int64_t resultValue = object ? object.longLongValue : defaultValue;
    if (!object && [_diskCache containsObjectForSpace:space key:key]) {
       resultValue = [_diskCache getInt64ForSpace:space key:key defaultValue:defaultValue];
       dispatch_async(WGCacheSyncQueue(), ^{
           [_memoryCache setObject:@(resultValue) forKey:memoryKey];
       });
        
    }
    return resultValue;
}

- (uint64_t)getUInt64ForSpace:(NSString *)space key:(NSString *)key {
    return [self getUInt64ForSpace:space key:key defaultValue:0];
}

- (uint64_t)getUInt64ForSpace:(NSString *)space key:(NSString *)key defaultValue:(uint64_t)defaultValue {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];
    NSNumber *object = [_memoryCache objectForKey:memoryKey];
    uint64_t resultValue = object ? object.unsignedLongLongValue : defaultValue;
    if (!object && [_diskCache containsObjectForSpace:space key:key]) {
       resultValue = [_diskCache getUInt64ForSpace:space key:key defaultValue:defaultValue];
       dispatch_async(WGCacheSyncQueue(), ^{
           [_memoryCache setObject:@(resultValue) forKey:memoryKey];
       });
        
    }
    return resultValue;
}

- (float)getFloatForSpace:(NSString *)space key:(NSString *)key {
    return [self getFloatForSpace:space key:key defaultValue:0];
}

- (float)getFloatForSpace:(NSString *)space key:(NSString *)key defaultValue:(float)defaultValue {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];
    NSNumber *object = [_memoryCache objectForKey:memoryKey];
    float resultValue = object ? object.floatValue : defaultValue;
    if (!object && [_diskCache containsObjectForSpace:space key:key]) {
       resultValue = [_diskCache getFloatForSpace:space key:key defaultValue:defaultValue];
       dispatch_async(WGCacheSyncQueue(), ^{
           [_memoryCache setObject:@(resultValue) forKey:memoryKey];
       });
        
    }
    return resultValue;
}

- (double)getDoubleForSpace:(NSString *)space key:(NSString *)key {
    return [self getDoubleForSpace:space key:key defaultValue:0];
}

- (double)getDoubleForSpace:(NSString *)space key:(NSString *)key defaultValue:(double)defaultValue {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];
    NSNumber *object = [_memoryCache objectForKey:memoryKey];
    double resultValue = object ? object.doubleValue : defaultValue;
    if (!object && [_diskCache containsObjectForSpace:space key:key]) {
       resultValue = [_diskCache getDoubleForSpace:space key:key defaultValue:defaultValue];
       dispatch_async(WGCacheSyncQueue(), ^{
           [_memoryCache setObject:@(resultValue) forKey:memoryKey];
       });
        
    }
    return resultValue;
}

- (nullable NSString *)getStringForSpace:(NSString *)space key:(NSString *)key {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];

    if ([_memoryCache containsObjectForKey:memoryKey]) {
        return [_memoryCache objectForKey:memoryKey];
    }
    
    NSString *value = [_diskCache getStringForSpace:space key:key];
    if (value) {
        dispatch_async(WGCacheSyncQueue(), ^{
            [_memoryCache setObject:value forKey:memoryKey];
        });
    }

    return value;
}

- (nullable NSDate *)getDateForSpace:(NSString *)space key:(NSString *)key {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];

    if ([_memoryCache containsObjectForKey:memoryKey]) {
        return [_memoryCache objectForKey:memoryKey];
    }

    NSDate *value = [_diskCache getDateForSpace:space key:key];
    if (value) {
        dispatch_async(WGCacheSyncQueue(), ^{
            [_memoryCache setObject:value forKey:memoryKey];
        });
    }

    return value;
}

- (nullable NSData *)getDataForSpace:(NSString *)space key:(NSString *)key {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];

    if ([_memoryCache containsObjectForKey:memoryKey]) {
        return [_memoryCache objectForKey:memoryKey];
    }

    NSData *value = [_diskCache getDataForSpace:space key:key];
    if (value) {
        dispatch_async(WGCacheSyncQueue(), ^{
            [_memoryCache setObject:value forKey:memoryKey];
        });
    }
    return value;
}

- (void)removeForSpace:(NSString *)space key:(NSString *)key {
    NSString *memoryKey = [self memoryCacheKeyWithSpace:space subkey:key];

    [_memoryCache removeObjectForKey:memoryKey];
    [_diskCache removeForSpace:space key:key];
}

- (void)removeForSpace:(NSString *)space keys:(NSArray *)keys {
    for (NSString *key in [keys copy]) {
        [self removeForSpace:space key:key];
    }
}

- (void)removeAllForSpace:(NSString *)space {
    NSArray *memoryAllKeys = [self memoryCacheAllKeysForSpace:space];

    for (NSString *key in memoryAllKeys) {
        [_memoryCache removeObjectForKey:key];
    }
    [_diskCache removeAllForSpace:space];
}

#pragma mark - action
- (NSString *)memoryCacheKeyWithSpace:(NSString *)space subkey:(NSString *)subkey {
    return [[NSString stringWithFormat:@"%@_%@", space?:@"WGDefaultCache", subkey] mutableCopy];
}

- (NSArray *)memoryCacheAllKeysForSpace:(NSString *)space {
    NSMutableArray *spaceAllKeys = NSMutableArray.new;
    NSArray *allKeys = _memoryCache.getAllKeys;

    for (NSString *key in allKeys) {
        if ([key hasPrefix:[NSString stringWithFormat:@"%@_", space]]) {
            [spaceAllKeys addObject:[key mutableCopy]];
        }
    }

    return spaceAllKeys;
}

- (uint64_t)memoryCacheCountForSpace:(NSString *)space {
    return [self memoryCacheAllKeysForSpace:space].count;
}

@end
