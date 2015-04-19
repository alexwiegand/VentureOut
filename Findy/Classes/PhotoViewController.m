//
//  PhotoViewController.m
//  Findy
//
//  Created by Yuri Petrenko on 2/2/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize strPhoto;

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
    [_imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strPhoto]]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}

- (IBAction)doneClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
