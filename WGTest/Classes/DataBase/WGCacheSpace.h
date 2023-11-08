//
//  WGCacheSpace.h
//  DianBo
//
//  Created by 耿文康 on 2023/7/25.
//  Copyright © 2023 微光. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WGCache.h"
NS_ASSUME_NONNULL_BEGIN
@interface WGCacheSpace : NSObject

/// 初始化
- (instancetype)initWithCacheCore:(WGCache *)cache name:(NSString * _Nullable)name;

/// 存储数量
- (uint64_t)count;
/// 所有key
- (NSArray *)allKeys;
/// 是否存在某key
- (BOOL)containsObjectForKey:(NSString *)key;
/// set缓存方法
- (void)setObject:(id)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setBool:(BOOL)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setInt32:(int32_t)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setUInt32:(uint32_t)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setInt64:(int64_t)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setUInt64:(uint64_t)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setFloat:(float)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setDouble:(double)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setString:(NSString *)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setDate:(NSDate *)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

- (void)setData:(NSData *)value key:(NSString *)key NS_SWIFT_NAME(set(value:forKey:));

/// get缓存方法
- (nullable id)getObjectOfClass:(Class)cls key:(NSString *)key NS_SWIFT_NAME(object(cls:forKey:));

- (BOOL)getBoolForKey:(NSString *)key __attribute__((swift_name("bool(forKey:)")));
- (BOOL)getBoolForKey:(NSString *)key defaultValue:(BOOL)defaultValue __attribute__((swift_name("bool(forKey:defaultValue:)")));

- (int32_t)getInt32ForKey:(NSString *)key NS_SWIFT_NAME(int32(forKey:));
- (int32_t)getInt32ForKey:(NSString *)key defaultValue:(int32_t)defaultValue NS_SWIFT_NAME(int32(forKey:defaultValue:));

- (uint32_t)getUInt32ForKey:(NSString *)key NS_SWIFT_NAME(uint32(forKey:));
- (uint32_t)getUInt32ForKey:(NSString *)key defaultValue:(uint32_t)defaultValue NS_SWIFT_NAME(uint32(forKey:defaultValue:));

- (int64_t)getInt64ForKey:(NSString *)key NS_SWIFT_NAME(int64(forKey:));
- (int64_t)getInt64ForKey:(NSString *)key defaultValue:(int64_t)defaultValue NS_SWIFT_NAME(int64(forKey:defaultValue:));

- (uint64_t)getUInt64ForKey:(NSString *)key NS_SWIFT_NAME(uint64(forKey:));
- (uint64_t)getUInt64ForKey:(NSString *)key defaultValue:(uint64_t)defaultValue NS_SWIFT_NAME(uint64(forKey:defaultValue:));

- (float)getFloatForKey:(NSString *)key NS_SWIFT_NAME(float(forKey:));
- (float)getFloatForKey:(NSString *)key defaultValue:(float)defaultValue NS_SWIFT_NAME(float(forKey:defaultValue:));

- (double)getDoubleForKey:(NSString *)key NS_SWIFT_NAME(double(forKey:));
- (double)getDoubleForKey:(NSString *)key defaultValue:(double)defaultValue NS_SWIFT_NAME(double(forKey:defaultValue:));

- (nullable NSString *)getStringForKey:(NSString *)key NS_SWIFT_NAME(string(forKey:));

- (nullable NSDate *)getDateForKey:(NSString *)key NS_SWIFT_NAME(date(forKey:));

- (nullable NSData *)getDataForKey:(NSString *)key NS_SWIFT_NAME(data(forKey:));

/// 移除缓存方法
- (void)removeForKey:(NSString *)key NS_SWIFT_NAME(remove(forKey:));
- (void)removeForKeys:(NSArray *)keys NS_SWIFT_NAME(remove(forKeys:));
- (void)removeAll;

@end

NS_ASSUME_NONNULL_END

