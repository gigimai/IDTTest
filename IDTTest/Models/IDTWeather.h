//
//  IDTWeather.h
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDTWeather : NSObject

/// the date this weather is relevant to
@property (nonatomic, strong) NSDate *dateOfForecast;

/// the general weather status:
/// clouds, rain, thunderstorm, snow, etc...
@property (nonatomic, strong) NSString* status;

/// the ID corresponding to general weather status
@property (nonatomic) int statusID;

/// the weather icon ID
@property (nonatomic, strong) NSString *weatherIconId;

/// a more descriptive weather condition:
/// light rain, heavy snow, etc...
@property (nonatomic, strong) NSString* condition;

/// min/max temp in celcius
@property (nonatomic) int temperature;

/// current humidity level (perecent)
@property (nonatomic) int humidity;

/// current wind speed in mph
@property (nonatomic) float windSpeed;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
                  isCurrentWeather:(BOOL)isCurrentWeather;
@end
