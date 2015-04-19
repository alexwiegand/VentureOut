//
//  FavoritesViewController.h
//  Findy
//
//  Created by iPhone on 9/26/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesViewController : UIViewController {
    
    IBOutlet UIView *menuView;
    IBOutlet UIScrollView *contentScrollView;
    IBOutlet UIScrollView *favoriteByScrollView;
    IBOutlet UILabel *lblMyFavorite;
    IBOutlet UILabel *lblFavoritesBy;
    IBOutlet UIButton *btnMyFavorite;
    IBOutlet UIButton *btnFavoritesBy;
    
    NSMutableArray *emailArray;
    NSMutableArray *placeArray;
}
- (IBAction)menuSelect:(id)sender;

@end
