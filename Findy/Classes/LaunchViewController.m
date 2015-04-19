//
//  LaunchViewController.m
//  Findy
//
//  Created by iPhone on 7/29/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "LaunchViewController.h"
#import "RegisterViewController.h"
#import "InterestViewController.h"
#import "AppDelegate.h"
#import "FindyAPI.h"
#import "InitialSlidingViewController.h"
#import "ImageResizingUtility.h"
#import "DataManager.h"
#import "SVProgressHUD.h"
#import "WebBrowserViewController.h"
#import "JSONKit.h"
#import "Flurry.h"

@interface LaunchViewController ()
@property (nonatomic, strong) NSMutableArray *viewControllers;
@end

@implementation LaunchViewController

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
    bAnimation = true;
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_login"]) {
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]) {
//            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"EMAIL_SIGNIN"] == TRUE) {
//                NSString *strEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_EMAIL"];
//                NSString *strPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_PASSWORD"];
//                if ((strEmail != nil) & (strPassword != nil)) {
//                    NSMutableDictionary *authenticationCredentails =
//                    [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:strEmail, strPassword, nil]
//                                                       forKeys:[NSArray arrayWithObjects:@"email",@"password",    nil]];
//                    [[FindyAPI instance] loginUserForObject:self
//                                               withSelector:@selector(authenticationResult:)
//                                                 andOptions:authenticationCredentails];
//                }
//            }
//        } else
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]){
    
            [DataManager sharedManager].fbID = [[NSUserDefaults standardUserDefaults] objectForKey:@"FACEBOOK_ID"];
        }
        
        [DataManager sharedManager].strEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_EMAIL"];
        [DataManager sharedManager].strFirstName = [[NSUserDefaults standardUserDefaults] objectForKey:@"FIRST_NAME"];
        [DataManager sharedManager].strLastName = [[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_NAME"];
        [DataManager sharedManager].strCity = [[NSUserDefaults standardUserDefaults] objectForKey:@"CITY"];
        [DataManager sharedManager].strGender = [[NSUserDefaults standardUserDefaults] objectForKey:@"GENDER"];
        [Flurry setGender:[DataManager sharedManager].strGender];
        [DataManager sharedManager].strBirthday = [[NSUserDefaults standardUserDefaults] objectForKey:@"BIRTHDAY"];
        
        int age = 0;
        if (([DataManager sharedManager].strBirthday != Nil) && (![[DataManager sharedManager].strBirthday isKindOfClass:[NSNull class]])) {
            NSString *birth = [DataManager sharedManager].strBirthday;
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[birth longLongValue]];
            
            NSDateComponents *todayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
            NSDateComponents *birthComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
            
            age = [todayComp year] - [birthComp year];
            
            if ([todayComp month] < [birthComp month]) {
                age --;
            } else if ([todayComp month] == [birthComp month]){
                if ([todayComp day] < [birthComp day]) {
                    age--;
                }
            }
        }
        
        [Flurry setAge:age];
        
        [DataManager sharedManager].strPicSmall = [[NSUserDefaults standardUserDefaults] objectForKey:@"PICSMALL"];
        [DataManager sharedManager].strPicBig = [[NSUserDefaults standardUserDefaults] objectForKey:@"PICBIG"];
        if (!IsNSStringValid([DataManager sharedManager].strPicBig)) {
            [DataManager sharedManager].strPicBig = [NSString stringWithFormat:@"http://crazebot.com/userpic_big.php?email=%@", [DataManager sharedManager].strEmail];
        }
        if (!IsNSStringValid([DataManager sharedManager].strPicSmall)) {
            [DataManager sharedManager].strPicSmall = [NSString stringWithFormat:@"http://crazebot.com/userpic_small.php?email=%@", [DataManager sharedManager].strEmail];
        }
        [DataManager sharedManager].interestArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"INTEREST_ARRAY"]];

        InitialSlidingViewController *slideView = [[InitialSlidingViewController alloc] init];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:slideView] animated:NO];
        [slideView release];
            
    //        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email", @"user_likes", @"user_birthday", @"user_location"]
    //                                           allowLoginUI:TRUE
    //                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
    //                                          if (error) {
    //                                              NSLog (@"Handle error %@", error.localizedDescription);
    //                                          } else {
    //                                              [FBSession setActiveSession:session];
    //                                              [self checkSessionState:state];
    //                                          }
    //                                      }];
    } else {
        if (IS_IOS7)
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
    //    [imgBackground setImage:[UIImage imageNamed:[(AppDelegate *)[[UIApplication sharedApplication] delegate] getResourceForDevice:@"LauncherBack1"]]];
    ////    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[(AppDelegate *)[[UIApplication sharedApplication] delegate] getResourceForDevice:@"LauncherBackground"]]];
        if (IS_IPHONE5) {
            [_scrollView setFrame:CGRectMake(0, 0, 320, 568)];
        } else {
            [_scrollView setFrame:CGRectMake(0, 0, 320, 480)];
        }
        
        FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes", @"user_birthday", @"user_location"]];

        // Set this loginUIViewController to be the loginView button's delegate
        loginView.delegate = self;
        loginView.frame = CGRectMake(30, (IS_IPHONE5) ? 463 + [DataManager sharedManager].fiOS7StatusHeight : 375 + [DataManager sharedManager].fiOS7StatusHeight, 260, 45);
        
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
        [self.view addSubview:loginView];

        //	[inputPasswordView addSubview:textFieldEmail];
    //	[inputPasswordView addSubview:textFieldPassword];
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
        
        //
        NSUInteger numberPages = 4;
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        for (NSUInteger i = 0; i < numberPages; i++)
        {
            [controllers addObject:[NSNull null]];
        }
        self.viewControllers = controllers;
        
        // a page is the width of the scroll view
        self.scrollView.pagingEnabled = YES;
        self.scrollView.contentSize =
        CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.delegate = self;
        
        self.pageControl.numberOfPages = numberPages;
        self.pageControl.currentPage = 0;
        
        // pages are created on demand
        // load the visible page
        // load the page on either side to avoid flashes when the user starts scrolling
        //
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
        
        [self performSelector:@selector(gotoScrollAuto) withObject:Nil afterDelay:5.f];
    }
}

- (void)gotoScrollAuto {
    if (!bAnimation) {
        return;
    }
    int page = self.pageControl.currentPage + 1;
    if (page == 4) {
        page = 0;
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    } else {
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    }
    
    if (page == 0) {
        [imgSignIn setImage:[UIImage imageNamed:@"SignInEmailBlack.png"]];
    } else {
        [imgSignIn setImage:[UIImage imageNamed:@"SignInEmailWhite.png"]];
    }
    
    self.pageControl.currentPage = page;
    
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:YES];
    
    [self performSelector:@selector(gotoScrollAuto) withObject:Nil afterDelay:3.f];
}

- (void)loadScrollViewWithPage:(NSUInteger)page
{
    if (page >= 4)
        return;
    
    // replace the placeholder if necessary
    UIImageView *imgView = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)imgView == [NSNull null])
    {
        NSString *filename = (IS_IPHONE5) ? [NSString stringWithFormat:@"LauncherBack%d-568h@2x.png", page + 1] : [NSString stringWithFormat:@"LauncherBack%d.png", page + 1];
        imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
        [self.viewControllers replaceObjectAtIndex:page withObject:imgView];
    }
    
    // add the controller's view to the scroll view
    if (imgView.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        imgView.frame = frame;
        
        [self.scrollView addSubview:imgView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fbLoginResult:(NSDictionary *)response {

    if ([[response objectForKey:@"exists"] boolValue]) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"FACEBOOK_REGISTER"];
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"auth"] forKey:@"auth_value"];
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

        if (IsNSStringValid([response objectForKey:@"pic_small"])) {
            [DataManager sharedManager].strPicSmall = [response objectForKey:@"pic_small"];
            [DataManager sharedManager].imgFace = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[response objectForKey:@"pic_small"]]]];
            [DataManager sharedManager].strPicBig = [NSString stringWithFormat:@"http://crazebot.com/userpic_big.php?email=%@", [response objectForKey:@"email"]];
            [DataManager sharedManager].imgBack = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://crazebot.com/userpic_big.php?email=%@", [response objectForKey:@"email"]]]]];
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
    NSMutableDictionary *paramDict;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]) {
        key = @"facebookId";
        if (IsNSStringValid([DataManager sharedManager].strEmail)) {
            paramDict  = [NSMutableDictionary dictionaryWithObject:[DataManager sharedManager].strEmail forKey:key];
        } else {
            paramDict  = [NSMutableDictionary dictionaryWithObject:[DataManager sharedManager].fbID forKey:key];
        }
        
    } else {
        key = @"email";
        paramDict  = [NSMutableDictionary dictionaryWithObject:[DataManager sharedManager].strEmail forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"user_login"];
    [[FindyAPI instance] getUserProfile:self withSelector:@selector(getUserProfile:) andOptions:paramDict];
}

- (void)getUserProfile:(NSDictionary *)response {

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
//        NSData *imgData = [NSData dataWithBase64EncodedString:[[response objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]];
//        [DataManager sharedManager].imgFace = [UIImage imageWithData:imgData];
        [DataManager sharedManager].strPicSmall = [response objectForKey:@"pic_small"];
        [DataManager sharedManager].strPicBig = [response objectForKey:@"pic_big"];
        [DataManager sharedManager].imgFace = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[response objectForKey:@"pic_small"]]]];
    }
    
    InitialSlidingViewController *slideView = [[InitialSlidingViewController alloc] init];
    [self.navigationController setViewControllers:[NSArray arrayWithObject:slideView] animated:YES];
    [slideView release];
}


- (void)authentication:(NSDictionary *)response {
    
}

#pragma mark - Button Action

- (IBAction)signInFB:(id)sender {

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_REGISTER"]) {
        
    } else {
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//        
//        if (appDelegate.session.isOpen) {
////            [appDelegate.session closeAndClearTokenInformation]; // FB delog
//            [self successLogin];
//        } else {
//            if (appDelegate.session.state != FBSessionStateCreated) {
//                appDelegate.session = [[FBSession alloc] init];
//            }
//            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
//                                                             FBSessionState status,
//                                                             NSError *error) {
//                // and here we make sure to update our UX according to the new session state
//                [FBSession setActiveSession:appDelegate.session];
//                 if(session.isOpen) {
////                     [self successLogin];
//                 }
//            }];
//        }
//        
//        // if the session isn't open, let's open it now and present the login UX to the user
    }
}

- (IBAction)signInEmail:(id)sender {
    //
//    [inputPasswordView textFieldAtIndex:0].text = @"yuri@gmail.com";
//	[inputPasswordView textFieldAtIndex:1].text = @"iphone.";
    //    textFieldEmail.text = @"m";
    //    textFieldPassword.text = @"m";
    //    textFieldEmail.text = @"c";
    //    textFieldPassword.text = @"c";
    //    textFieldEmail.text = @"y";
    //    textFieldPassword.text = @"y";
    //    textFieldEmail.text = @"a";
    //    textFieldPassword.text = @"a";
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = @"http://findyapp.com/invite/privacy-policy.html";
    webBrowser.viewTitle = @"Privacy Policy";
    webBrowser.strType = @"";
    [self.navigationController pushViewController:webBrowser animated:YES];
    
    return;
	CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0, 30.0);
	[inputPasswordView setTransform:moveUp];
	[textFieldEmail becomeFirstResponder];
	[inputPasswordView show];
}

- (IBAction)signUpEmail:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = @"http://findyapp.com/terms.html";
    webBrowser.viewTitle = @"Terms of use";
    webBrowser.strType = @"";
    [self.navigationController pushViewController:webBrowser animated:YES];
    
    return;
    
//    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"FACEBOOK_LOGIN"];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
//                                                         bundle: nil];
//    RegisterViewController *registerViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
//    [self.navigationController pushViewController:registerViewController animated:YES];
}


- (void)dealloc {
    [_scrollView release];
    [_pageControl release];
    [signinButton release];
    [facebookButton release];
    [imgSignIn release];
    [super dealloc];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
        return TRUE;
}



- (void)viewDidUnload {
    [_scrollView release];
    _scrollView = nil;
    [_pageControl release];
    _pageControl = nil;
    [signinButton release];
    signinButton = nil;
    [facebookButton release];
    facebookButton = nil;
    [imgSignIn release];
    imgSignIn = nil;
    [super viewDidUnload];
}

#pragma mark - UIScrollView
// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    bAnimation = false;
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    if (page == 0) {
        [imgSignIn setImage:[UIImage imageNamed:@"SignInEmailBlack.png"]];
    } else {
        [imgSignIn setImage:[UIImage imageNamed:@"SignInEmailWhite.png"]];
    }
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((scrollView.contentOffset.x < 0) || (scrollView.contentOffset.x > 960)) {
        [self.scrollView setScrollEnabled:NO];
    } else {
        [self.scrollView setScrollEnabled:YES];
    }
}

- (void)gotoPage:(BOOL)animated
{
    NSInteger page = self.pageControl.currentPage;
    
    if (page == 0) {
        [imgSignIn setImage:[UIImage imageNamed:@"SignInEmailBlack.png"]];
    } else {
        [imgSignIn setImage:[UIImage imageNamed:@"SignInEmailWhite.png"]];
    }
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];

	// update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (IBAction)valueChanged:(id)sender
{
    [self gotoPage:YES];    // YES = animate
}

#pragma mark - Sign In Delegate
- (void) authenticationResult:(NSDictionary*) response {

    if (([[response objectForKey:@"exists"] boolValue]) && ([[response objectForKey:@"valid"] boolValue])) {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"FACEBOOK_LOGIN"];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"user_login"];
        
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
        [DataManager sharedManager].fbID = [response objectForKey:@"facebookId"];
        if ([response valueForKey:@"shoutouts"] != [NSNull null]) {
            for (NSDictionary *dict in [response objectForKey:@"shoutouts"]) {
                [[DataManager sharedManager].shoutoutArray addObject:dict];
            }
        }
        
//        NSData *imgData = [NSData dataWithBase64EncodedString:[[response objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]];
//        [DataManager sharedManager].imgFace = [[UIImage alloc] initWithData:imgData];
        [DataManager sharedManager].imgFace = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[response objectForKey:@"pic_small"]]]];
        [DataManager sharedManager].strPicSmall = [response objectForKey:@"pic_small"];
//        imgData = [NSData dataWithBase64EncodedString:[[response objectForKey:@"pic_big"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]];
//        [DataManager sharedManager].imgBack = [[UIImage alloc] initWithData:imgData];
        [DataManager sharedManager].imgBack = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[response objectForKey:@"pic_big"]]]];
        
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

#pragma mark - Facebook Delegate
- (void) checkSessionState:(FBSessionState)state {
    switch (state) {
        case FBSessionStateOpen:
            NSLog(@"FBSessionStateOpen");
            break;
        case FBSessionStateCreated:
            NSLog(@"FBSessionStateCreated");
            break;
        case FBSessionStateCreatedOpening:
            NSLog(@"FBSessionStateCreatedOpening");
            break;
        case FBSessionStateCreatedTokenLoaded:
            NSLog(@"FBSessionStateCreatedTokenLoaded");
            break;
        case FBSessionStateOpenTokenExtended:
            NSLog(@"FBSessionStateOpenTokenExtended");
            // I think this is the state that is calling
            break;
        case FBSessionStateClosed:
            NSLog(@"FBSessionStateClosed");
            break;
        case FBSessionStateClosedLoginFailed:
            NSLog(@"FBSessionStateClosedLoginFailed");
            break;
        default:
            break;
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [SVProgressHUD showWithStatus:@"Sign in with Facebook" maskType:SVProgressHUDMaskTypeClear];
}
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"FACEBOOK_LOGIN"];

    [DataManager sharedManager].fbID = [user objectForKey:@"id"];
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].fbID forKey:@"FACEBOOK_ID"];
    [DataManager sharedManager].strFirstName = user.first_name;
    [DataManager sharedManager].strLastName = user.last_name;
    if (IsNSStringValid([user objectForKey:@"email"])) {
        [DataManager sharedManager].strEmail = [user objectForKey:@"email"];
    } else {
        [DataManager sharedManager].strEmail = [NSString stringWithFormat:@"%@@facebook.com", [user objectForKey:@"username"]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strEmail forKey:@"USER_EMAIL"];

    [DataManager sharedManager].strCity = [user.location objectForKey:@"name"];
    NSLog(@"%@", [user.location  objectForKey:@"name"]);
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
    } else {
        [DataManager sharedManager].imgBack = [UIImage imageNamed:[NSString stringWithFormat:@"DefaultLibrary%02d.jpg", (arc4random() % 12) + 1]];
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
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail,[DataManager sharedManager].fbID, [[[FBSession activeSession] accessTokenData] accessToken], nil]
                                                                            forKeys:[NSArray arrayWithObjects:@"email", @"facebookId", @"facebookaccesstoken", nil]];
        [[FindyAPI instance] updateAuth:self withSelector:@selector(fbLoginResult:) andOptions:paramDict];
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
