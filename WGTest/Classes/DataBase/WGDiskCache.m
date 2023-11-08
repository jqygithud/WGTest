//
//  WGDiskCache.m
//  DianBo
//
//  Created by 耿文康 on 2023/7/17.
//  Copyright © 2023 微光. All rights reserved.
//

#import "WGDiskCache.h"
#import <MMKV/MMKV.h>
@implementation WGDiskCache

- (instancetype)init {
    @throw [NSException exceptionWithName:@"YYDiskCache init error" reason:@"YYDiskCache must be initialized with a path. Use 'initWithPath:' instead." userInfo:nil];
    return [self initWithPath:@""];
}


- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (!self) return nil;
    _path = path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [MMKV initializeMMKV:path logLevel:MMKVLogNone];
    });
    
    return self;
}

- (BOOL)containsObjectForSpace:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        return [mmkv containsKey:key];
    }
    return NO;
}

- (uint64_t)countForSpace:(NSString *)space {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        return mmkv.count;
    }
    return 0;
}

- (NSArray *)allKeysForSpace:(NSString *)space {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        return mmkv.allKeys;
    }
    return @[];
}

#pragma mark - set cache
-(void)setObject:(id)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setObject:value forKey:key];
    }
}

- (void)setBool:(BOOL)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setBool:value forKey:key];
    }
}

- (void)setInt32:(int32_t)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setInt32:value forKey:key];
    }
}

- (void)setUInt32:(uint32_t)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setUInt32:value forKey:key];
    }
}

- (void)setInt64:(int64_t)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setInt64:value forKey:key];
    }
}

- (void)setUInt64:(uint64_t)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setUInt64:value forKey:key];
    }
}

- (void)setFloat:(float)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setFloat:value forKey:key];
    }
}

- (void)setDouble:(double)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setDouble:value forKey:key];
    }
}

- (void)setString:(NSString *)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setString:value forKey:key];
    }
}

- (void)setDate:(NSDate *)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setDate:value forKey:key];
    }
}

- (void)setData:(NSData *)value space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv setData:value forKey:key];
    }
}
#pragma mark - get cache

- (id)getObjectOfClass:(Class)cls space:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        return [mmkv getObjectOfClass:cls forKey:key];
    }
    return nil;
}

- (BOOL)getBoolForSpace:(NSString *)space key:(NSString *)key {
    return [self getBoolForSpace:space key:key defaultValue:NO];
}

- (BOOL)getBoolForSpace:(NSString *)space key:(NSString *)key defaultValue:(BOOL)defaultValue {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        if (![mmkv containsKey:key]) {
            return defaultValue;
        }
        return [mmkv getBoolForKey:key];
    }
    return defaultValue;
}


- (int32_t)getInt32ForSpace:(NSString *)space key:(NSString *)key {
    return [self getInt32ForSpace:space key:key defaultValue: 0];
}

- (int32_t)getInt32ForSpace:(NSString *)space key:(NSString *)key defaultValue:(int32_t)defaultValue {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        if (![mmkv containsKey:key]) {
            return defaultValue;
        }
        return [mmkv getInt32ForKey:key];
    }
    return defaultValue;
}


- (uint32_t)getUInt32ForSpace:(NSString *)space key:(NSString *)key {
    return [self getUInt32ForSpace:space key:key defaultValue: 0];
}

- (uint32_t)getUInt32ForSpace:(NSString *)space key:(NSString *)key defaultValue:(uint32_t)defaultValue {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        if (![mmkv containsKey:key]) {
            return defaultValue;
        }
        return [mmkv getUInt32ForKey:key];
    }
    return defaultValue;
}



- (int64_t)getInt64ForSpace:(NSString *)space key:(NSString *)key {
    return [self getInt64ForSpace:space key:key defaultValue: 0];
}

- (int64_t)getInt64ForSpace:(NSString *)space key:(NSString *)key defaultValue:(int64_t)defaultValue {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        if (![mmkv containsKey:key]) {
            return defaultValue;
        }
        return [mmkv getInt64ForKey:key];
    }
    return defaultValue;
}


- (uint64_t)getUInt64ForSpace:(NSString *)space key:(NSString *)key {
    return [self getUInt64ForSpace:space key:key defaultValue: 0];
}

- (uint64_t)getUInt64ForSpace:(NSString *)space key:(NSString *)key defaultValue:(uint64_t)defaultValue {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        if (![mmkv containsKey:key]) {
            return defaultValue;
        }
        return [mmkv getUInt64ForKey:key];
    }
    return defaultValue;
}


- (float)getFloatForSpace:(NSString *)space key:(NSString *)key {
    return [self getFloatForSpace:space key:key defaultValue: 0];
}

- (float)getFloatForSpace:(NSString *)space key:(NSString *)key defaultValue:(float)defaultValue {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        if (![mmkv containsKey:key]) {
            return defaultValue;
        }
        return [mmkv getFloatForKey:key];
    }
    return defaultValue;
}



- (double)getDoubleForSpace:(NSString *)space key:(NSString *)key {
    return [self getDoubleForSpace:space key:key defaultValue: 0];
}

- (double)getDoubleForSpace:(NSString *)space key:(NSString *)key defaultValue:(double)defaultValue {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        if (![mmkv containsKey:key]) {
            return defaultValue;
        }
        return [mmkv getDoubleForKey:key];
    }
    return defaultValue;
}

- (nullable NSString *)getStringForSpace:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        return [mmkv getStringForKey:key];
    }
    return nil;
}

- (nullable NSDate *)getDateForSpace:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        return [mmkv getDateForKey:key];
    }
    return nil;
}


- (nullable NSData *)getDataForSpace:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        return [mmkv getDataForKey:key];
    }
    return nil;
}




- (void)removeForSpace:(NSString *)space key:(NSString *)key {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv removeValueForKey:key];
    }
}

- (void)removeAllForSpace:(NSString *)space {
    MMKV *mmkv = [self getMMKVForSpace:space];
    if (mmkv) {
        [mmkv clearAll];
    }
}


- (MMKV *)getMMKVForSpace:(NSString *)space {
    if (!space || [@"" isEqualToString:space]) {
        return [MMKV defaultMMKV];
    }
    return [MMKV mmkvWithID:space];
}

@end
