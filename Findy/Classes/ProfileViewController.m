//
//  ProfileViewController.m
//  Findy
//
//  Created by iPhone on 8/13/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "ProfileViewController.h"
#import "ChatViewController.h"
#import "MutualFriendViewController.h"
#import "PlaceProfileViewController.h"
#import "PhotoViewController.h"
#import "WebBrowserViewController.h"
#import "NSString+USStateMap.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize bMine, contentDictionary, email, bFriend, nMutualCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [Flurry logEvent:@"Profile"];
    scrollPos = 0;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"add_activity"]) {
        [self getUser];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"add_activity"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PLACE_PROFILE"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Comment_show"];
}

- (void)getUser {
    [btnMutualFriend setHidden:YES];
    [txtComment resignFirstResponder];
    [btnMoreShoutout setHidden:YES];
    bCommentShow = FALSE;
    
    for (UIView *view in contentScrollView.subviews) {
        if ((view != btnMoreShoutout) && (view != cWriteView) && (view != txtComment) && (view != btnPostComment) && (view != btnMutualFriend) && (view != lblMutualFriend)) {
            [view removeFromSuperview];
        }
    }
    
    if ((bMine) || ([email isEqualToString:[DataManager sharedManager].strEmail])) {
        [SVProgressHUD showWithStatus:@"Get My profile" maskType:SVProgressHUDMaskTypeClear];

        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:[DataManager sharedManager].strEmail forKey:@"email"];
        
        [[FindyAPI instance] getUserProfile:self withSelector:@selector(getUserProfile:) andOptions:paramDict];
    } else {
        NSString *key = @"";
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]) {
//            key = @"facebookId";
//        } else {
            key = @"email";
//        }
        
        [txtComment.layer setCornerRadius:3.f];
        [txtComment.layer setBorderWidth:.5f];
        [txtComment.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
        
        [SVProgressHUD showWithStatus:@"Get profile" maskType:SVProgressHUDMaskTypeClear];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:email forKey:key];
        
        [[FindyAPI instance] getUserProfile:self withSelector:@selector(getUserProfile:) andOptions:paramDict];
    }
}

- (void)getUserProfile:(NSDictionary *)response {
    if (contentDictionary != nil) {
        [contentDictionary release];
        contentDictionary = nil;
    }
    
    contentDictionary = [[NSDictionary alloc] initWithDictionary:response];
    
    [SVProgressHUD dismiss];
    
    if (shoutoutArray == nil) {
        shoutoutArray = [[NSMutableArray alloc] init];
    } else {
        [shoutoutArray removeAllObjects];
    }
    if ([contentDictionary objectForKey:@"shoutouts"] != [NSNull null]) {
        for (NSMutableDictionary *sDict in [contentDictionary objectForKey:@"shoutouts"]) {
            [shoutoutArray addObject:sDict];
        }
    }
    [self initProfileView];
    
//    [self performSelector:@selector(gotoChatView) withObject:nil afterDelay:0.1f];
}

- (void)gotoChatView {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ChatMessage"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        
        ChatViewController *chatController = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        //        chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];
        
        //        chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];
        chatController.partnerEmail = [contentDictionary objectForKey:@"email"];
        chatController.strTitle = [contentDictionary objectForKey:@"first"];
        chatController.leftFace = [[UIImage alloc] initWithData:UIImagePNGRepresentation(faceView.image)];
        chatController.bChatReply = FALSE;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}

ECSlidingViewTopNotificationHandlerMacro
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
     
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    nSelComment = -1;
    
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (bMine) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PLACE_PROFILE"]) {
            [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
            [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
            bBack = TRUE;
        } else {
            [backButton setImage:[UIImage imageNamed:@"SlidingButton.png"] forState:UIControlStateNormal];
            [backButton setFrame:CGRectMake(0.f, [DataManager sharedManager].fiOS7StatusHeight, 40.f, 44.f)];
            bBack = FALSE;
        }
    } else {
        bBack = TRUE;
        [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
        [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    }
    [backButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (bMine) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"PLACE_PROFILE"]) {
            [nextButton setBackgroundImage:[UIImage imageNamed:@"ShoutoutToolButton.png"] forState:UIControlStateNormal];
            [nextButton setFrame:CGRectMake(275.f, 5.f + [DataManager sharedManager].fiOS7StatusHeight, 35, 34.f)];
        }
    } else {
        [nextButton setBackgroundImage:[UIImage imageNamed:@"ChatMenuButton.png"] forState:UIControlStateNormal];
        [nextButton setFrame:CGRectMake(286.5, 9.f + [DataManager sharedManager].fiOS7StatusHeight, 28.f, 26.f)];
    }
    
    [nextButton addTarget:self action:@selector(shoutoutPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:(bMine) ? @"My Profile" : @"Profile"];
    [self.view addSubview:lblTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:txtComment];
    
    txtComment.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    txtComment.showsHorizontalScrollIndicator = NO;
    txtComment.layer.cornerRadius = 5;
    txtComment.layer.borderWidth = 1.f;
    txtComment.layer.borderColor = [UIColorFromRGB(0x9B9B9B) CGColor];
    [self resizeTextViewForText:@"" animated:YES];
    
    btnPostComment.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    btnPostComment.layer.cornerRadius = 5;
    [btnPostComment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPostComment setTitleColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [btnPostComment setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [btnPostComment setBackgroundColor:UIColorFromRGB(0xFF5C1A)];
    [btnPostComment setTitle:@"Post" forState:UIControlStateNormal];
    
    ECSlidingViewTopNotificationMacro;
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    ppArray = [[NSMutableArray alloc] initWithObjects:@"Archery", @"Cycling", @"Fitness and Workout", @"Golf", @"Hiking", @"Kiteboarding", @"Martial Arts", @"Mountain biking", @"Photography", @"Rock climbing", @"Running", @"Salsa dancing", @"Scuba diving", @"Surfing", @"Tennis", @"Yoga", nil];
    [self getUser];
}

- (BOOL)checkFavorite:(NSString *)strEmail {
    for (NSString *str in [DataManager sharedManager].favoritesArray) {
        if ([str isEqualToString:strEmail]) {
            return TRUE;
        }
    }
    
    return FALSE;
}

-(NSMutableArray *)getCommentCountAndRemoveMultiples:(NSMutableArray *)array{
    
    NSMutableArray *newArray = [[NSMutableArray alloc]initWithArray:(NSArray *)array];
    NSMutableArray *countArray = [NSMutableArray new];
    int countInt = 1;
    for (int i = 0; i < newArray.count; i++) {
        NSString *string = [[newArray objectAtIndex:i] objectForKey:@"comment_email"];
        for (int j = i+1; j < newArray.count; j++) {
            if ([string isEqualToString:[[newArray objectAtIndex:j] objectForKey:@"comment_email"]]) {
                [newArray removeObjectAtIndex:j];
                countInt++;
                j--;
            }
        }
        [countArray addObject:[NSNumber numberWithInt:countInt]];
        countInt = 1;
    }
    NSMutableArray *finalArray = [[NSMutableArray alloc] initWithObjects:newArray, countArray, nil];

    return finalArray;
    
}

-(NSMutableArray *)getCountAndRemoveMultiples:(NSMutableArray *)array{
    
    NSMutableArray *newArray = [[NSMutableArray alloc]initWithArray:(NSArray *)array];
    NSMutableArray *countArray = [NSMutableArray new];
    int countInt = 1;
    for (int i = 0; i < newArray.count; i++) {
        NSString *string = [newArray objectAtIndex:i];
        for (int j = i+1; j < newArray.count; j++) {
            if ([string isEqualToString:[newArray objectAtIndex:j]]) {
                [newArray removeObjectAtIndex:j];
                countInt++;
                j--;
            }
        }
        [countArray addObject:[NSNumber numberWithInt:countInt]];
        countInt = 1;
    }
    NSMutableArray *finalArray = [[NSMutableArray alloc] initWithObjects:newArray, countArray, nil];

    return finalArray;
    
}

- (void)initProfileView {
    [contentScrollView setFrame:CGRectMake(0, [DataManager sharedManager].fiOS7StatusHeight + 44.f, 320.f, SCREEN_HEIGHT - 44 - [DataManager sharedManager].fiOS7StatusHeight)];
    int y = (bBack) ? -20.f : 0;
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PLACE_PROFILE"]) {
//        y = -20;
//    }
    int ySpace = 5;

    for (UIView *view in contentScrollView.subviews) {
        if ((view != btnMoreShoutout) && (view != cWriteView) && (view != txtComment) && (view != btnPostComment) && (view != btnMutualFriend) && (view != lblMutualFriend)) {
            [view removeFromSuperview];
        }
    }

    UIImageView *imgWhite = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 320, 335)];
    [imgWhite setBackgroundColor:[UIColor whiteColor]];
    [contentScrollView addSubview:imgWhite];
    [imgWhite release];
    
//    NSData *backData = [NSData dataWithBase64EncodedString:[[contentDictionary objectForKey:@"pic_big"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]];
//    
////    NSLog(@"%@", [contentDictionary objectForKey:@"pic_big"]);
//    UIImageView *imgBack = [[UIImageView alloc] initWithImage:(bMine) ? [[ImageResizingUtility instance] imageByCropping:[DataManager sharedManager].imgBack _targetSize:CGSizeMake(320, 262)] : [[ImageResizingUtility instance] imageByCropping:[[UIImage alloc] initWithData:backData] _targetSize:CGSizeMake(320, 262)]];
//    [imgBack setFrame:CGRectMake(0, y, 320, 262)];
//    [contentScrollView addSubview:imgBack];
//    [imgBack release];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"update_picture"];
    AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, y, 320, 262)];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 0;
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"update_picture"]) {
//        
//        pImageView.imageURL = [NSURL URLWithString:[[contentDictionary objectForKey:@"pic_big"] stringByAppendingFormat:@"&%i", rand()]];
//    } else {
    if (bMine) {
        pImageView.imageURL = [NSURL URLWithString:[DataManager sharedManager].strPicBig];
    } else {
        pImageView.imageURL = [NSURL URLWithString:[contentDictionary objectForKey:@"pic_big"]];
    }
    
//    }
    
    [contentScrollView addSubview:pImageView];
    [pImageView release];
    
    y += 257;
    y += ySpace;
    
//    NSData *faceData = [NSData dataWithBase64EncodedString:[[contentDictionary objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]];
//    
//    UIImageView *imgFace = [[UIImageView alloc] init];
//    [imgFace setFrame:CGRectMake(5, y - 27, 80, 80)];
//    [imgFace setImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:(bMine) ? [DataManager sharedManager].imgFace : [[UIImage alloc] initWithData:faceData] withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//    [contentScrollView addSubview:imgFace];
//    [imgFace release];
    
    faceView = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, y - 12, 80, 80)];
    faceView.contentMode = UIViewContentModeScaleAspectFill;
    faceView.clipsToBounds = YES;
    faceView.bCircle = 1;
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"update_picture"];
    NSURL *imageURL;
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"update_picture"]){
//        imageURL = [NSURL URLWithString:[[contentDictionary objectForKey:@"pic_small"] stringByAppendingFormat:@"&%i", rand()]];
//        
//        
//    } else {
    if (bMine) {
        imageURL = [NSURL URLWithString:[DataManager sharedManager].strPicSmall];
    } else {
        imageURL = [NSURL URLWithString:[contentDictionary objectForKey:@"pic_small"]];
    }
    
//    }
    faceView.imageURL = imageURL;
    [contentScrollView addSubview:faceView];
    [faceView release];
    
    UIButton *btnFace = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFace setFrame:CGRectMake(5, y - 12, 80, 80)];
    [btnFace addTarget:self action:@selector(showPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:btnFace];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(93, (bMine) ? y + 15 : y + 5, 250, 18)];
    [lblName setText:[[contentDictionary objectForKey:@"first"] capitalizedString]];
    if (bMine) {
        [DataManager sharedManager].strFirstName = [contentDictionary objectForKey:@"first"];
    }
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:TITLE_FONT_SIZE]];
    [lblName sizeToFit];
    [contentScrollView addSubview:lblName];
    [lblName release];
    
    if (!bMine) {
        UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [favoriteButton setBackgroundImage:[UIImage imageNamed:@"FavoriteButton.png"] forState:UIControlStateNormal];
        [favoriteButton setBackgroundImage:[UIImage imageNamed:@"FavoriteDisableButton.png"] forState:UIControlStateSelected];
        [favoriteButton setFrame:CGRectMake(231, y + 5, 84, 33)];
        [favoriteButton addTarget:self action:@selector(favoritePressed:) forControlEvents:UIControlEventTouchUpInside];
        [contentScrollView addSubview:favoriteButton];
        
        if ([self checkFavorite:[contentDictionary objectForKey:@"email"]]) {
            [favoriteButton setSelected:YES];
        }
    }
    
    int age = 0;
    if (![[contentDictionary objectForKey:@"birthyear"] isKindOfClass:[NSNull class]]) {
        NSString *birth = [[contentDictionary objectForKey:@"birthyear"] objectForKey:@"sec"];
        [DataManager sharedManager].strBirthday = birth;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[birth longLongValue]];
        
        NSDateComponents *todayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
        NSDateComponents *birthComp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
        
        age = [todayComp year] - [birthComp year];
        
        if ([todayComp month] < [birthComp month]) {
            age --;
        } else if ([todayComp month] == [birthComp month]){
            if ([todayComp day] < [birthComp day]) {
                age--;
            }
        }
    }
//    NSString *strCity = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_STATE"];
    NSString *strGender = ([contentDictionary valueForKey:@"gender"]) ? [contentDictionary objectForKey:@"gender"] : @"%26";
    
    UILabel *lblAge = [[UILabel alloc] initWithFrame:CGRectMake(lblName.frame.origin.x + lblName.frame.size.width + 10, (bMine) ? y + 19 : y + 9, 217, 15)];
    [lblAge setBackgroundColor:[UIColor clearColor]];
    [lblAge setText:[NSString stringWithFormat:@"%@ %d", strGender, age]];
    [lblAge setFont:[UIFont fontWithName:@"HelveticaNeue" size:REPLIES_FONT_SIZE]];
    [lblAge setTextColor:UIColorFromRGB(0x4A4A4A)];
    [contentScrollView addSubview:lblAge];
    [lblAge release];

    UIImageView *imgHouse = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HouseIcon.png"]];
    [imgHouse setFrame:CGRectMake(95, (bMine) ? y + 45 : y + 32, 13, 16)];
    [contentScrollView addSubview:imgHouse];
    
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(113, (bMine) ? y + 45 : y + 32, 217, 20)];
    [lblAddress setBackgroundColor:[UIColor clearColor]];
    
    NSString *strCity = ([contentDictionary valueForKey:@"city"]) ? [contentDictionary objectForKey:@"city"] : [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_STATE"];
    NSArray *cityArray = [strCity componentsSeparatedByString:@". "];
    if ([cityArray count] < 2) {
        cityArray = [strCity componentsSeparatedByString:@", "];
    }

    if ([[cityArray lastObject] length] == 2) {
        strCity = @"";
        for (int i = 0; i < [cityArray count]; i++) {
            NSString *str = [cityArray objectAtIndex:i];
            if (i == ([cityArray count] - 1)) {
                strCity = [NSString stringWithFormat:@"%@, %@", strCity, [str uppercaseString]];
            } else {
                strCity = str;
            }
        }
    } else {
        if ([[[cityArray lastObject] lowercaseString] isEqualToString:@"california"]) {
            strCity = [NSString stringWithFormat:@"%@, %@", [cityArray objectAtIndex:0], [[cityArray objectAtIndex:1] stateAbbreviationFromFullName]];
        } else {
            strCity = [strCity capitalizedString];
        }
    }
    NSRange range = [[strCity lowercaseString] rangeOfString:@"null"];
    if (range.location != NSNotFound) {
        strCity = @"";
    }

    if (IsNSStringValid(strCity)) {
        [lblAddress setText:[NSString stringWithFormat:@"%@", strCity]];
    }
    
    NSLog(@"--%@", lblAddress.text);
    [lblAddress setFont:[UIFont fontWithName:@"HelveticaNeue" size:REPLIES_FONT_SIZE]];
    [lblAddress setTextColor:UIColorFromRGB(0x4A4A4A)];
    [contentScrollView addSubview:lblAddress];
    [lblAddress release];
    
    
    // Get Distance
    if (!bMine) {
        UIImageView *imgHouse = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LocationIcon.png"]];
        [imgHouse setFrame:CGRectMake(93, y + 54.5, 14, 15)];
        [contentScrollView addSubview:imgHouse];
        
        CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:[DataManager sharedManager].latitude
                                                             longitude:[DataManager sharedManager].longitude];
        CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:[[[contentDictionary objectForKey:@"loc"] objectAtIndex:1] floatValue]
                                                                longitude:[[[contentDictionary objectForKey:@"loc"] objectAtIndex:0] floatValue]];
        
        CLLocationDistance distance = [targetLocation distanceFromLocation:curLocation];
        
        UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(lblAddress.frame.origin.x, y + 52, 217.f, 15)];
        [lblMile setBackgroundColor:[UIColor clearColor]];
        [lblMile setText:[NSString stringWithFormat:@"%0.1fmi", distance / 1609.34]];
        [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:REPLIES_FONT_SIZE]];
        [lblMile setTextColor:UIColorFromRGB(0x4A4A4A)];
        [contentScrollView addSubview:lblMile];
        [lblMile release];
    }
    
    y += 73;
    y += ySpace;
    y += ySpace;
 
    

    if (shoutoutArray != nil) {
        if ([shoutoutArray count] > 0) {
            
            float shoutY = y + 5;
            
            UILabel *lblShout = [[UILabel alloc] initWithFrame:CGRectMake(15, shoutY, 320, 20)];
            [lblShout setTextColor:UIColorFromRGB(0x4A4A4A)];
            [lblShout setBackgroundColor:[UIColor clearColor]];
            [lblShout setText:@"SHOUT-OUTS"];
            [lblShout setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
            [lblShout sizeToFit];
            [contentScrollView addSubview:lblShout];
            [lblShout release];
            
            shoutY += lblShout.frame.size.height + ySpace + 5;
            
            int limit = 4;
            if (bMoreShoutOut) {
                limit = -1;
            }
            for (int i = [shoutoutArray count] - 1; i >= 0; i--) {
                BOOL bWrite = FALSE;
                
                if ([shoutoutArray count] - i == limit) {
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Comment_show"] && scrollPos) {
                        [btnMoreShoutout setHidden:NO];
                        [btnMoreShoutout setFrame:CGRectMake(10, shoutY, 300, 46)];
                        shoutY += 46 + ySpace;
                        y = shoutY;
                        break;
                    }
                }
                
                y = shoutY;
                UIImageView *imgShoutBack = [[UIImageView alloc] initWithFrame:CGRectMake(10, shoutY, 300, 0)];
                [imgShoutBack setBackgroundColor:[UIColor whiteColor]];
                [imgShoutBack.layer setCornerRadius:2.f];
                [imgShoutBack.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
                [imgShoutBack.layer setBorderWidth:.5f];
                [imgShoutBack.layer setMasksToBounds:YES];
                [contentScrollView addSubview:imgShoutBack];
                
                
                NSDictionary *sDict = [shoutoutArray objectAtIndex:i];
                if ([[sDict objectForKey:@"shout"] isEqualToString:@""]) {
                    limit ++;
                    continue;
                }
                
                if (!bMine) {
                    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [replyButton setBackgroundImage:[UIImage imageNamed:@"ReplyButton.png"] forState:UIControlStateNormal];
                    [replyButton setFrame:CGRectMake(211, shoutY + 5, 94, 32)];
                    [replyButton addTarget:self action:@selector(replyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [replyButton setTag:100 + i];
                    [contentScrollView addSubview:replyButton];
                }

                // Title
                shoutY += 15;
                UILabel *shoutTitle = [[UILabel alloc] initWithFrame:CGRectMake(25, shoutY - 5, 150, 20)];
                NSString *interest = [sDict objectForKey:@"interest"];
                interest = [interest stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
                interest = [interest stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
                if ([interest isEqualToString:@"Ballroomdancing"]) {
                    interest = @"Ballroom dancing";
                }
                if ([interest isEqualToString:@"Rockclimbing"]) {
                    interest = @"Rock climbing";
                }
                [shoutTitle setText:interest];
                [shoutTitle setBackgroundColor:[UIColor clearColor]];
                [shoutTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:INTEREST_FONT_SIZE]];
                [shoutTitle sizeToFit];
                [contentScrollView addSubview:shoutTitle];

                // Time
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[sDict objectForKey:@"time"] longLongValue]];

                NSDate *curDate = [NSDate date];

                NSTimeInterval interval = [curDate timeIntervalSinceDate:date];
                NSInteger ti = abs((NSInteger)interval);

                NSInteger seconds = ti % 60;
                NSInteger minutes = (ti / 60) % 60;
                NSInteger hours = (ti / 3600);
                NSInteger day = ti / 86400;
                NSInteger month = day / 2592000;

                UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(shoutTitle.frame.origin.x + shoutTitle.frame.size.width + 5, shoutTitle.frame.origin.y + 3, 300 - shoutTitle.frame.size.width - 25, 20.f)];
                [lblTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
                [lblTime setTextColor:UIColorFromRGB(0x4A4A4A)];

                NSString *strTime;
                if (month) {
                    strTime = [NSString stringWithFormat:@"%iM ago", month];
                } else {
                    if (day) {
                        strTime = [NSString stringWithFormat:@"%id ago", day];
                    } else {
                        if (hours) {
                            strTime = [NSString stringWithFormat:@"%ih ago", hours];
                        } else {
                            if (minutes) {
                                strTime = [NSString stringWithFormat:@"%im ago", minutes];
                            } else {
                                if (seconds) {
                                    strTime = [NSString stringWithFormat:@"%is ago", seconds];
                                } else {
                                    strTime = @"";
                                }
                            }
                        }
                    }
                }
                [lblTime setText:strTime];
                [lblTime sizeToFit];
                if ((lblTime.frame.origin.x + lblTime.frame.size.width) > 205) {
                    [lblTime setFrame:CGRectMake(35, shoutTitle.frame.origin.y + shoutTitle.frame.size.height, 250, 20.f)];
                    shoutY += 3;
                    [lblTime sizeToFit];
                }
                [contentScrollView addSubview:lblTime];

                shoutY += (lblTime.frame.origin.y - shoutY) + lblTime.frame.size.height + ySpace + ySpace + ySpace;
                
                UIImageView *imgShoutMini = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShoutOutMini.png"]];
                [imgShoutMini setFrame:CGRectMake(20, shoutY, imgShoutMini.frame.size.width, imgShoutMini.frame.size.height)];
                [contentScrollView addSubview:imgShoutMini];

                
                float sHeight = 0;
                if (IS_IOS7) {
                    UITextView *shoutBody = [[UITextView alloc] initWithFrame:CGRectMake(23 + imgShoutMini.frame.size.width, imgShoutMini.frame.origin.y - 2, 255, 0)];
                    [shoutBody setEditable:YES];
                    [shoutBody setScrollEnabled:YES];
                    [shoutBody setDelegate:self];
                    [shoutBody setBackgroundColor:[UIColor clearColor]];
                    [shoutBody setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                    [shoutBody setText:[sDict objectForKey:@"shout"]];
                    [shoutBody setDataDetectorTypes:UIDataDetectorTypeCalendarEvent | UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber];
                    [contentScrollView addSubview:shoutBody];
                    [shoutBody sizeToFit];
                    [shoutBody release];
                    [imgShoutMini release];
                    [shoutBody setContentInset:UIEdgeInsetsMake(-8, -3, 0, 0)];
                    
                    [shoutBody setEditable:NO];
                    [shoutBody setScrollEnabled:NO];
                    
                    sHeight = shoutBody.frame.size.height;
                } else {
                    UILabel *shoutBody = [[UILabel alloc] initWithFrame:CGRectMake(23 + imgShoutMini.frame.size.width, imgShoutMini.frame.origin.y - 2, 255, 0)];
                    [shoutBody setBackgroundColor:[UIColor clearColor]];
                    [shoutBody setNumberOfLines:10000];
                    [shoutBody setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                    [shoutBody setText:[sDict objectForKey:@"shout"]];
                    [contentScrollView addSubview:shoutBody];
                    [shoutBody sizeToFit];
                    [shoutBody release];
                    [imgShoutMini release];
                    sHeight = shoutBody.frame.size.height + 10;
                }
                
                

//                CGSize size = [[sDict objectForKey:@"shout"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]
//                              constrainedToSize:CGSizeMake(255, 1000)];
//
//                CGRect frame = shoutBody.frame;
//                frame.size.height = size.height + 10;
//                shoutBody.frame = frame;
                
                
//                float tmpHeight = ((size.height < 33) && (size.height > 20)) ? 10 + 10 * (int)(size.height / 16.f)  : 10;
                float tmpHeight = 10;
                shoutY += sHeight - tmpHeight;

                if (([sDict valueForKey:@"place_link"] && IsNSStringValid([sDict objectForKey:@"place_link"])) || ([sDict valueForKey:@"deal_link"] && IsNSStringValid([sDict objectForKey:@"deal_link"]))) {
                 
                    UILabel *lblAttach = [[UILabel alloc] initWithFrame:CGRectMake(35, shoutY, 300, 15)];
                    
                    NSString *attTitle = (IsNSStringValid([sDict valueForKey:@"place_link"])) ? @"Attached place" : @"Attached deal";
                    
                    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:attTitle];
                    [aString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, [aString  length])];
                    [aString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:12.f] range:NSMakeRange(0, [aString  length])];
                    [lblAttach setAttributedText:aString];
                    [lblAttach setTextColor:UIColorFromRGB(0x757171)];
                    [contentScrollView addSubview:lblAttach];
                    [lblAttach release];
                    
                    shoutY += 25;
                    
                    AsyncImageView *aImgView = [[AsyncImageView alloc] initWithFrame:CGRectMake(25.f, shoutY, 40.f, 40.f)];
                    aImgView.contentMode = UIViewContentModeScaleAspectFill;
                    aImgView.clipsToBounds = YES;
                    aImgView.bCircle = 1;
//                    NSLog(@"%@", sDict);
                    if (IsNSStringValid([sDict objectForKey:@"attach_image_url"])) {
                        aImgView.imageURL = [NSURL URLWithString:[sDict objectForKey:@"attach_image_url"]];
                    }
                    [contentScrollView addSubview:aImgView];
                    [aImgView release];
                    
                    UILabel *lblAttachTitle = [[UILabel alloc] initWithFrame:CGRectMake(75.f, shoutY, 240.f, 20)];
                    [lblAttachTitle setTextColor:[UIColor colorWithRed:1.f green:74 / 255.f blue:0 alpha:1.f]];
                    [lblAttachTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f]];
                    if (IsNSStringValid([sDict objectForKey:@"attach_title"]))
                        [lblAttachTitle setText:[[sDict objectForKey:@"attach_title"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
                    [contentScrollView addSubview:lblAttachTitle];
                    [lblAttachTitle release];
                    
                    UILabel *lblAttachDetail = [[UILabel alloc] initWithFrame:CGRectMake(75.f, shoutY + 18.f, 215.f, 20)];
                    [lblAttachDetail setTextColor:[UIColor darkGrayColor]];
                    [lblAttachDetail setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.f]];
                    if (IsNSStringValid([sDict objectForKey:@"attach_detail"]))
                        [lblAttachDetail setText:[[sDict objectForKey:@"attach_detail"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
                    [contentScrollView addSubview:lblAttachDetail];
                    [lblAttachDetail release];
                    
                    UIButton *btnAttach = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btnAttach setFrame:CGRectMake(25.f, shoutY, 275.f, 40.f)];
                    [btnAttach addTarget:self action:@selector(attachClick:) forControlEvents:UIControlEventTouchUpInside];
                    [btnAttach setTag:i];
                    [contentScrollView addSubview:btnAttach];
                    
                    //                    }
                    
                    shoutY += 50;
                }
                
                
                UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line.png"]];
                [lineView setFrame:CGRectMake(10, shoutY, 300, 1)];
                [contentScrollView addSubview:lineView];
                
                shoutY += ySpace + ySpace;
               
                // Replies, Comment View
                if (ISNSArrayValid([sDict objectForKey:@"replies"]) || ISNSArrayValid([sDict objectForKey:@"comments"]) || (bCommentShow && (i == nSelComment - 200))) {
                    
                    NSMutableArray *replyArray = [self getCountAndRemoveMultiples:[sDict objectForKey:@"replies"]];
                    NSMutableArray *commentArray = [self getCommentCountAndRemoveMultiples:[sDict objectForKey:@"comments"]];
                    
                    float x = 20.f;
                    float tmpY = 0;
                    if (ISNSArrayValid([sDict objectForKey:@"replies"])) {
                        NSString *replyString = [NSString stringWithFormat:@"%d Chat Replied", [[replyArray objectAtIndex:0] count]];
                        CGSize size = [replyString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE] forWidth:80.f lineBreakMode:NSLineBreakByWordWrapping];
                        
                        UILabel *lblReply = [[UILabel alloc] initWithFrame:CGRectMake(x, shoutY + (26 - size.height) / 2.f, size.width, size.height)];
                        [lblReply setText:replyString];
                        [lblReply setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
                        [contentScrollView addSubview:lblReply];
                        [lblReply release];
                        
                        x += lblReply.frame.size.width + 15;
                        tmpY = 33;
                    }
                    
                    if (ISNSArrayValid([sDict objectForKey:@"comments"])) {
                        UIButton *btnCommentWrite = [UIButton buttonWithType:UIButtonTypeCustom];
                        [btnCommentWrite setFrame:CGRectMake(x, shoutY, 80, 27)];
                        [btnCommentWrite.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
                        [btnCommentWrite setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btnCommentWrite setTitle:[NSString stringWithFormat:@"%d Commented", [[commentArray objectAtIndex:0] count]] forState:UIControlStateNormal];
                        [btnCommentWrite.titleLabel sizeToFit];
                        [btnCommentWrite addTarget:self action:@selector(commentPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCommentWrite setTag:(200 + i)];
                        [contentScrollView addSubview:btnCommentWrite];
                        
                        x += btnCommentWrite.frame.size.width + 15;
                        tmpY = 33;
                    }
                    
                    if (((i == nSelComment - 200) && (bCommentShow == TRUE))  || ([[NSUserDefaults standardUserDefaults] boolForKey:@"Comment_show"] && ([[sDict objectForKey:@"shout"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"Comment_text"]]))) {
                        if (([[NSUserDefaults standardUserDefaults] boolForKey:@"Comment_show"] && ([[sDict objectForKey:@"shout"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"Comment_text"]]))) {
                            scrollPos = shoutY - 50;
                            bCommentShow = TRUE;
                            nSelComment = 200 + i;
                        }
                        
                        shoutY += tmpY;
                        for (int p = 0; p < [[sDict objectForKey:@"comments"] count]; p++) {
                            NSDictionary *cDict = [[sDict objectForKey:@"comments"] objectAtIndex:p];

                            UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line.png"]];
                            [lineView setFrame:CGRectMake(10, shoutY, 300, 1)];
                            [contentScrollView addSubview:lineView];
                            
                            shoutY += 10;
                            
//                            UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[cDict objectForKey:@"comment_pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
//
//                            UIImageView *imgFace = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//                            [imgFace setFrame:CGRectMake(20, shoutY, 45, 45)];
//                            [contentScrollView addSubview:imgFace];
                            
                            AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(20, shoutY, 45, 45)];
                            pImageView.contentMode = UIViewContentModeScaleAspectFill;
                            pImageView.clipsToBounds = YES;
                            pImageView.bCircle = 1;
                            pImageView.imageURL = [NSURL URLWithString:[cDict objectForKey:@"comment_pic_small"]];
                            [contentScrollView addSubview:pImageView];
                            [pImageView release];
                            
                            UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                            [commentBtn setFrame:pImageView.frame];
                            [commentBtn setTag:p];
                            [commentBtn addTarget:self action:@selector(commentProfileSelect:) forControlEvents:UIControlEventTouchUpInside];
                            [contentScrollView addSubview:commentBtn];
                            NSLog(@"%@", cDict);
                            UILabel *lblCommentName = [[UILabel alloc] initWithFrame:CGRectMake(75, shoutY, 220, 20)];
                            [lblCommentName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:INTEREST_FONT_SIZE]];
                            [lblCommentName setText:[cDict objectForKey:@"comment_first"]];
                            [lblCommentName sizeToFit];
                            [contentScrollView addSubview:lblCommentName];
                            [lblCommentName release];

                            shoutY += lblCommentName.frame.size.height + 5;
                            
                            float fCommentHeight = 0;
                            if (IS_IOS7) {
                                UITextView *lblComment = [[UITextView alloc] initWithFrame:CGRectMake(75, shoutY, 220, 20)];
                                [lblComment setEditable:NO];
                                [lblComment setDelegate:self];
                                [lblComment setBackgroundColor:[UIColor clearColor]];
                                [lblComment setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                                [lblComment setText:[cDict objectForKey:@"comment_text"]];
                                [lblComment setDataDetectorTypes:UIDataDetectorTypeCalendarEvent | UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber];
                                
                                [contentScrollView addSubview:lblComment];
                                [lblComment sizeToFit];
                                [lblComment release];
                                
                                [lblComment setContentInset:UIEdgeInsetsMake(-8, -3, 0, 0)];
                                [lblComment setScrollEnabled:NO];
                                
                                fCommentHeight = lblComment.frame.size.height;
                                shoutY += fCommentHeight;
                            } else {
                                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(75, shoutY, 220, 20)];
                                [lblComment setNumberOfLines:10000];
                                [lblComment setBackgroundColor:[UIColor clearColor]];
                                [lblComment setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                                [lblComment setText:[cDict objectForKey:@"comment_text"]];
                                
                                [contentScrollView addSubview:lblComment];
                                [lblComment sizeToFit];
                                [lblComment release];
                                
                                fCommentHeight = lblComment.frame.size.height;
                                shoutY += fCommentHeight + 5;
                            }
                        }
                        
                        [cWriteView setHidden:NO];
                        [contentScrollView bringSubviewToFront:cWriteView];
                        [self changeFrame:cWriteView.frame.size.height _type:1 _y:shoutY];
                        [cWriteView bringSubviewToFront:txtComment];
                        [cWriteView bringSubviewToFront:btnPostComment];
                        bWrite = TRUE;
                        
                        shoutY += cWriteView.frame.size.height;
                    } else {
                        if (bCommentShow == FALSE) {
                            [cWriteView setHidden:YES];
                        }

                        UIButton *btnComment = [UIButton buttonWithType:UIButtonTypeCustom];
                        [btnComment setFrame:CGRectMake(x, shoutY, 63, 27)];
                        [btnComment.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MILES_FONT_SIZE]];
                        [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        [btnComment setTitle:@"Comment" forState:UIControlStateNormal];
                        [btnComment addTarget:self action:@selector(commentPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnComment setTag:(200 + i)];
                        [contentScrollView addSubview:btnComment];

                        shoutY += 33.f;
                    }
                } else {
                    if (bCommentShow == FALSE) {
                        [cWriteView setHidden:YES];
                    }
                    
                    UIButton *btnComment = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btnComment setFrame:CGRectMake(20, shoutY, 280, 27)];
                    [btnComment.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:MILES_FONT_SIZE]];
                    [btnComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btnComment setTitle:@"Comment" forState:UIControlStateNormal];
                    [btnComment addTarget:self action:@selector(commentPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [btnComment setTag:(200 + i)];
                    [contentScrollView addSubview:btnComment];
                    
                    shoutY += 33;
                }
                
                [imgShoutBack setFrame:CGRectMake(10, imgShoutBack.frame.origin.y, 300, shoutY - y)];
                
                shoutY += ySpace * 2;
            }
            
            y = shoutY + ySpace;
        }
    }
    
    interestView = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320, 0)];
    [contentScrollView addSubview:interestView];
    
    y += ySpace;
    int y0 = y;
//    if ((![[contentDictionary valueForKey:@"facebookId"] isEqualToString:@"(null)"]) && (![[contentDictionary valueForKey:@"facebookId"] isEqualToString:@" "])) {
//        if ([[[DataManager sharedManager].mutualDict objectForKey:[contentDictionary objectForKey:@"facebookId"]] intValue] > 0) {
    if (!bMine) {
        [btnMutualFriend setHidden:NO];
        [btnMutualFriend setFrame:CGRectMake(10, y, 300, 46)];
        
        [lblMutualFriend setHidden:NO];
        [lblMutualFriend setFrame:CGRectMake(220, y, 60, 46)];
        y += 46 + ySpace;
    }
//        }
//    }

    
    NSString *strPopular;
    if (bMine) {
        strPopular = @"MY FAVORITE ACTIVITIES";
        y -= 20;
    } else {
        strPopular = @"FAVORITE ACTIVITIES";
        y -= 20;
    }
    
    UILabel *lblPopular = [[UILabel alloc] initWithFrame:CGRectMake(15, y - y0 + 35, 320, 20)];
    [lblPopular setTextColor:UIColorFromRGB(0x4A4A4A)];
    [lblPopular setBackgroundColor:[UIColor clearColor]];
    [lblPopular setText:strPopular];
    [lblPopular setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
    [lblPopular sizeToFit];
    [interestView addSubview:lblPopular];
    [lblPopular release];
    
    y += 50;
    y += ySpace;

//    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopPadding.png"]];
//    [topImageView setFrame:CGRectMake(10, y - y0, 300, 5)];
//    [topImageView setContentMode:UIViewContentModeScaleToFill];
//    [interestView addSubview:topImageView];
//    [topImageView release];
    
    // Calculate Content Height
    UIImageView *bodyImageView = [[UIImageView alloc] init];
    int nHeight = 0;
    [bodyImageView setBackgroundColor:[UIColor whiteColor]];
    [bodyImageView setFrame:CGRectMake(10, y - y0 + 5, 300, 0)];
    [bodyImageView setContentMode:UIViewContentModeScaleToFill];
    [interestView addSubview:bodyImageView];
    
    y += 5;
    
    
    for (int i = 0; i < [[contentDictionary objectForKey:@"interests"] count]; i++) {
        NSString *interest = [[[contentDictionary objectForKey:@"interests"] objectAtIndex:i] stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
        if ([interest isEqualToString:@"Fitness & Workout"]) {
            continue;
        }
        UILabel *lblInterest = [[UILabel alloc] initWithFrame:CGRectMake(25, y - y0, 270, 32)];
        [lblInterest setText:interest];
        [lblInterest setBackgroundColor:[UIColor clearColor]];
        [lblInterest setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:INTEREST_FONT_SIZE]];
        [lblInterest sizeToFit];
        [lblInterest setFrame:CGRectMake(lblInterest.frame.origin.x, lblInterest.frame.origin.y, lblInterest.frame.size.width, 32)];
        [interestView addSubview:lblInterest];
        
        if ([[DataManager sharedManager].interestArray containsObject:interest]) {
            UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(lblInterest.frame.origin.x + lblInterest.frame.size.width + 5, lblInterest.frame.origin.y + 12.5, 10, 7)];
            [imgCheck setImage:[UIImage imageNamed:@"ActivityCheck.png"]];
            [interestView addSubview:imgCheck];
        }
        
        y += 32;
        if (i != ([[contentDictionary objectForKey:@"interests"] count] - 1)) {
            UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line.png"]];
            [lineView setFrame:CGRectMake(10, lblInterest.frame.origin.y + lblInterest.frame.size.height, 300, 1)];
            [interestView addSubview:lineView];
            [lineView release];
            
            y += 1;
            nHeight += 33;
        } else {
            nHeight += 32;
        }
        [lblInterest release];
    }
    
    [bodyImageView setFrame:CGRectMake(10, bodyImageView.frame.origin.y, 300, nHeight)];
    
    // Add Footer Image
//    UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
//    [footerImage setFrame:CGRectMake(10, bodyImageView.frame.origin.y + nHeight, 300, 5)];
//    [interestView addSubview:footerImage];
//    [footerImage release];
//    [bodyImageView release];
    
    y += 10;
    y += ySpace;
    
    if (bMine) {
        UIButton *btnAddInterest = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAddInterest setBackgroundImage:[UIImage imageNamed:@"AddInterestButton.png"] forState:UIControlStateNormal];
        [btnAddInterest setFrame:CGRectMake(170, y - y0 , 139, 40)];
        [btnAddInterest addTarget:self action:@selector(addInterest) forControlEvents:UIControlEventTouchUpInside];
        [interestView addSubview:btnAddInterest];
        
        y += 35;
    }
    
    y += ySpace;
    [interestView setFrame:CGRectMake(0, interestView.frame.origin.y, 320, y - interestView.frame.origin.y)];
    [contentScrollView bringSubviewToFront:btnMutualFriend];
    
    NSString *fbID = [contentDictionary objectForKey:@"facebookId"];

    if ([[DataManager sharedManager].mutualDict valueForKey:fbID]) {
        nMutualCount = [[[DataManager sharedManager].mutualDict objectForKey:fbID] intValue];
        if (nMutualCount != 0) {
            [lblMutualFriend setHidden:NO];
            [lblMutualFriend setText:[NSString stringWithFormat:@"%d", nMutualCount]];
        }
    } else {
        [lblMutualFriend setHidden:YES];
        [lblMutualFriend setText:@"0"];
    }
    
    if (nMutualCount == 0) {
        [lblMutualFriend setHidden:YES];
    }
    [contentScrollView bringSubviewToFront:lblMutualFriend];
    [contentScrollView setContentSize:CGSizeMake(320, y)];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Comment_show"]) {
        [contentScrollView setContentOffset:CGPointMake(0, scrollPos)];
    } else {
        [contentScrollView setScrollsToTop:YES];
    }
    [contentScrollView bringSubviewToFront:cWriteView];
}

- (void)showPhoto:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    PhotoViewController *photoViewController = (PhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    photoViewController.strPhoto = [contentDictionary objectForKey:@"pic_small"];
    [self.navigationController pushViewController:photoViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [contentScrollView release];
    [btnMoreShoutout release];
    [contentDictionary release];
    [cWriteView release];
    [txtComment release];
    [btnPostComment release];
    [btnMutualFriend release];
    [lblMutualFriend release];
    [super dealloc];
}

- (void)postCommentResult:(NSDictionary *)response {
//    NSLog(@"%@", response);
}

- (void)changeFrame:(float)nHeight _type:(int)type _y:(float)y {
    if (nHeight == 44) {
        [txtComment setFrame:CGRectMake(10, 10, 220, 27)];
        [btnPostComment setFrame:CGRectMake(243, 8, 45, 28)];
    } else if (nHeight == 66) {
        [txtComment setFrame:CGRectMake(10, 10, 220, 47)];
        [btnPostComment setFrame:CGRectMake(243, 19, 45, 28)];
    }
    
    [cWriteView setFrame:CGRectMake(10, y, 300, nHeight)];
}

#pragma mark - UIButton Touch Event
- (void)commentPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (nSelComment < 100) {
        bCommentShow = TRUE;
    }
    
    if (nSelComment == button.tag) {
        bCommentShow = !bCommentShow;
    }
    
    nSelComment = button.tag;
    
    for (UIView *view in contentScrollView.subviews) {
        if ((view != btnMoreShoutout) && (view != cWriteView) && (view != txtComment) && (view != btnPostComment) && (view != btnMutualFriend) && (view != lblMutualFriend)) {
            [view removeFromSuperview];
        }
    }
        
    [self initProfileView];
    
//    NSLog(@"Comment");
}

- (void)revealMenu:(id)sender {
    if (bBack) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
}

- (void)shoutoutPressed:(id)sender {
    if (bMine) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        UIViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"ShoutOutViewController"];
        [self.navigationController pushViewController:interstViewController animated:YES];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        
        
        ChatViewController *chatController = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
//        chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];

//        chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];
        chatController.partnerEmail = [contentDictionary objectForKey:@"email"];
        chatController.strTitle = [contentDictionary objectForKey:@"first"];
        chatController.leftFace = [[UIImage alloc] initWithData:UIImagePNGRepresentation(faceView.image)];
        chatController.bChatReply = FALSE;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}

- (IBAction)dismissKeyboard:(id)sender {
    [txtComment resignFirstResponder];
    [contentScrollView setFrame:CGRectMake(0, [DataManager sharedManager].fiOS7StatusHeight + 44.f, 320.f, SCREEN_HEIGHT - 44 - [DataManager sharedManager].fiOS7StatusHeight)];
//    [self initProfileView];
}

- (IBAction)mutualFriend:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    MutualFriendViewController *mutualVieController = [storyboard instantiateViewControllerWithIdentifier:@"MutualFriendViewController"];
    mutualVieController.uID = [contentDictionary objectForKey:@"facebookId"];
    [self.navigationController pushViewController:mutualVieController animated:YES];
}

- (IBAction)viewMoreShoutOut:(id)sender {
    bMoreShoutOut = TRUE;
    [btnMoreShoutout setHidden:YES];
    [self initProfileView];
}
- (void)commentProfileSelect:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PLACE_PROFILE"];
    UIButton *button = (UIButton *)sender;
    NSDictionary *shoutDict = [shoutoutArray objectAtIndex:nSelComment - 200];
    NSDictionary *comment = [[shoutDict objectForKey:@"comments"] objectAtIndex:button.tag];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    if ([[comment objectForKey:@"comment_email"] isEqualToString:[DataManager sharedManager].strEmail]) {
        [profileController setFlag:TRUE];
    } else {
        [profileController setFlag:FALSE];
    }
    
    profileController.email = [comment objectForKey:@"comment_email"];
    
    [self.navigationController pushViewController:profileController animated:YES];
}

- (IBAction)postCommentPressed:(id)sender {
    [txtComment resignFirstResponder];
    [contentScrollView setFrame:CGRectMake(0, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320, SCREEN_HEIGHT - 44 - [DataManager sharedManager].fiOS7StatusHeight)];
    NSDictionary *shoutDict = [shoutoutArray objectAtIndex:nSelComment - 200];
    
    NSString *comment = txtComment.text;
    
    NSMutableArray *commentArray;
    if ([shoutDict valueForKey:@"comments"] == nil) {
        commentArray = [[NSMutableArray alloc] init];
    } else {
        commentArray = [[NSMutableArray alloc] initWithArray:[shoutDict objectForKey:@"comments"]];
    }
    
    if ([txtComment.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please input comment" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    } else {
        /*
         *  email // e-mail of the user with the shoutout
         *  shout // text of the shoutout
         *  interest // interest of the shoutout
         *  comment_email // email of the person making a comment
         *  comment_text // text of the comment from the person making the comment
         */
        NSString *pComment = [comment stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[contentDictionary objectForKey:@"email"], [shoutDict objectForKey:@"shout"], [shoutDict objectForKey:@"interest"], [DataManager sharedManager].strEmail, pComment, nil]
                                                                            forKeys:[NSArray arrayWithObjects:@"email", @"shout", @"interest", @"comment_email", @"comment_text", nil]];
        [[FindyAPI instance] postComment:self withSelector:@selector(postCommentResult:) andOptions:paramDict];
    }
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss MM/dd/yyyy"];
    
    NSString *strTime = [dateFormat stringFromDate:today];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, [DataManager sharedManager].strFirstName, [DataManager sharedManager].strPicSmall, comment, strTime, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"comment_email", @"comment_first", @"comment_pic_small", @"comment_text", @"comment_time",nil]];
    [commentArray addObject:paramDict];

    NSMutableDictionary *commentDict;
//    NSLog(@"%@", shoutDict);
    if (IsNSStringValid([shoutDict valueForKey:@"attach_title"])) {
        commentDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                  commentArray,
                                                                  [shoutDict objectForKey:@"interest"],
                                                                  [shoutDict objectForKey:@"shout"],
                                                                  [shoutDict objectForKey:@"time"],
                                                                  [shoutDict objectForKey:@"attach_title"],
                                                                  [shoutDict objectForKey:@"attach_detail"],
                                                                  [shoutDict objectForKey:@"attach_url"],
                                                                  [shoutDict objectForKey:@"attach_image_url"],
                                                                  [shoutDict objectForKey:@"deal_link"],
                                                                  [shoutDict objectForKey:@"place_link"],
                                                                  nil]
                                                         forKeys:[NSArray arrayWithObjects:@"comments", @"interest", @"shout", @"time", @"attach_title", @"attach_detail", @"attach_url", @"attach_image_url", @"deal_link", @"place_link", nil]];
    } else {
        commentDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:commentArray, [shoutDict objectForKey:@"interest"], [shoutDict objectForKey:@"shout"], [shoutDict objectForKey:@"time"], nil] forKeys:[NSArray arrayWithObjects:@"comments", @"interest", @"shout", @"time", nil]];
    }
 
    if (bMine) {
        [shoutoutArray replaceObjectAtIndex:nSelComment - 200 withObject:commentDict];
    } else {
        [shoutoutArray replaceObjectAtIndex:nSelComment - 200 withObject:commentDict];
    }
    
    [txtComment setText:@""];
    [self changeFrame:44 _type:1 _y:cWriteView.frame.origin.y];
    [self initProfileView];
}

- (void)addInterest {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"add_activity"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ShoutOut"];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
//                                                         bundle: nil];
//    UIViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"AllInterestViewController"];
//    [self.navigationController pushViewController:profileViewController animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"AddInterestViewController"];
    [self.navigationController pushViewController:interstViewController animated:YES];
}

- (void)favoritePressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    if (button.selected) {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                                       [DataManager sharedManager].strEmail,
                                                                                       [contentDictionary objectForKey:@"email"], nil]
                                                                              forKeys:[NSArray arrayWithObjects:
                                                                                       @"email", @"favorite", nil]];
        [[FindyAPI instance] addFavorite:self withSelector:@selector(favoriteResult:) andOptions:paramDict];
        
        [[DataManager sharedManager].favoritesArray addObject:[contentDictionary objectForKey:@"email"]];
        
        
        [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"favorite_people_count"] + 1 forKey:@"favorite_people_count"];
        
        int favCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"favorite_people_count"];
        if ((([[[DataManager sharedManager] favoritesArray] count] == 1) && ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_FIRST_FAVORITE_PEOPLE"])) || (favCount == 5)){
//            [[Kiip sharedInstance] saveMoment:@"Favoriting! Keep it On!" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
//                if (error) {
//                    NSLog(@"something's wrong");
//                    // handle with an Alert dialog.
//                }
//                if (poptart) {
//                    [poptart show];
//                }
//                if (!poptart) {
//                    // handle logic when there is no reward to give.
//                }
//            }];
        }
    } else {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                                       [DataManager sharedManager].strEmail,
                                                                                       [contentDictionary objectForKey:@"email"], nil]
                                                                              forKeys:[NSArray arrayWithObjects:
                                                                                       @"email", @"favorite", nil]];
        [[FindyAPI instance] removeFavorite:self withSelector:@selector(favoriteResult:) andOptions:paramDict];
        [[DataManager sharedManager].favoritesArray removeObject:[contentDictionary objectForKey:@"email"]];
    }
}

- (void)favoriteResult:(NSDictionary *)response {
//    NSLog(@"%@", response);
}

- (void)replyButtonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *shoutDict = [shoutoutArray objectAtIndex:button.tag - 100];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                        bundle: nil];
    
    ChatViewController *chatController = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
//    chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];
    chatController.shoutInterest = [shoutDict objectForKey:@"interest"];
    chatController.shoutoutText = [shoutDict objectForKey:@"shout"];
    chatController.partnerEmail = [contentDictionary objectForKey:@"email"];
    chatController.strTitle = [contentDictionary objectForKey:@"first"];
    chatController.leftFace = [[UIImage alloc] initWithData:UIImagePNGRepresentation(faceView.image)];
    chatController.bChatReply = TRUE;
    [self.navigationController pushViewController:chatController animated:YES];
}

- (void)setFlag:(BOOL)flag {
    self.bMine = flag;
}
- (void)setContentValue:(NSDictionary *)cDict {
    self.contentDictionary = [[NSDictionary alloc] initWithDictionary:cDict];
}

- (void)attachClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *content = [shoutoutArray objectAtIndex:button.tag];
    
    if ([content valueForKey:@"place_link"] && IsNSStringValid([content valueForKey:@"place_link"])) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        
        PlaceProfileViewController *profileController = (PlaceProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaceProfileViewController"];
        
        profileController.strTitle = ([content valueForKey:@"attach_title"] && IsNSStringValid([content valueForKey:@"attach_title"])) ? [[content objectForKey:@"attach_title"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "] : @"";
        //    profileController.contentDictionary = [placesArray objectAtIndex:[sButton tag]];
        profileController.strInterest = [content objectForKey:@"interest"];
        profileController.strID = [content objectForKey:@"place_link"];
        [self.navigationController pushViewController:profileController animated:YES];
        
    } else if ([content valueForKey:@"deal_link"] && IsNSStringValid([content valueForKey:@"deal_link"])) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
        webBrowser.urlString = [content objectForKey:@"deal_link"];
        webBrowser.viewTitle = [[content objectForKey:@"attach_title"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        webBrowser.subTitle = [[content objectForKey:@"attach_detail"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        webBrowser.strType = @"GROUPON";
        [self.navigationController pushViewController:webBrowser animated:YES];
    }
    
//    NSLog(@"%@", content);
}

#pragma mark - UITextView Delegate

- (void)textViewTextDidChange:(NSNotification*)notification {
    [contentScrollView bringSubviewToFront:txtComment];
    NSString* newText = txtComment.text;
    
    [self resizeTextViewForText:newText animated:YES];
    [txtComment setContentOffset:CGPointMake(0, txtComment.contentSize.height - txtComment.frame.size.height)];
    NSLog(@"%@", newText);
}

- (void)resizeTextViewForText:(NSString*)text animated:(BOOL)animated {
    
    const int kComposerBackgroundTopPadding = 5;
    const int kComposerBackgroundBottomPadding = 5;
    const int kTextViewMaxHeight = 180;
    
    CGFloat fixedWidth = txtComment.frame.size.width;
    CGSize oldSize = txtComment.frame.size;
    CGSize newSize = [txtComment sizeThatFits:CGSizeMake(fixedWidth, kTextViewMaxHeight)];
    
    if (newSize.height > kTextViewMaxHeight) {
        newSize.height = oldSize.height;
    }
    
    // If the height doesn't need to change skip reconfiguration.
    if (oldSize.height == newSize.height) {
        return;
    }
    
    // Recalculate composer view container frame
    CGRect newContainerFrame = cWriteView.frame;
    
    newContainerFrame.size.height = newSize.height + kComposerBackgroundTopPadding + kComposerBackgroundBottomPadding;
//    newContainerFrame.origin.y = ([self currentScreenSize].height - [self currentKeyboardHeight]) - newContainerFrame.size.height;
    
    // Recalculate send button frame
    CGRect newSendButtonFrame = btnPostComment.frame;
    newSendButtonFrame.origin.y = newContainerFrame.size.height - (kComposerBackgroundBottomPadding + newSendButtonFrame.size.height);
    
    
    // Recalculate UITextView frame
    CGRect newTextViewFrame = txtComment.frame;
    newTextViewFrame.size.height = newSize.height;
    newTextViewFrame.origin.y = kComposerBackgroundTopPadding;
    
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             cWriteView.frame = newContainerFrame;
                             btnPostComment.frame = newSendButtonFrame;
                             txtComment.frame = newTextViewFrame;
                             [txtComment setContentOffset:CGPointMake(0, 0) animated:YES];
                         }
                         completion:nil];
    } else {
        cWriteView.frame = newContainerFrame;
        btnPostComment.frame = newSendButtonFrame;
        txtComment.frame = newTextViewFrame;
        [txtComment setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    [contentScrollView setContentOffset:CGPointMake(0, contentScrollView.contentOffset.y + newSize.height - oldSize.height)];
    [self initProfileView];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [contentScrollView setFrame:CGRectMake(0, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320, contentScrollView.frame.size.height - 216)];
    [contentScrollView setContentOffset:CGPointMake(0, [textView superview].frame.origin.y - cWriteView.frame.size.height - 216 + [DataManager sharedManager].fiOS7StatusHeight) animated:YES];
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if ([text isEqualToString:@"\n"]) {
//        if (cWriteView.frame.size.height <= 66) {
//            [self changeFrame:66 _type:1 _y:cWriteView.frame.origin.y];
//            [self initProfileView];
//        }
//    }
//    
//    [textView scrollRangeToVisible:range];
//    
//    return YES;
//}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
//    NSLog(@"%@", [URL absoluteString]);
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"A - %d", buttonIndex);
}

- (void)viewDidUnload {
    [btnMutualFriend release];
    btnMutualFriend = nil;
    [lblMutualFriend release];
    lblMutualFriend = nil;
    [super viewDidUnload];
}
@end
