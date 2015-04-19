//
//  InterestSelectViewController.h
//  Findy
//
//  Created by iPhone on 7/31/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InterestSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UIAlertViewDelegate, UISearchBarDelegate, UITextFieldDelegate> {
    NSMutableArray *popularArray;
    NSMutableArray *selectedArray;
    NSMutableArray *searchResults;
    NSMutableArray *sectionArray;
    NSMutableArray *interestArray;
    NSMutableArray *ppArray;
    NSMutableArray *fArray;
    
    IBOutlet UIView *suggestView;
    NSString *searchActivity;
}

@property (nonatomic) UILocalizedIndexedCollation *collation;
@property (retain, nonatomic) IBOutlet UITableView *interestTable;
@property (retain, nonatomic) IBOutlet UIView *topView;

- (IBAction)suggestActivity:(id)sender;
@end
