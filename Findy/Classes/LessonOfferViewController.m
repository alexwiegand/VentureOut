//
//  LessonOfferViewController.m
//  Findy
//
//  Created by Alexander Wiegand on 4/25/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import "LessonOfferViewController.h"

@interface LessonOfferViewController ()

@end

@implementation LessonOfferViewController

@synthesize contentDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [lblName setText:[NSString stringWithFormat:@"Name: %@",[DataManager sharedManager].strFirstName]];
    [lblLessonFor setText:[NSString stringWithFormat:@"%@", [contentDict objectForKey:@"find_text"]]];
    CGRect frame = lblLessonFor.frame;
    [lblLessonFor sizeToFit];
    
    if (lblLessonFor.frame.size.height < 51) {
        [lblLessonFor setFrame:frame];
    } else {
        float yHeight = lblLessonFor.frame.size.height - frame.size.height + 20;
        frame = lblLessonFor.frame;
        
        frame.origin.y += 10;
        
        lblLessonFor.frame = frame;
        
        [secondLine setFrame:CGRectMake(secondLine.frame.origin.x, secondLine.frame.origin.y + yHeight, secondLine.frame.size.width, secondLine.frame.size.height)];
        [thirdLine setFrame:CGRectMake(thirdLine.frame.origin.x, thirdLine.frame.origin.y + yHeight, thirdLine.frame.size.width, thirdLine.frame.size.height)];
        [lblMyEmail setFrame:CGRectMake(lblMyEmail.frame.origin.x, lblMyEmail.frame.origin.y + yHeight, lblMyEmail.frame.size.width, lblMyEmail.frame.size.height)];
        [lblMyPhone setFrame:CGRectMake(lblMyPhone.frame.origin.x, lblMyPhone.frame.origin.y + yHeight, lblMyPhone.frame.size.width, lblMyPhone.frame.size.height)];
        [txtEmail setFrame:CGRectMake(txtEmail.frame.origin.x, txtEmail.frame.origin.y + yHeight, txtEmail.frame.size.width, txtEmail.frame.size.height)];
        [txtPhoneNumber setFrame:CGRectMake(txtPhoneNumber.frame.origin.x, txtPhoneNumber.frame.origin.y + yHeight, txtPhoneNumber.frame.size.width, txtPhoneNumber.frame.size.height)];
        [imgBack setFrame:CGRectMake(imgBack.frame.origin.x, imgBack.frame.origin.y, imgBack.frame.size.width, imgBack.frame.size.height + yHeight)];
        [btnSend setFrame:CGRectMake(btnSend.frame.origin.x, btnSend.frame.origin.y, btnSend.frame.size.width, btnSend.frame.size.height + yHeight)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [lblName release];
    [lblLessonFor release];
    [txtEmail release];
    [txtPhoneNumber release];
    [contentDict release];
    [imgBack release];
    [thirdLine release];
    [btnSend release];
    [lblMyEmail release];
    [lblMyPhone release];
    [super dealloc];
}
- (void)viewDidUnload {
    [lblName release];
    lblName = nil;
    [lblLessonFor release];
    lblLessonFor = nil;
    [txtEmail release];
    txtEmail = nil;
    [txtPhoneNumber release];
    txtPhoneNumber = nil;
    [imgBack release];
    imgBack = nil;
    [thirdLine release];
    thirdLine = nil;
    [btnSend release];
    btnSend = nil;
    [lblMyEmail release];
    lblMyEmail = nil;
    [lblMyPhone release];
    lblMyPhone = nil;
    [super viewDidUnload];
}
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendClick:(id)sender {
    if ([txtEmail.text isEqualToString:@""] || [txtPhoneNumber.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please input email and phone number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    NSCharacterSet *_NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:txtPhoneNumber.text];
    if (([txtEmail.text rangeOfString:@"@"].location == NSNotFound) ||(txtPhoneNumber.text.length < 10) || (![_NumericOnly isSupersetOfSet:myStringSet])) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your info for accuracy" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:txtEmail.text, [DataManager sharedManager].strFirstName, txtPhoneNumber.text, [contentDict objectForKey:@"yelp_id"],[contentDict objectForKey:@"offer_code"], nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"personal_email", @"first", @"phone", @"yelp_id", @"offer_code", nil]];
    [[FindyAPI instance] sendBookLesson:self withSelector:@selector(sendResult:) andOptions:paramDict];
}

- (void)sendResult:(NSDictionary *)response {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Your discount was applied. The instructor received your contact info and will get in touch shortly!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert setTag:100];
    [alert show];
    [alert release];
//    NSLog(@"%@", response);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
@end
