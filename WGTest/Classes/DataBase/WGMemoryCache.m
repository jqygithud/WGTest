//
//  WGMemoryCache.m
//  DianBo
//
//  Created by 耿文康 on 2023/7/17.
//  Copyright © 2023 微光. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <pthread.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "WGMemoryCache.h"

static inline dispatch_queue_t WGMemoryCacheGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

/**
   A node in linked map.
   Typically, you should not use this class directly.
 */
@interface _WGLinkedMapNode : NSObject {
    @package
    __unsafe_unretained _WGLinkedMapNode *_prev; // retained by dic
    __unsafe_unretained _WGLinkedMapNode *_next; // retained by dic
    NSString *_key;
    id _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}
@end

@implementation _WGLinkedMapNode
@end


/**
   A linked map used by YYMemoryCache.
   It's not thread-safe and does not validate the parameters.

   Typically, you should not use this class directly.
 */
@interface _WGLinkedMap : NSObject {
    @package
    NSMutableDictionary *_dic; // do not set object directly
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    _WGLinkedMapNode *_head; // MRU, do not change it directly
    _WGLinkedMapNode *_tail; // LRU, do not change it directly
    BOOL _releaseOnMainThread;
    BOOL _releaseAsynchronously;
}

/// Insert a node at head and update the total cost.
/// Node and node.key should not be nil.
- (void)insertNodeAtHead:(_WGLinkedMapNode *)node;

/// Bring a inner node to header.
/// Node should already inside the dic.
- (void)bringNodeToHead:(_WGLinkedMapNode *)node;

/// Remove a inner node and update the total cost.
/// Node should already inside the dic.
- (void)removeNode:(_WGLinkedMapNode *)node;

/// Remove tail node if exist.
- (_WGLinkedMapNode *)removeTailNode;

/// Remove all node in background queue.
- (void)removeAll;

@end

@implementation _WGLinkedMap

- (instancetype)init {
    self = [super init];
    _dic = NSMutableDictionary.new;
    _releaseOnMainThread = NO;
    _releaseAsynchronously = YES;
    return self;
}


- (void)insertNodeAtHead:(_WGLinkedMapNode *)node {
    [_dic setValue:node forKey:node->_key];
    _totalCost += node->_cost;
    _totalCount++;

    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)bringNodeToHead:(_WGLinkedMapNode *)node {
    if (_head == node) {
        return;
    }

    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }

    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

- (void)removeNode:(_WGLinkedMapNode *)node {
    [_dic removeObjectForKey:node->_key];
    _totalCost -= node->_cost;
    _totalCount--;

    if (node->_next) {
        node->_next->_prev = node->_prev;
    }

    if (node->_prev) {
        node->_prev->_next = node->_next;
    }

    if (_head == node) {
        _head = node->_next;
    }

    if (_tail == node) {
        _tail = node->_prev;
    }
}

- (_WGLinkedMapNode *)removeTailNode {
    if (!_tail) {
        return nil;
    }

    _WGLinkedMapNode *tail = _tail;
    [_dic removeObjectForKey:_tail->_key];
    _totalCost -= _tail->_cost;
    _totalCount--;

    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail->_prev;
        _tail->_next = nil;
    }

    return tail;
}

- (void)removeAll {
    _totalCost = 0;
    _totalCount = 0;
    _head = nil;
    _tail = nil;

    if (_dic.allKeys.count > 0) {
        NSMutableDictionary *holder = _dic;
        _dic = NSMutableDictionary.new;

        if (_releaseAsynchronously) {
            dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : WGMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [holder class];
            });
        } else if (_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [holder class];
            });
        } else {
            [holder class];
        }
    }
}

@end



@implementation WGMemoryCache {
    pthread_mutex_t _lock;
    _WGLinkedMap *_lru;
    dispatch_queue_t _queue;
}

- (void)_trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;

        if (!self) {
            return;
        }

        [self _trimInBackground];
        [self _trimRecursively];
    });
}

- (void)_trimInBackground {
    dispatch_async(_queue, ^{
        [self _trimToCost:self->_costLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToAge:self->_ageLimit];
    });
}

- (void)_trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;

    pthread_mutex_lock(&_lock);

    if (costLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCost <= costLimit) {
        finish = YES;
    }

    pthread_mutex_unlock(&_lock);

    if (finish) {
        return;
    }

    NSMutableArray *holder = [NSMutableArray new];

    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCost > costLimit) {
                _WGLinkedMapNode *node = [_lru removeTailNode];

                if (node) {
                    [holder addObject:node];
                }
            } else {
                finish = YES;
            }

            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }

    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : WGMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)_trimToCount:(NSUInteger)countLimit {
    BOOL finish = NO;

    pthread_mutex_lock(&_lock);

    if (countLimit == 0) {
        [_lru removeAll];
        finish = YES;
    } else if (_lru->_totalCount <= countLimit) {
        finish = YES;
    }

    pthread_mutex_unlock(&_lock);

    if (finish) {
        return;
    }

    NSMutableArray *holder = [NSMutableArray new];

    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_totalCount > countLimit) {
                _WGLinkedMapNode *node = [_lru removeTailNode];

                if (node) {
                    [holder addObject:node];
                }
            } else {
                finish = YES;
            }

            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }

    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : WGMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)_trimToAge:(NSTimeInterval)ageLimit {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();

    pthread_mutex_lock(&_lock);

    if (ageLimit <= 0) {
        [_lru removeAll];
        finish = YES;
    } else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageLimit) {
        finish = YES;
    }

    pthread_mutex_unlock(&_lock);

    if (finish) {
        return;
    }

    NSMutableArray *holder = [NSMutableArray new];

    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_lru->_tail && (now - _lru->_tail->_time) > ageLimit) {
                _WGLinkedMapNode *node = [_lru removeTailNode];

                if (node) {
                    [holder addObject:node];
                }
            } else {
                finish = YES;
            }

            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }

    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : WGMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

- (void)_appDidReceiveMemoryWarningNotification {
    if (self.didReceiveMemoryWarningBlock) {
        self.didReceiveMemoryWarningBlock(self);
    }

    if (self.shouldRemoveAllObjectsOnMemoryWarning) {
        [self removeAllObjects];
    }
}

- (void)_appDidEnterBackgroundNotification {
    if (self.didEnterBackgroundBlock) {
        self.didEnterBackgroundBlock(self);
    }

    if (self.shouldRemoveAllObjectsWhenEnteringBackground) {
        [self removeAllObjects];
    }
}

#pragma mark - public

- (instancetype)init {
    self = super.init;
    pthread_mutex_init(&_lock, NULL);
    _lru = [_WGLinkedMap new];
    _queue = dispatch_queue_create("com.wg.cache.memory", DISPATCH_QUEUE_SERIAL);

    _countLimit = NSUIntegerMax;
    _costLimit = NSUIntegerMax;
    _ageLimit = DBL_MAX;
    _autoTrimInterval = 5.0;
    _shouldRemoveAllObjectsOnMemoryWarning = YES;
    _shouldRemoveAllObjectsWhenEnteringBackground = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];

    [self _trimRecursively];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_lru removeAll];
    pthread_mutex_destroy(&_lock);
}

- (NSUInteger)totalCount {
    pthread_mutex_lock(&_lock);
    NSUInteger count = _lru->_totalCount;
    pthread_mutex_unlock(&_lock);
    return count;
}

- (NSUInteger)totalCost {
    pthread_mutex_lock(&_lock);
    NSUInteger totalCost = _lru->_totalCost;
    pthread_mutex_unlock(&_lock);
    return totalCost;
}

- (BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    BOOL releaseOnMainThread = _lru->_releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
    return releaseOnMainThread;
}

- (void)setReleaseOnMainThread:(BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    _lru->_releaseOnMainThread = releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)releaseAsynchronously {
    pthread_mutex_lock(&_lock);
    BOOL releaseAsynchronously = _lru->_releaseAsynchronously;
    pthread_mutex_unlock(&_lock);
    return releaseAsynchronously;
}

- (void)setReleaseAsynchronously:(BOOL)releaseAsynchronously {
    pthread_mutex_lock(&_lock);
    _lru->_releaseAsynchronously = releaseAsynchronously;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)containsObjectForKey:(NSString *)key {
    if (!key) {
        return NO;
    }
    pthread_mutex_lock(&_lock);
    BOOL contains = [_lru->_dic objectForKey:key] ? true : false;
    pthread_mutex_unlock(&_lock);
    return contains;
}

- (id)objectForKey:(NSString *)key {
    if (!key) {
        return nil;
    }

    pthread_mutex_lock(&_lock);
    _WGLinkedMapNode *node = [_lru->_dic objectForKey:key];

    if (node) {
        node->_time = CACurrentMediaTime();
        [_lru bringNodeToHead:node];
    }

    pthread_mutex_unlock(&_lock);
    return node ? node->_value : nil;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key withCost:(NSUInteger)cost {
    if (!key) {
        return;
    }

    if (!object) {
        [self removeObjectForKey:key];
        return;
    }

    pthread_mutex_lock(&_lock);
    _WGLinkedMapNode *node = [_lru->_dic objectForKey:key];
    NSTimeInterval now = CACurrentMediaTime();

    if (node) {
        _lru->_totalCost -= node->_cost;
        _lru->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        [_lru bringNodeToHead:node];
    } else {
        node = [_WGLinkedMapNode new];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_lru insertNodeAtHead:node];
    }

    if (_lru->_totalCost > _costLimit) {
        dispatch_async(_queue, ^{
            [self trimToCost:_costLimit];
        });
    }

    if (_lru->_totalCount > _countLimit) {
        _WGLinkedMapNode *node = [_lru removeTailNode];

        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : WGMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }

    pthread_mutex_unlock(&_lock);
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key) {
        return;
    }

    pthread_mutex_lock(&_lock);
    _WGLinkedMapNode *node = [_lru->_dic objectForKey:key];

    if (node) {
        [_lru removeNode:node];

        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : WGMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                node->_prev = nil;
                node->_next = nil;
                node->_value = nil;
                node->_key = nil;
//                [node class]; //hold and release in queue
            });
        } else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }

    pthread_mutex_unlock(&_lock);
}

- (void)removeAllObjects {
    pthread_mutex_lock(&_lock);
    [_lru removeAll];
    pthread_mutex_unlock(&_lock);
}

- (NSArray *)getAllKeys {
    pthread_mutex_lock(&_lock);
    NSArray *keyArray = _lru->_dic.allKeys;
    pthread_mutex_unlock(&_lock);
    return keyArray;
}

- (void)trimToCount:(NSUInteger)count {
    if (count == 0) {
        [self removeAllObjects];
        return;
    }

    [self _trimToCount:count];
}

- (void)trimToCost:(NSUInteger)cost {
    [self _trimToCost:cost];
}

- (void)trimToAge:(NSTimeInterval)age {
    [self _trimToAge:age];
}

@end
