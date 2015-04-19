//
//  MenuViewController.h
//  Findy
//
//  Created by iPhone on 8/3/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "AsyncImageView.h"
@interface MenuViewController : UIViewController {
    
    IBOutlet UIImageView *imgProfile;
    
    IBOutlet UIButton *btnFindMenu;
    IBOutlet UIButton *btnProfileMenu;
    IBOutlet UIButton *btnUpdateFeedMenu;
    IBOutlet UIButton *btnDealsMenu;
    IBOutlet UIButton *btnFavoriteMenu;
    IBOutlet UIButton *btnMessagesMenu;
    IBOutlet UIButton *btnMyCommunity;
    IBOutlet UIScrollView *menuScroll;
    IBOutlet UIImageView *notifcationBack;
    
    IBOutlet UILabel *notificationLabel;
    UIButton *selectedButton;
    
    IBOutlet UIImageView *nBack;
    IBOutlet UILabel *nLabel;
    AsyncImageView *pImageView;
}
- (IBAction)findMenuPressed:(id)sender;
- (IBAction)profileMenuPressed:(id)sender;
- (IBAction)updateMenuPressed:(id)sender;
- (IBAction)dealsMenuPressed:(id)sender;
- (IBAction)favoriteMenuPressed:(id)sender;
- (IBAction)messageMenuPressed:(id)sender;
- (IBAction)notificationMenuPressed:(id)sender;
- (IBAction)settingsMenuPressed:(id)sender;
- (IBAction)inviteMyFriendPressed:(id)sender;

@end
