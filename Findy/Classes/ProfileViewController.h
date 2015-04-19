//
//  ProfileViewController.h
//  Findy
//
//  Created by iPhone on 8/13/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate> {
    
    IBOutlet UIScrollView *contentScrollView;
    UIView *interestView;
    IBOutlet UIButton *btnMoreShoutout;
    IBOutlet UIButton *btnMutualFriend;
    IBOutlet UILabel *lblMutualFriend;
    
    BOOL bMoreShoutOut;
    int nSelComment;
    IBOutlet UIView *cWriteView;
    IBOutlet UITextView *txtComment;
    IBOutlet UIButton *btnPostComment;
    
    NSMutableArray *shoutoutArray;
    BOOL bCommentShow;
    
    BOOL bMine;
    BOOL bBack;
    NSDictionary *contentDictionary;
    NSMutableArray *ppArray;
    NSString *email;
    NSString *shoutComment;
    
    AsyncImageView *faceView;
    
    float scrollPos;
}

@property (readwrite) int nMutualCount;
@property (nonatomic, readwrite) BOOL bMine;
@property (nonatomic, retain) NSDictionary *contentDictionary;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *shoutComment;
@property (readwrite) BOOL bFriend;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)mutualFriend:(id)sender;

- (IBAction)viewMoreShoutOut:(id)sender;
- (IBAction)postCommentPressed:(id)sender;

- (void)setFlag:(BOOL)flag;
- (void)setContentValue:(NSDictionary *)cDict;
@end
