//
//  AppDelegate.h
//  Findy
//
//  Created by iPhone on 7/29/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//
// Testing git with Yuri

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UIAlertViewDelegate> {
    NSDictionary *notificationInfo;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FBSession *session;
@property (retain, nonatomic) IBOutlet CLGeocoder *geoCoder;
@property (retain, nonatomic) IBOutlet CLLocationManager *locationManager;

- (NSString *)getResourceForDevice:(NSString *)fileName;
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
- (void)getLocation;
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error;
@end
