//
//  IDTRequestsCache.h
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDTRequestsCache : NSObject

/*!
 @discussion this sets the length of time for which the cached items will be kept
 we do not guarantee that the item will be persisted during this length of time
 items will be purged prematurely if a memory warning is received
 
 if timeout is not set, a default of 600 seconds is assumed
 
 @params timeout - time(in seconds) after which cached object is purged
 */
- (void)setTimeout:(int)timeout;

/*!
 @discussion will get cached data if it exists in cache. otherwise, it will return nil
 */
- (id)getCachedResponseForRequest:(NSString *)request;

/*!
 @discussion this will persist any request for a set length of time
 only data from successful requests should be cached
 and only GET requests should be cached
 */
- (void)saveResponse:(id)dataResponse forRequest:(NSString *)request;

/*!
 @discussion this will remove the stored response in the caceh
 */
- (void)removeRequestFromCache:(NSString *)request;
@end
