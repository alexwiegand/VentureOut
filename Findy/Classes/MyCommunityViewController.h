//
//  MyCommunityViewController.h
//  Findy
//
//  Created by Alexander Wiegand on 4/25/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCommunityViewController : UIViewController {
    
    IBOutlet UIScrollView *contentScrollView;
    NSMutableArray *placeArray;
    IBOutlet UIView *nonCommunityView;
}

- (IBAction)menuPressed:(id)sender;
- (IBAction)shoutoutPressed:(id)sender;
- (IBAction)findCommunityPressed:(id)sender;
@end
