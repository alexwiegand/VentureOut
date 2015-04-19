//
//  ProfileSettingViewController.m
//  Findy
//
//  Created by iPhone on 12/17/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "ProfileSettingViewController.h"

@interface ProfileSettingViewController ()

@end

@implementation ProfileSettingViewController

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

#pragma mark - UIButton Action
- (IBAction)changePhotoPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"from_settings"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"ProfilePhotoViewController"];
    [self.navigationController pushViewController:profileViewController animated:YES];
}
- (IBAction)editInfoPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"from_settings"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *registerViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:registerViewController animated:YES];
}

@end
