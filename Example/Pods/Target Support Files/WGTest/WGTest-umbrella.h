#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "WGCache.h"
#import "WGCacheSpace.h"
#import "WGDiskCache.h"
#import "WGMemoryCache.h"

FOUNDATION_EXPORT double WGTestVersionNumber;
FOUNDATION_EXPORT const unsigned char WGTestVersionString[];

