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

@implementation IDTWeatherRadar

- (void)fetchWeatherFromProvider:(NSString*)URL parameters:(NSDictionary *)parameters completionBlock:(void (^)(NSDictionary *))completionBlock {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URL
      parameters:parameters
         success:^(AFHTTPRequestOperation* operation, id responseObject) {
             if (responseObject) {
                 completionBlock(responseObject);
             } else {
                 // handle no results
             }
         } failure:^(AFHTTPRequestOperation*
                     operation, NSError *error) {
             // handle error
         }];
}

- (NSString *)getUrlFromEndpoint:(NSString *)endpoint {
    NSString *url = nil;
    if (endpoint.length && [endpoint characterAtIndex:0] != '/' && [IDTWeatherBaseURL characterAtIndex:IDTWeatherBaseURL.length - 1] != '/') {
        url = [[IDTWeatherBaseURL stringByAppendingString:@"/"]stringByAppendingString:endpoint];
    } else {
        url = [IDTWeatherBaseURL stringByAppendingString:endpoint];
    }
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (void)getWeeklyWeather:(float)latitude longitude:(float)longitude
         completionBlock:(void (^)(NSArray *))completionBlock {
    
    // formulate the url to query the api to get the 7 day
    // forecast. cnt=7 asks the api for 7 days. units = imperial
    // will return temperatures in Farenheit
    NSString *url = [self getUrlFromEndpoint:@"data/2.5/forecast/daily"];
    
    // escape the url to avoid any potential errors
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // call the fetch function from Listing 4
    [self fetchWeatherFromProvider:url
                        parameters:[self requestParameters:@{@"lat":@(latitude),@"lon":@(longitude)}]
                   completionBlock:
     ^(NSDictionary * weatherData) {
         // create an array of weather objects (one for each day)
         // initialize them using the function from listing 7
         // and return the results to the calling controller
         NSMutableArray *weeklyWeather =
         [[NSMutableArray alloc] init];
         
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
    // formulate the url to query the api to get current weather
    NSString *url = [self getUrlFromEndpoint:@"data/2.5/weather"];
    
    // call the fetch function from Listing 4
    [self fetchWeatherFromProvider:url
                        parameters:[self requestParameters:@{@"lat":@(latitude),@"lon":@(longitude)}]
                   completionBlock:^(NSDictionary * weatherData) {
                       completionBlock([[IDTWeather alloc]
                                        initWithDictionary:weatherData isCurrentWeather:TRUE]);
                   }];
}

- (NSDictionary *)requestParameters:(NSDictionary *)parameters {
    NSMutableDictionary *params = [parameters mutableCopy];
    if (!params) {
        params = [NSMutableDictionary new];
    }
    //Inject openweatherorg APP ID
    [params setObject:@"dfe8ab65bd12f706b2c374d571ef9801" forKey:@"APPID"];
    return  params.copy;
}
@end
