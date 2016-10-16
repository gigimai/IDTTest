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
@property (weak, nonatomic) IBOutlet UILabel *weatherConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateOfForeCastLabel;
@property (weak, nonatomic) IBOutlet UIButton *humidityButton;
@property (weak, nonatomic) IBOutlet UIButton *windSpeedButton;
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
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
            CLPlacemark *placeMark = placemarks.firstObject;
            self.cityInfoLabel.text = placeMark.locality;
        }
    }];
    IDTWeatherRadar *radar = [IDTWeatherRadar new];
    __weak typeof(self) weakSelf = self;
    [radar getCurrentWeather:currentLocation.coordinate.latitude
                   longitude:currentLocation.coordinate.longitude
             completionBlock:^(IDTWeather *weather) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     __strong typeof(weakSelf) strongSelf = weakSelf;
                     [strongSelf updateWeatherResultWithWeather:weather];
                 });
             }];
}

- (void)updateWeatherResultWithWeather:(IDTWeather *)weather {
    self.weatherConditionLabel.text = [weather.condition capitalizedString];
    int temperature = weather.temperature;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d°", temperature];
    self.dateOfForeCastLabel.text = [self getDateStringFromDate:weather.dateOfForecast];
    [self.humidityButton setTitle:[NSString stringWithFormat:@"%d %%",weather.humidity] forState:UIControlStateNormal];
    [self.windSpeedButton setTitle:[NSString stringWithFormat:@"%.1f mph",weather.windSpeed] forState:UIControlStateNormal];
}

- (NSString *)getDateStringFromDate:(NSDate *)date {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EE, MMMM dd, yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

@end
