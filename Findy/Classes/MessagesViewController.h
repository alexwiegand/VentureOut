//
//  MessagesViewController.h
//  Findy
//
//  Created by iPhone on 9/26/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    NSMutableArray *contentArray;
    IBOutlet UITableView *contentTableView;
    BOOL bRead;
}

@end
