//
//  WebBrowserViewController.m
//  Findy
//
//  Created by iPhone on 11/22/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "WebBrowserViewController.h"

@interface WebBrowserViewController ()
@property (nonatomic, retain) NSMutableDictionary *postParams;
@end

@implementation WebBrowserViewController

@synthesize strType;

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
   
    self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
    
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 260.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:self.viewTitle];
    [lblTitle sizeToFit];
    float fontSize = 18.f;
    while ((lblTitle.frame.size.width > 260.f) && (fontSize >= 10)) {
        fontSize -= 0.5f;
        [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize]];
        [lblTitle sizeToFit];
    }
    [lblTitle setFrame:CGRectMake(30.f, [DataManager sharedManager].fiOS7StatusHeight + (44.f - lblTitle.frame.size.height) / 2.f, 260.f, lblTitle.frame.size.height)];
    
    [self.view addSubview:lblTitle];

    [self.indicatorView startAnimating];
    //Create a URL object.
    self.urlString = [self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([self.urlString rangeOfString:@"http://www.anrdoezrs.net/"].location == NSNotFound) {
        self.urlString = [self.urlString stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    }
    
    self.urlString = [self.urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [self.webView setScalesPageToFit:YES];
    [self.webView setAutoresizesSubviews:YES];
    
    NSURL *url = [NSURL URLWithString:self.urlString];

    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:requestObj];
    [self.webView setDelegate:self];
    
    
    if (![strType isEqualToString:@""]) {
        self.postParams = [@{
                             @"link" : self.urlString,
    //                       @"picture" : @"https://developers.facebook.com/attachment/iossdk_logo.png",
                             @"name" : self.subTitle,
                             @"description" : [NSString stringWithFormat:@"%@. Check out this deal", self.viewTitle]
    //                         @"caption" : @"One-stop-shop for your activity!"
                             } mutableCopy];
    }
    
}

- (void)backButtonPressed:(id)sender {
    [self.webView setDelegate:Nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_webView release];
    [_indicatorView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [self setIndicatorView:nil];
    [super viewDidUnload];
}

- (void)tweetTwitter {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil
                                  completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *accountArray = [account accountsWithAccountType:accountType];
             
             if ([accountArray count] > 0)
             {
                 
             } else {
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
                 //                    UIAlertView *alertWindow = [[UIAlertView alloc]initWithTitle:@"No Account" message:@"Sorry dude, there is no twitter-account specified yet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 //                    [alertWindow show];
             }
         }
     }];
}

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
         
         
     }];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.indicatorView startAnimating];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] absoluteString] hasPrefix:@"js-call:facebook"]) {
//            self.postParams[@"message"] = [NSString stringWithFormat:@"%@: %@", btnInterest.titleLabel.text, txtShoutout.text];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully Published!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
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
    } else if ([[[request URL] absoluteString] hasPrefix:@"js-call:twitter"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Successfully Published!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                      ACAccountTypeIdentifierTwitter];
        
        [account requestAccessToAccountsWithType:accountType options:nil
                                      completion:^(BOOL granted, NSError *error)
         {
             if (granted == YES)
             {
                 NSArray *arrayOfAccounts = [[NSArray alloc] initWithArray:[account accountsWithAccountType:accountType]];
                 
                 if ([arrayOfAccounts count] > 0)
                 {
                     NSString *status = [NSString stringWithFormat:@"%@ %@ via #FindyApp  %@", self.subTitle, self.viewTitle, self.urlString];
                     
                     NSDictionary *message = @{@"status": status};
                     
                     NSURL *requestURL = [NSURL
                                          URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                     
                     SLRequest *postRequest = [SLRequest
                                               requestForServiceType:SLServiceTypeTwitter
                                               requestMethod:SLRequestMethodPOST
                                               URL:requestURL parameters:message];
                     ACAccount* twitterAccount = [arrayOfAccounts lastObject];
                     postRequest.account = twitterAccount;
                     
                     [postRequest
                      performRequestWithHandler:^(NSData *responseData,
                                                  NSHTTPURLResponse *urlResponse, NSError *error)
                      {
//                          [[[UIAlertView alloc] initWithTitle:@"HTTP RESPONSE" message:[NSString stringWithFormat:@"%d", [urlResponse statusCode]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//                          
//                          NSLog(@"%@", error.description);
                          
                      }];
                 } else {
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
                     //                    UIAlertView *alertWindow = [[UIAlertView alloc]initWithTitle:@"No Account" message:@"Sorry dude, there is no twitter-account specified yet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                     //                    [alertWindow show];
                 }
             }
         }];
    } else if ([[[request URL] absoluteString] hasPrefix:@"js-call:email"]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = self;
            [controller setSubject:@"Here is a deal I wanted to share with you"];
            [controller setMessageBody:
             [NSString stringWithFormat:@"%@ \n %@ \n via #FindyApp %@", self.subTitle, self.viewTitle, self.urlString] isHTML:NO];
            if (controller) [self presentModalViewController:controller animated:YES];
            [controller release];
        }
    }
    
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicatorView stopAnimating];
    if ([strType isEqualToString:@"LIVING"]) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"share_container.getElementsByTagName(\"a\")[0].href=\"js-call:facebook\";share_container.getElementsByTagName(\"a\")[1].href=\"js-call:twitter\";share_container.getElementsByTagName(\"a\")[2].href=\"js-call:email\";"];
    } else if ([strType isEqualToString:@"GROUPON"]){
        [self.webView stringByEvaluatingJavaScriptFromString:@"$('#email_button').attr('onclick','').unbind('click'); $('#facebook_button').attr('onclick','').unbind('click');$('#twitter_button').attr('onclick','').unbind('click');"];
        [self.webView stringByEvaluatingJavaScriptFromString:@"$('#email_button').bind('click', function() { $('#share_options_popup').hide(); location.href='js-call:email'; });         $('#facebook_button').bind( \"click\", function() { $('#share_options_popup').hide(); location.href='js-call:facebook'; });$('#twitter_button').bind( 'click', function() { $('#share_options_popup').hide(); location.href='js-call:twitter'; });"];
        [self.webView stringByEvaluatingJavaScriptFromString:@"window.onerror=function(a,b,c){alert(a+'\n'+b+'\n'+c)}"];
    }
    

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}
@end
