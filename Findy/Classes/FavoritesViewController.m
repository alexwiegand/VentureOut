//
//  FavoritesViewController.m
//  Findy
//
//  Created by iPhone on 9/26/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "FavoritesViewController.h"
#import "ProfileViewController.h"
#import "PlaceProfileViewController.h"

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


ECSlidingViewTopNotificationHandlerMacro

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Favorite"];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
     
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"SlidingButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, [DataManager sharedManager].fiOS7StatusHeight, 40.f, 44.f)];
    [backButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"ShoutoutToolButton.png"] forState:UIControlStateNormal];
    [nextButton setFrame:CGRectMake(275.f, 5.f + [DataManager sharedManager].fiOS7StatusHeight, 35, 34.f)];
    [nextButton addTarget:self action:@selector(shoutoutPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"Favorites Feed"];
    [self.view addSubview:lblTitle];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    ECSlidingViewTopNotificationMacro;
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    [menuView setFrame:CGRectMake(-1, 43 + [DataManager sharedManager].fiOS7StatusHeight, 321, 42)];
    
    [contentScrollView setFrame:CGRectMake(0, 76 + [DataManager sharedManager].fiOS7StatusHeight, 320.f, (IS_IPHONE5) ? 472 : 384)];
    [favoriteByScrollView setFrame:CGRectMake(0, 76 + [DataManager sharedManager].fiOS7StatusHeight, 320.f, (IS_IPHONE5) ? 472 : 384)];
    
    emailArray = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", nil]];
    [[FindyAPI instance] favoriteDetail:self withSelector:@selector(getFavoriteDetail:) andOptions:paramDict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)shoutoutPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ShoutOut"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"ShoutOutViewController"];
    [self.navigationController pushViewController:interstViewController animated:YES];
}

- (void)dealloc {
    [menuView release];
    [contentScrollView release];
    [lblMyFavorite release];
    [lblFavoritesBy release];
    [btnMyFavorite release];
    [btnFavoritesBy release];
    [favoriteByScrollView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [menuView release];
    menuView = nil;
    [contentScrollView release];
    contentScrollView = nil;
    [lblMyFavorite release];
    lblMyFavorite = nil;
    [lblFavoritesBy release];
    lblFavoritesBy = nil;
    [btnMyFavorite release];
    btnMyFavorite = nil;
    [btnFavoritesBy release];
    btnFavoritesBy = nil;
    [favoriteByScrollView release];
    favoriteByScrollView = nil;
    [super viewDidUnload];
}
- (IBAction)menuSelect:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (button == btnFavoritesBy) {
        
    } else if (button == btnMyFavorite) {
        
    }
    
    if ([button isSelected]) {
        return;
    }
    
    [btnFavoritesBy setSelected:NO];
    [btnMyFavorite setSelected:NO];
    [lblMyFavorite setTextColor:[UIColor blackColor]];
    [lblFavoritesBy setTextColor:[UIColor blackColor]];
    
    if (button == btnFavoritesBy) {
        [lblFavoritesBy setTextColor:[UIColor whiteColor]];
        [contentScrollView setHidden:YES];
        [favoriteByScrollView setHidden:NO];
        for (UIView *view in [contentScrollView subviews]) {
            [view removeFromSuperview];
        }
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", nil]];
        [[FindyAPI instance] favoritedBy:self withSelector:@selector(getFavoriteBy:) andOptions:paramDict];
    } else if (button == btnMyFavorite) {
        [lblMyFavorite setTextColor:[UIColor whiteColor]];
        [contentScrollView setHidden:NO];
        [favoriteByScrollView setHidden:YES];
        for (UIView *view in [favoriteByScrollView subviews]) {
            [view removeFromSuperview];
        }
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", nil]];
        [[FindyAPI instance] favoriteDetail:self withSelector:@selector(getFavoriteDetail:) andOptions:paramDict];
    }
    
    [button setSelected:YES];
}

- (void)getFavoriteDetail:(NSDictionary *)response {
    float y = 20;
    if ([emailArray count]) {
        [emailArray removeAllObjects];
    }
    
    for (int i = 0;i < [[response objectForKey:@"favorites"] count]; i++) {
        NSDictionary *content = [[response objectForKey:@"favorites"] objectAtIndex:i];
        [emailArray addObject:[content objectForKey:@"email"]];
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
        
//        UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[content objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
//        
//        y += 5;
//        UIImageView *pImageView = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//        [pImageView setFrame:CGRectMake(19.f, y + 5.f, 65.f, 65.f)];
//        [contentScrollView addSubview:pImageView];
//        [pImageView release];

        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(19, y + 5.f, 65, 65)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
        pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        NSURL *imageURL = [NSURL URLWithString:[content objectForKey:@"pic_small"]];
        pImageView.imageURL = imageURL;
        [contentScrollView addSubview:pImageView];
        [pImageView release];
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(95.f, y + 15.f, 140.f, 20.f)];
        [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
        [lblName setTextColor:[UIColor colorWithRed:0 green:.6f blue:.8f alpha:1.f]];
        [lblName setText:[content objectForKey:@"first"]];
        [contentScrollView addSubview:lblName];
        [lblName release];
        
        int x = 95;
        NSString *mString = [self getMatchingInterest:[content objectForKey:@"interests"]];
        NSString *uString = [self getUnmatchingInterest:[content objectForKey:@"interests"]];
        NSString *aString;
        CGSize matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE]];
        
        float nWidth = 120.f;
        if (matchSize.width > nWidth) {
            NSArray *mArray = [mString componentsSeparatedByString:@", "];
            mString = [mArray objectAtIndex:0];
            matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE]];
            int i = 0;
            while ((matchSize.width < nWidth) && (i < [mArray count])) {
                i++;
                mString = [mString stringByAppendingFormat:@", %@", [mArray objectAtIndex:i]];
                matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE]];
            }
            
            aString = [NSString stringWithFormat:@"+%d", [mArray count] - i];
            uString = @"";
        } else {
            CGSize unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
            
            if (unmatchSize.width > (nWidth - matchSize.width)) {
                NSArray *uArray = [uString componentsSeparatedByString:@", "];
                uString = [uArray objectAtIndex:0];
                unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                int i = 0;
                while ((unmatchSize.width < (nWidth - matchSize.width)) && (i < [uArray count])) {
                    i++;
                    uString = [uString stringByAppendingFormat:@", %@", [uArray objectAtIndex:i]];
                    unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                }

                aString = [NSString stringWithFormat:@"+%d", [uArray count] - i];
            }
        }
        NSString *iString = @"";
        
        NSMutableAttributedString *attributeString;
        if (IsNSStringValid(mString) && IsNSStringValid(uString)) {
            iString = [NSString stringWithFormat:@"%@, %@", mString, uString];
//            NSLog(@"%d", [aString length]);
            if ([aString length])
                iString = [iString stringByAppendingFormat:@", %@",aString];
            attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [mString length] + 1)];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange([mString length] + 2, [uString length] + 1)];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange([iString length] - [aString length], [aString length])];
        } else if (IsNSStringValid(mString) && (!IsNSStringValid(uString))) {
            iString = [NSString stringWithFormat:@"%@",mString];
            if ([aString length])
                iString = [iString stringByAppendingFormat:@", %@",aString];
            attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [iString length])];
        } else if ((!IsNSStringValid(mString)) && IsNSStringValid(uString)) {
            iString = [NSString stringWithFormat:@"%@", uString];
            if ([aString length])
                iString = [iString stringByAppendingFormat:@", %@",aString];
            attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [iString length])];
        } else {
            iString = @"";
            attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
        }
        
        
        UILabel *lblMatchingInterest = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 45.f, 205.f, 20.f)];
        [lblMatchingInterest setBackgroundColor:[UIColor clearColor]];
        [lblMatchingInterest setAttributedText:attributeString];
        [contentScrollView addSubview:lblMatchingInterest];
        
        UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
        [footerImage setFrame:CGRectMake(10, pImageView.frame.origin.y + pImageView.frame.size.height + 5, 300, 5)];
        [contentScrollView addSubview:footerImage];
        [footerImage release];
        
        UIButton *btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnProfile setFrame:CGRectMake(10, y - 5, 300, 90)];
        [btnProfile addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside];
        [btnProfile setTag:i];
        [contentScrollView addSubview:btnProfile];
        
        y += 90;
    }
    
//    
//    
//    if (placeArray != nil) {
//        [placeArray removeAllObjects];
//        [placeArray release];
//    }
//    
//    placeArray = [[NSMutableArray alloc] initWithArray:[response objectForKey:@"favorite_places"]];
//    
//    if ([placeArray count]) {
//        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 20)];
//        [lblTitle setTextColor:UIColorFromRGB(0x4A4A4A)];
//        [lblTitle setBackgroundColor:[UIColor clearColor]];
//        [lblTitle setText:@"PLACES"];
//        [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
//        [contentScrollView addSubview:lblTitle];
//        [lblTitle release];
//        
//        y += 20;
//    }
//    
//    for (int i = 0;i < [placeArray count]; i++) {
//        NSDictionary *content = [placeArray objectAtIndex:i];
//        NSLog(@"%@", content);
//        if (IsNSStringValid([content objectForKey:@"pic_small"]) && (![[content objectForKey:@"pic_small"] isEqualToString:@"null"])) {
//            
//            UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopPadding.png"]];
//            [topImageView setFrame:CGRectMake(10, y, 300, 5)];
//            [topImageView setContentMode:UIViewContentModeScaleToFill];
//            [contentScrollView addSubview:topImageView];
//            [topImageView release];
//            
//            // Calculate Content Height
//            int nHeight = 75.f;
//            UIImageView *bodyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ContentPadding.png"]];
//            [bodyImageView setFrame:CGRectMake(10, y + 5, 300, nHeight)];
//            [bodyImageView setContentMode:UIViewContentModeScaleToFill];
//            [contentScrollView addSubview:bodyImageView];
//            
//            y += 5;
//            AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(19.f, y + 5.f, 65.f, 65.f)];
//            pImageView.contentMode = UIViewContentModeScaleAspectFill;
//            pImageView.clipsToBounds = YES;
//            pImageView.bCircle = 1;
//            NSURL *imageURL = [NSURL URLWithString:[content objectForKey:@"pic_small"]];
//            pImageView.imageURL = imageURL;
//            [contentScrollView addSubview:pImageView];
//            [pImageView release];
//        
//            UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(95.f, y + 15.f, 200.f, 20.f)];
//            [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
//            [lblName setTextColor:[UIColor colorWithRed:1.f green:.35f blue:0 alpha:1.f]];
//            [lblName setText:[content objectForKey:@"name"]];
//            [contentScrollView addSubview:lblName];
//            [lblName release];
//            
//            int x = 95;
//            
//            if (IsNSStringValid([content objectForKey:@"interest"])) {
//                UILabel *lblMatchingInterest = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 45.f, 205.f, 20.f)];
//                [lblMatchingInterest setBackgroundColor:[UIColor clearColor]];
//                [lblMatchingInterest setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE]];
//                [lblMatchingInterest setText:[content objectForKey:@"interest"]];
//                [contentScrollView addSubview:lblMatchingInterest];
//            }
//            
//            UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
//            [footerImage setFrame:CGRectMake(10, y + 75.f, 300, 5)];
//            [contentScrollView addSubview:footerImage];
//            [footerImage release];
//            
//            UIButton *btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
//            [btnProfile setFrame:CGRectMake(10, y - 5, 300, 90)];
//            [btnProfile addTarget:self action:@selector(showPlace:) forControlEvents:UIControlEventTouchUpInside];
//            [btnProfile setTag:i];
//            [contentScrollView addSubview:btnProfile];
//            
//            y += 90;
//        }
//    }
    
    UIButton *favoriteFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteFacebook setFrame:CGRectMake(18.f, y, 284, 43)];
    [favoriteFacebook setImage:[UIImage imageNamed:@"FavoriteFacebookButton.png"] forState:UIControlStateNormal];
    [favoriteFacebook addTarget:self action:@selector(showFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:favoriteFacebook];

    y += 50;
    
    [contentScrollView setContentSize:CGSizeMake(320, y)];
}

- (void)showFavorite:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"InviteFBFriendViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
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

- (void)showProfile:(id)sender {
    UIButton *button = (UIButton *)sender;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [profileController setFlag:FALSE];
    
    profileController.email = [emailArray objectAtIndex:button.tag];

    [self.navigationController pushViewController:profileController animated:YES];
}

- (void)getFavoriteBy:(NSDictionary *)response {
    float y = 10;
    if ([emailArray count]) {
        [emailArray removeAllObjects];
    }
    
    for (int i = 0;i < [[response objectForKey:@"favoritedby"] count]; i++) {
        NSDictionary *content = [[response objectForKey:@"favoritedby"] objectAtIndex:i];
        [emailArray addObject:[content objectForKey:@"email"]];
        
        UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopPadding.png"]];
        [topImageView setFrame:CGRectMake(10, y, 300, 5)];
        [topImageView setContentMode:UIViewContentModeScaleToFill];
        [favoriteByScrollView addSubview:topImageView];
        [topImageView release];
        
        // Calculate Content Height
        int nHeight = 75.f;
        UIImageView *bodyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ContentPadding.png"]];
        [bodyImageView setFrame:CGRectMake(10, y + 5, 300, nHeight)];
        [bodyImageView setContentMode:UIViewContentModeScaleToFill];
        [favoriteByScrollView addSubview:bodyImageView];
        
//        UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[content objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
//        
//        y += 5;
//        UIImageView *pImageView = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//        [pImageView setFrame:CGRectMake(19.f, y + 5.f, 65.f, 65.f)];
//        [favoriteByScrollView addSubview:pImageView];
//        [pImageView release];
        
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(19, y + 5.f, 65, 65)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
        pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        NSURL *imageURL = [NSURL URLWithString:[content objectForKey:@"pic_small"]];
        pImageView.imageURL = imageURL;
        [favoriteByScrollView addSubview:pImageView];
        [pImageView release];
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(95.f, y + 15.f, 140.f, 20.f)];
        [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
        [lblName setTextColor:[UIColor colorWithRed:0 green:.6f blue:.8f alpha:1.f]];
        [lblName setText:[content objectForKey:@"first"]];
        [favoriteByScrollView addSubview:lblName];
        [lblName release];
        
        int x = 95;
        NSString *mString = [self getMatchingInterest:[content objectForKey:@"interests"]];
        NSString *uString = [self getUnmatchingInterest:[content objectForKey:@"interests"]];
        NSString *aString = @"";
        CGSize matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE]];
        
        float nWidth = 120.f;
        if (matchSize.width > nWidth) {
            NSArray *mArray = [mString componentsSeparatedByString:@", "];
            mString = [mArray objectAtIndex:0];
            matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE]];
            int i = 0;
            while ((matchSize.width < nWidth) && (i < [mArray count])) {
                i++;
                mString = [mString stringByAppendingFormat:@", %@", [mArray objectAtIndex:i]];
                matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE]];
            }
            
            aString = [NSString stringWithFormat:@"+%d", [mArray count] - i];
            uString = @"";
        } else {
            CGSize unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
            
            if (unmatchSize.width > (nWidth - matchSize.width)) {
                NSArray *uArray = [uString componentsSeparatedByString:@", "];
                uString = [uArray objectAtIndex:0];
                unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                int i = 0;
                while ((unmatchSize.width < (nWidth - matchSize.width)) && (i < [uArray count])) {
                    i++;
                    uString = [uString stringByAppendingFormat:@", %@", [uArray objectAtIndex:i]];
                    unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                }
                
                aString = [NSString stringWithFormat:@"+%d", [uArray count] - i];
            }
        }
        NSString *iString = @"";
        
        NSMutableAttributedString *attributeString;
        if (IsNSStringValid(mString) && IsNSStringValid(uString)) {
            iString = [NSString stringWithFormat:@"%@, %@", mString, uString];
            if ((aString != nil) && (IsNSStringValid(aString)))
                iString = [iString stringByAppendingFormat:@", %@",aString];
            attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [mString length] + 1)];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange([mString length] + 2, [uString length] + 1)];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange([iString length] - [aString length], [aString length])];
        } else if (IsNSStringValid(mString) && (!IsNSStringValid(uString))) {
            iString = [NSString stringWithFormat:@"%@",mString];
            if ([aString length])
                iString = [iString stringByAppendingFormat:@", %@",aString];
            attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [iString length])];
        } else if ((!IsNSStringValid(mString)) && IsNSStringValid(uString)) {
            iString = [NSString stringWithFormat:@"%@", uString];
            if ([aString length])
                iString = [iString stringByAppendingFormat:@", %@",aString];
            attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
            [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [iString length])];
        } else {
            iString = @"";
            attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
        }
        
        
        UILabel *lblMatchingInterest = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 45.f, 205.f, 20.f)];
        [lblMatchingInterest setBackgroundColor:[UIColor clearColor]];
        [lblMatchingInterest setAttributedText:attributeString];
        [favoriteByScrollView addSubview:lblMatchingInterest];
        
        
        
        UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
        [footerImage setFrame:CGRectMake(10, pImageView.frame.origin.y + pImageView.frame.size.height + 5, 300, 5)];
        [favoriteByScrollView addSubview:footerImage];
        [footerImage release];
        
        UIButton *btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnProfile setFrame:CGRectMake(10, y - 5, 300, 90)];
        [btnProfile addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside];
        [btnProfile setTag:i];
        [favoriteByScrollView addSubview:btnProfile];
        
        y += 90;
    }
    
    UIButton *favoriteFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteFacebook setFrame:CGRectMake(18.f, y, 284, 43)];
    [favoriteFacebook setImage:[UIImage imageNamed:@"FavoriteFacebookButton.png"] forState:UIControlStateNormal];
    [favoriteFacebook addTarget:self action:@selector(showFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [favoriteByScrollView addSubview:favoriteFacebook];
    
    [favoriteByScrollView setContentSize:CGSizeMake(320, y + 50)];
}

- (NSString *)getMatchingInterest:(NSArray *)interestArray {
    NSMutableArray *arrInterest = [[NSMutableArray alloc] init];
    for (NSString *interest in interestArray) {
        if ([[DataManager sharedManager].interestArray containsObject:interest]) {
            [arrInterest addObject:interest];
        }
    }
    return [arrInterest componentsJoinedByString:@", "];
}

- (NSString *)getUnmatchingInterest:(NSArray *)interestArray {
    NSMutableArray *arrInterest = [[NSMutableArray alloc] init];
    for (NSString *interest in interestArray) {
        if (![[DataManager sharedManager].interestArray containsObject:interest]) {
            [arrInterest addObject:interest];
        }
    }
    return [arrInterest componentsJoinedByString:@", "];
}

@end
