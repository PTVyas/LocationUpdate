//
//  ViewController.m
//  LocationUpdate
//
//  Created by WOS_MacMini_1 on 26/04/18.
//  Copyright © 2018 White Orange Software. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMapsBase/GoogleMapsBase.h>


@interface ViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>
{
    CLLocationManager *locationManager;
}
@property (strong, nonatomic) IBOutlet GMSMapView *mapContainerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //---------> Hi Hello
    [self manage_Map];
    
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    [locationManager setDelegate:self];
    if (([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])) {
        [locationManager requestAlwaysAuthorization];
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    locationManager.distanceFilter = 50; // meters
    
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //[locationManager setDistanceFilter:kCLDistanceFilterNone];
    //[locationManager setHeadingFilter:kCLHeadingFilterNone];
    [locationManager startMonitoringSignificantLocationChanges];
    
    
    [locationManager startUpdatingLocation];
    
    CGFloat latitudeValue = locationManager.location.coordinate.latitude;
    CGFloat longtitudeValue = locationManager.location.coordinate.longitude;
    
    //Set Label La-Log Values
    [self setValue_InLabel_Lat:latitudeValue Long:longtitudeValue];
    //Add Location
    [self manage_AddLocationPin_Lat:latitudeValue Long:longtitudeValue];
    //Set Camera Position
    [self manage_SetPinPosition_Lat:latitudeValue Long:longtitudeValue];
    
    [self addLocation_In_UserDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Function
- (void) manage_Map
{
    //GoogleMap Settings
    
    //mapView.isMyLocationEnabled = true
    //mapView.settings.myLocationButton = true
    
    self.mapContainerView.myLocationEnabled = YES;
    
    self.mapContainerView.settings.myLocationButton = YES;
    self.mapContainerView.settings.allowScrollGesturesDuringRotateOrZoom = YES;
    self.mapContainerView.settings.compassButton = YES;
    
    //self.mapContainerView.mapType = kGMSTypeNone;
    //self.mapContainerView.mapType = kGMSTypeHybrid;
    self.mapContainerView.mapType = kGMSTypeNormal; //Default
    //self.mapContainerView.mapType = kGMSTypeTerrain;
    //self.mapContainerView.mapType = kGMSTypeSatellite;
}

- (void) manage_AddLocationPin_Lat:(CGFloat )Lat Long:(CGFloat)Long
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.appearAnimation = kGMSMarkerAnimationPop; //Animation
    
    //Set Values
    marker.position = CLLocationCoordinate2DMake(Lat,Long);
    //marker.title = "Title";
    //marker.snippet = "SubTitle";
    //marker.userData = dic;
    marker.map = self.mapContainerView;
    
    //Set Camera Position
    //[self manage_SetPinPosition_Lat:Lat Long:Long];
}

- (void) manage_SetPinPosition_Lat:(CGFloat )Lat Long:(CGFloat)Long {
    
    CGFloat curretZoom = 16;
    curretZoom = self.mapContainerView.camera.zoom;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:Lat longitude:Long zoom:curretZoom];
    self.mapContainerView.camera = camera;
}

- (void) setValue_InLabel_Lat:(CGFloat )Lat Long:(CGFloat)Long {
    lblLocation.text = [NSString stringWithFormat:@"%f,%f",Lat,Long];
}

- (void) addLocation_In_UserDefault {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(05.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self manage_AddLocationData];
        [self addLocation_In_UserDefault];
    });
}
    
- (void) manage_AddLocationData {
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd MMM yyyy hh:mm:ss a"];
    NSString *strDate = [df stringFromDate:[NSDate date]];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:lblLocation.text forKey:@"1"];
    //[dic setValue:[NSString stringWithFormat:@"%@",[NSDate date]] forKey:@"2"];
    [dic setValue:strDate forKey:@"2"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUD_DataKey = @"data".uppercaseString;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    //arr = [userDefaults objectForKey:strUD_DataKey];
    arr = [[NSMutableArray alloc] initWithArray:[userDefaults objectForKey:strUD_DataKey]];
    [arr addObject:dic];
    
    [userDefaults removeObjectForKey:strUD_DataKey];
    [userDefaults setObject:arr forKey:strUD_DataKey];
    [userDefaults synchronize];
    
    NSLog(@"Add Data : %@",lblLocation.text);
}

#pragma mark - Current Location Delegate Methods
//------------ Current Location Address-----
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    
    NSString *strMess = @"";
    strMess = [error localizedDescription];
    //strMess = @"Failed to Get Your Location";
    NSLog(@"Get Location Error: %@",strMess);
    
    //[locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"didUpdateToLocation: %@", newLocation);

    NSLog(@"OldLocation: %f - %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation: %f - %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    [self setValue_InLabel_Lat:newLocation.coordinate.latitude
                          Long:newLocation.coordinate.longitude];
    
    //Remove Old pin
    [self.mapContainerView clear];
    //Add new Location pin
    [self manage_AddLocationPin_Lat:newLocation.coordinate.latitude
                               Long:newLocation.coordinate.longitude];
    
    //Stop Location Manager
    //[locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    CGFloat latitudeValue = location.coordinate.latitude;
    CGFloat longtitudeValue = location.coordinate.longitude;
    
    NSLog(@"didUpdateLocations: %f - %f", latitudeValue, longtitudeValue);
    [self setValue_InLabel_Lat:latitudeValue Long:longtitudeValue];
    
    /*
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // Update your marker on your map using location.coordinate.latitude
        //and location.coordinate.longitude);
        
        NSLog(@"time didUpdateLocations: %f - %f", latitudeValue, longtitudeValue);
        lblLocation.text = [NSString stringWithFormat:@"%f - %f",latitudeValue,longtitudeValue];
        
    }
    */
    
    //Remove Old pin
    [self.mapContainerView clear];
    //Add new Location pin
    [self manage_AddLocationPin_Lat:latitudeValue Long:longtitudeValue];
    //Set Camera Position
    [self manage_SetPinPosition_Lat:latitudeValue Long:longtitudeValue];
}

//---------> Hi Hello last
@end
