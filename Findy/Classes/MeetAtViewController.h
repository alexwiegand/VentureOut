//
//  MeetAtViewController.h
//  Findy
//
//  Created by iPhone on 12/3/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeetAtViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *searchArray;
}

@property (nonatomic, retain) NSString *partnerEmail;

@end
