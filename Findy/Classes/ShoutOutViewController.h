//
//  ShoutOutViewController.h
//  Findy
//
//  Created by iPhone on 8/8/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ShoutOutViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate> {
    
    IBOutlet UIButton *btnInterest;
    IBOutlet UITextView *txtShoutout;
    IBOutlet UISwitch *swtTwitter;
    IBOutlet UISwitch *swtFacbook;
    IBOutlet UISwitch *swtFavorite;
    IBOutlet UIScrollView *scollView;
    IBOutlet UIImageView *imgSharing;
    IBOutlet UILabel *lblDate;
    IBOutlet UIImageView *imgTxtBack;
    IBOutlet UILabel *attachTitle;
    IBOutlet UILabel *attachDetail;
    IBOutlet UIButton *btnAttach;
    
    ACAccount *twitterAccount;
    NSArray *arrayOfAccounts;
}

- (IBAction)twitterClick:(id)sender;
- (IBAction)facebookClick:(id)sender;
- (IBAction)favoriteClick:(id)sender;
- (IBAction)interestClick:(id)sender;
- (IBAction)hideTextView:(id)sender;
- (IBAction)attachSthClick:(id)sender;

@end
