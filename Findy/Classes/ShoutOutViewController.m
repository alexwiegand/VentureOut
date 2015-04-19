//
//  ShoutOutViewController.m
//  Findy
//
//  Created by iPhone on 8/8/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "ShoutOutViewController.h"


@interface ShoutOutViewController ()
@property (nonatomic, retain) NSMutableDictionary *postParams;
@end

@implementation ShoutOutViewController

#define kPlaceholderPostMessage @"\"Looking for a climbing buddy for this weekend in San Francisco\""

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Attach_Title"]) {
//        [btnAttach setHidden:YES];
        [btnAttach setTitle:@"" forState:UIControlStateNormal];
        [attachDetail setHidden:NO];
        [attachTitle setHidden:NO];
        
        [attachTitle setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"Attach_Title"]];
        [attachDetail setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"Attach_Detail"]];
    } else {
//        [btnAttach setHidden:NO];
        [btnAttach setTitle:@"Attach a place or a deal" forState:UIControlStateNormal];
        [attachTitle setHidden:YES];
        [attachDetail setHidden:YES];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShoutOut"]) {
        if ([[DataManager sharedManager].strShoutout isEqualToString:@""]) {
            [btnInterest.titleLabel setText:@"   Select an Activity"];
            [btnInterest.titleLabel setTextColor:[UIColor lightGrayColor]];
        } else {
            [btnInterest.titleLabel setText:[NSString stringWithFormat:@"   %@", [DataManager sharedManager].strShoutout]];
            [btnInterest.titleLabel setTextColor:[UIColor blackColor]];
        }
    } else {
        [btnInterest.titleLabel setText:@"   Select an Activity"];
        [btnInterest.titleLabel setTextColor:[UIColor lightGrayColor]];
    }
    
    [scollView setFrame:CGRectMake(0, 44, 320, (IS_IPHONE5) ? 524 : 416)];
//    int height = imgSharing.frame.origin.y + imgSharing.frame.size.height + 10;
    [scollView setContentSize:CGSizeMake(320, 540)];
}

- (void)viewDidDisappear:(BOOL)animated {
    
}

ECSlidingViewTopNotificationHandlerMacro

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
     
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"CancelButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(7.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 52.f, 30.f)];
    [backButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"PublishButton.png"] forState:UIControlStateNormal];
    [nextButton setFrame:CGRectMake(260.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 52.f, 30.f)];
    [nextButton addTarget:self action:@selector(publishButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"Shout-Out"];
    [self.view addSubview:lblTitle];
    
    ECSlidingViewTopNotificationMacro;
    
    if (IS_IOS7) {
        [txtShoutout setDataDetectorTypes:UIDataDetectorTypeCalendarEvent | UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber];
    }
    
    
    //         [dateFormat setDateFormat:@"dd"];
    //
    //         strTime = [NSString stringWithFormat:@"%@ %@th", strTime, [dateFormat stringFromDate:today]];
    
    [lblDate setText:[NSString stringWithFormat:@"%@, %@", [self getDate], [DataManager sharedManager].strCity]];
}

- (NSString *)getDate {
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE, MMMM dd"];
    //         SATURDAY, AUGUST 25th, SAN FRANCISCO, CA
    return [dateFormat stringFromDate:today];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelButtonPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_place"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Title"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Detail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Url"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Image"];
    [attachDetail setText:@""];
    [attachTitle setText:@""];
    [attachDetail setHidden:YES];
    [attachTitle setHidden:YES];
    
//    [btnAttach setHidden:NO];
    [btnAttach setTitle:@"Attach a place or a deal" forState:UIControlStateNormal];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)publishButtonPressed:(id)sender {
    NSString *aTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Attach_Title"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *aDetail = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"Attach_Detail"] stringByReplacingOccurrencesOfString:@"&" withString:@", "] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *attachUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"Attach_Url"];
    NSString *placeUrl = ([[NSUserDefaults standardUserDefaults] boolForKey:@"is_place"]) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"Attach_Place_Url"] : @" ";
    NSString *aImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"Attach_Image"];
    
    NSString *text = [txtShoutout.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    if (([btnInterest.titleLabel.text isEqualToString:@"   Select an Activity"]) || (text.length == 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please make sure to select an activity and type text" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    
    if ([txtShoutout.text isEqualToString:kPlaceholderPostMessage]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please make sure to select an activity and type text" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }
    NSMutableDictionary *articleParams =[[NSMutableDictionary alloc] init];
    
    if (swtTwitter.on) {
        [articleParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"On" forKey:@"Twitter"]];
        NSString *link = @"http://findyapp.com";
        if (attachTitle.hidden == NO) {
            link = ([[NSUserDefaults standardUserDefaults] boolForKey:@"is_place"]) ? placeUrl : attachUrl;
        }
        NSString *status = [NSString stringWithFormat:@"%@: %@ via @FindyApp %@", btnInterest.titleLabel.text, txtShoutout.text, link];
        
        NSDictionary *message = @{@"status": status};
        
        NSURL *requestURL = [NSURL
                             URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
        
        SLRequest *postRequest = [SLRequest
                                  requestForServiceType:SLServiceTypeTwitter
                                  requestMethod:SLRequestMethodPOST
                                  URL:requestURL parameters:message];
        twitterAccount = [arrayOfAccounts lastObject];
        postRequest.account = twitterAccount;
        
        [postRequest
         performRequestWithHandler:^(NSData *responseData,
                                     NSHTTPURLResponse *urlResponse, NSError *error)
         {
             
         }];
    } else {
        [articleParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"Off" forKey:@"Twitter"]];
    }
    
    if (swtFacbook.on) {
        NSString *link = @"http://findyapp.com";
        if ((attachTitle.hidden == NO) && (![[aTitle stringByReplacingOccurrencesOfString:@"%20" withString:@" "] isEqualToString:@"3rd Ave Kiteboarding"])) {
            link = ([[NSUserDefaults standardUserDefaults] boolForKey:@"is_place"]) ? placeUrl : attachUrl;
        }
        
        if (!IsNSStringValid(aTitle)){
            aTitle = @"Findy - Find a buddy and a place for your favorite activity!";
        }
      
        
        NSString *desc = @"Open Findy anywhere to see which friends and interesting\npeople nearby share your activity interests.\nDiscover which places offer you the \nbest experience, deals, and rewards.";
        
        if (attachTitle.hidden == NO) {
            desc = @"Findy - Find a buddy and a place for your favorite activity! \n Open Findy anywhere to see which friends and interesting people nearby share your activity interests. Discover which places offer you the best experience, deals, and rewards.";
        }
        self.postParams = [[NSMutableDictionary alloc] init];
        [self.postParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:link forKey:@"link"]];
        NSLog(@"%@", aImageUrl);
        if (IsNSStringValid(aImageUrl)) {
            [self.postParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:aImageUrl forKey:@"picture"]];
        } else {
            [self.postParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"https://scontent-a-dfw.xx.fbcdn.net/hphotos-ash2/t1.0-9/150465_285107161622008_708756312_n.jpg" forKey:@"picture"]];
        }
        
        [self.postParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[aTitle stringByReplacingOccurrencesOfString:@"%20" withString:@" "] forKey:@"name"]];
        [self.postParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:desc forKey:@"description"]];
        if (IsNSStringValid(aDetail)) {
            [self.postParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[aDetail stringByReplacingOccurrencesOfString:@"%20" withString:@" "] forKey:@"caption"]];
        }
        
//        self.postParams = [@{
//                             @"link" : link,
//                             @"picture" : aImageUrl,
//                             @"name" : [aTitle stringByReplacingOccurrencesOfString:@"%20" withString:@" "],
//                             @"description" : desc,
//                             @"caption" : [aDetail stringByReplacingOccurrencesOfString:@"%20" withString:@" "]
//                             } mutableCopy];
        
        if (![txtShoutout.text isEqualToString:kPlaceholderPostMessage] && ![txtShoutout.text isEqualToString:@""]) {
            self.postParams[@"message"] = [NSString stringWithFormat:@"%@: %@", btnInterest.titleLabel.text, txtShoutout.text];
        }
        [articleParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"On" forKey:@"Facebook"]];
        if ([FBSession.activeSession.permissions
             indexOfObject:@"publish_actions"] == NSNotFound) {
            // No permissions found in session, ask for it
            [FBSession.activeSession
             requestNewPublishPermissions:@[@"publish_actions"]
             defaultAudience:FBSessionDefaultAudienceFriends
             completionHandler:^(FBSession *session, NSError *error) {
                 if (!error) {
                     // If permissions granted, publish the story
                     [self publishStory];
                 }
             }];
        } else {
            // If permissions present, publish the story
            [self publishStory];
        }
    } else {
        [articleParams addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"Off" forKey:@"Facebook"]];
    }
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss MM/dd/yyyy"];
    
    NSString *strTime = [dateFormat stringFromDate:today];
    NSString *strShout = [txtShoutout.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([strShout characterAtIndex:[strShout length] - 1] == '\n') {
        strShout = [strShout substringToIndex:[strShout length] - 1];
    }
    NSString *onlyFav = (swtFavorite.on) ? @"TRUE" : @"FALSE";
    NSString *interest = [DataManager sharedManager].strShoutout;
    
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [content objectForKey:@"title"]] forKey:@"Attach_Title"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [content objectForKey:@"subtitle"]] forKey:@"Attach_Detail"];
//    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [content objectForKey:@"subtitle"]] forKey:@"Attach_Url"];
//    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    
    [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strEmail forKey:@"email"]];
    [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:strShout forKey:@"shout"]];
    [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:interest forKey:@"interest"]];
    [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:strTime forKey:@"time"]];
    [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:onlyFav forKey:@"onlyfavs"]];
    
    if (attachTitle.hidden == NO) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"is_place"]) {
            [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"" forKey:@"deal_link"]];
            if (IsNSStringValid(attachUrl))
                [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:attachUrl forKey:@"place_link"]];
        } else {
            [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"" forKey:@"place_link"]];
            if (IsNSStringValid(attachUrl))
                [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:attachUrl forKey:@"deal_link"]];
        }
        
        if (IsNSStringValid(attachUrl)) {
            [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:attachUrl forKey:@"attach_url"]];
        }
        
        if (IsNSStringValid(aTitle))
            [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:aTitle forKey:@"attach_title"]];
        
        if (IsNSStringValid(aDetail))
            [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:aDetail forKey:@"attach_detail"]];
        
        if (IsNSStringValid(aImageUrl))
            [paramDict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:aImageUrl forKey:@"attach_image_url"]];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_place"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Title"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Detail"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Url"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Image"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ShoutOut"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Place_Url"];
    
    [[FindyAPI instance] addShoutOut:self
                        withSelector:@selector(shoutOutResult:)
                          andOptions:paramDict];
    
    [Flurry logEvent:@"Create_Shoutout" withParameters:articleParams];
}

- (void)shoutOutResult:(NSDictionary *)response {
    if ([response objectForKey:@"success"]) {
        
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm:ss MM/dd/yyyy"];
        
        NSString *strTime = [dateFormat stringFromDate:today];
        
        
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:txtShoutout.text, [btnInterest.titleLabel.text substringFromIndex:2], strTime, nil]
                                                                            forKeys:[NSArray arrayWithObjects:@"shout", @"interest", @"time",nil]];
        [[DataManager sharedManager].shoutoutArray addObject:paramDict];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Shout-Out published! View it in your profile." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert setTag:100];
        [alert show];
        [alert release];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
//        if (([[[DataManager sharedManager] shoutoutArray] count] == 1) && (![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_FIRST_SHOUTOUT"])) {
////            [[Kiip sharedInstance] saveMoment:@"Creating Your Shout-Out!" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
////                if (error) {
////                    NSLog(@"something's wrong");
////                    // handle with an Alert dialog.
////                }
////                if (poptart) {
////                    [poptart show];
////                    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"IS_FIRST_SHOUTOUT"];
////                }
////                if (!poptart) {
////                    // handle logic when there is no reward to give.
////                }
////            }];
//        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)resetPostMessage
{
    txtShoutout.text = kPlaceholderPostMessage;
    txtShoutout.textColor = [UIColor lightGrayColor];
}

- (void)setPostMessage {
    if ([txtShoutout.text isEqualToString:kPlaceholderPostMessage]) {
        txtShoutout.text = @"";
    }
    txtShoutout.textColor = [UIColor blackColor];
}

- (void)dealloc {
    [btnInterest release];
    [txtShoutout release];
    [swtTwitter release];
    [swtFacbook release];
    [swtFavorite release];
    [scollView release];
    [imgSharing release];
    [lblDate release];
    [imgTxtBack release];
    [attachTitle release];
    [attachDetail release];
    [btnAttach release];
    [super dealloc];
}

- (IBAction)twitterClick:(id)sender {
    if (swtTwitter.on) {
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                      ACAccountTypeIdentifierTwitter];
        
        [account requestAccessToAccountsWithType:accountType options:nil
                                      completion:^(BOOL granted, NSError *error)
        {
            if (granted == YES)
            {
                arrayOfAccounts = [[NSArray alloc] initWithArray:[account accountsWithAccountType:accountType]];
                
                if ([arrayOfAccounts count] > 0)
                {
                    
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
//                    UIAlertView *alertWindow = [[UIAlertView alloc]initWithTitle:@"No Account" message:@"Sorry dude, there is no twitter-account specified yet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                    [alertWindow show];
                }
            }
        }];
    }
}

- (IBAction)facebookClick:(id)sender {
    if (swtFacbook.on) {
        // Add user message parameter if user filled it in
        if (FBSession.activeSession == nil) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            if (!appDelegate.session.isOpen) {
                // create a fresh session object
                appDelegate.session = [[FBSession alloc] init];
                [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                                 FBSessionState status,
                                                                 NSError *error) {
                    [FBSession setActiveSession:appDelegate.session];
                }];
            }
        }

    }
}

/*
 * Publish the story
 */
- (void)publishStory
{
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:self.postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = [NSString stringWithFormat:
                          @"Posted action, id: %@",
                          result[@"id"]];
         }
//         // Show the result in an alert
//         [[[UIAlertView alloc] initWithTitle:@"Result"
//                                     message:alertText
//                                    delegate:self
//                           cancelButtonTitle:@"OK!"
//                           otherButtonTitles:nil]
//          show];
     }];
}

- (IBAction)favoriteClick:(id)sender {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
//                                                         bundle: nil];
//    
//    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
//    
//    [self.navigationController pushViewController:controller animated:YES];

//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"GOTO_NOTIFICATION"];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)interestClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"ShoutOut"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"CurrentInterestViewController"];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (IBAction)hideTextView:(id)sender {
    [txtShoutout resignFirstResponder];
}

- (IBAction)attachSthClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Attach a Place", @"Attach a Deal", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_place"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Title"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Detail"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Url"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Image"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Place_Url"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        UIViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"AttachPlaceViewController"];
        [self.navigationController pushViewController:interstViewController animated:YES];
    } else if(buttonIndex == 1) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"is_place"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Title"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Detail"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Url"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Image"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Attach_Place_Url"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        UIViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"AttachDealViewController"];
        [self.navigationController pushViewController:interstViewController animated:YES];
    }
}

#pragma mark - UITextView Delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [imgTxtBack setHidden:YES];
    [self setPostMessage];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [txtShoutout resignFirstResponder];
    if ([textView.text isEqualToString:@""]) {
        [imgTxtBack setHidden:NO];
    } else {
        [imgTxtBack setHidden:YES];
    }
    
    return YES;
}

#pragma mark - Touches Begin

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [txtShoutout resignFirstResponder];
}

- (void)viewDidUnload {
    [scollView release];
    scollView = nil;
    [imgSharing release];
    imgSharing = nil;
    [lblDate release];
    lblDate = nil;
//    [self setGeoCoder:nil];
//    [self setLocationManager:nil];
    [imgTxtBack release];
    imgTxtBack = nil;
    [attachTitle release];
    attachTitle = nil;
    [attachDetail release];
    attachDetail = nil;
    [btnAttach release];
    btnAttach = nil;
    [super viewDidUnload];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [lblDate setText:[NSString stringWithFormat:@"%@, %@", [self getDate], [DataManager sharedManager].strCity]];
}

@end
