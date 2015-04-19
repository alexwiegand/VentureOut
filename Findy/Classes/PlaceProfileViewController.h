//
//  PlaceProfileViewController.h
//  Findy
//
//  Created by iPhone on 9/5/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OAuthConsumer.h"

@interface PlaceProfileViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIScrollView *contentScrollView;
    UIImageView *titleImageView;
    UIActivityIndicatorView *indicatorView;
    UIButton *favoriteButton;
    UIButton *btnUrl;
    UILabel *lblSuggestTitle;
    IBOutlet UIImageView *lblHit;
    
    UITableView *tblPlaceUser;
    NSMutableArray *placeUserArray;
    
    NSString *homePageURL;
    NSString *infoUrl;
    NSString *windUrl;
    float distance;
    float yPos;
    
    float fLat;
    float fLng;
    
    NSMutableArray *placeOfferArray;
}

@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, retain) NSDictionary *contentDictionary;
@property (nonatomic, retain) NSString *strID;
@property (nonatomic ,retain) NSString *strInterest;
@property (readwrite) float distance;
@property (nonatomic, retain) NSMutableArray *placeOfferArray;

@end
