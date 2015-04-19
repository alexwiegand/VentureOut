//
//  LessonOfferViewController.h
//  Findy
//
//  Created by Alexander Wiegand on 4/25/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LessonOfferViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblLessonFor;
    IBOutlet UIImageView *imgBack;
    IBOutlet UIImageView *secondLine;
    IBOutlet UIImageView *thirdLine;
    IBOutlet UIButton *btnSend;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPhoneNumber;
    IBOutlet UILabel *lblMyEmail;
    IBOutlet UILabel *lblMyPhone;
    
    NSDictionary *contentDict;
}

@property (nonatomic, retain) NSDictionary *contentDict;

- (IBAction)sendClick:(id)sender;

@end
