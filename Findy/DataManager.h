//
//  DataManager.h
//  Findy
//
//  Created by iPhone on 7/31/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject {
    NSString *strFirstName;
    NSString *strLastName;
    NSString *strCity;
    
    NSString *strEmail;
    NSString *strPassword;
    
    NSString *strGender;
    
    NSString *strBirthday;
    
    NSString *strInterest;
    
    NSString *strShoutout;
    
    NSString *strPicSmall;
    NSString *strPicBig;
    
    NSString *fbID;
    
    double latitude;
    double longitude;
    
    UIImage *imgBack;
    UIImage *imgFace;
    
    BOOL bPhotoSide;
    
    NSMutableArray *interestArray;
    NSMutableArray *shoutoutArray;
    NSMutableArray *othersShoutout;
    NSMutableArray *favoritesArray;
    NSMutableArray *favoritePlaceArray;
    NSMutableArray *placesArray;
    NSMutableArray *peopleArray;
    NSMutableDictionary *mutualDict;
    NSMutableArray *dealsArray;
    NSMutableArray *fbFriendArray;
    NSMutableDictionary *fbFriendDict;
    NSMutableDictionary *placeOfferDict;
    
    float fiOS7StatusHeight;
    
   
}

@property (nonatomic, retain) NSString *strFirstName;
@property (nonatomic, retain) NSString *strLastName;
@property (nonatomic, retain) NSString *strCity;
@property (nonatomic, retain) NSString *strEmail;
@property (nonatomic, retain) NSString *strPassword;
@property (nonatomic, retain) NSString *strGender;
@property (nonatomic, retain) NSString *strBirthday;
@property (nonatomic, retain) NSString *strShoutout;
@property (nonatomic, retain) NSString *strPicSmall;
@property (nonatomic, retain) NSString *strPicBig;
@property (nonatomic, retain) NSString *fbID;

@property (readwrite) double latitude;
@property (readwrite) double longitude;
@property (readwrite) float  fiOS7StatusHeight;

@property (nonatomic, retain) UIImage *imgBack;
@property (nonatomic, retain) UIImage *imgFace;

@property (nonatomic, retain) NSMutableArray *interestArray;
@property (nonatomic, retain) NSMutableArray *shoutoutArray;
@property (nonatomic, retain) NSMutableArray *othersShoutout;
@property (nonatomic, retain) NSMutableArray *favoritesArray;
@property (nonatomic, retain) NSMutableArray *favoritePlaceArray;
@property (nonatomic, retain) NSMutableArray *placesArray;
@property (nonatomic, retain) NSMutableArray *peopleArray;
@property (nonatomic, assign) NSMutableDictionary *mutualDict;
@property (nonatomic, retain) NSMutableArray *dealsArray;
@property (nonatomic, retain) NSMutableArray *fbFriendArray;
@property (nonatomic, retain) NSMutableDictionary *fbFriendDict;
@property (nonatomic, retain) NSMutableDictionary *placeOfferDict;

@property (readwrite) BOOL bPhotoSide;

// Shared Manager
+ (DataManager *) sharedManager;

@end
