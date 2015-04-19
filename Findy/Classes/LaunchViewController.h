//
//  LaunchViewController.h
//  Findy
//
//  Created by iPhone on 7/29/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LaunchViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate, FBLoginViewDelegate, UIAlertViewDelegate> {
    
    UIAlertView *inputPasswordView;
	UITextField *textFieldEmail;
	UITextField *textFieldPassword;
    
    IBOutlet UIImageView *imgBackground;
    
    IBOutlet UIButton *signinButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIImageView *imgSignIn;
    
    BOOL bAnimation;
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)signInFB:(id)sender;
- (IBAction)signUpEmail:(id)sender;
- (IBAction)signInEmail:(id)sender;
- (IBAction)valueChanged:(id)sender;

@end
