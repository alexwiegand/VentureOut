//
//  MyCommunityViewController.m
//  Findy
//
//  Created by Alexander Wiegand on 4/25/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import "MyCommunityViewController.h"
#import "PlaceProfileViewController.h"

@interface MyCommunityViewController ()

@end


@implementation MyCommunityViewController

ECSlidingViewTopNotificationHandlerMacro


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
    
    ECSlidingViewTopNotificationMacro;
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", nil]];
    [[FindyAPI instance] favoriteDetail:self withSelector:@selector(getFavoriteDetail:) andOptions:paramDict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [contentScrollView release];
    [nonCommunityView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [contentScrollView release];
    contentScrollView = nil;
    [nonCommunityView release];
    nonCommunityView = nil;
    [super viewDidUnload];
}
- (IBAction)menuPressed:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)shoutoutPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ShoutOut"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"ShoutOutViewController"];
    [self.navigationController pushViewController:interstViewController animated:YES];
}

- (IBAction)findCommunityPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (void)getFavoriteDetail:(NSDictionary *)response {
    float y = 20;
    
    if (placeArray != nil) {
        [placeArray removeAllObjects];
        [placeArray release];
    }

    placeArray = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"favorite_places"]];
    
    if ([placeArray count] == 0) {
        [nonCommunityView setHidden:NO];
        [contentScrollView setHidden:YES];
    } else {
        [nonCommunityView setHidden:YES];
        [contentScrollView setHidden:NO];
    }
    for (int i = 0;i < [placeArray count]; i++) {
        NSDictionary *content = [placeArray objectAtIndex:i];

        if (IsNSStringValid([content objectForKey:@"pic_small"]) && (![[content objectForKey:@"pic_small"] isEqualToString:@"null"])) {
            
            UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopPadding.png"]];
            [topImageView setFrame:CGRectMake(10, y, 300, 5)];
            [topImageView setContentMode:UIViewContentModeScaleToFill];
            [contentScrollView addSubview:topImageView];
            [topImageView release];
            
            // Calculate Content Height
            int nHeight = 75.f;
            UIImageView *bodyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ContentPadding.png"]];
            [bodyImageView setFrame:CGRectMake(10, y + 5, 300, nHeight)];
            [bodyImageView setContentMode:UIViewContentModeScaleToFill];
            [contentScrollView addSubview:bodyImageView];
            
            y += 5;
            AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(19.f, y + 5.f, 65.f, 65.f)];
            pImageView.contentMode = UIViewContentModeScaleAspectFill;
            pImageView.clipsToBounds = YES;
            pImageView.bCircle = 1;
            NSURL *imageURL = [NSURL URLWithString:[content objectForKey:@"pic_small"]];
            pImageView.imageURL = imageURL;
            [contentScrollView addSubview:pImageView];
            [pImageView release];
            
            UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(95.f, y + 15.f, 200.f, 20.f)];
            [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
            [lblName setTextColor:[UIColor colorWithRed:1.f green:.35f blue:0 alpha:1.f]];
            [lblName setText:[content objectForKey:@"name"]];
            [contentScrollView addSubview:lblName];
            [lblName release];
            
            int x = 95;
            
            int nCommunity = [[content objectForKey:@"user_count"] intValue];
            
            if (IsNSStringValid([content objectForKey:@"interest"])) {
                
                UILabel *lblMatchingInterest = [[UILabel alloc] initWithFrame:CGRectMake(x, (nCommunity > 0) ? y + 35 : y + 45, 0, 20)];
                [lblMatchingInterest setBackgroundColor:[UIColor clearColor]];
                [lblMatchingInterest setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:INTEREST_FONT_SIZE]];
                [lblMatchingInterest setText:[NSString stringWithFormat:@"%@",[content objectForKey:@"interest"]]];
                [lblMatchingInterest sizeToFit];
                [contentScrollView addSubview:lblMatchingInterest];
                if (lblMatchingInterest.frame.size.width > 205) {
                    [lblMatchingInterest setFrame:CGRectMake(x, (nCommunity > 0) ? y + 35 : y + 45.f, 205, lblMatchingInterest.frame.size.height)];
                }
                [lblMatchingInterest release];
            }
            
            if (nCommunity > 0) {
                UILabel *lblCommunity = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 53, 200.f, 20.f)];
                [lblCommunity setBackgroundColor:[UIColor clearColor]];
                [lblCommunity setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
                [lblCommunity setText:(nCommunity == 0) ? @"Be the first to join this community" : (nCommunity == 1) ? [NSString stringWithFormat:@"%d person in this community", nCommunity] : [NSString stringWithFormat:@"%d people in this community", nCommunity]];
                [contentScrollView addSubview:lblCommunity];
                [lblCommunity release];
            }
            
            
            UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
            [footerImage setFrame:CGRectMake(10, y + 75.f, 300, 5)];
            [contentScrollView addSubview:footerImage];
            [footerImage release];
            
            UIButton *btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnProfile setFrame:CGRectMake(10, y - 5, 300, 90)];
            [btnProfile addTarget:self action:@selector(showPlace:) forControlEvents:UIControlEventTouchUpInside];
            [btnProfile setTag:i];
            [contentScrollView addSubview:btnProfile];
            
            y += 90;
        }
    }
//    
//    UIButton *favoriteFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
//    [favoriteFacebook setFrame:CGRectMake(18.f, y, 284, 43)];
//    [favoriteFacebook setImage:[UIImage imageNamed:@"FavoriteFacebookButton.png"] forState:UIControlStateNormal];
//    [favoriteFacebook addTarget:self action:@selector(showFavorite:) forControlEvents:UIControlEventTouchUpInside];
//    [contentScrollView addSubview:favoriteFacebook];
//    
//    y += 50;
    
    [contentScrollView setContentSize:CGSizeMake(320, y + 20)];
}

- (void)showPlace:(id)sender {
    UIButton *sButton = (UIButton *)sender;
    NSDictionary *content = [placeArray objectAtIndex:sButton.tag];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    PlaceProfileViewController *profileController = (PlaceProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaceProfileViewController"];
    profileController.strTitle = [content objectForKey:@"name"];
    profileController.strInterest = [content objectForKey:@"interest"];
    profileController.strID = [content objectForKey:@"yelp_id"];
    [self.navigationController pushViewController:profileController animated:YES];
}
@end
