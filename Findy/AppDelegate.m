// 44270
//  AppDelegate.m
//  Findy
//
//  Created by iPhone on 7/29/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "AppDelegate.h"
//#import "TestFlight.h"
#import "Flurry.h"

@implementation AppDelegate

@synthesize session = _session;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
//    [TestFlight takeOff:@"0710c026-d1de-4a2a-aef6-7c2f5fed4715"];
//    [Taplytics startTaplyticsAPIKey:@"0ee785e8e8b773b71a61cb4c6890b4c84be01a2d"];
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:FLURRY_API_KEY];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
//        self.window.backgroundColor = [UIColor colorWithRed:1.f green:0 blue:0 alpha:1];
//        [application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
//        self.window.clipsToBounds =YES;
//        self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
//        
//        //Added on 19th Sep 2013
//        self.window.bounds = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
//    }
    [FBProfilePictureView class];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"from_setting"];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    
    self.geoCoder = [[CLGeocoder alloc] init];
    [self getLocation];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"FACEBOOK_REGISTER"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"from_settings"];

    // Override point for customization after application launch.
    if (IS_IOS7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                               [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    }

    if ([FBSession activeSession]) {
        [[FBSession activeSession] closeAndClearTokenInformation];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"deals_init_loading"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ChatMessage"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"loaded_inviteFB"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"from_invite"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Title"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Detail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Url"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FIRST_REGISTER"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PLACE_PROFILE"];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ENTER_BACKGROUND"];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ENTER_BACKGROUND"]) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"ENTER_BACKGROUND"];
    }
//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"FIRST_REGISTER"];
//    Kiip *kiip = [[Kiip alloc] initWithAppKey:@"531abd9e9cbb286a129a08ef4cb61650" andSecret:@"b77b87a5c9673fb22cebcd15331ee51c"];
//    kiip.delegate = self;
//    [Kiip setSharedInstance:kiip];
//    int count = [[NSUserDefaults standardUserDefaults] integerForKey:@"RUN_APP"];
//
//    [[NSUserDefaults standardUserDefaults] setInteger:count + 1 forKey:@"RUN_APP"];
//
//    if (count == 5) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you like Findy?" message:@"Can you please rate it 5 stars in the App Store?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//        [alert setTag:100];
//        [alert  show];
//        
//        [[Kiip sharedInstance] saveMoment:@"Being a Good Sport!" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
//            if (error) {
//                NSLog(@"something's wrong");
//                // handle with an Alert dialog.
//            }
//            if (poptart) {
//                [poptart show];
//            }
//            if (!poptart) {
//                // handle logic when there is no reward to give.
//            }
//        }];
//    }
    NSLog(@"%@", launchOptions);
    if (launchOptions != nil) {
        notificationInfo = [[NSDictionary alloc] initWithDictionary:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
        if (notificationInfo) {
            
            [UIApplication sharedApplication].applicationIconBadgeNumber--;
            
            [self performSelector:@selector(pushNotificationAct) withObject:nil afterDelay:5.f];
        }
    }
    
    [[FindyAPI instance] getAppVersion:self withSelector:@selector(checkAppVersion:) andOptions:nil];
    
    return YES;
}

- (void)checkAppVersion:(NSDictionary *)response {
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
//    NSLog(@"%@ --------- %@", [[[response objectForKey:@"results"] objectAtIndex:0] objectForKey:@"version"], version);
    if ([version floatValue] < [[[[response objectForKey:@"results"] objectAtIndex:0] objectForKey:@"version"] floatValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New update available" message:@"Please update your app for a better experience." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert setTag:100];
        [alert  show];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSString *str = [NSString stringWithFormat:@"%@", deviceToken];
    str = [str substringWithRange:NSMakeRange(1, [str length] - 2)];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:str forKey:@"device_token"];
    NSLog(@"-----------DEVICE_TOKEN---------%@", str);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].fbID forKey:@"FACEBOOK_ID"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strEmail forKey:@"USER_EMAIL"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strFirstName forKey:@"FIRST_NAME"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strLastName forKey:@"LAST_NAME"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strCity forKey:@"CITY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strGender forKey:@"GENDER"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strBirthday forKey:@"BIRTHDAY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].interestArray forKey:@"INTEREST_ARRAY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strPicSmall forKey:@"PICSMALL"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strPicBig forKey:@"PICBIG"];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ENTER_BACKGROUND"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].fbID forKey:@"FACEBOOK_ID"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strEmail forKey:@"USER_EMAIL"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strFirstName forKey:@"FIRST_NAME"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strLastName forKey:@"LAST_NAME"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strCity forKey:@"CITY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strGender forKey:@"GENDER"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strBirthday forKey:@"BIRTHDAY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].interestArray forKey:@"INTEREST_ARRAY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strPicSmall forKey:@"PICSMALL"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strPicBig forKey:@"PICBIG"];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
//    if (self.session.state != FBSessionStateCreated) {
//        // Create a new, logged out session.
//        self.session = [[FBSession alloc] init];
//    }
//    
//    // if the session isn't open, let's open it now and present the login UX to the user
//    [self.session openWithCompletionHandler:^(FBSession *session,
//                                                     FBSessionState status,
//                                                     NSError *error) {
//        // and here we make sure to update our UX according to the new session state
//        
//        
//        [FBRequestConnection
//         startForMeWithCompletionHandler:^(FBRequestConnection *connection,
//                                           id<FBGraphUser> user,
//                                           NSError *error) {             
//         }];
//    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].fbID forKey:@"FACEBOOK_ID"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strEmail forKey:@"USER_EMAIL"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strFirstName forKey:@"FIRST_NAME"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strLastName forKey:@"LAST_NAME"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strCity forKey:@"CITY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strGender forKey:@"GENDER"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strBirthday forKey:@"BIRTHDAY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].interestArray forKey:@"INTEREST_ARRAY"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strPicSmall forKey:@"PICSMALL"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strPicBig forKey:@"PICBIG"];
    
    [self.session close];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    notificationInfo = [[NSDictionary alloc] initWithDictionary:userInfo];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ENTER_BACKGROUND"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"In_ChatView"]) {
            [self performSelector:@selector(pushNotificationAct) withObject:nil afterDelay:3.f];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:[aps objectForKey:@"alert"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
//        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"GOTO_CHAT"];
//        [[NSUserDefaults standardUserDefaults] setObject:[notificationInfo objectForKey:@"email"] forKey:@"Chat_email"];
    } else {
        [UIApplication sharedApplication].applicationIconBadgeNumber--;
        
        [self performSelector:@selector(pushNotificationAct) withObject:nil afterDelay:5.f];
    }

}

- (NSString *)getResourceForDevice:(NSString *)fileName {
    NSString *fName = @"";
    if (IS_IPHONE5) {
        fName = [NSString stringWithFormat:@"%@-568h@2x.png", fileName];
    } else {
        if (IS_RETINA) {
            fName = [NSString stringWithFormat:@"%@@2x.png", fileName];
        } else {
            fName = [NSString stringWithFormat:@"%@.png", fileName];
        }
    }
    return fName;
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
    
}

#pragma mark - FaceBOOk integration

// In order to process the response you get from interacting with the Facebook login process,
// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

- (void)getLocation {
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [self.geoCoder reverseGeocodeLocation:_locationManager.location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
//         NSLog(@"%@", placemark.addressDictionary);
         NSString *city = [placemark.addressDictionary valueForKey:@"City"];
//         NSString *country = [[placemark.addressDictionary valueForKey:@"CountryCode"] uppercaseString];
         
//         NSString *state = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] objectAtIndex:2];
//         NSRange range = [state rangeOfString:@","];
//         state=[state substringFromIndex:range.location + 2];
//         range = [state rangeOfString:@" "];
//         state = [state substringToIndex:range.location];
         NSString *state = [placemark.addressDictionary valueForKey:@"State"];
         NSLog(@"%@", placemark.addressDictionary);
         if ((![[NSUserDefaults standardUserDefaults] boolForKey:@"user_login"]) && ([DataManager sharedManager].strCity == nil)) {
             [DataManager sharedManager].strCity = [NSString stringWithFormat:@"%@. %@", city, state];
         }
         NSLog(@"%@", [DataManager sharedManager].strCity);
         
         [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@, %@", city, state] forKey:@"CURRENT_STATE"];
         [DataManager sharedManager].latitude = _locationManager.location.coordinate.latitude;
         [DataManager sharedManager].longitude = _locationManager.location.coordinate.longitude;
         
         [Flurry setLatitude:_locationManager.location.coordinate.latitude
                   longitude:_locationManager.location.coordinate.longitude
          horizontalAccuracy:_locationManager.location.horizontalAccuracy
            verticalAccuracy:_locationManager.location.verticalAccuracy];
         
//         NSLog(@"Location *********** %f, %f", [DataManager sharedManager].latitude, [DataManager sharedManager].longitude);
         [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude], @"latitude", [NSString stringWithFormat:@"%f", [DataManager sharedManager].longitude], @"longitude", nil] forKey:@"USER_LOCATION"];
     }];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation; 

    
    if (currentLocation != nil) {
        [DataManager sharedManager].latitude = currentLocation.coordinate.latitude;
        [DataManager sharedManager].longitude = currentLocation.coordinate.longitude;
//
        
        [Flurry setLatitude:currentLocation.coordinate.latitude
                  longitude:currentLocation.coordinate.longitude
         horizontalAccuracy:currentLocation.horizontalAccuracy
           verticalAccuracy:currentLocation.verticalAccuracy];
        
        [self.geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString *city = [placemark.addressDictionary valueForKey:@"City"];
             NSString *state = [placemark.addressDictionary valueForKey:@"State"];
             
             if ((![[NSUserDefaults standardUserDefaults] boolForKey:@"user_login"]) && ([DataManager sharedManager].strCity == nil)) {
                 [DataManager sharedManager].strCity = [NSString stringWithFormat:@"%@. %@", city, state];
             }
            
             [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@, %@", city, state] forKey:@"CURRENT_STATE"];
             [DataManager sharedManager].latitude = _locationManager.location.coordinate.latitude;
             [DataManager sharedManager].longitude = _locationManager.location.coordinate.longitude;
             
             [Flurry setLatitude:_locationManager.location.coordinate.latitude
                       longitude:_locationManager.location.coordinate.longitude
              horizontalAccuracy:_locationManager.location.horizontalAccuracy
                verticalAccuracy:_locationManager.location.verticalAccuracy];
             
            [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude], @"latitude", [NSString stringWithFormat:@"%f", [DataManager sharedManager].longitude], @"longitude", nil] forKey:@"USER_LOCATION"];
         }];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude], @"latitude", [NSString stringWithFormat:@"%f", [DataManager sharedManager].longitude], @"longitude", nil] forKey:@"USER_LOCATION"];
    }
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
        switch (state) {
                   case FBSessionStateOpen: {
                           FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
                           [cacheDescriptor prefetchAndCacheForSession:session];
                       }
                       break;
                   case FBSessionStateClosed:
                   case FBSessionStateClosedLoginFailed:
                       [FBSession.activeSession closeAndClearTokenInformation];
                       break;
                   default:
                       break;
            }
    
        if (error) {
               UIAlertView *alertView = [[UIAlertView alloc]
                                                      initWithTitle:@"Error"
                                                      message:error.localizedDescription
                                                      delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
               [alertView show];
            }
}

- (void)pushNotificationAct {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if ([userDefault objectForKey:@"user_login"]) {
        NSLog(@"%@", notificationInfo);
        
        if ([[notificationInfo objectForKey:@"type"] isEqualToString:@"app_update"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/findy-find-local-buddy-for/id776764902?ls=1&mt=8"]];
            return;
        }
        
        if ([[notificationInfo objectForKey:@"type"] isEqualToString:@"chat"]) {                            // Chat
            
            int nNot = [[userDefault objectForKey:@"MESSAGE_NUMBER"] intValue];
            [userDefault setObject:[NSString stringWithFormat:@"%d", nNot + 1] forKey:@"MESSAGE_NUMBER"];
            
            [userDefault setBool:TRUE forKey:@"ChatMessage"];
            
            if ([userDefault boolForKey:@"In_ChatView"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddChat" object:notificationInfo];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoChatView" object:notificationInfo];
            }
            
        } else if ([[notificationInfo objectForKey:@"type"] isEqualToString:@"deal"]) {                     // Deal
            
            int nNot = [[userDefault objectForKey:@"NOTIFICATION_NUMBER"] intValue];
            [userDefault setObject:[NSString stringWithFormat:@"%d", nNot + 1] forKey:@"NOTIFICATION_NUMBER"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoDeal" object:nil];
            
        } else if ([[notificationInfo objectForKey:@"type"] isEqualToString:@"comment"]) {                  // Comment
            
            int nNot = [[userDefault objectForKey:@"NOTIFICATION_NUMBER"] intValue];
            [userDefault setObject:[NSString stringWithFormat:@"%d", nNot + 1] forKey:@"NOTIFICATION_NUMBER"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentProfile" object:nil];
            
        } else if ([[notificationInfo objectForKey:@"type"] isEqualToString:@"shoutout"]){                   // Shoutout
            
            int nNot = [[userDefault objectForKey:@"NOTIFICATION_NUMBER"] intValue];
            [userDefault setObject:[NSString stringWithFormat:@"%d", nNot + 1] forKey:@"NOTIFICATION_NUMBER"];
            
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"Comment_show"];
            [[NSUserDefaults standardUserDefaults] setObject:[notificationInfo objectForKey:@"message"] forKey:@"Comment_text"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoOtherProfile" object:notificationInfo];
            
        } else {                                                                                            // Other
            
            int nNot = [[userDefault objectForKey:@"NOTIFICATION_NUMBER"] intValue];
            [userDefault setObject:[NSString stringWithFormat:@"%d", nNot + 1] forKey:@"NOTIFICATION_NUMBER"];
            
            [userDefault setBool:FALSE forKey:@"ChatMessage"];
            
            if ([[notificationInfo objectForKey:@"email"] isEqualToString:[DataManager sharedManager].strEmail]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyProfile" object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoOtherProfile" object:notificationInfo];
            }
            
        }
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://bit.ly/R0IuvD"]];
        }
    } else {
        if (buttonIndex == 1) {
            [self pushNotificationAct];
            NSLog(@"%@", notificationInfo);
        }
    }
}

@end
