//
//  IDTWeather.m
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import "IDTWeather.h"

@implementation IDTWeather
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                  isCurrentWeather:(BOOL)isCurrentWeather {
    self = [super init];
    
    if (self) {
        /*
         * Parse weather data from the API into this weather
         * object. Error check each field as there is no guarantee
         * that the same data will be available for every location
         */
        
        _dateOfForecast = [self utcToLocalTime:[NSDate
                                                dateWithTimeIntervalSince1970:
                                                [dictionary[@"dt"] doubleValue]]];
        
        // use the bool to determine which data format to parse
        if (isCurrentWeather) {
            int temperatureMin =
            [dictionary[@"main"][@"temp_min"] intValue];
            if(temperatureMin) {
                _temperatureMin = temperatureMin;
            }
            
            int temperatureMax =
            [dictionary[@"main"][@"temp_max"] intValue];
            if (temperatureMax) {
                _temperatureMax = temperatureMax;
            }
            
            int humidity =
            [dictionary[@"main"][@"humidity"] intValue];
            if (humidity) {
                _humidity = humidity;
            }
            
            float windSpeed =
            [dictionary[@"wind"][@"speed"] floatValue];
            if (windSpeed) {
                _windSpeed = windSpeed;
            }
        }
        else {
            int temperatureMin =
            [dictionary[@"temp"][@"min"] intValue];
            if (temperatureMin) {
                _temperatureMin = temperatureMin;
            }
            
            int temperatureMax =
            [dictionary[@"temp"][@"max"] intValue];
            if (temperatureMax) {
                _temperatureMax = temperatureMax;
            }
            
            int humidity =
            [dictionary[@"humidity"] intValue];
            if (humidity) {
                _humidity = humidity;
            }
            
            float windSpeed =
            [dictionary[@"speed"] floatValue];
            if (windSpeed) {
                _windSpeed = windSpeed;
            }
        }
        
        /*
         * weather section of the response is an array of
         * dictionary objects. The first object in the array
         * contains the desired weather information.
         * this JSON is formatted the same for both requests
         */
        NSArray* weather = dictionary[@"weather"];
        if ([weather count] > 0) {
            NSDictionary* weatherData = [weather objectAtIndex:0];
            if (weatherData) {
                NSString *status = weatherData[@"main"];
                if (status) {
                    _status = status;
                }
                
                int statusID = [weatherData[@"id"] intValue];
                if (statusID) {
                    _statusID = statusID;
                }
                
                NSString *condition = weatherData[@"description"];
                if (condition) {
                    _condition = condition;
                }
            }
        }
        
    }
    
    return self;
}

-(NSDate *)utcToLocalTime:(NSDate*)date {
    NSTimeZone *currentTimeZone =
    [NSTimeZone defaultTimeZone];
    NSInteger secondsOffset =
    [currentTimeZone secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval:
            secondsOffset sinceDate:date];
}
@end
