//
//  NotificationsViewController.h
//  Findy
//
//  Created by iPhone on 10/15/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableArray *notificationsArray;
    IBOutlet UITableView *notificationTableView;
}



@end
