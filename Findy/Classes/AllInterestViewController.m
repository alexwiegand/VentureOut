//
//  AllInterestViewController.m
//  Findy
//
//  Created by iPhone on 8/7/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "AllInterestViewController.h"
#import "AddInterestViewController.h"
#import "FindyAPI.h"

@interface AllInterestViewController ()

@end

@implementation AllInterestViewController


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
    
    keyArray = [[NSArray alloc] initWithObjects:@"Popular",
                @"Activities",
                @"Industry",
                @"Sports Fan",
                @"Cuisine",
                @"Gaming",
                @"Vehicles",
                @"Parenting", nil];
    
    [[FindyAPI instance] getAllCraze:self withSelector:@selector(getAllCraze:) andOptions:nil];

}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAllCraze:(NSMutableDictionary *)response {
    allCraze = [[response objectForKey:@"Parents"] retain];
    
    [SVProgressHUD dismiss];
    int y = 52.5;
//    keyArray = [[allCraze allKeys] retain];

    for (int i = 0; i < [keyArray count]; i++) {
        UIButton *btnPopular = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnPopular setBackgroundImage:[UIImage imageNamed:@"PopularButton.png"] forState:UIControlStateNormal];
        [btnPopular setFrame:CGRectMake(10, y, 300.f, 45.5f)];
        [btnPopular addTarget:self action:@selector(popularPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btnPopular setTag:i];
        [scrollView addSubview:btnPopular];
        
        UILabel *lblPopular = [[UILabel alloc] initWithFrame:CGRectMake(23.5f, y + 14.5f, 200.f, 20.f)];
        [lblPopular setText:[keyArray objectAtIndex:i]];
        [lblPopular setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
        [lblPopular setBackgroundColor:[UIColor clearColor]];
        [scrollView addSubview:lblPopular];
        [lblPopular release];
        
        [self.view bringSubviewToFront:lblPopular];
        
        y += 60;
    }
    [scrollView setContentSize:CGSizeMake(320, y)];
}

//I who got on it my

- (void)popularPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *key = [keyArray objectAtIndex:button.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    AddInterestViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"AddInterestViewController"];
    NSMutableArray *popArray = [[NSMutableArray alloc] initWithArray:[allCraze objectForKey:key]];
    [popArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    interstViewController.popularArray = popArray;
    [self.navigationController pushViewController:interstViewController animated:YES];
}

- (void)dealloc {
    [scrollView release];
    [super dealloc];
}
@end
