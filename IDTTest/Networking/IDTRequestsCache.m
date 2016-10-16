//
//  IDTRequestsCache.m
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import "IDTRequestsCache.h"
#import <UIKit/UIKit.h>
#import "IDTCachedRequest.h"

#define DEFAULT_TIMEOUT 600

static int cacheTimeout = DEFAULT_TIMEOUT;

@interface IDTRequestsCache ()

@property (atomic, strong) NSMutableDictionary *cache;
@property (atomic, readwrite) dispatch_source_t timer;
@property (atomic, readwrite) int cacheTimeout;

@end

@implementation IDTRequestsCache


- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = @{}.mutableCopy;
        self.cacheTimeout = DEFAULT_TIMEOUT;
        // set timer
        double interval = 1.0;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(self.timer, ^{
            [self removeExpiredRequests];
        });
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        dispatch_resume(self.timer);
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTimeout:(int)timeout {
    cacheTimeout = timeout;
}

- (id)getCachedResponseForRequest:(NSString *)request {
    @synchronized(self.cache) {
        IDTCachedRequest *cachedRequest = [self.cache objectForKey:request];
        return cachedRequest.reponse;
    }
}

- (void)saveResponse:(id)dataResponse forRequest:(NSString *)request {
    @synchronized(self.cache) {
        IDTCachedRequest *cachedRequest = [IDTCachedRequest new];
        cachedRequest.reponse = dataResponse;
        cachedRequest.createdDate = [NSDate new];
        [self.cache setObject:cachedRequest forKey:request];
    }
}

- (void)removeExpiredRequests {
    @synchronized(self.cache) {
        NSArray *keys = self.cache.allKeys.copy;
        for (NSString *key in keys) {
            IDTCachedRequest *cachedRequest = self.cache[key];
            if ([[NSDate date] timeIntervalSinceDate:cachedRequest.createdDate] > cacheTimeout) {
                [self.cache removeObjectForKey:key];
            }
        }
    }
}

- (void)removeRequestFromCache:(NSString *)request {
    @synchronized(self.cache) {
        [self.cache removeObjectForKey:request];
    }
}

- (void)receivedMemoryWarning {
    @synchronized(self.cache) {
        [self.cache removeAllObjects];
    }
}

@end
