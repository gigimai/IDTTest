//
//  IDTWeatherForecastViewController.m
//  IDTTest
//
//  Created by MaiMai on 10/16/16.
//  Copyright © 2016 MaiMai. All rights reserved.
//

#import "IDTWeatherForecastViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SVProgressHUD.h"
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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showUIElements:NO];
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

- (void)applicationDidEnterForeground {
    [self.locationManager startUpdatingLocation];
}

#pragma MARK - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            [self showAlertControllerWithTitle:@"Oopsie daisie"
                                       message:@"App does not know where you are. You need to allow me to access your current location data"];
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self showLoadingIndicator:YES];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                CLPlacemark *placeMark = placemarks.firstObject;
                self.cityInfoLabel.text = placeMark.locality;
            }
        });
    }];
    IDTWeatherRadar *radar = [IDTWeatherRadar new];
    __weak typeof(self) weakSelf = self;
    [radar getCurrentWeather:currentLocation.coordinate.latitude
                   longitude:currentLocation.coordinate.longitude
             completionBlock:^(IDTWeather *weather) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     __strong typeof(weakSelf) strongSelf = weakSelf;
                     [strongSelf showLoadingIndicator:NO];
                     if (weather) {
                         [strongSelf updateWeatherResultWithWeather:weather];
                     } else {
                         [strongSelf showAlertControllerWithTitle:@"Oops" message:@"Something went wrong. We cannot find your weather. Meowy :-("];
                     }
                 });
             }];
}

#pragma MARK - UI Configurations

- (void)showLoadingIndicator:(BOOL)show {
    if (show) {
        [SVProgressHUD show];
    } else {
        [SVProgressHUD dismiss];
    }
}

- (void)showUIElements:(BOOL)show {
    self.cityInfoLabel.hidden = !show;
    self.weatherConditionLabel.hidden = !show;
    self.temperatureLabel.hidden = !show;
    self.dateOfForeCastLabel.hidden = !show;
    self.humidityButton.hidden = !show;
    self.windSpeedButton.hidden = !show;
}

- (void)updateWeatherResultWithWeather:(IDTWeather *)weather {
    self.weatherConditionLabel.text = [weather.condition capitalizedString];
    int temperature = weather.temperature;
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d°", temperature];
    self.dateOfForeCastLabel.text = [self getDateStringFromDate:weather.dateOfForecast];
    [self.humidityButton setTitle:[NSString stringWithFormat:@"%d %%",weather.humidity] forState:UIControlStateNormal];
    [self.windSpeedButton setTitle:[NSString stringWithFormat:@"%.1f mph",weather.windSpeed] forState:UIControlStateNormal];
    [self showUIElements:YES];
}

#pragma MARK - Helpers

- (NSString *)getDateStringFromDate:(NSDate *)date {
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (void)showAlertControllerWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
