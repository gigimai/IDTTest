//
//  IDTWeatherForecastViewController.m
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import "IDTWeatherForecastViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "IDTWeatherRadar.h"
#import "IDTWeather.h"

@interface IDTWeatherForecastViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cityInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherInfoLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation IDTWeatherForecastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLocationManager];
}

- (void)setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

#pragma MARK - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            NSLog(@"No authorization");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    CLLocation *currentLocation = self.locationManager.location;
    IDTWeatherRadar *radar = [IDTWeatherRadar new];
    [radar getCurrentWeather:currentLocation.coordinate.latitude
                   longitude:currentLocation.coordinate.longitude
             completionBlock:^(IDTWeather *weather) {
                 NSLog(@"Weather %@",weather);
             }];
}

@end
