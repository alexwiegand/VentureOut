//
//  AddInterestViewController.h
//  Findy
//
//  Created by iPhone on 8/7/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddInterestViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, UISearchBarDelegate, UITextFieldDelegate> {
    NSMutableArray *popularArray;
    NSMutableArray *interestArray;
    NSMutableArray *removeCraze;
    NSMutableArray *sectionArray;
    NSMutableArray *selectedArray;
    NSMutableArray *ppArray;
    NSMutableArray *fArray;
    
    NSMutableArray *searchResults;
    
    IBOutlet UIView *suggestView;
    NSString *searchActivity;
}

@property (nonatomic) UILocalizedIndexedCollation *collation;
@property (nonatomic, retain) NSMutableArray *popularArray;
@property (retain, nonatomic) IBOutlet UITableView *interestTable;
- (IBAction)suggestActivity:(id)sender;

@end
