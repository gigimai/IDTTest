//
//  IDTHTTPRequestOperationManager.h
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface IDTHTTPRequestOperationManager : AFHTTPRequestOperationManager

+(instancetype)sharedInstance;

@end
