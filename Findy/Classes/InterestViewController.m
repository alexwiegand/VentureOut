//
//  InterestViewController.m
//  Findy
//
//  Created by iPhone on 7/30/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "InterestViewController.h"
#import "AppDelegate.h"
#import "DataManager.h"

@interface InterestViewController ()

@end

@implementation InterestViewController

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

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"Add Activities"];
    [self.view addSubview:lblTitle];
    [lblTitle release];
    
    UIButton *btnPopular = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPopular setBackgroundImage:[UIImage imageNamed:@"PopularButton.png"] forState:UIControlStateNormal];
    [btnPopular setFrame:CGRectMake(0, 52.5f + [DataManager sharedManager].fiOS7StatusHeight, 320, 45.5f)];
    [btnPopular addTarget:self action:@selector(popularPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPopular];
    
    UILabel *lblPopular = [[UILabel alloc] initWithFrame:CGRectMake(23.5f, 52.5f + [DataManager sharedManager].fiOS7StatusHeight, 77.f, 45.5f)];
    [lblPopular setText:@"Popular"];
    [lblPopular setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [lblPopular setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:lblPopular];
    [lblPopular release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popularPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"InterestSelectViewController"];
    [self.navigationController pushViewController:profileViewController animated:YES];
}
@end
