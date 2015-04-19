//
//  DealsRewardViewController.h
//  Findy
//
//  Created by iPhone on 10/1/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
@interface DealsRewardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIView *menuView;
    IBOutlet UIButton *btnDeals;
    IBOutlet UIButton *btnRewards;
    IBOutlet UILabel *lblDeals;
    IBOutlet UILabel *lblRewards;
    IBOutlet UITableView *dealsTableView;
    IBOutlet UITableView *rewardsTableView;
    IBOutlet UILabel *lblNoRewards;
    
    NSMutableArray *divisionArray;
    NSMutableArray *dealsTableArray;
    NSMutableArray *dealsArray;
}
- (IBAction)menuSelect:(id)sender;

@end
