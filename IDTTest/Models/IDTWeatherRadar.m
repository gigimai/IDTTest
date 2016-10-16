//
//  IDTWeatherRadar.m
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import "IDTWeatherRadar.h"
#import "AFNetworking.h"

static const NSString *IDTWeatherBaseURL = @"http://api.openweathermap.org/";

/// Endpoints
static NSString * const IDTWeeklyWeatherEndpoint = @"data/2.5/forecast/daily";
static NSString * const IDTTodayWeatherEndpoint = @"data/2.5/weather";

/// Param keys
static NSString * const kLongitude = @"lon";
static NSString * const kLattitude = @"lat";
static NSString * const kUnits = @"units";
static NSString * const kAppID = @"APPID";

@implementation IDTWeatherRadar

- (void)fetchWeatherFromProvider:(NSString*)URL
                      parameters:(NSDictionary *)parameters
                 completionBlock:(void (^)(NSDictionary *))completionBlock {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URL
      parameters:parameters
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             if (responseObject) {
                 completionBlock(responseObject);
             } else {
                 completionBlock(nil);
             }
         } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
             // handle error
         }];
}

- (void)getWeeklyWeather:(float)latitude longitude:(float)longitude
         completionBlock:(void (^)(NSArray *))completionBlock {
    
    // formulate the url to query the api to get the 7 day
    // forecast. cnt=7 asks the api for 7 days. units = imperial
    // will return temperatures in Farenheit
    NSString *url = [self getUrlFromEndpoint:IDTWeeklyWeatherEndpoint];
    
    [self fetchWeatherFromProvider:url
                        parameters:[self requestParameters:@{kLattitude:@(latitude),kLongitude:@(longitude)}]
                   completionBlock:^(NSDictionary * weatherData) {
                       // create an array of weather objects (one for each day)
                       // initialize them using the function from listing 7
                       // and return the results to the calling controller
                       NSMutableArray *weeklyWeather = [[NSMutableArray alloc] init];
                       
                       for(NSDictionary* weather in weatherData[@"list"]) {
                           // pass false since the weather is a future forecast
                           // this lets the init function know which format of
                           // data to parse
                           IDTWeather* day = [[IDTWeather alloc] initWithDictionary:weather isCurrentWeather:FALSE];
                           [weeklyWeather addObject:day];
                       }
                       
                       completionBlock(weeklyWeather);
                   }];
}

- (void)getCurrentWeather:(float)latitude longitude:(float)longitude
          completionBlock:(void (^)(IDTWeather *))completionBlock {
    
    NSString *url = [self getUrlFromEndpoint:IDTTodayWeatherEndpoint];
    [self fetchWeatherFromProvider:url
                        parameters:[self requestParameters:@{kLattitude:@(latitude),kLongitude:@(longitude)}]
                   completionBlock:^(NSDictionary * weatherData) {
                       completionBlock([[IDTWeather alloc]
                                        initWithDictionary:weatherData isCurrentWeather:TRUE]);
                   }];
}

#pragma MARK - Helpers

- (NSDictionary *)requestParameters:(NSDictionary *)parameters {
    
    NSMutableDictionary *params = [parameters mutableCopy];
    if (!params) {
        params = [NSMutableDictionary new];
    }
    /// Inject openweatherorg APP ID
    [params setObject:@"dfe8ab65bd12f706b2c374d571ef9801" forKey:kAppID];
    /// To return temperature in Celsius
    [params setObject:@"metric" forKey:kUnits];
    return  params.copy;
}

- (NSString *)getUrlFromEndpoint:(NSString *)endpoint {
    
    NSString *url = nil;
    if (endpoint.length && [endpoint characterAtIndex:0] != '/' && [IDTWeatherBaseURL characterAtIndex:IDTWeatherBaseURL.length - 1] != '/') {
        url = [[IDTWeatherBaseURL stringByAppendingString:@"/"]stringByAppendingString:endpoint];
    } else {
        url = [IDTWeatherBaseURL stringByAppendingString:endpoint];
    }
    // escape the url to avoid any potential errors
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}
@end
