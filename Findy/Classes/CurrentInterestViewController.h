//
//  CurrentInterestViewController.h
//  Findy
//
//  Created by iPhone on 8/24/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrentInterestViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *interestTableView;

@end
