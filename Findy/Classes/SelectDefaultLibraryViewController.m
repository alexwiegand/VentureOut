//
//  SelectDefaultLibraryViewController.m
//  Findy
//
//  Created by iPhone on 8/1/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "SelectDefaultLibraryViewController.h"
#import "AppDelegate.h"
#import "ImageSelectButton.h"
#import "DataManager.h"
#import "ImageResizingUtility.h"

@interface SelectDefaultLibraryViewController ()

@end

@implementation SelectDefaultLibraryViewController

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
    [backButton setImage:[UIImage imageNamed:@"CancelButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(10.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 52.0, 30.f)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"DoneButton.png"] forState:UIControlStateNormal];
    [nextButton setFrame:CGRectMake(263.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 49.0, 30.f)];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"Select Photo"];
    [self.view addSubview:lblTitle];
    
    buttonArray = [[NSMutableArray alloc] init];
    
    int x = 10, y = 54 + [DataManager sharedManager].fiOS7StatusHeight;
    for (int i = 1; i <= 12; i++) {
        ImageSelectButton *button = [[ImageSelectButton alloc] initWithFrame:CGRectMake(x + (i - 1) % 3 * 105.f, y + (i - 1) / 3 * 105.f, 85.f, 85.f)];
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"DefaultLibrary%02d.jpg", i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:i];
        [self.view addSubview:button];
        [buttonArray addObject:button];
        [button release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonPressed:(id)sender {
    UIImage *imgResult = [UIImage imageNamed:[NSString stringWithFormat:@"DefaultLibrary%02d.jpg", nTag]];
    int width = 640, height = 520;

    if ((imgResult.size.width > width) || (imgResult.size.height > height)) {
        imgResult = [[ImageResizingUtility instance] imageByCropping:imgResult _targetSize:CGSizeMake(width, height)];
    }
    
    [DataManager sharedManager].imgBack = imgResult;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectImage:(id)sender {
    ImageSelectButton *button = (ImageSelectButton *)sender;
    for (int i = 0; i < [buttonArray count]; i++) {
        [[buttonArray objectAtIndex:i] setSelected:FALSE];
    }
    [button setSelected:!button.selected];
    nTag = button.tag;
}

@end
