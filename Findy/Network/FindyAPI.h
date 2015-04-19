//
//  FindyAPI.h
//  Findy
//
//  Created by iPhone on 7/30/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGOOGLE_API_KEY @"AIzaSyD4lSKs5Ri90U3PJIKycZvXyP_CCBWGhf4"

@interface FindyAPI : NSObject

+ (FindyAPI *)instance;

#pragma mark - User API
/*
 *  Required dictionary keys
 *  "username"  (email)
 *  "password"
 */
- (void) loginUserForObject:(id)object
               withSelector:(SEL)selector
                 andOptions:(NSMutableDictionary*)options;
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
 *  "pic_big"
 *  "pic_small"
 *  "long"
 *  "lat"
 *  "craze"
 */
- (void) RegisterUserForObject:(id)object
                  withSelector:(SEL)selector
                    andOptions:(NSMutableDictionary*)options;

/*
 *  Required dictionary keys
 *  "email"  (email)
 *  "facebookId"
 */
- (void) getUserProfile:(id)object
           withSelector:(SEL)selector
             andOptions:(NSMutableDictionary*)options;

/*
 * Required dictionary keys
 * email
 * favorite : (other users email)
 */

- (void)addFavorite:(id)object
       withSelector:(SEL)selector
         andOptions:(NSMutableDictionary *)options;

/*
 * Required dictionary keys
 * email
 * favorite : (other users email)
 */

- (void)removeFavorite:(id)object
       withSelector:(SEL)selector
         andOptions:(NSMutableDictionary *)options;

/*
 * Required dictionary keys
 * email
 */
- (void)favoriteDetail:(id)object
          withSelector:(SEL) selector
            andOptions:(NSMutableDictionary *)options;

/*
 * Required dictionary keys
 * email
 */
- (void)favoritedBy:(id)object
          withSelector:(SEL) selector
            andOptions:(NSMutableDictionary *)options;

/*
 * Required dictionary keys
 * email
 * facebookId
 * facebookaccesstoken
 */

- (void)updateAuth:(id)object
      withSelector:(SEL) selector
        andOptions:(NSMutableDictionary *)options;
/*
 * Required dictionary keys
 * email array
 */
- (void)getUserExist:(id)object
        withSelector:(SEL) selector
          andOptions:(NSMutableDictionary *)options;

/*
 * Required dictionary keys
 * email : user email
 * user info params
 */
- (void)updateUserInfo:(id)object
          withSelector:(SEL) selector
            andOptions:(NSMutableDictionary *)options;

/*
 * Required dictionary keys
 * email : user email
 * user info params
 */
- (void)updateUserLocation:(id)object
              withSelector:(SEL) selector
                andOptions:(NSMutableDictionary *)options;
/*
 * Required dictionary keys
 * yelp_id
 * auth_email
 * auth
 */
- (void)getPlaceUser:(id)object
        withSelector:(SEL) selector
          andOptions:(NSMutableDictionary *)options;


/*
 * Required dictionary keys
 * auth
 * auth_email
 * yelp_id
 */
- (void)placeDetail:(id)object
       withSelector:(SEL) selector
         andOptions:(NSMutableDictionary *)options;
/*
 * Required dictionary keys
 * auth
 * auth_email
 * email
 */
- (void)placeNear:(id)object
     withSelector:(SEL) selector
       andOptions:(NSMutableDictionary *)options;


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
          andOptions:(NSMutableDictionary*)options;

/*
 *  email           // e-mail of user with the shoutout
 *  shout           // text of the shoutout
 *  interest        // interest of the shoutout
 *  reply_email     // e-mail of the user replying to a shoutout
 */

- (void) addShoutOutReply:(id)object
             withSelector:(SEL)selector
               andOptions:(NSMutableDictionary *)options;

/*
 *  email // e-mail of the user with the shoutout
 *  shout // text of the shoutout
 *  interest // interest of the shoutout
 *  comment_email // email of the person making a comment
 *  comment_text // text of the comment from the person making the comment
 */
- (void) postComment:(id)object
             withSelector:(SEL)selector
               andOptions:(NSMutableDictionary *)options;

#pragma mark - Interest API
/*
 * Get All Craze(interest) List
 */

- (void)getAllCraze:(id)object
       withSelector:(SEL)selector
         andOptions:(NSMutableDictionary *)options;
/*
 * Add Interest
 */

- (void)addCraze:(id)object
    withSelector:(SEL)selector
      andOptions:(NSMutableDictionary *)options;

/*
 * Add Interest
 */

- (void)removeCraze:(id)object
    withSelector:(SEL)selector
      andOptions:(NSMutableDictionary *)options;

/*
 * Suggest Activities
 * craze
 */

- (void)suggestActivity:(id)object
           withSelector:(SEL)selector
             andOptions:(NSMutableDictionary *)options;


#pragma mark - Chat API

/*
 * sendchat.php:$from = $_GET['from'];
 * sendchat.php:$to = $_GET['to'];
 * sendchat.php:$msg = $_GET['msg'];
 */

- (void)sendchat:(id)object
    withSelector:(SEL)selector
      andOptions:(NSMutableDictionary *)options;

/*
 *  $email = $_GET['email']; // e-mail of user with the shoutout
 *  $shout = $_GET['shout']; // text of the shoutout
 *  $interest = $_GET['interest']; // interest of the shoutout
 *  $reply_email = $_GET['reply_email']; // e-mail of the user replying to a shoutout
 */

- (void)sendReplyChat:(id)object
         withSelector:(SEL)selector
           andOptions:(NSMutableDictionary *)options;

/*
 * Returns a list of chat messages between 'me' (email) and 'you' (email)
 * ... after the time indicated by 'after'.
 * getchat.php:$me = $_GET['me'];
 * getchat.php:$you = $_GET['you'];
 * getchat.php:$after = $_GET['after'];
 */

- (void)getChat:(id)object
   withSelector:(SEL)selector
     andOptions:(NSMutableDictionary *)options;

/*
 *  Returns a list of chats open with this user
 *  openchats.php:$email = $_GET['email'];
 */

- (void)openChat:(id)object
   withSelector:(SEL)selector
     andOptions:(NSMutableDictionary *)options;

#pragma mark - Deals & Rewards
    
/*
 *  Returns a list of Deals & Rewards
 *  http://api.groupon.com/v2/deals.json?client_id=ce74f45407a97f7767d78595d0d4094ada5b0a90&lat=37.275823&lng=-121.829616
 */
- (void)getDealsRewards:(id)object
           withSelector:(SEL)selector
             andOptions:(NSMutableDictionary *)options;

/*
 *  Returns a list of living social deals
 *  sample url : http://monocle.livingsocial.com/v2/deals?category=entertainment,Fitness/Active&coords=37.774514,-122.426147&radius=10&api-key=7DF7BB03CE274ADB845026DE53852151
 */
- (void)getLivingSocial:(id)object
           withSelector:(SEL)selector
             andOptions:(NSMutableDictionary *)options;

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
           andOptions:(NSMutableDictionary *)options;


#pragma mark - Notification
/*
 * Required dictionary keys
 * email
 */
- (void)getNotifications:(id)object
            withSelector:(SEL) selector
              andOptions:(NSMutableDictionary *)options;

#pragma mark - Favorite Place
/*
 * Required dictionary keys
 * email
 * place
 */
- (void)addFavoritePlace:(id)object
            withSelector:(SEL) selector
              andOptions:(NSMutableDictionary *)options;

/*
 * Required dictionary keys
 * email
 * place
 */
- (void)removeFavoritePlace:(id)object
               withSelector:(SEL) selector
                 andOptions:(NSMutableDictionary *)options;

/*
 *  Required Dictionary Keys
 *  Email
 *  name
 *  interest
 *  address
 */
- (void)suggestPlace:(id)object
        withSelector:(SEL)selector
          andOptions:(NSMutableDictionary *)options;

/*
 *  Required Dictionary Keys
 *  yelp_id
 */
- (void)placeUsers:(id)object
      withSelector:(SEL)selector
        andOptions:(NSMutableDictionary *)options;

#pragma mark - Private Methods

/*
 ** Returns a list of users near this user
 * usersnear.php:$email = $_GET['email'];
 */

- (void)getUsersNearBy:(id)object
       withSelector:(SEL)selector
         andOptions:(NSMutableDictionary *)options;


- (void)getAppVersion:(id)object
         withSelector:(SEL)selector
           andOptions:(NSMutableDictionary *)options;

- (void)sendBookLesson:(id)object
          withSelector:(SEL)selector
            andOptions:(NSMutableDictionary *)options;
- (void)getOffer:(id)object
    withSelector:(SEL)selector
      andOptions:(NSMutableDictionary  *)options;

@end

