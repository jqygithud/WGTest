//
//  WGCache.h
//  DianBo
//
//  Created by 耿文康 on 2023/7/17.
//  Copyright © 2023 微光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGDiskCache.h"
#import "WGMemoryCache.h"
NS_ASSUME_NONNULL_BEGIN

@interface WGCache : NSObject
@property (copy, readonly) NSString *name;
@property (strong, readonly) WGMemoryCache *memoryCache;
@property (strong, readonly) WGDiskCache *diskCache;

- (instancetype)initWithName:(NSString *)name;

- (instancetype)initWithPath:( NSString * _Nullable )path;

- (uint64_t)countForSpace:(NSString *)space;

- (NSArray *)allKeysForSpace:(NSString *)space;

- (BOOL)containsObjectForSpace:(NSString *)space key:(NSString *)key;

- (void)setObject:(id)value space:(NSString *)space key:(NSString *)key;

- (void)setBool:(BOOL)value space:(NSString *)space key:(NSString *)key;

- (void)setInt32:(int32_t)value space:(NSString *)space key:(NSString *)key;

- (void)setUInt32:(uint32_t)value space:(NSString *)space key:(NSString *)key;

- (void)setInt64:(int64_t)value space:(NSString *)space key:(NSString *)key;

- (void)setUInt64:(uint64_t)value space:(NSString *)space key:(NSString *)key;

- (void)setFloat:(float)value space:(NSString *)space key:(NSString *)key;

- (void)setDouble:(double)value space:(NSString *)space key:(NSString *)key;

- (void)setString:(NSString *)value space:(NSString *)space key:(NSString *)key;

- (void)setDate:(NSDate *)value space:(NSString *)space key:(NSString *)key;

- (void)setData:(NSData *)value space:(NSString *)space key:(NSString *)key;


- (id)getObjectOfClass:(Class)cls space:(NSString *)space key:(NSString *)key;

- (BOOL)getBoolForSpace:(NSString *)space key:(NSString *)key;
- (BOOL)getBoolForSpace:(NSString *)space key:(NSString *)key defaultValue:(BOOL)defaultValue;

- (int32_t)getInt32ForSpace:(NSString *)space key:(NSString *)key;
- (int32_t)getInt32ForSpace:(NSString *)space key:(NSString *)key defaultValue:(int32_t)defaultValue;

- (uint32_t)getUInt32ForSpace:(NSString *)space key:(NSString *)key;
- (uint32_t)getUInt32ForSpace:(NSString *)space key:(NSString *)key defaultValue:(uint32_t)defaultValue;

- (int64_t)getInt64ForSpace:(NSString *)space key:(NSString *)key;
- (int64_t)getInt64ForSpace:(NSString *)space key:(NSString *)key defaultValue:(int64_t)defaultValue;

- (uint64_t)getUInt64ForSpace:(NSString *)space key:(NSString *)key;
- (uint64_t)getUInt64ForSpace:(NSString *)space key:(NSString *)key defaultValue:(uint64_t)defaultValue;

- (float)getFloatForSpace:(NSString *)space key:(NSString *)key;
- (float)getFloatForSpace:(NSString *)space key:(NSString *)key defaultValue:(float)defaultValue;

- (double)getDoubleForSpace:(NSString *)space key:(NSString *)key;
- (double)getDoubleForSpace:(NSString *)space key:(NSString *)key defaultValue:(double)defaultValue;

- (nullable NSString *)getStringForSpace:(NSString *)space key:(NSString *)key;

- (nullable NSDate *)getDateForSpace:(NSString *)space key:(NSString *)key;

- (nullable NSData *)getDataForSpace:(NSString *)space key:(NSString *)key;

- (void)removeForSpace:(NSString *)space key:(NSString *)key;
- (void)removeForSpace:(NSString *)space keys:(NSArray *)keys;
- (void)removeAllForSpace:(NSString *)space;


@end

NS_ASSUME_NONNULL_END
