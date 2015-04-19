//
//  DataManager.m
//  Findy
//
//  Created by iPhone on 7/31/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

@synthesize strBirthday, strCity, strEmail, strFirstName, strGender, strLastName, strPassword, imgBack, imgFace, bPhotoSide, interestArray, latitude, longitude, strShoutout, shoutoutArray, favoritesArray, othersShoutout, fiOS7StatusHeight, fbID, favoritePlaceArray, placesArray, peopleArray, mutualDict, strPicSmall, dealsArray, strPicBig, fbFriendArray, fbFriendDict, placeOfferDict;

/**
 * Singleton accessor.
 */
////////////////////////////////////////////////////////////////////////////////
+ (DataManager *) sharedManager {
	static DataManager *sharedInstance;
	
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[DataManager alloc] init];
        }
		
		return sharedInstance;
	}
	
	return nil;
}


- (id)init {
    if (self = [super init]) {
        strFirstName = @"";
        strLastName = @"";
        strCity = @"";
        strEmail = @"";
        strPassword = @"";
        strGender = @"";
        strBirthday = @"";
        strShoutout = @"";
        strPicSmall = @"";
        strPicBig = @"";
        fbID = @"";
        
        imgFace = nil;
        imgBack = nil;
        
        bPhotoSide = FALSE;
        
        interestArray = [[NSMutableArray alloc] init];
        shoutoutArray = [[NSMutableArray alloc] init];
        favoritesArray = [[NSMutableArray alloc] init];
        othersShoutout = [[NSMutableArray alloc] init];
        favoritePlaceArray = [[NSMutableArray alloc] init];
        placesArray = [[NSMutableArray alloc] init];
        peopleArray = [[NSMutableArray alloc] init];
        mutualDict = [[NSMutableDictionary alloc] init];
        dealsArray = [[NSMutableArray alloc] init];
        fbFriendArray = [[NSMutableArray alloc] init];
        fbFriendDict = [[NSMutableDictionary alloc] init];
        placeOfferDict = [[NSMutableDictionary alloc] init];
        
        if (IS_IOS7) {
            fiOS7StatusHeight = 20;
        } else {
            fiOS7StatusHeight = 0;
        }
    }
    return self;
}
@end
