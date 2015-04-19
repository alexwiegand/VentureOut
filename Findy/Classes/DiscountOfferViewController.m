//
//  DiscountOfferViewController.m
//  Findy
//
//  Created by Alexander Wiegand on 4/25/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import "DiscountOfferViewController.h"

@interface DiscountOfferViewController ()

@end

@implementation DiscountOfferViewController

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
    [scrollView setContentSize:CGSizeMake(320, 480)];
    [lblTitle setText:[contentDict objectForKey:@"title"]];
    [lblSubTitle setText:[contentDict objectForKey:@"subtitle"]];
    
    AsyncImageView * pImageView = [[AsyncImageView alloc] initWithFrame:offerPic.frame];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 1;
    pImageView.imageURL = [NSURL URLWithString:[contentDict objectForKey:@"offer_pic"]];
    [scrollView addSubview:pImageView];
    [pImageView release];
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
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [lblTitle release];
    [lblSubTitle release];
    [scrollView release];
    [offerPic release];
    [contentDict release];
    [txtEmail release];
    [super dealloc];
}
- (void)viewDidUnload {
    [lblTitle release];
    lblTitle = nil;
    [lblSubTitle release];
    lblSubTitle = nil;
    [scrollView release];
    scrollView = nil;
    [offerPic release];
    offerPic = nil;
    [txtEmail release];
    txtEmail = nil;
    [super viewDidUnload];
}
- (IBAction)getMyOffer:(id)sender {
    
    if ([txtEmail.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please input email and phone number" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    if ([txtEmail.text rangeOfString:@"@"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your info for accuracy" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:txtEmail.text, [contentDict objectForKey:@"yelp_id"], [contentDict objectForKey:@"offer_code"], nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"personal_email", @"yelp_id", @"offer_code", nil]];
    [[FindyAPI instance] getOffer:self withSelector:@selector(getOffer:) andOptions:paramDict];
}

- (void)getOffer:(NSDictionary *)response {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Your discount code has been emailed to you. Please find it at the email address you provided." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert setTag:100];
    [alert show];
    [alert release];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height - 236.f)];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [scrollView setFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height + 236.f)];
    [textField resignFirstResponder];
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
