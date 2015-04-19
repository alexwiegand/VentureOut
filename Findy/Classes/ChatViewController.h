//
//  ChatViewController.h
//  Findy
//
//  Created by iPhone on 8/19/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageComposerView.h"
@interface ChatViewController : UIViewController <UITextViewDelegate, MessageComposerViewDelegate> {
    
    IBOutlet UIScrollView *chatScrollView;
    MessageComposerView *chatView;
    BOOL bChatReply;
    
    UIImage *leftFace;
    UIImage *rightFace;
    
    NSMutableArray *chatArray;
    NSDate *curDate;
    NSString *placeholderText;
    
    NSString *faceDataString;
    
    NSString *shoutInterest;
    NSString *shoutoutText;
    
    long lastDate;
    
    int yPos;
}

@property (readwrite) BOOL bChatReply;
@property (nonatomic, retain) UIImage *leftFace;
@property (nonatomic, retain) NSString *shoutInterest;
@property (nonatomic, retain) NSString *shoutoutText;
@property (nonatomic, retain) NSString *partnerEmail;
@property (nonatomic, retain) NSString *strTitle;

@end
