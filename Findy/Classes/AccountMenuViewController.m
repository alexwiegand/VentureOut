//
//  AccountMenuViewController.m
//  Findy
//
//  Created by iPhone on 12/18/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "AccountMenuViewController.h"
#import "WebBrowserViewController.h"

@interface AccountMenuViewController ()

@end

@implementation AccountMenuViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)privacyPolicyPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = @"http://findyapp.com/invite/privacy-policy.html";
    webBrowser.viewTitle = @"Privacy Policy";
    webBrowser.strType = @"";
    [self.navigationController pushViewController:webBrowser animated:YES];
}
- (IBAction)termsofusePressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = @"http://findyapp.com/terms.html";
    webBrowser.viewTitle = @"Terms of use";
    webBrowser.strType = @"";
    [self.navigationController pushViewController:webBrowser animated:YES];
}
- (IBAction)logoutPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Nil message:@"Do you want to log out?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"EMAIL_SIGNIN"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FACEBOOK_LOGIN"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FACEBOOK_REGISTER"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_EMAIL"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"USER_PASSWORD"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FACEBOOK_ID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_login"];
        if ([FBSession activeSession]) {
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
        
        [[DataManager sharedManager].peopleArray removeAllObjects];
        [[DataManager sharedManager].favoritePlaceArray removeAllObjects];
        [[DataManager sharedManager].favoritesArray removeAllObjects];
        [[DataManager sharedManager].interestArray removeAllObjects];
        [[DataManager sharedManager].placesArray removeAllObjects];
        [[DataManager sharedManager].shoutoutArray removeAllObjects];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        UIViewController *launchViewController = [storyboard instantiateViewControllerWithIdentifier:@"LaunchViewController"];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:launchViewController] animated:YES];
    }
}

@end
