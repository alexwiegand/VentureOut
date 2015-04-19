//
//  DiscountOfferViewController.h
//  Findy
//
//  Created by Alexander Wiegand on 4/25/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscountOfferViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblSubTitle;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *offerPic;
    IBOutlet UITextField *txtEmail;
    
    NSDictionary *contentDict;
}

@property (nonatomic, retain) NSDictionary *contentDict;

- (IBAction)getMyOffer:(id)sender;

@end
