//
//  IDTWeatherRadar.h
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDTWeather.h"

@interface IDTWeatherRadar : NSObject
/**
 * Returns weekly forecasted weather conditions
 * for the specified lat/long
 *
 * @param latitude Location latitude
 * @param longitude Location longitude
 * @param completionBlock Array of weather results
 */
- (void)getWeeklyWeather:(float)latitude longitude:(float)longitude
         completionBlock:(void (^)(NSArray *))completionBlock;

/**
 * Returns realtime weather conditions
 * for the specified lat/long
 *
 * @param latitude Location latitude
 * @param longitude Location longitude
 * @param completionBlock Weather object
 */
- (void)getCurrentWeather:(float)latitude longitude:(float)longitude
          completionBlock:(void (^)(IDTWeather *))completionBlock;
@end
