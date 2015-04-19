//
//  InviteFBFriendViewController.h
//  Findy
//
//  Created by iPhone on 10/11/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteFBFriendViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *friendArray;
    
    UITableView *favoriteTableView;
    UITableView *inviteTableView;
    
    NSMutableArray *favoriteArray;
    NSMutableArray *inviteArray;
    NSMutableArray *emailArray;
    IBOutlet UIScrollView *contentScrollView;
    
    UIButton *curButton;
}

@end
