//
//  AttachDealViewController.h
//  Findy
//
//  Created by Alexander Wiegand on 3/24/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachDealViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    

    IBOutlet UITableView *dealsTableView;
    
    NSMutableArray *divisionArray;
    NSMutableArray *dealsTableArray;
    NSMutableArray *dealsArray;
}

@end
