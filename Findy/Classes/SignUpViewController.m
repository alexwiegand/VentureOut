//
//  SignUpViewController.m
//  Findy
//
//  Created by iPhone on 7/29/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "SignUpViewController.h"
#import "InitialSlidingViewController.h"
#import "RegisterViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

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
    
    // input password view
	textFieldEmail = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 261.0, 31.0)];
	textFieldEmail.font = [UIFont boldSystemFontOfSize:14];
	textFieldEmail.borderStyle = UITextBorderStyleRoundedRect;
	textFieldEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textFieldEmail.autocorrectionType = UITextAutocorrectionTypeNo;
	textFieldEmail.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textFieldEmail.returnKeyType = UIReturnKeyDefault;
	textFieldEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
	textFieldEmail.keyboardType = UIKeyboardTypeAlphabet;
	textFieldEmail.placeholder = @"Username";
	textFieldEmail.clearsOnBeginEditing = NO;
	textFieldEmail.delegate = self;
	textFieldEmail.enablesReturnKeyAutomatically = YES;
    //	[textFieldEmail setBackgroundColor:[UIColor clearColor]];
	
	textFieldPassword = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 92.0, 261.0, 31.0)];
	textFieldPassword.font = [UIFont boldSystemFontOfSize:14];
	textFieldPassword.borderStyle = UITextBorderStyleRoundedRect;
	textFieldPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textFieldPassword.autocorrectionType = UITextAutocorrectionTypeNo;
	textFieldPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textFieldPassword.returnKeyType = UIReturnKeyDone;
	textFieldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
	textFieldPassword.keyboardType = UIKeyboardTypeAlphabet;
	textFieldPassword.secureTextEntry = YES;
	textFieldPassword.placeholder = @"Password";
	textFieldPassword.clearsOnBeginEditing = NO;
	textFieldPassword.delegate = self;
	textFieldPassword.enablesReturnKeyAutomatically = YES;
    //	[textFieldPassword setBackgroundColor:[UIColor clearColor]];
	
	inputPasswordView = [[UIAlertView alloc] init];
    [inputPasswordView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
	[inputPasswordView setDelegate:self];
	[inputPasswordView setTitle:@"Sign In"];
	[inputPasswordView addButtonWithTitle:@"Cancel"];
	[inputPasswordView addButtonWithTitle:@"OK"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)signup:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"FACEBOOK_LOGIN"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    RegisterViewController *registerViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:registerViewController animated:YES];
}
- (IBAction)Login:(id)sender {
    //
    [inputPasswordView textFieldAtIndex:0].text = @"yuri@gmail.com";
	[inputPasswordView textFieldAtIndex:1].text = @"iphone.";
    //    textFieldEmail.text = @"m";
    //    textFieldPassword.text = @"m";
    //    textFieldEmail.text = @"c";
    //    textFieldPassword.text = @"c";
    //    textFieldEmail.text = @"y";
    //    textFieldPassword.text = @"y";
    //    textFieldEmail.text = @"a";
    //    textFieldPassword.text = @"a";
	
	CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 30.0);
	[inputPasswordView setTransform:moveUp];
	[textFieldEmail becomeFirstResponder];
	[inputPasswordView show];
}

- (void) authenticationResult:(NSDictionary*) response {
    
    if (([[response objectForKey:@"exists"] boolValue]) && ([[response objectForKey:@"valid"] boolValue])) {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"FACEBOOK_LOGIN"];
        NSString *curEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_EMAIL"];
        
        if (![[response objectForKey:@"email"] isEqualToString:curEmail]) {
            [[NSUserDefaults standardUserDefaults] setObject:[inputPasswordView textFieldAtIndex:0].text forKey:@"USER_EMAIL"];
            [[NSUserDefaults standardUserDefaults] setObject:[inputPasswordView textFieldAtIndex:1].text forKey:@"USER_PASSWORD"];
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EMAIL_SIGNIN"] == FALSE) {
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"EMAIL_SIGNIN"];
            [[NSUserDefaults standardUserDefaults] setObject:[inputPasswordView textFieldAtIndex:0].text forKey:@"USER_EMAIL"];
            [[NSUserDefaults standardUserDefaults] setObject:[inputPasswordView textFieldAtIndex:1].text forKey:@"USER_PASSWORD"];
        }
        
        [DataManager sharedManager].strEmail = [response objectForKey:@"email"];
        [DataManager sharedManager].strFirstName = [response objectForKey:@"first"];
        [DataManager sharedManager].strPassword = textFieldPassword.text;
        [DataManager sharedManager].strLastName = [response objectForKey:@"last"];
        [DataManager sharedManager].strGender = [response objectForKey:@"gender"];
        [DataManager sharedManager].strBirthday = [response objectForKey:@"birthyear"];
        if ([response valueForKey:@"shoutouts"] != [NSNull null]) {
            for (NSDictionary *dict in [response objectForKey:@"shoutouts"]) {
                [[DataManager sharedManager].shoutoutArray addObject:dict];
            }
        }
        
        NSData *imgData = [NSData dataWithBase64EncodedString:[[response objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]];
        [DataManager sharedManager].imgFace = [[UIImage alloc] initWithData:imgData];
        
        imgData = [NSData dataWithBase64EncodedString:[[response objectForKey:@"pic_big"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]];
        [DataManager sharedManager].imgBack = [[UIImage alloc] initWithData:imgData];
        
        //        NSLog(@"%@", [response objectForKey:@"loc"]);
        [DataManager sharedManager].latitude = [[[response objectForKey:@"loc"] objectAtIndex:1] floatValue];
        [DataManager sharedManager].longitude = [[[response objectForKey:@"loc"] objectAtIndex:0] floatValue];
        for (int i = 0; i < [[response objectForKey:@"interests"]  count]; i++) {
            NSString *interest = [[response objectForKey:@"interests"] objectAtIndex:i];
            interest = [interest stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
            
            [[DataManager sharedManager].interestArray addObject:interest];
        }
        
        for (NSString *str in [response objectForKey:@"favorites"]) {
            [[DataManager sharedManager].favoritesArray addObject:str];
        }
        
        InitialSlidingViewController *slideView = [[InitialSlidingViewController alloc] init];
        //        [self.navigationController pushViewController:slideView animated:YES];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:slideView] animated:YES];
        [slideView release];
    } else {
        if ([[response objectForKey:@"valid"] boolValue] == FALSE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication" message:@"Wrong Email or Password" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            
            return;
        }
        
        if ([[response objectForKey:@"exists"] boolValue] == FALSE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication" message:@"You have to sign up your account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView == inputPasswordView) {
        NSString *email = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        
		if (buttonIndex == 1) {
            NSMutableDictionary *authenticationCredentails =
            [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:email, password, nil]
                                               forKeys:[NSArray arrayWithObjects:@"email",@"password", nil]];
            [[FindyAPI instance] loginUserForObject:self
                                       withSelector:@selector(authenticationResult:)
                                         andOptions:authenticationCredentails];
        }
	}
}
@end
