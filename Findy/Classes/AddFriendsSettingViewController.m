//
//  AddFriendsSettingViewController.m
//  Findy
//
//  Created by iPhone on 12/18/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "AddFriendsSettingViewController.h"

@interface AddFriendsSettingViewController ()

@end

@implementation AddFriendsSettingViewController

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
- (IBAction)inviteFacebook:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"from_setting"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"InviteFBFriendViewController"];
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)inviteContract:(id)sender {
}

@end
