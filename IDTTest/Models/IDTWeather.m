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
        
        _dateOfForecast = [self utcToLocalTime:[NSDate dateWithTimeIntervalSince1970:[dictionary[@"dt"] doubleValue]]];
        
        // use the bool to determine which data format to parse
        if (isCurrentWeather) {
            int temperature = [dictionary[@"main"][@"temp"] intValue];
            if(temperature) {
                _temperature = temperature;
            }

            int humidity = [dictionary[@"main"][@"humidity"] intValue];
            if (humidity) {
                _humidity = humidity;
            }
            
            float windSpeed = [dictionary[@"wind"][@"speed"] floatValue];
            if (windSpeed) {
                _windSpeed = windSpeed;
            }
        } else {
            int temperature = [dictionary[@"temp"] intValue];
            if (temperature) {
                _temperature = temperature;
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
                
                NSString *weatherIcon = weatherData[@"icon"];
                if (weatherIcon) {
                    _weatherIconId = weatherIcon;
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
