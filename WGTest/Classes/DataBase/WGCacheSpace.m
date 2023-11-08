//
//  WGCacheHandler.m
//  DianBo
//
//  Created by 耿文康 on 2023/7/25.
//  Copyright © 2023 微光. All rights reserved.
//

#import "WGCacheSpace.h"
@interface WGCacheSpace ()
@property (nonatomic, weak) WGCache *core;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL didConfigSpace;
@end

@implementation WGCacheSpace

- (instancetype)initWithCacheCore:(WGCache *)cache name:(NSString *)name {
    if (self = [super init]) {
        self.core = cache;
        self.name = name;
    }

    return self;
}


- (uint64_t)count {
    return [_core countForSpace:_name];
}

- (NSArray *)allKeys {
    return [_core allKeysForSpace:_name];
}

- (BOOL)containsObjectForKey:(NSString *)key {
   
    return [_core containsObjectForSpace:_name key:key];
}

- (void)setObject:(id)value key:(NSString *)key {
    
    [_core setObject:value space:_name key:key];
}

- (void)setBool:(BOOL)value key:(NSString *)key {

    [_core setBool:value space:_name key:key];
}

- (void)setInt32:(int32_t)value key:(NSString *)key {

    [_core setInt32:value space:_name key:key];
}

- (void)setUInt32:(uint32_t)value key:(NSString *)key {
    
    [_core setUInt32:value space:_name key:key];
}

- (void)setInt64:(int64_t)value key:(NSString *)key {
    
    [_core setInt64:value space:_name key:key];
}

- (void)setUInt64:(uint64_t)value key:(NSString *)key {
    
    [_core setUInt64:value space:_name key:key];
}

- (void)setFloat:(float)value key:(NSString *)key {
    
    [_core setFloat:value space:_name key:key];
}

- (void)setDouble:(double)value key:(NSString *)key {
    
    [_core setDouble:value space:_name key:key];
}

- (void)setString:(NSString *)value key:(NSString *)key {
    
    [_core setString:value space:_name key:key];
}

- (void)setDate:(NSDate *)value key:(NSString *)key {
    
    [_core setDate:value space:_name key:key];
}

- (void)setData:(NSData *)value key:(NSString *)key {
    
    [_core setData:value space:_name key:key];
}

- (id)getObjectOfClass:(Class)cls key:(NSString *)key {
    
    return [_core getObjectOfClass:cls space:_name key:key];
}

- (BOOL)getBoolForKey:(NSString *)key {
    
    return [_core getBoolForSpace:_name key:key];
}
- (BOOL)getBoolForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    
    return [_core getBoolForSpace:_name key:key defaultValue:defaultValue];
}

- (int32_t)getInt32ForKey:(NSString *)key {
    
    return [_core getInt32ForSpace:_name key:key];
}

- (int32_t)getInt32ForKey:(NSString *)key defaultValue:(int32_t)defaultValue {
    
    return [_core getInt32ForSpace:_name key:key defaultValue:defaultValue];
}


- (uint32_t)getUInt32ForKey:(NSString *)key {
    
    return [_core getUInt32ForSpace:_name key:key];
}

- (uint32_t)getUInt32ForKey:(NSString *)key defaultValue:(uint32_t)defaultValue {
    
    return [_core getUInt32ForSpace:_name key:key defaultValue:defaultValue];
}

- (int64_t)getInt64ForKey:(NSString *)key {
    
    return [_core getInt64ForSpace:_name key:key];
}

- (int64_t)getInt64ForKey:(NSString *)key defaultValue:(int64_t)defaultValue {
    
    return [_core getInt64ForSpace:_name key:key defaultValue:defaultValue];
}

- (uint64_t)getUInt64ForKey:(NSString *)key {
    
    return [_core getUInt64ForSpace:_name key:key];
}

- (uint64_t)getUInt64ForKey:(NSString *)key defaultValue:(uint64_t)defaultValue {
    
    return [_core getUInt64ForSpace:_name key:key defaultValue:defaultValue];
}

- (float)getFloatForKey:(NSString *)key {
    
    return [_core getFloatForSpace:_name key:key];
}

- (float)getFloatForKey:(NSString *)key defaultValue:(float)defaultValue {
    
    return [_core getFloatForSpace:_name key:key defaultValue:defaultValue];
}

- (double)getDoubleForKey:(NSString *)key {
    
    return [_core getDoubleForSpace:_name key:key];
}

- (double)getDoubleForKey:(NSString *)key defaultValue:(double)defaultValue {
    
    return [_core getDoubleForSpace:_name key:key defaultValue:defaultValue];
}

- (nullable NSString *)getStringForKey:(NSString *)key {
    
    return [_core getStringForSpace:_name key:key];
}

- (nullable NSDate *)getDateForKey:(NSString *)key {
    
    return [_core getDateForSpace:_name key:key];
}

- (nullable NSData *)getDataForKey:(NSString *)key {
    
    return [_core getDataForSpace:_name key:key];
}

- (void)removeForKey:(NSString *)key {
    
    [_core removeForSpace:_name key:key];
}

- (void)removeForKeys:(NSArray *)keys {
    [_core removeForSpace:_name keys:keys];
};

- (void)removeAll {
    [_core removeAllForSpace:_name];
};


@end
