//
//  FindyAPI.m
//  Findy
//
//  Created by iPhone on 7/30/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "FindyAPI.h"

#import "JSONKit.h"
#import "Reachability.h"
#import "SVProgressHUD.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


@implementation FindyAPI

NSString *const API_ROOT = @"https://crazebot.com/";
NSString *const LOGIN_METHOD = @"login.php";
NSString *const REGISTER_METHOD = @"register.php";
NSString *const ALL_CRAZE_METHOD = @"allcrazes.php";
NSString *const ADD_CRAZE_METHOD = @"addcraze.php";
NSString *const REMOVE_CRAZE_METHOD = @"removecraze.php";
NSString *const SUGGEST_ACTIVITIES = @"suggest.php";
NSString *const GET_USER_NEARBY = @"usersnear.php";
NSString *const ADD_SHOUT_OUT = @"addshoutout.php";
NSString *const GET_USER_PROFILE = @"user.php";
NSString *const ADD_FAVORITE = @"addfavorite.php";
NSString *const REMOVE_FAVORITE = @"removefavorite.php";
NSString *const ADD_SHOUT_OUT_REPLY = @"sendchat.php";
NSString *const ADD_SHOUT_OUT_COMMENT = @"addshoutoutcomment.php";
NSString *const POST_COMMENT = @"addshoutoutcomment.php";
NSString *const SEND_CHAT = @"sendchat.php";
NSString *const SEND_REPLY_CHAT = @"addshoutoutreply.php";
NSString *const GET_CHAT = @"getchat.php";
NSString *const GET_UPDATE_FEED = @"updates.php";
NSString *const OPEN_CHAT = @"openchats.php";
NSString *const FAVORITE_DETAIL = @"favoritesdetails.php";
NSString *const FAVORITE_BY = @"favoritedby.php";
NSString *const USER_EXIST = @"userexists.php";
NSString *const GET_DEALS_REWARDS = @"http://api.groupon.com/v2/deals.json?client_id=ce74f45407a97f7767d78595d0d4094ada5b0a90";
NSString *const GET_NOTIFICATIONS = @"notifications.php";
NSString *const SUGGEST_PLACE = @"suggestplace.php";
NSString *const ADD_FAVORITE_PLACE = @"addfavoriteplace.php";
NSString *const REMOVE_FAVORITE_PLACE = @"removefavoriteplace.php";
NSString *const GET_LIVING_SOCIAL = @"http://monocle.livingsocial.com/v2/deals?category=entertainment,Fitness/Active";
NSString *const UPDATE_USERINFO = @"updateuser.php";
NSString *const UPDATE_USERLOC = @"updateuser.php";
NSString *const PLACE_USERS = @"placeusers.php";
NSString *const UPDATE_AUTH = @"updateauth.php";
NSString *const PLACE_USER_COUNT = @"placeusercount.php";
NSString *const PLACE_DETAIL = @"placedetails.php";
NSString *const PLACE_NEAR = @"placesnear.php";
NSString *const GET_PLACE_OFFER = @"offers.php";
NSString *const SEND_BOOK_LESSON = @"booklesson.php";
NSString *const GET_MY_OFFER = @"getoffer.php";
//
/**
 * Singleton accessor.
 */
////////////////////////////////////////////////////////////////////////////////
+ (FindyAPI *) instance {
	static FindyAPI *sharedInstance;
	
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[FindyAPI alloc] init];
        }
		
		return sharedInstance;
	}
	
	return nil;
}

#pragma mark - User API

////////////////////////////////////////////////////////////////////////////////
/*
 *  Required dictionary keys
 *  "username"  (email)
 *  "password"
 */
- (void) loginUserForObject:(id)object
               withSelector:(SEL)selector
                 andOptions:(NSMutableDictionary*)options {
    
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Authenticating. Please wait."]) {
//
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&password=%@&auth=%@&auth_email=%@",API_ROOT, LOGIN_METHOD, [options objectForKey:@"email"], [options objectForKey:@"password"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
                
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 *  Required dictionary keys
 *  "email"  (email)
 *  "password"
 *  "twitter"
 *  "first"
 *  "last"
 *  "zip"
 *  "birthyear"
 *  "gender"
 *  "facebookId"
 *  "facebookaccesstoken"
 *  "pic_big_data"
 *  "pic_small_data"
 *  "long"
 *  "lat"
 *  "craze"
 */
- (void) RegisterUserForObject:(id)object
                  withSelector:(SEL)selector
                    andOptions:(NSMutableDictionary*)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Registering. Please wait."]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, REGISTER_METHOD];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSString *strParameter = [NSString stringWithFormat:@"email=%@&password=%@&twitter=%@&first=%@&last=%@&zip=%@&birthyear=%@&gender=%@&facebookId=%@&facebookaccesstoken=%@&pic_big_data=%@&pic_small_data=%@&long=%@&lat=%@&craze=%@&city=%@&devicetoken=%@"
                                  , ([options valueForKey:@"email"]) ? [options objectForKey:@"email"] : @""
                                  , ([options valueForKey:@"password"]) ? [options objectForKey:@"password"] : @""
                                  , ([options valueForKey:@"twitter"]) ? [options objectForKey:@"twitter"] : @""
                                  , ([options valueForKey:@"first"]) ? [options objectForKey:@"first"] : @""
                                  , ([options valueForKey:@"last"]) ? [options objectForKey:@"last"] : @""
                                  , ([options valueForKey:@"zip"]) ? [options objectForKey:@"zip"] : @""
                                  , ([options valueForKey:@"birthyear"]) ? [options objectForKey:@"birthyear"] : @""
                                  , ([options valueForKey:@"gender"]) ? [options objectForKey:@"gender"] : @""
                                  , ([options valueForKey:@"facebookId"]) ? [options objectForKey:@"facebookId"] : @""
                                  , ([options valueForKey:@"facebookaccesstoken"]) ? [options objectForKey:@"facebookaccesstoken"] : @""
                                  , ([options valueForKey:@"pic_big_data"]) ? [options objectForKey:@"pic_big_data"] : @""
                                  , ([options valueForKey:@"pic_small_data"]) ? [options objectForKey:@"pic_small_data"] : @""
                                  , ([options valueForKey:@"long"]) ? [options objectForKey:@"long"] : @""
                                  , ([options valueForKey:@"lat"]) ? [options objectForKey:@"lat"] : @""
                                  , ([options valueForKey:@"craze"]) ? [[options objectForKey:@"craze"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] : @""
                                  , ([options valueForKey:@"city"]) ? [options objectForKey:@"city"] : @""
                                  , ([options valueForKey:@"devicetoken"]) ? [options objectForKey:@"devicetoken"] : @""];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]   
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [SVProgressHUD showSuccessWithStatus:@"Success"];
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
        
    }
}

/*
 *  Required dictionary keys
 *  "email"  (email)
 *  "facebookId"
 */
- (void) getUserProfile:(id)object
           withSelector:(SEL)selector
             andOptions:(NSMutableDictionary*)options {
    
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Retrieving user info"]) {
        NSMutableString *urlString;
        if ([options valueForKey:@"facebookId"]) {
            urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&auth=%@&auth_email=%@",API_ROOT, GET_USER_PROFILE, [options objectForKey:@"facebookId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [options objectForKey:@"facebookId"]];
        } else {
            urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&auth=%@&auth_email=%@",API_ROOT, GET_USER_PROFILE, [options objectForKey:@"email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        }
        
        ALog(@"%@",urlString);
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Required dictionary keys
 * email
 * favorite : (other users email)
 */
- (void)addFavorite:(id)object
       withSelector:(SEL)selector
         andOptions:(NSMutableDictionary *)options {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&favorite=%@&auth=%@&auth_email=%@",API_ROOT, ADD_FAVORITE, [options objectForKey:@"email"], [options objectForKey:@"favorite"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to connect to server."];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Required dictionary keys
 * email
 * favorite : (other users email)
 */

- (void)removeFavorite:(id)object
          withSelector:(SEL)selector
            andOptions:(NSMutableDictionary *)options {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&favorite=%@&auth=%@&auth_email=%@",API_ROOT, REMOVE_FAVORITE, [options objectForKey:@"email"], [options objectForKey:@"favorite"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Required dictionary keys
 * email
 */
- (void)favoriteDetail:(id)object
          withSelector:(SEL) selector
            andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Retrieving favorites"]) {
    
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&auth=%@&auth_email=%@",API_ROOT, FAVORITE_DETAIL, [options objectForKey:@"email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
//        ALog(@"%@", urlString);
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Required dictionary keys
 * email
 */
- (void)favoritedBy:(id)object
       withSelector:(SEL) selector
         andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Finding people who favorited you"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&auth=%@&auth_email=%@",API_ROOT, FAVORITE_BY, [options objectForKey:@"email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        ALog(@"%@", urlString);
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}
/*
 * Required dictionary keys
 * email 
 * facebookId
 * facebookaccesstoken
 */

- (void)updateAuth:(id)object
      withSelector:(SEL) selector
        andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Authenticating"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, UPDATE_AUTH];
        NSString *strParameter = [NSString stringWithFormat:@"email=%@&facebookId=%@&facebookaccesstoken=%@",[options objectForKey:@"email"], [options objectForKey:@"facebookId"], [options objectForKey:@"facebookaccesstoken"]];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Required dictionary keys
 * email array
 */
- (void)getUserExist:(id)object
        withSelector:(SEL) selector
          andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Finding friends"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, USER_EXIST];
        NSString *strParameter = [NSString stringWithFormat:@"facebookId=%@&auth=%@&auth_email=%@",[options objectForKey:@"email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Required dictionary keys
 * email : user email
 * user info params
 */
- (void)updateUserInfo:(id)object
          withSelector:(SEL) selector
            andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Updating user info"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?",API_ROOT, UPDATE_USERINFO];
        NSString *strParameter = @"";
        for (NSString *key in [options allKeys]) {
            strParameter = [strParameter stringByAppendingFormat:@"%@=%@&", key, [options objectForKey:key]];
        }
        strParameter = [strParameter stringByAppendingFormat:@"auth=%@&auth_email=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
//        strParameter = [strParameter substringToIndex:[strParameter length] - 1];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Required dictionary keys
 * yelp_id :
 * auth_email
 * auth
 */
- (void)updateUserLocation:(id)object
              withSelector:(SEL) selector
                andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Updating user info"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?",API_ROOT, UPDATE_USERINFO];
        NSString *strParameter = @"";
        for (NSString *key in [options allKeys]) {
            strParameter = [strParameter stringByAppendingFormat:@"%@=%@&", key, [options objectForKey:key]];
        }
        strParameter = [strParameter stringByAppendingFormat:@"auth=%@&auth_email=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        //        strParameter = [strParameter substringToIndex:[strParameter length] - 1];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}
/*
 * Required dictionary keys
 * yelp_id
 * auth_email
 * auth
 */
- (void)getPlaceUser:(id)object
        withSelector:(SEL) selector
          andOptions:(NSMutableDictionary *)options {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?",API_ROOT, PLACE_USER_COUNT];
    NSString *strParameter = @"";

    
    strParameter = [strParameter stringByAppendingFormat:@"yelp_id=%@&auth=%@&auth_email=%@", [options objectForKey:@"yelp_id"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
//    strParameter = [strParameter substringToIndex:[strParameter length] - 1];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                            timeoutInterval:60];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
//                                   [self dismiss];
                               } else {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:nil]);
                                   [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
//                                   [self dismiss];
                               }
                               
                           }];
}

/*
 * Required dictionary keys
 * auth
 * auth_email
 * yelp_id
 */
- (void)placeDetail:(id)object
       withSelector:(SEL) selector
         andOptions:(NSMutableDictionary *)options {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?",API_ROOT, PLACE_DETAIL];
    NSString *strParameter = @"";
    
    
    strParameter = [strParameter stringByAppendingFormat:@"yelp_id=%@&auth=%@&auth_email=%@", [options objectForKey:@"yelp_id"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
    //    strParameter = [strParameter substringToIndex:[strParameter length] - 1];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                            timeoutInterval:60];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                   //                                   [self dismiss];
                               } else {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:nil]);
                                   [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                   //                                   [self dismiss];
                               }
                               
                           }];
}

/*
 * Required dictionary keys
 * auth
 * auth_email
 * email
 */
- (void)placeNear:(id)object
     withSelector:(SEL) selector
       andOptions:(NSMutableDictionary *)options {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?",API_ROOT, PLACE_NEAR];
    NSString *strParameter = @"";
    
    
    strParameter = [strParameter stringByAppendingFormat:@"auth=%@&auth_email=%@&email=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail, [options objectForKey:@"email"]];
    //    strParameter = [strParameter substringToIndex:[strParameter length] - 1];
    
    NSLog(@"%@", strParameter);
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                            timeoutInterval:60];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                   //                                   [self dismiss];
                               } else {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:nil]);
                                   [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                   //                                   [self dismiss];
                               }
                               
                           }];
}

#pragma mark - Interest API
/*
 * Get All Craze(interest) List
 */

- (void)getAllCraze:(id)object
       withSelector:(SEL)selector
         andOptions:(NSMutableDictionary *)options {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@",API_ROOT, ALL_CRAZE_METHOD, [options objectForKey:@"emails"]];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                            timeoutInterval:60];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                   [self dismiss];
                               } else {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:nil]);
                                   [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                   [self dismiss];
                               }
                               
                           }];
}

/*
 * Add Interest
 */

- (void)addCraze:(id)object
       withSelector:(SEL)selector
         andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Adding activities"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, ADD_CRAZE_METHOD];
        NSString *strParameter = [NSString stringWithFormat:@"email=%@&craze=%@&auth=%@&auth_email=%@",[options objectForKey:@"email"], [[[options objectForKey:@"craze"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to add it."];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}
/*
 * Revmove Interest
 */

- (void)removeCraze:(id)object
    withSelector:(SEL)selector
      andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Removing activities"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, REMOVE_CRAZE_METHOD];
        NSString *strParameter = [NSString stringWithFormat:@"email=%@&craze=%@&auth=%@&auth_email=%@",[options objectForKey:@"email"], [[[options objectForKey:@"craze"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Suggest Activities
 * craze
 */

- (void)suggestActivity:(id)object
           withSelector:(SEL)selector
             andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Suggesting activities"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, SUGGEST_ACTIVITIES];
        NSString *strParameter = [NSString stringWithFormat:@"craze=%@&auth=%@&auth_email=%@", [[[options objectForKey:@"craze"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}


#pragma mark - Shout Out API
/*
 *  Required dictionary keys
 *  "email"  (email)
 *  "shout"
 *  "interest"
 *  "time"
 */
- (void) addShoutOut:(id)object
        withSelector:(SEL)selector
          andOptions:(NSMutableDictionary*)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Adding Shout-Out"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, ADD_SHOUT_OUT];
        
        NSString *strParameter;
        if ([options valueForKey:@"attach_url"]) {
            strParameter= [NSString stringWithFormat:@"email=%@&shout=%@&interest=%@&time=%@&onlyfavs=%@&auth=%@&auth_email=%@&deal_link=%@&place_link=%@&attach_title=%@&attach_url=%@&attach_image_url=%@&attach_detail=%@", [options objectForKey:@"email"], [options objectForKey:@"shout"], [[[options objectForKey:@"interest"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [options objectForKey:@"time"], [options objectForKey:@"onlyfavs"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail, [options objectForKey:@"deal_link"], [options objectForKey:@"place_link"], [options objectForKey:@"attach_title"], [options objectForKey:@"attach_url"], [options objectForKey:@"attach_image_url"], [options objectForKey:@"attach_detail"]];
        }
        else {
            strParameter= [NSString stringWithFormat:@"email=%@&shout=%@&interest=%@&time=%@&onlyfavs=%@&auth=%@&auth_email=%@", [options objectForKey:@"email"], [options objectForKey:@"shout"], [[[options objectForKey:@"interest"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [options objectForKey:@"time"], [options objectForKey:@"onlyfavs"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        }
        
        NSLog(@"%@", strParameter);
        
        strParameter = [strParameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 *  email           // e-mail of user with the shoutout
 *  shout           // text of the shoutout
 *  interest        // interest of the shoutout
 *  reply_email     // e-mail of the user replying to a shoutout
 */

- (void) addShoutOutReply:(id)object
             withSelector:(SEL)selector
               andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Adding Shout-Out reply"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, ADD_SHOUT_OUT_REPLY];
        NSString *strParameter = [NSString stringWithFormat:@"email=%@&shout=%@&interest=%@&reply_email=%@&auth=%@&auth_email=%@", [options objectForKey:@"email"], [options objectForKey:@"shout"], [[[options objectForKey:@"interest"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [options objectForKey:@"reply_email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 *  email // e-mail of the user with the shoutout
 *  shout // text of the shoutout
 *  interest // interest of the shoutout
 *  comment_email // email of the person making a comment
 *  comment_text // text of the comment from the person making the comment
 */
- (void) postComment:(id)object
        withSelector:(SEL)selector
          andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Posting comment"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, POST_COMMENT];
        NSString *strParameter = [NSString stringWithFormat:@"email=%@&shout=%@&interest=%@&comment_email=%@&comment_text=%@&auth=%@&auth_email=%@", [options objectForKey:@"email"], [options objectForKey:@"shout"], [[[options objectForKey:@"interest"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [options objectForKey:@"comment_email"], [options objectForKey:@"comment_text"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to post comment. Check your internet."];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

#pragma mark - Main APIs

/*
 ** Returns a list of users near this user
 * usersnear.php:$email = $_GET['email'];
 */

- (void)getUsersNearBy:(id)object
          withSelector:(SEL)selector
            andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Finding people near you"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&auth=%@&auth_email=%@",API_ROOT, GET_USER_NEARBY, [options objectForKey:@"email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        ALog(@"%@",urlString);
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
//                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
//                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

#pragma mark - Chat API

/*
 * sendchat.php:$from = $_GET['from'];
 * sendchat.php:$to = $_GET['to'];
 * sendchat.php:$msg = $_GET['msg'];
 */

- (void)sendchat:(id)object
    withSelector:(SEL)selector
      andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Sending message"]) {
        NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, SEND_CHAT];
        NSString *strParameter = [NSString stringWithFormat:@"from=%@&to=%@&msg=%@&auth=%@&auth_email=%@", [options objectForKey:@"from"], [options objectForKey:@"to"], (IS_IOS7) ? [[options objectForKey:@"msg"] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters] : [[options objectForKey:@"msg"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        strParameter = [strParameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        strParameter = ;
        NSLog(@"%@", strParameter);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 *  $email = $_GET['email']; // e-mail of user with the shoutout
 *  $shout = $_GET['shout']; // text of the shoutout
 *  $interest = $_GET['interest']; // interest of the shoutout
 *  $reply_email = $_GET['reply_email']; // e-mail of the user replying to a shoutout
 */

- (void)sendReplyChat:(id)object
         withSelector:(SEL)selector
           andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Sending message"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, SEND_REPLY_CHAT];
        NSString *strParameter = [NSString stringWithFormat:@"email=%@&shout=%@&interest=%@&reply_email=%@&auth=%@&auth_email=%@", [options objectForKey:@"email"], [options objectForKey:@"shout"], [[[options objectForKey:@"interest"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [options objectForKey:@"reply_email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        strParameter = [strParameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@", strParameter);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[strParameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
        
    
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 * Returns a list of chat messages between 'me' (email) and 'you' (email)
 * ... after the time indicated by 'after'.
 * getchat.php:$me = $_GET['me'];
 * getchat.php:$you = $_GET['you'];
 * getchat.php:$after = $_GET['after'];
 */

- (void)getChat:(id)object
   withSelector:(SEL)selector
     andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Retrieving messages"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?me=%@&you=%@&auth=%@&auth_email=%@",API_ROOT, GET_CHAT, [options objectForKey:@"me"], [options objectForKey:@"you"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        
        if ([options valueForKey:@"after"]) {
            [urlString appendString:[NSString stringWithFormat:@"&after=%@", [options objectForKey:@"after"]]];
        }
        
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 *  Returns a list of chats open with this user
 *  openchats.php:$email = $_GET['email'];
 */

- (void)openChat:(id)object
    withSelector:(SEL)selector
      andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Retrieving messages"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&auth=%@&auth_email=%@",API_ROOT, OPEN_CHAT, [options objectForKey:@"email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        ALog(@"%@",urlString);
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}
    
#pragma mark - Deals & Rewards
    
/*
 *  Returns a list of Deals & Rewards
 *  http://api.groupon.com/v2/deals.json?client_id=ce74f45407a97f7767d78595d0d4094ada5b0a90&lat=37.275823&lng=-121.829616
 */
- (void)getDealsRewards:(id)object
           withSelector:(SEL)selector
             andOptions:(NSMutableDictionary *)options {
//    &lat=37.275823&lng=-121.829616
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Finding deals and rewards"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@&lat=%@&lng=%@&tag=%@&radius=10",GET_DEALS_REWARDS, [options objectForKey:@"lat"], [options objectForKey:@"lng"], [[options objectForKey:@"tag"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 *  Returns a list of living social deals
 *  sample url : http://monocle.livingsocial.com/v2/deals?category=entertainment,Fitness/Active&coords=37.774514,-122.426147&radius=10&api-key=7DF7BB03CE274ADB845026DE53852151
 */
- (void)getLivingSocial:(id)object
           withSelector:(SEL)selector
             andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Finding deals"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@&coords=%@,%@&radius=10&api-key=7DF7BB03CE274ADB845026DE53852151",GET_LIVING_SOCIAL, [options objectForKey:@"lat"], [options objectForKey:@"lng"]];
        ALog(@"%@",urlString);
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

#pragma mark - Update Feed
/*
 *  Returns a list of events related to a user
 *  1. Chat messages with other users.
 *  2. Shoutouts made by favorited users.
 *  3. Notification that someone else favorited this user
 *  newsfeed.php:$email = $_GET['email'];
 */

- (void)getUpdateFeed:(id)object
         withSelector:(SEL)selector
           andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Updating feed"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&auth=%@&auth_email=%@",API_ROOT, GET_UPDATE_FEED, [options objectForKey:@"email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        
        ALog(@"%@",urlString);
        
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

#pragma mark - Favorite Place
/*
 * Required dictionary keys
 * email
 * place
 */
- (void)addFavoritePlace:(id)object
            withSelector:(SEL) selector
              andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Adding favorite place"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, ADD_FAVORITE_PLACE];
        NSString *paramString = [NSMutableString stringWithFormat:@"email=%@&yelp_id=%@&name=%@&interest=%@&pic_small=%@&auth=%@&auth_email=%@", [options objectForKey:@"email"], [options objectForKey:@"yelp_id"], [options objectForKey:@"name"], [[[options objectForKey:@"interest"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [options objectForKey:@"pic_small"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        paramString = [paramString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];;
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}
/*
 * Required dictionary keys
 * email
 * place
 */
- (void)removeFavoritePlace:(id)object
               withSelector:(SEL) selector
                 andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Removing favorite place"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&yelp_id=%@&auth=%@&auth_email=%@",API_ROOT, REMOVE_FAVORITE_PLACE, [options objectForKey:@"email"], [options objectForKey:@"yelp_id"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

/*
 *  Required Dictionary Keys
 *  Email
 *  name
 *  interest
 *  address
 */
- (void)suggestPlace:(id)object
        withSelector:(SEL)selector
          andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Suggesting place"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",API_ROOT, GET_NOTIFICATIONS];
        
        NSString *paramString = [NSMutableString stringWithFormat:@"email=%@&name=%@&interest=%@&address=%@&auth=%@&auth_email=%@", [options objectForKey:@"email"], [options objectForKey:@"name"], [[[options objectForKey:@"interest"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [options objectForKey:@"address"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        paramString = [paramString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

#pragma mark - Notifications
/*
 * Required dictionary keys
 * email
 */
- (void)getNotifications:(id)object
            withSelector:(SEL) selector
              andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Retrieving notifications"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?email=%@&place=%@&auth=%@&auth_email=%@",API_ROOT, GET_NOTIFICATIONS, [options objectForKey:@"email"], [options objectForKey:@"place"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        NSLog(@"%@", urlString);
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

- (void)sendBookLesson:(id)object
          withSelector:(SEL)selector
            andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Sending Offer"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?personal_email=%@&first=%@&phone=%@&yelp_id=%@&offer_code=%@&auth=%@&auth_email=%@",API_ROOT, SEND_BOOK_LESSON, [options objectForKey:@"personal_email"], [options objectForKey:@"first"], [options objectForKey:@"phone"], [options objectForKey:@"yelp_id"], [options objectForKey:@"offer_code"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}

- (void)getOffer:(id)object
    withSelector:(SEL)selector
      andOptions:(NSMutableDictionary  *)options {
    
        if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Getting my offer"]) {
        
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?yelp_id=%@&offer_code=%@&personal_email=%@&auth=%@&auth_email=%@",API_ROOT, GET_MY_OFFER, [options objectForKey:@"yelp_id"], [options objectForKey:@"offer_code"], [options objectForKey:@"personal_email"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
    
}

/*
 *  Required Dictionary Keys
 *  yelp_id
 */
- (void)placeUsers:(id)object
      withSelector:(SEL)selector
        andOptions:(NSMutableDictionary *)options {
    if ([self checkInternetConnectivityAndShowProgressBarWithMessage:@"Retrieving community"]) {
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?yelp_id=%@&auth=%@&auth_email=%@",API_ROOT, PLACE_USERS, [options objectForKey:@"yelp_id"], [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                    cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                                timeoutInterval:60];
        [request setHTTPMethod:@"GET"];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                       [self dismiss];
                                   } else {
                                       SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                       withObject:nil]);
                                       [SVProgressHUD showErrorWithStatus:@"Unable to authenticate, try again"];
                                       [self dismiss];
                                   }
                                   
                               }];
    }
}


#pragma mark - Private Methods

////////////////////////////////////////////////////////////////////////////////
- (bool) checkInternetConnectivityAndShowProgressBarWithMessage:(NSString*)theMessage {
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]) {
        
        [SVProgressHUD showWithStatus:theMessage maskType:SVProgressHUDMaskTypeClear];
        [self setApplicationNetworkActivityIndicator:YES];
        
    } else { [SVProgressHUD showErrorWithStatus:@"Internet is not available. Please check your internet connection settings."]; }
    
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
}

////////////////////////////////////////////////////////////////////////////////
- (void)setApplicationNetworkActivityIndicator:(BOOL)value {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:value];
    
}

////////////////////////////////////////////////////////////////////////////////
- (void) dismiss {
    
    [self setApplicationNetworkActivityIndicator:NO];
    [SVProgressHUD dismiss];
    
}

- (void)getAppVersion:(id)object
         withSelector:(SEL)selector
           andOptions:(NSMutableDictionary *)options {
    NSString *urlString = @"http://itunes.apple.com/lookup?id=776764902";
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                            timeoutInterval:60];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:[[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data]]);
                                   [self dismiss];
                               } else {
                                   SuppressPerformSelectorLeakWarning([object performSelector:selector
                                                                                   withObject:nil]);
                                   [SVProgressHUD showErrorWithStatus:@"Please check your internet connection!"];
                                   [self dismiss];
                               }
                               
                           }];
}
@end
