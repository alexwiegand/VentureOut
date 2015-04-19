//
//  MutualFriendViewController.h
//  Findy
//
//  Created by Yuri Petrenko on 1/26/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutualFriendViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *friendArray;
    NSMutableDictionary *fidDict;
    UIButton *curButton;
    
    IBOutlet UITableView *friendTableView;
    NSString *uID;
}

@property (nonatomic, retain) NSString *uID;

@end
