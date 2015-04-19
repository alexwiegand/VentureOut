//
//  SignUpViewController.h
//  Findy
//
//  Created by iPhone on 7/29/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController <UITextFieldDelegate>{
    UIAlertView *inputPasswordView;
	UITextField *textFieldEmail;
	UITextField *textFieldPassword;
}


@end
