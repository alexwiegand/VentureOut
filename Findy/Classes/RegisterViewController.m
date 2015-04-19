//
//  RegisterViewController.m
//  Findy
//
//  Created by iPhone on 7/30/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "ProfilePhotoViewController.h"
#import "InterestViewController.h"
#import "InitialSlidingViewController.h"
#import "DataManager.h"
#import "JSONKit.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

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
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[self getImageForDevice:@"ABC"]];
    self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    [datePickerView setHidden:YES];
    [datePickerView setMaximumDate:[NSDate date]];
    [toolBar setHidden:YES];
    
    [datePickerView setFrame:CGRectMake(0, (IS_IPHONE5) ? 568 : 480, 320, 216)];
    [toolBar setFrame:CGRectMake(0, (IS_IPHONE5) ? 568 : 480, 320, 44.f)];
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
     
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"DoneButton.png"] forState:UIControlStateNormal];
    [nextButton setFrame:CGRectMake(263.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 49.f, 30.f)];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    
    [scrollView setFrame:CGRectMake(0, 44.0 + [DataManager sharedManager].fiOS7StatusHeight, 320, SCREEN_HEIGHT - 44.0 - [DataManager sharedManager].fiOS7StatusHeight)];
    [scrollView setContentSize:CGSizeMake(320, 486)];
    
    bAgeChanged = FALSE;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_settings"]) {
        [lblTitle setText:@"Edit Info"];
        
        txtFirstName.text = [DataManager sharedManager].strFirstName;
        txtLastName.text = [DataManager sharedManager].strLastName;
        txtCity.text = [DataManager sharedManager].strCity;
        txtEmail.text = [DataManager sharedManager].strEmail;
        [txtEmail setEnabled:NO];
        [txtEmail setTextColor:[UIColor lightGrayColor]];
        txtPassword.text = [DataManager sharedManager].strPassword;
        if ([[DataManager sharedManager].strGender isEqualToString:@"M"]) {
            [btnMale setSelected:YES];
            [btnFemale setSelected:NO];
        } else {
            [btnMale setSelected:NO];
            [btnFemale setSelected:YES];
        }

        if ([[DataManager sharedManager].strBirthday isKindOfClass:[NSString class]]) {
            txtBirthday.text = [DataManager sharedManager].strBirthday;
        } else if ([[DataManager sharedManager].strBirthday isKindOfClass:[NSDictionary class]]){
            NSString *birth = [(NSDictionary *)[DataManager sharedManager].strBirthday objectForKey:@"sec"];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[birth longLongValue]];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yyyy"];
            
            txtBirthday.text = [formatter stringFromDate:date];
        } else {
            txtBirthday.text = @"MM/DD/YY";
        }
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *date = [[NSDate alloc] init];
        date = [formatter dateFromString:txtBirthday.text];
        if ((![txtBirthday.text isEqualToString:@"MM/DD/YY"]) && (![txtBirthday.text isEqualToString:@""])) {
            [datePickerView setDate:date];
        }
        
        [formatter release];
    } else {
        if ([FBSession activeSession]) {
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
        FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes", @"user_birthday", @"user_location"]];
        
        // Set this loginUIViewController to be the loginView button's delegate
        loginView.delegate = self;
        loginView.frame = CGRectMake(30, 20, 260, 45);
        
        for (id obj in loginView.subviews)
        {
            if ([obj isKindOfClass:[UIButton class]])
            {
                UIButton * loginButton =  obj;
                UIImage *loginImage = [UIImage imageNamed:@"SignInFB.png"];
                [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
                [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
                [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
                [loginButton sizeToFit];
            }
            if ([obj isKindOfClass:[UILabel class]])
            {
                [obj removeFromSuperview];
            }
        }
        
        // Add the button to the view
        [scrollView addSubview:loginView];
        
        [lblTitle setText:@"Register"];
    }
    [self.view addSubview:lblTitle];
    
    if (IS_IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)getImageForDevice:(NSString *)fileName {
    return [UIImage imageNamed:[(AppDelegate *)[[UIApplication sharedApplication] delegate] getResourceForDevice:fileName]];
}

- (IBAction)genderSelect:(id)sender {
    [curTextField resignFirstResponder];
    if (curTextField == txtBirthday) {
        [self hidePickerView];
    } else {
        [scrollView setFrame:CGRectMake(0, 44.0 + [DataManager sharedManager].fiOS7StatusHeight, 320, SCREEN_HEIGHT - 44.0 - [DataManager sharedManager].fiOS7StatusHeight)];
    }
    
    UIButton *button = (UIButton *)sender;
    if (button == btnMale) {
        [btnFemale setSelected:NO];
    } else {
        [btnMale setSelected:NO];
    }
    [button setSelected:YES];
}

- (IBAction)donePicker:(id)sender {
    [self hidePickerView];
    [curTextField resignFirstResponder];
    if (age > 18) {
        [scrollView setFrame:CGRectMake(0, 44.0 + [DataManager sharedManager].fiOS7StatusHeight, 320, SCREEN_HEIGHT - 44.0 - [DataManager sharedManager].fiOS7StatusHeight)];
        [scrollView setContentSize:CGSizeMake(300, 486)];
    }
}

- (void)backButtonPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"from_settings"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonPressed:(id)sender {
    NSString *alertString = @"";
    if ([txtFirstName.text isEqualToString:@""]) {
        alertString = @"Please input First Name.";
    } else if ([txtLastName.text isEqualToString:@""]) {
        alertString = @"Please input Last Name.";
    } else if ([txtCity.text isEqualToString:@""]) {
        alertString = @"Please input City.";
    } else if ([txtEmail.text isEqualToString:@""]) {
        alertString = @"Please input Email.";
    } else if ([txtPassword.text isEqualToString:@""]) {
        alertString = @"Please input Password.";
    } else if ([txtConfirmPassword.text isEqualToString:@""]) {
        alertString = @"Please input Confirm Password.";
    } else if ([txtBirthday.text isEqualToString:@""]) {
        alertString = @"Please input  Brithday";
    } else if (([btnMale isSelected] == FALSE) && ([btnFemale isSelected] == FALSE)) {
        alertString = @"Please select gender";
    }
    
    if (![alertString isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    } else {
        if ([txtPassword.text isEqualToString:txtConfirmPassword.text]) {
            [DataManager sharedManager].strFirstName=txtFirstName.text;
            [DataManager sharedManager].strLastName=txtLastName.text;
            [DataManager sharedManager].strCity=txtCity.text;
            [DataManager sharedManager].strEmail=txtEmail.text;
            [DataManager sharedManager].strPassword=txtPassword.text;
            [DataManager sharedManager].strGender=([btnMale isSelected]) ? @"M" : @"F";
            [DataManager sharedManager].strBirthday=txtBirthday.text;
    
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_settings"]) {
                NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, txtFirstName.text, txtLastName.text, txtCity.text, [DataManager sharedManager].strGender, txtBirthday.text, txtPassword.text, nil]
                                                                                    forKeys:[NSArray arrayWithObjects:@"email", @"first", @"last", @"city", @"gender", @"birthday",  @"password", nil]];
                [[FindyAPI instance] updateUserInfo:self withSelector:@selector(updateUser:) andOptions:paramDict];
            } else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                                     bundle: nil];
                ProfilePhotoViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"ProfilePhotoViewController"];
                [self.navigationController pushViewController:profileViewController animated:YES];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please check your password again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)updateUser:(NSDictionary *)response {

    if ([response objectForKey:@"success"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"from_settings"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc {
    [txtFirstName release];
    [txtLastName release];
    [txtCity release];
    [txtEmail release];
    [txtPassword release];
    [txtConfirmPassword release];
    [btnMale release];
    [btnFemale release];
    [txtBirthday release];
    [scrollView release];
    [datePickerView release];
    [toolBar release];
    [btnDone release];
    [super dealloc];
}

- (void)showPickerView {
    [datePickerView setHidden:NO];
    [toolBar setHidden:NO];
    [UIView beginAnimations:nil context:nil];

    [datePickerView setFrame:CGRectMake(0, (IS_IPHONE5) ? 352 : 264, 320, 216)];
    [toolBar setFrame:CGRectMake(0, (IS_IPHONE5) ? 288 : 224, 320.0, 44.f)];
    [UIView commitAnimations];
}

- (void)hidePickerView {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *strBirth = [formatter stringFromDate:datePickerView.date];
    
    [formatter release];
    
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    
    NSDate *today = [NSDate date];
    
    age = [[yearFormatter stringFromDate:today] intValue] - [[yearFormatter stringFromDate:datePickerView.date] intValue];
    
    if ((age < 18) && (bAgeChanged)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"18+ years old" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        [txtFirstName setUserInteractionEnabled:YES];
        [txtLastName setUserInteractionEnabled:YES];
        [txtCity setUserInteractionEnabled:YES];
        [txtEmail setUserInteractionEnabled:YES];
        [txtPassword setUserInteractionEnabled:YES];
        [txtConfirmPassword setUserInteractionEnabled:YES];
        [txtBirthday setUserInteractionEnabled:YES];
        [btnMale setUserInteractionEnabled:YES];
        [btnFemale setUserInteractionEnabled:YES];
        
        [datePickerView setHidden:YES];
        [toolBar setHidden:YES];
        
        [UIView beginAnimations:nil context:nil];
        
        [datePickerView setFrame:CGRectMake(0, (IS_IPHONE5) ? 568 : 480, 320, 216)];
        [toolBar setFrame:CGRectMake(0, (IS_IPHONE5) ? 568 : 480, 320, 44.f)];
        
        [UIView commitAnimations];
        [txtBirthday setText:strBirth];
    }
}
- (IBAction)signInFB:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (appDelegate.session.isOpen) {
        //            [appDelegate.session closeAndClearTokenInformation]; // FB delog
        [self successLogin];
    } else {
        if (appDelegate.session.state != FBSessionStateCreated) {
            appDelegate.session = [[FBSession alloc] init];
        }
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [FBSession setActiveSession:appDelegate.session];
            if(session.isOpen) {
                [self successLogin];
            }
        }];
    }
}

- (void)successLogin {
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"FACEBOOK_LOGIN"];
    [SVProgressHUD showWithStatus:@"Sign in with Facebook" maskType:SVProgressHUDMaskTypeClear];
    [FBSettings setLoggingBehavior:[NSSet setWithObjects:
                                    FBLoggingBehaviorFBRequests, nil]];
    
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection,
                                       id<FBGraphUser> user,
                                       NSError *error) {
         if (error.code == 0) {
             [DataManager sharedManager].fbID = [user objectForKey:@"id"];
             [DataManager sharedManager].strFirstName = user.first_name;
             [DataManager sharedManager].strLastName = user.last_name;
             [DataManager sharedManager].strEmail = [user objectForKey:@"email"];
             [DataManager sharedManager].strCity = [user.location objectForKey:@"name"];
             [DataManager sharedManager].strGender = ([[user objectForKey:@"gender"] isEqualToString:@"female"]) ? @"F" : @"M";
             [DataManager sharedManager].strBirthday = user.birthday;
             
             NSString *urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", [user objectForKey:@"id"]];
             NSMutableURLRequest *urlRequest =
             [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                     cachePolicy:NSURLRequestUseProtocolCachePolicy
                                 timeoutInterval:30];
             NSData *imgData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
             if (imgData != Nil) {
                 [DataManager sharedManager].imgFace = [UIImage imageWithData:imgData];
                 int s = ([DataManager sharedManager].imgFace.size.width < [DataManager sharedManager].imgFace.size.height) ? [DataManager sharedManager].imgFace.size.width : [DataManager sharedManager].imgFace.size.height;
                 [DataManager sharedManager].imgFace = [[ImageResizingUtility instance] imageByCropping:[DataManager sharedManager].imgFace _targetSize:CGSizeMake(s, s)];
             } else {
                 [DataManager sharedManager].imgFace = nil;
             }
             
             urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover", [user objectForKey:@"id"]];
             
             urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:30];
             NSData *coverData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
             NSDictionary *coverDict = [[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:coverData];
             
             if ([coverDict valueForKey:@"cover"]) {
                 NSString *urlString = [[coverDict objectForKey:@"cover"] objectForKey:@"source"];
                 [DataManager sharedManager].imgBack = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
             }
             
             [SVProgressHUD dismiss];
             
             if (user.location != nil) {
                 AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                 [delegate.geoCoder geocodeAddressString:[user.location objectForKey:@"name"] completionHandler:^(NSArray *placemarks, NSError *error) {
                     CLPlacemark *placemark = [placemarks objectAtIndex:0];
                     [DataManager sharedManager].latitude = placemark.location.coordinate.latitude;
                     [DataManager sharedManager].longitude = placemark.location.coordinate.longitude;
                 }];
             } else {
                 [DataManager sharedManager].latitude = 0;
                 [DataManager sharedManager].longitude = 0;
             }
             
             if (IsNSStringValid([DataManager sharedManager].fbID)) {
                 NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].fbID, nil]
                                                                                     forKeys:[NSArray arrayWithObjects:@"email", nil]];
                 [[FindyAPI instance] getUserExist:self withSelector:@selector(fbLoginResult:) andOptions:paramDict];
             }
         }
         
     }];
    
}

- (void)fbLoginResult:(NSDictionary *)response {

    if ([[[[response objectForKey:@"fids"] objectForKey:[DataManager sharedManager].fbID] objectForKey:@"status"] boolValue]) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"FACEBOOK_REGISTER"];
        
        NSString *curEmail = [DataManager sharedManager].strEmail;
        
        NSString *key = @"FindyiPhoneApp";
        
        NSData *eData = [[[DataManager sharedManager].strEmail dataUsingEncoding: NSASCIIStringEncoding] AESEncryptWithPassphrase:key];
        
        [Base64 initialize];
        NSString *password = [Base64 encode:eData];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"USER_PASSWORD"];
        
        
        if (![[response objectForKey:@"email"] isEqualToString:curEmail]) {
            [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].fbID forKey:@"FACEBOOK_ID"];
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EMAIL_SIGNIN"] == FALSE) {
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"EMAIL_SIGNIN"];
        }
        if ([response valueForKey:@"shoutouts"] != [NSNull null]) {
            for (NSDictionary *dict in [response objectForKey:@"shoutouts"]) {
                [[DataManager sharedManager].shoutoutArray addObject:dict];
            }
        }
        if (ISNSArrayValid([response objectForKey:@"favorites"])) {
            for (NSString *str in [response objectForKey:@"favorites"]) {
                [[DataManager sharedManager].favoritesArray addObject:str];
            }
        }
        
        [self performSelector:@selector(userProfile) withObject:nil afterDelay:0.1f];
        
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        UIViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"InterestSelectViewController"];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (void)userProfile {
    NSString *key = @"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]) {
        key = @"facebookId";
    } else {
        key = @"email";
    }
    
    if (IsNSStringValid([DataManager sharedManager].strEmail)) {
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:[DataManager sharedManager].strEmail forKey:key];
        
        [[FindyAPI instance] getUserProfile:self withSelector:@selector(getUserProfile:) andOptions:paramDict];
    }
}


- (void)getUserProfile:(NSDictionary *)response {
    //    NSLog(@"%@", [response objectForKey:@"shoutouts"]);
    if (ISNSArrayValid([response objectForKey:@"loc"])) {
        [DataManager sharedManager].latitude = [[[response objectForKey:@"loc"] objectAtIndex:1] floatValue];
        [DataManager sharedManager].longitude = [[[response objectForKey:@"loc"] objectAtIndex:0] floatValue];
    }
    if ([response valueForKey:@"shoutouts"] != [NSNull null]) {
        [[DataManager sharedManager].shoutoutArray removeAllObjects];
        for (NSDictionary *dict in [response objectForKey:@"shoutouts"]) {
            [[DataManager sharedManager].shoutoutArray addObject:dict];
        }
    }
    if ([DataManager sharedManager].interestArray != nil) {
        [[DataManager sharedManager].interestArray removeAllObjects];
    }
    
    NSArray *interestsArray = [response objectForKey:@"interests"];
    
    if (ISNSArrayValid(interestsArray)) {
        for (int i = 0; i < [[response objectForKey:@"interests"]  count]; i++) {
            NSString *interest = [[response objectForKey:@"interests"] objectAtIndex:i];
            interest = [interest stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
            
            [[DataManager sharedManager].interestArray addObject:interest];
        }
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]) {
        [DataManager sharedManager].strGender = [[NSString alloc] initWithString:[response objectForKey:@"gender"]];
        //    [DataManager sharedManager].imgFace =
        //    UIImage *picSmall = nil;
        NSData *imgData = [NSData dataWithBase64EncodedString:[[response objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]];
        [DataManager sharedManager].imgFace = [UIImage imageWithData:imgData];
    }
    
    InitialSlidingViewController *slideView = [[InitialSlidingViewController alloc] init];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:slideView] animated:YES];
    [slideView release];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [scrollView setFrame:CGRectMake(0, 44.0 + [DataManager sharedManager].fiOS7StatusHeight, 320, SCREEN_HEIGHT - 44.0 - [DataManager sharedManager].fiOS7StatusHeight - 216)];
    [scrollView setContentSize:CGSizeMake(320, 486)];
    
    if (textField == txtBirthday) {
        bAgeChanged = TRUE;
        [curTextField resignFirstResponder];
        [self showPickerView];
        return FALSE;
    } else {
        if (curTextField == txtBirthday) {
            [self hidePickerView];
            if (age < 18) {
                return FALSE;
            }
        }
        
    }
    curTextField = textField;
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [scrollView setFrame:CGRectMake(0, 44.0 + [DataManager sharedManager].fiOS7StatusHeight, 320, SCREEN_HEIGHT - 44.0 - [DataManager sharedManager].fiOS7StatusHeight)];
    [scrollView setContentSize:CGSizeMake(320, 486)];
    [textField resignFirstResponder];
    
    return TRUE;
}   

- (void)viewDidUnload {
    [btnDone release];
    btnDone = nil;
    [super viewDidUnload];
}


- (IBAction)changeDate:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *strBirth = [formatter stringFromDate:datePickerView.date];
    
    [formatter release];
    
    [txtBirthday setText:strBirth];
}

#pragma mark - Facebook Delegate
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [SVProgressHUD showWithStatus:@"Sign in with Facebook" maskType:SVProgressHUDMaskTypeClear];
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"FACEBOOK_LOGIN"];
    [DataManager sharedManager].fbID = [user objectForKey:@"id"];
    [DataManager sharedManager].strFirstName = user.first_name;
    [DataManager sharedManager].strLastName = user.last_name;
    if (IsNSStringValid([user objectForKey:@"email"])) {
        [DataManager sharedManager].strEmail = [user objectForKey:@"email"];
    } else {
        [DataManager sharedManager].strEmail = [NSString stringWithFormat:@"%@@facebook.com", [user objectForKey:@"username"]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strEmail forKey:@"USER_EMAIL"];
    
    [DataManager sharedManager].strCity = [user.location objectForKey:@"name"];
    NSLog(@"%@", [DataManager sharedManager].strCity);
    [DataManager sharedManager].strGender = ([[user objectForKey:@"gender"] isEqualToString:@"female"]) ? @"F" : @"M";
    [DataManager sharedManager].strBirthday = user.birthday;
    
    NSString *urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", [user objectForKey:@"id"]];
    NSMutableURLRequest *urlRequest =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                        timeoutInterval:30];
    NSData *imgData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    if (imgData != Nil) {
        [DataManager sharedManager].imgFace = [UIImage imageWithData:imgData];
        int s = ([DataManager sharedManager].imgFace.size.width < [DataManager sharedManager].imgFace.size.height) ? [DataManager sharedManager].imgFace.size.width : [DataManager sharedManager].imgFace.size.height;
        [DataManager sharedManager].imgFace = [[ImageResizingUtility instance] imageByCropping:[DataManager sharedManager].imgFace _targetSize:CGSizeMake(s, s)];
    } else {
        [DataManager sharedManager].imgFace = nil;
    }
    
    urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover", [user objectForKey:@"id"]];
    
    urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:30];
    NSData *coverData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    NSDictionary *coverDict = [[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:coverData];
    
    if ([coverDict valueForKey:@"cover"]) {
        NSString *urlString = [[coverDict objectForKey:@"cover"] objectForKey:@"source"];
        [DataManager sharedManager].imgBack = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
    }
    
    [SVProgressHUD dismiss];
    
    if (user.location != nil) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.geoCoder geocodeAddressString:[user.location objectForKey:@"name"] completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [DataManager sharedManager].latitude = placemark.location.coordinate.latitude;
            [DataManager sharedManager].longitude = placemark.location.coordinate.longitude;
        }];
    } else {
        [DataManager sharedManager].latitude = 0;
        [DataManager sharedManager].longitude = 0;
    }
    
    if (IsNSStringValid([DataManager sharedManager].fbID)) {
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].fbID, nil]
                                                                            forKeys:[NSArray arrayWithObjects:@"email", nil]];
        [[FindyAPI instance] getUserExist:self withSelector:@selector(fbLoginResult:) andOptions:paramDict];
    }
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
