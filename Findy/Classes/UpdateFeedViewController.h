//
//  UpdateFeedViewController.h
//  Findy
//
//  Created by iPhone on 9/21/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateFeedViewController : UIViewController {
    IBOutlet UIScrollView *contentScrollView;
    
    NSMutableArray *emailArray;
    IBOutlet UIView *nonFavoriteView;
    
    
}

@property (retain, nonatomic) IBOutlet UIScrollView *contentScrollView;
- (IBAction)favoriteInFindy:(id)sender;
- (IBAction)favoriteInFacebook:(id)sender;

@end
