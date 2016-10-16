//
//  IDTHTTPRequestOperationManager.m
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import "IDTHTTPRequestOperationManager.h"
#import "IDTRequestsCache.h"

@interface IDTHTTPRequestOperationManager ()

@property (atomic, strong, readonly) IDTRequestsCache *cache;

@end

@implementation IDTHTTPRequestOperationManager

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    __strong static IDTHTTPRequestOperationManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] initWithBaseURL:nil];
    });
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        _cache = [[IDTRequestsCache alloc] init];
    }
    return self;
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        
        return nil;
    }
    if ([method isEqualToString:@"GET"]) {
        @synchronized (self.cache) {
            id cachedResponse = [self.cache getCachedResponseForRequest:[self generateCachingKeyForRequest:request]];
            if (cachedResponse && success) {
                success(nil, cachedResponse);
                return nil;
            }
        }
    }
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^void(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject && [method isEqualToString:@"GET"]) {
            @synchronized (self.cache) {
                [self.cache saveResponse:responseObject forRequest:[self generateCachingKeyForRequest:request]];
            }
        }
        success(operation, responseObject);
    };
    return [super HTTPRequestOperationWithRequest:request success:successBlock failure:failure];
}


- (NSString *)generateCachingKeyForRequest:(NSURLRequest *)request {
    return request.URL.absoluteString;
}
@end
