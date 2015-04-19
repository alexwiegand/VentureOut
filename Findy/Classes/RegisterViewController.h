//
//  RegisterViewController.h
//  Findy
//
//  Created by iPhone on 7/30/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <UITextFieldDelegate, FBLoginViewDelegate> {
    
    IBOutlet UITextField *txtFirstName;
    IBOutlet UITextField *txtLastName;
    IBOutlet UITextField *txtCity;
    
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtConfirmPassword;
    IBOutlet UIButton *btnMale;
    IBOutlet UIButton *btnFemale;
    IBOutlet UITextField *txtBirthday;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIDatePicker *datePickerView;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIButton *btnDone;
    
    UITextField *curTextField;
    int age;
    BOOL bAgeChanged;
}

- (UIImage *)getImageForDevice:(NSString *)fileName;

- (IBAction)genderSelect:(id)sender;
- (IBAction)donePicker:(id)sender;
@end
