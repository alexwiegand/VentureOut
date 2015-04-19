//
//  MainViewController.m
//  Findy
//
//  Created by iPhone on 7/31/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "MainViewController.h"
#import "AllInterestViewController.h"
#import "ProfileViewController.h"
#import "PlaceProfileViewController.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "FindyAPI.h"
#import "MapAnnotation.h"
#import "ChatViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize mapView, bInitialLoading;

- (void)viewWillAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"GOTO_NOTIFICATION"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GOTO_NOTIFICATION"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        
        self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
        
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }
    
    if (![[DataManager sharedManager].interestArray count]) {
        [DataManager sharedManager].interestArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"INTEREST_ARRAY"]];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"INTEREST_UPDATE"]) {
        [self initFilterView];
    }
//    [contentScrollView setFrame:CGRectMake(10, 79 + [DataManager sharedManager].fiOS7StatusHeight, 300, SCREEN_HEIGHT - 79 - [DataManager sharedManager].fiOS7StatusHeight)];
    [btnDone setHidden:YES];
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)dealloc {
    [listButton release];
    [mapButton release];
    [filterButton release];
    [lblList release];
    [lblMap release];
    [lblFilter release];
    [contentScrollView release];
    [mapView release];
    [filterScrollView release];
    [btnAddInterest release];
    
    [lblAge release];
    [lblRadius release];
    [lblAgeTitle release];
    [lblRadiusTitle release];
    [btnFilterByPeople release];
    [btnFilterByPlace release];
    [imgInterestFooter release];
    [viewAgeFilter release];
    [viewRadiusFilter release];
    [radiusPicker release];
    [agePicker release];
    [pickerToolbar release];
    
//    [apiResultArray release];
    [ageFilterArray release];
    [radiusFilterArray release];
    [interestFilterArray release];
    [_geoCoder release];
    [_locationManager release];
    [menuView release];
    [filterByTableView release];
    [interestTableView release];
    [lblInterest release];
    [btnDone release];

    [super dealloc];
}

ECSlidingViewTopNotificationHandlerMacro

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Main_View"];
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
    [lblTitle setText:@"Find!"];
    [self.view addSubview:lblTitle];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    ECSlidingViewTopNotificationMacro;
    
//    ECSlidingViewAddingLeftAndRightViewToTopViewMacro

//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    
    lblAgeMin = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 20, 46)];
    [lblAgeMin setBackgroundColor:[UIColor clearColor]];
    [lblAgeMin setText:@"18"];
    [viewAgeFilter addSubview:lblAgeMin];
    
    lblAgeMax = [[UILabel alloc] initWithFrame:CGRectMake(275, 20, 30, 46)];
    [lblAgeMax setBackgroundColor:[UIColor clearColor]];
    [lblAgeMax setText:@"70+"];
    [viewAgeFilter addSubview:lblAgeMax];
    
    ageSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(40, 20, 235, 46)];
    ageSlider.lowerValue = 0;
    ageSlider.upperValue = 1;
    [ageSlider addTarget:self action:@selector(updateAgeSlider:) forControlEvents:UIControlEventValueChanged];
    [viewAgeFilter addSubview:ageSlider];
    
    lblRadiusValue = [[UILabel alloc] initWithFrame:CGRectMake(265, 20, 50, 46)];
    [lblRadiusValue setBackgroundColor:[UIColor clearColor]];
    [lblRadiusValue setText:@"50 mi"];
    [viewRadiusFilter addSubview:lblRadiusValue];
    
    radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(70.f, 20, 185, 46)];
    [radiusSlider setMinimumValue:0.f];
    [radiusSlider setMaximumValue:1.f];
    [radiusSlider setValue:1.f];
//    radiusSlider.lowerHandleHidden = true;
//    radiusSlider.upperValue = 1;
    [radiusSlider addTarget:self action:@selector(updateRangeSlider:) forControlEvents:UIControlEventValueChanged];
    [viewRadiusFilter addSubview:radiusSlider];
    
    [menuView setFrame:CGRectMake(-1, 43 + [DataManager sharedManager].fiOS7StatusHeight, 321, 42)];

    [contentScrollView setFrame:CGRectMake(10, 76 + [DataManager sharedManager].fiOS7StatusHeight, 310.f, (IS_IOS7) ? (SCREEN_HEIGHT - 76 - [DataManager sharedManager].fiOS7StatusHeight) : (SCREEN_HEIGHT - 96 - [DataManager sharedManager].fiOS7StatusHeight))];
    [mapView setFrame:CGRectMake(0, 74.0 + [DataManager sharedManager].fiOS7StatusHeight, 320.f, (IS_IPHONE5) ? 474 : 386)];
    
    
    ageFilterArray = [[NSArray alloc] initWithObjects:@"All", @"18-20", @"21-29", @"30-39", @"40-49", @"50-59", @"60-70", @"71+", nil];
    radiusFilterArray = [[NSArray alloc] initWithObjects:@"0.5 mi",@"1 mi", @"5 mi", @"10 mi", @"25 mi", @"50 mi", @"Max", nil];
    // Get user list near by you.
    nFilterBy = FILTER_BOTH;
    
//    [[UIApplication sharedApplication].delegate getLocation];
//    [self performSelector:@selector(getUsersNearBy) withObject:nil afterDelay:2.f];
    
//    [self getUsersNearBy];
 
    filterByTableArray = [[NSMutableArray alloc] initWithObjects:@"People", @"Places", nil];
    interestTableArray = [[NSMutableArray alloc] init];
    interestSelectArray =[[NSMutableArray alloc] init];
    placeOfferDict = [[NSMutableDictionary alloc] init];
    ageFilterMin = 0;
    ageFilterMax = 200;
    bAddActivity = TRUE;
    [interestTableView setScrollEnabled:NO];
    [filterByTableView setScrollEnabled:NO];
    
    [filterByTableView reloadData];
    
    [radiusPicker setBackgroundColor:[UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f]];
    [agePicker setBackgroundColor:[UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f]];
    bFilterChanged = false;

    UIImageView *pImg1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaddingLing.png"]];
    [pImg1 setFrame:CGRectMake(0, filterByTableView.frame.origin.y - 1, SCREEN_WIDTH, 1)];
    [filterScrollView addSubview:pImg1];
    [pImg1 release];
    
    UIImageView *pImg2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaddingLing.png"]];
    [pImg2 setFrame:CGRectMake(0, filterByTableView.frame.origin.y + filterByTableView.frame.size.height, SCREEN_WIDTH, 1)];
    [filterScrollView addSubview:pImg2];
    [pImg2 release];
    
    pImg3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaddingLing.png"]];
    [pImg3 setFrame:CGRectMake(0, interestTableView.frame.origin.y - 1, SCREEN_WIDTH, 1)];
    [filterScrollView addSubview:pImg3];
    [pImg3 release];
    
    pImg4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaddingLing.png"]];
    [pImg4 setFrame:CGRectMake(0, interestTableView.frame.origin.y + interestTableView.frame.size.height, SCREEN_WIDTH, 1)];
    [filterScrollView addSubview:pImg4];
    [pImg4 release];
    
    //    OtherProfile" object:[NSString stringWithFormat:@"%@", [notificationInfo objectForKey:@"email"]]]
    
    [self initFilterView];
    
    if (!bInitialLoading) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_invite"]) {
//            [self showViews:[DataManager sharedManager].peopleArray];
            if (placesArray != nil) {
                [placesArray removeAllObjects];
                [placesArray release];
            }
            
            placesArray = [[NSMutableArray alloc] initWithArray:[DataManager sharedManager].placesArray];
            
            [self sortUsersAndPlaces];
        } else {
            [SVProgressHUD showWithStatus:@"Finding people near you" maskType:SVProgressHUDMaskTypeClear];
            [self updateUserLocation];
        }
    } else {
        [SVProgressHUD showWithStatus:@"Finding people near you" maskType:SVProgressHUDMaskTypeClear];
        [self updateUserLocation];
    }
    
//    if ([[DataManager sharedManager].interestArray containsObject:@"Kiteboarding"]) {
        [self getPlaceNear];
//    }
}


- (void)viewWillDisappear:(BOOL)animated {
    bInitialLoading = FALSE;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"INTEREST_UPDATE"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"from_invite"];
}

#pragma mark - Methods
- (void)initFilterView {
    int y = 185;
    
    if (interestFilterArray != nil) {
        [interestFilterArray removeAllObjects];
    }
    
    interestFilterArray = [[NSMutableArray alloc] init];
    y = filterByTableView.frame.origin.y + filterByTableView.frame.size.height;

    if ([[DataManager sharedManager].interestArray count] > 0) {
        
        for (int i = 0; i < [[DataManager sharedManager].interestArray count]; i++) {
            if ([[[DataManager sharedManager].interestArray objectAtIndex:i] isEqualToString:@"Fitness & Workout"]) {
                continue;
            }
            [interestFilterArray addObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                                            [[DataManager sharedManager].interestArray objectAtIndex:i], @"value", @"TRUE", @"valid", nil]];
        }
        [interestTableView setFrame:CGRectMake(0, interestTableView.frame.origin.y, SCREEN_WIDTH, 44.f * [interestFilterArray count] - 1)];
        cntSelInterest = [interestFilterArray count];
        [interestTableView reloadData];
        
        [pImg3 setFrame:CGRectMake(0, interestTableView.frame.origin.y - 1, SCREEN_WIDTH, 1)];
        [pImg4 setFrame:CGRectMake(0, interestTableView.frame.origin.y + interestTableView.frame.size.height, SCREEN_WIDTH, 1)];
        
        y = 44.f * [interestFilterArray count] + interestTableView.frame.origin.y;
    } else {
        [lblInterest setHidden:YES];
        [interestTableView setHidden:YES];
    }
    
    y = interestTableView.frame.origin.y + interestTableView.frame.size.height + 15;
    
    [viewAgeFilter setHidden:NO];
    [viewAgeFilter setFrame:CGRectMake(0,  y, 320, 74)];
    [viewRadiusFilter setFrame:CGRectMake(0, viewAgeFilter.frame.origin.y + viewAgeFilter.frame.size.height + 7, 320, 74)];
    
    [filterScrollView setContentSize:CGSizeMake(320, viewRadiusFilter.frame.origin.y + viewRadiusFilter.frame.size.height + 10)];

    radiusFilter = 85000;
    placeRadius = 40000;
}


- (NSString *)placeInterest:(NSString *)interest {
    if ([interest isEqualToString:@"rock climbing"]) {
        return @"climbing";
    } else if (([interest isEqualToString:@"fitness and workout"]) || ([interest isEqualToString:@"fitness & workout"])){
        return @"gyms";
    } else if ([interest isEqualToString:@"salsa dancing"]){
        return @"dancestudio";
    } else if ([interest isEqualToString:@"swing dancing"]) {
        return @"%20";
    } else if (([interest isEqualToString:@"cycling"]) || ([interest isEqualToString:@"mountain biking"])){
        return @"bikes";
    } else if ([interest isEqualToString:@"basketball"]) {
        return @"basketballcourts";
    } else if ([interest isEqualToString:@"running"]){
        return @"sportgoods";
    } else if ([interest isEqualToString:@"scuba diving"]){
        return @"scuba";
    } else if ([interest isEqualToString:@"photography"]){
        return @"photographystores";
    } else if ([interest isEqualToString:@"baseball"]){
        return @"sportgoods";
    } else if ([interest isEqualToString:@"billiards"]){
        return @"poolhalls";
    } else if ([interest isEqualToString:@"book reading"]){
        return @"bookstores";
    } else if ([interest isEqualToString:@"computer programming"]){
        return @"shared office spaces";
    } else if ([interest isEqualToString:@"cooking"]){
        return @"cookingschools";
    } else if ([interest isEqualToString:@"gardening"]){
        return @"gardening";
    } else if ([interest isEqualToString:@"hang gliding"]){
        return @"hanggliding";
    } else if ([interest isEqualToString:@"horseback riding"]){
        return @"horsebackriding";
    } else if ([interest isEqualToString:@"ice hockey"]){
        return @"skatingrinks";
    } else if ([interest isEqualToString:@"kayaking"]){
        return @"rafting";
    } else if ([interest isEqualToString:@"martial arts"]){
        return @"martialarts";
    } else if ([interest isEqualToString:@"motorcycling"]){
        return @"motorcyclinggear";
    } else if ([interest isEqualToString:@"painting"]){
        return @"artschools";
    } else if ([interest isEqualToString:@"paragliding"]){
        return @"%20";
    } else if ([interest isEqualToString:@"pingpong"]){
        return @"%20";
    } else if ([interest isEqualToString:@"sailing"]){
        return @"boating";
    } else if ([interest isEqualToString:@"singing"]){
        return @"theater";
    } else if ([interest isEqualToString:@"skateboarding"]){
        return @"skate_parks";
    } else if ([interest isEqualToString:@"skiing"]){
        return @"outdoorgear";
    } else if ([interest isEqualToString:@"snowboarding"]){
        return @"outdoorgear";
    } else if ([interest isEqualToString:@"swimming"]){
        return @"swimmingpools";
    } else if ([interest isEqualToString:@"travel"]){
        return @"%20";
    } else if ([interest isEqualToString:@"triatlon"]){
        return @"sports wear";
    } else if ([interest isEqualToString:@"volleyball"]){
        return @"%20";
    } else if ([interest isEqualToString:@"wakeboarding"]){
        return @"%20";
    } else if ([interest isEqualToString:@"walking"]){
        return @"%20";
    } else if ([interest isEqualToString:@"weightlifting"]){
        return @"gyms";
    } else if ([interest isEqualToString:@"windsurfing"]){
        return @"surfing";
    } else if ([interest isEqualToString:@"tabletops gaming"]){
        return @"hobbyshops";
    } else if ([interest isEqualToString:@"fencing"]){
        return @"%20";
    } else if ([interest isEqualToString:@"football"]){
        return @"%20";
    } else if ([interest isEqualToString:@"racquetball"]){
        return @"sportswear";
    } else if ([interest isEqualToString:@"ultimate frisbee"]){
        return @"parks";
    } else if ([interest isEqualToString:@"hot air ballooning"]){
        return @"%20";
    } else if ([interest isEqualToString:@"hip hop"]){
        return @"dancestudio";
    } else if ([interest isEqualToString:@"ice skating"]){
        return @"skatingrinks";
    } else if ([interest isEqualToString:@"hop hop dancing"]){
        return @"dancestudio";
    }
    
    return interest;
}

- (void)getFavorite {
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://crazebot.com/favoritesdetails.php?email=%@&auth=%@&auth_email=%@",[DataManager sharedManager].strEmail, [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"], [DataManager sharedManager].strEmail];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                            timeoutInterval:60];
    [request setHTTPMethod:@"GET"];
    
    
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    if (data != nil && [(NSHTTPURLResponse *)response statusCode] == 200) {
        NSDictionary *responseDict = [[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:data];
        if ([responseDict valueForKey:@"favorites"]) {
            [[DataManager sharedManager].favoritesArray removeAllObjects];
            for (NSDictionary *dict in [responseDict objectForKey:@"favorites"]) {
                [[DataManager sharedManager].favoritesArray addObject:[dict objectForKey:@"email"]];
            }
        }
        if ([responseDict valueForKey:@"favorite_places"]) {
            [DataManager sharedManager].favoritePlaceArray = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"favorite_places"]];
        }
    }
}


- (NSString *)getMatchingInterest:(NSArray *)interestArray {
    NSString *matchInterest = @"";
    for (NSString * curInterest in interestArray) {
        for (NSDictionary *myInterest in interestFilterArray) {
            if ([[myInterest objectForKey:@"valid"] isEqualToString:@"TRUE"]) {
                if ([[curInterest capitalizedString] isEqualToString:[[myInterest objectForKey:@"value"] capitalizedString]]) {
                    if ([curInterest isEqualToString:@""]) {
                        continue;
                    }
                    matchInterest = [matchInterest stringByAppendingString:@", "];
                    if ([curInterest isEqualToString:@"Ballroomdancing"]) {
                        curInterest = @"Ballroom Dancing";
                    }
                    matchInterest = [matchInterest stringByAppendingString:curInterest];
                } else {
                    continue;
                }
            }
        }
    }
    if ([matchInterest isEqualToString:@""]) {
        return @"";
    }
    return [matchInterest substringFromIndex:2];
}

- (NSString *)getUnmatchingInterest:(NSArray *)interestArray {
    NSString *unmatchInterest = @"";
    for (NSString * curInterest in interestArray) {
        BOOL bContain = FALSE;
        
        for (NSDictionary *myInterest in interestFilterArray) {
            
            if ([[myInterest objectForKey:@"valid"] isEqualToString:@"TRUE"]) {
                
                if ([[curInterest capitalizedString] isEqualToString:[[myInterest objectForKey:@"value"] capitalizedString]]) {
                    bContain = TRUE;
                    break;
                } else {
                    continue;
                }
            }
        }
        
        if (bContain == FALSE) {
            unmatchInterest = [unmatchInterest stringByAppendingString:@", "];
            if ([curInterest isEqualToString:@"Ballroomdancing"]) {
                curInterest = @"Ballroom Dancing";
            }
            unmatchInterest = [unmatchInterest stringByAppendingString:curInterest];
        }
    }
    
    if ([unmatchInterest isEqualToString:@""]) {
        return @"";
    }
    return [unmatchInterest substringFromIndex:2];
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

- (void)getFavoriteDetail:(NSDictionary *)response {
    
}

#pragma mark - Update User Location API
- (void)updateUserLocation {
    for (UIView *view in contentScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    if (([DataManager sharedManager].longitude == 0) && ([DataManager sharedManager].longitude == 0)) {
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] getLocation];
    }
    
    NSDictionary *locDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_LOCATION"];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[DataManager sharedManager].strEmail, @"email", [locDict objectForKey:@"latitude"], @"lat", [locDict objectForKey:@"longitude"], @"long", nil];
    [[FindyAPI instance] updateUserLocation:self withSelector:@selector(updateLocationResult:) andOptions:paramDict];
}

- (void)updateLocationResult:(NSDictionary *)response {
    if ([response isKindOfClass:[NSDictionary class]]) {
        [self getUsersNearBy];
    }
    //    if ([[DataManager sharedManager].peopleArray count] == 0) {
    
    //    } else {
    ////        if ([DataManager sharedManager].mutualDict) {
    ////            [[DataManager sharedManager].mutualDict removeAllObjects];
    ////            [[DataManager sharedManager].mutualDict release];
    ////        }
    //
    //        mutualDict = [[NSMutableDictionary alloc] initWithDictionary:[DataManager sharedManager].mutualDict];
    //        [self showViews:[DataManager sharedManager].peopleArray];
    //    }
}


#pragma mark - Get Users and Places Near By

- (void)getPlaceNear {
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, [DataManager sharedManager].strEmail, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"auth_email", @"email", nil]];
    [[FindyAPI instance] placeNear:self withSelector:@selector(placeNear:) andOptions:paramDict];
}

- (void)placeNear:(NSArray *)response {
    if ([response count]) {
        NSDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:[response objectAtIndex:0]];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"address"] forKey:@"address"]];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"yelp_id"] forKey:@"id"]];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:
                                        [NSString stringWithFormat:@"%f",
                                         [self getDistance:[[[result objectForKey:@"loc"] objectAtIndex:1] floatValue]
                                                _longitude:[[[result objectForKey:@"loc"] objectAtIndex:0] floatValue]]]
                                                                   forKey:@"distance"]];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"pic"] forKey:@"image_url"]];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"name"] forKey:@"name"]];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"links"] forKey:@"links"]];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"user_count"] forKey:@"user_count"]];
        
        newPlaceDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"PlACE", @"99999999999999", @"Kiteboarding", dict, nil]
                                                            forKeys:[NSArray arrayWithObjects:@"data_type", @"distance", @"interest", @"value", nil]];
        
        [[NSUserDefaults standardUserDefaults] setObject:newPlaceDict forKey:@"KITE_PLACE"];
    }
}



- (void)getUsersNearBy {
    if (IsNSStringValid([DataManager sharedManager].strEmail)) {
        NSMutableDictionary *authenticationCredentails =
        [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil]
                                           forKeys:[NSArray arrayWithObjects:@"email", nil]];
        [[FindyAPI instance] getUsersNearBy:self
                               withSelector:@selector(getUserResult:)
                                 andOptions:authenticationCredentails];
    } else {
        
    }
    
}

- (BOOL)checkFriend:(NSMutableArray *)array _id:(NSString *)fbId {
    for (NSDictionary<FBGraphUser>* friend in array) {
        if ([fbId isEqualToString:[friend objectForKey:@"id"]]) {
            return FALSE;
        }
    }
    return TRUE;
}

- (void)getUserResult:(NSArray *) response {

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"INTEREST_UPDATE"];
//    NSLog(@"%@", [[response objectAtIndex:0] objectForKey:@"first"]);
//    [self performSelector:@selector(showViews:) withObject:response afterDelay:2.f];
//    [DataManager sharedManager].imgFace = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[DataManager sharedManager].strPicSmall]]];
//    [DataManager sharedManager].imgBack = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://crazebot.com/userpic_big.php?email=%@", [DataManager sharedManager].strEmail]]]];
    
    if ([response isKindOfClass:[NSDictionary class]]) {
        [SVProgressHUD dismiss];
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
        [[DataManager sharedManager].shoutoutArray removeAllObjects];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        UIViewController *launchViewController = [storyboard instantiateViewControllerWithIdentifier:@"LaunchViewController"];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:launchViewController] animated:YES];
        return;
    }
    
    [DataManager sharedManager].peopleArray = [[NSMutableArray alloc] initWithArray:response];
    
    if (IsNSStringValid([DataManager sharedManager].fbID)) {

        // Make the API request that uses FQL
        
        FBSession *session = [FBSession activeSession];
        if (![session isOpen]) {
            [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email", @"user_likes", @"user_birthday", @"user_location"]
                                               allowLoginUI:TRUE
                                          completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                              if (error) {
                                                  NSLog (@"Handle error %@", error.localizedDescription);
                                              } else {
                                                  [FBSession setActiveSession:session];
                                                  
                                                  
                                                  FBRequest* friendsRequest = [FBRequest requestForMyFriends];
                                                  [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                                                                NSDictionary* result,
                                                                                                NSError *error) {
                                                      friendArray = [[NSMutableArray alloc] initWithArray:[result  objectForKey:@"data"]];
                                                          
                                                      NSMutableArray *uIDArray = [[NSMutableArray alloc] init];
                                                      mutualDict = [[NSMutableDictionary alloc] init];
                                                      for (NSDictionary *peopleDict in response) {
                                                          if ((![[peopleDict valueForKey:@"facebookId"] isEqualToString:@"(null)"]) && (![[peopleDict valueForKey:@"facebookId"] isEqualToString:@" "])) {
//                                                              if ([self checkFriend:friendArray _id:[peopleDict objectForKey:@"facebookId"]]) {
                                                                  [uIDArray addObject:[NSString stringWithFormat:@"\"%@\"", [peopleDict objectForKey:@"facebookId"]]];
                                                                  [mutualDict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:0], [peopleDict objectForKey:@"facebookId"], nil]];
//                                                              }
                                                          }
                                                      }

                                                      NSString * query = [NSString stringWithFormat:@"SELECT uid1, uid2 FROM friend where uid1 IN (%@) and uid2 in (SELECT uid2 FROM friend where uid1=me())", [uIDArray componentsJoinedByString:@", "]];
                                                      NSDictionary *queryParam = @{ @"q": query };
                                                      
                                                      [FBRequestConnection startWithGraphPath:@"/fql"
                                                                                   parameters:queryParam
                                                                                   HTTPMethod:@"GET"
                                                                            completionHandler:^(FBRequestConnection *connection,
                                                                                                id result,
                                                                                                NSError *error) {
                                                                                if (error) {
                                                                                    
                                                                                } else {
                                                                                    for (NSDictionary *idDict in [result objectForKey:@"data"]) {
                                                                                        NSNumber *number = [[NSNumber alloc] initWithInt:([[mutualDict objectForKey:[idDict objectForKey:@"uid1"]] intValue] + 1)];
                                                                                        [mutualDict removeObjectForKey:[idDict objectForKey:@"uid1"]];
                                                                                        [mutualDict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:number, [idDict objectForKey:@"uid1"], nil]];
                                                                                    }
                                                                                    if ([DataManager sharedManager].mutualDict) {
                                                                                        [[DataManager sharedManager].mutualDict removeAllObjects];
                                                                                        [[DataManager sharedManager].mutualDict release];
                                                                                    }
                                                                                    
                                                                                    [DataManager sharedManager].mutualDict = [[NSMutableDictionary alloc] initWithDictionary:mutualDict];
                                                                                    [self showViews:response];
                                                                                }
                                                                            }];
        
                                                  }];
                                                  
                                                  
                                                  
                                              }
                                          }];
        } else {
            FBRequest* friendsRequest = [FBRequest requestForMyFriends];
            [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                          NSDictionary* result,
                                                          NSError *error) {
                friendArray = [[NSMutableArray alloc] initWithArray:[result  objectForKey:@"data"]];
                
                NSMutableArray *uIDArray = [[NSMutableArray alloc] init];
                mutualDict = [[NSMutableDictionary alloc] init];
                for (NSDictionary *peopleDict in response) {
                    if ((![[peopleDict valueForKey:@"facebookId"] isEqualToString:@"(null)"]) && (![[peopleDict valueForKey:@"facebookId"] isEqualToString:@" "])) {
//                        if ([self checkFriend:friendArray _id:[peopleDict objectForKey:@"facebookId"]]) {
                            [uIDArray addObject:[NSString stringWithFormat:@"\"%@\"", [peopleDict objectForKey:@"facebookId"]]];
                            [mutualDict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:0], [peopleDict objectForKey:@"facebookId"], nil]];
//                        }
                    }
                }
                NSString * query = [NSString stringWithFormat:@"SELECT uid1, uid2 FROM friend where uid1 IN (%@) and uid2 in (SELECT uid2 FROM friend where uid1=me())", [uIDArray componentsJoinedByString:@", "]];
                NSDictionary *queryParam = @{ @"q": query };
                
                [FBRequestConnection startWithGraphPath:@"/fql"
                                             parameters:queryParam
                                             HTTPMethod:@"GET"
                                      completionHandler:^(FBRequestConnection *connection,
                                                          id result,
                                                          NSError *error) {
                                          if (error) {
                                              
                                          } else {

                                              for (NSDictionary *idDict in [result objectForKey:@"data"]) {
                                                  NSNumber *number = [[NSNumber alloc] initWithInt:([[mutualDict objectForKey:[idDict objectForKey:@"uid1"]] intValue] + 1)];
                                                  [mutualDict removeObjectForKey:[idDict objectForKey:@"uid1"]];
                                                  [mutualDict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:number, [idDict objectForKey:@"uid1"], nil]];
                                              }
                                              if ([DataManager sharedManager].mutualDict) {
                                                  [[DataManager sharedManager].mutualDict removeAllObjects];
                                                  [[DataManager sharedManager].mutualDict release];
                                              }
                                              
                                              [DataManager sharedManager].mutualDict = [[NSMutableDictionary alloc] initWithDictionary:mutualDict];
                                              [self showViews:response];
                                          }
                                      }];
            }];
        }
        
        
    } else {
        [self showViews:response];
    }
    
//    NSLog(@"%@", response);
    
//    [self showViews:response];
}

- (void)showViews:(NSArray *) response{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_invite"]) {
//        [self showList];
//    } else {
        [self orderTheUser];
//    }
}

- (CLLocationDistance)getDistance:(float)lat _longitude:(float)lng {
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:[DataManager sharedManager].latitude
                                                         longitude:[DataManager sharedManager].longitude];
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:lat
                                                            longitude:lng];
    
    CLLocationDistance distance = [targetLocation distanceFromLocation:curLocation];
    return distance;
}

- (void)orderTheUser {
    NSMutableArray *pArray = [[DataManager sharedManager].peopleArray mutableCopy];
    [pArray autorelease];
    
    [[DataManager sharedManager].peopleArray removeAllObjects];
    for (NSMutableDictionary *content in pArray) {
        CLLocationDistance distance = [self getDistance:[[[content objectForKey:@"loc"] objectAtIndex:1] floatValue] _longitude:[[[content objectForKey:@"loc"] objectAtIndex:0] floatValue]];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:content];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%0.1f", distance / 1609.34] forKey:@"distance"]];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:@"PEOPLE" forKey:@"data_type"]];
        
        [[DataManager sharedManager].peopleArray addObject:dict];
    }
    
    [[DataManager sharedManager].peopleArray sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
     {
         float key1 = [[a objectForKey: @"distance"] floatValue];
         float key2 = [[b objectForKey: @"distance"] floatValue];
         
         return (key1 > key2);
     }
     ];
  
    [self showList];
}

- (void)checkEmpty {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"INSTALLED"]) {
        [SVProgressHUD dismiss];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"INSTALLED"];
        [self addOverlayImage];
    }
    
    if ((![self checkFilterPeople]) && (bAddActivity)){
        [self addEmptyLabel];
    }
}
#pragma mark - Place Relate API

- (void)getPlaces {
    placesArray = [[NSMutableArray alloc] init];
    placeRadius = 1609.34;
    
    for (int i = 0; i < [interestFilterArray count]; i++) {
        if ([[[interestFilterArray objectAtIndex:i] objectForKey:@"valid"] isEqualToString:@"FALSE"]) {
            continue;
        }
        NSString *inter = [[[interestFilterArray objectAtIndex:i] objectForKey:@"value"] lowercaseString];
        if (([inter isEqualToString:@"baseball"]) || ([inter isEqualToString:@"racquetball"]) || ([inter isEqualToString:@"skiing"]) || ([inter isEqualToString:@"snowboarding"])) {
            continue;
        }
        
        inter = [self placeInterest:[[[interestFilterArray objectAtIndex:i] objectForKey:@"value"] lowercaseString]];
//        NSLog(@"%@", inter);
        if (placeRadius > 40000) {
            placeRadius = 40000;
        }
        
        inter = [inter stringByReplacingOccurrencesOfString:@" " withString:@""];
        inter = [inter stringByReplacingOccurrencesOfString:@"&" withString:@""];


        NSString *urlString = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&category_filter=%@&radius_filter=%f&ll=%f,%f", [[[[interestFilterArray objectAtIndex:i] objectForKey:@"value"] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"%20"], [inter lowercaseString] , placeRadius, [DataManager sharedManager].latitude, [DataManager sharedManager].longitude];

//        urlString = [urlString stringByReplacingOccurrencesOfString:@" & " withString:@"%20%26%20"];
//        urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@","];
        
        NSURL *URL = [NSURL URLWithString:urlString];
        OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"hirq2-YQaGOjQvw6mTp-XQ" secret:@"FyfSMc-25pAa2_eGAPkxm5_pEv0"] autorelease];
        OAToken *token = [[[OAToken alloc] initWithKey:@"3H_Er0KrO6ZO6ZguVqjdS84kArT69wa8" secret:@"Zf76165ehF2MabZu-ruCPFEK-Vk"] autorelease];
        
        id<OASignatureProviding, NSObject> provider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
        NSString *realm = nil;
        
        OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                       consumer:consumer
                                                                          token:token
                                                                          realm:realm
                                                              signatureProvider:provider];
        [request prepare];
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:Nil error:nil];
        if (responseData != nil) {
            NSDictionary * rDictionary = [[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:responseData];

            if (([[rDictionary objectForKey:@"businesses"] count] < 5) && (placeRadius < 40000)) {
                placeRadius *= 2;
                i --;
                continue;
            } else if ([[rDictionary objectForKey:@"businesses"] count]) {
                NSMutableArray *array = [NSMutableArray arrayWithArray:[rDictionary objectForKey:@"businesses"]];
                [array sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
                 {
                     float key1 = [[a objectForKey: @"distance"] floatValue];
                     float key2 = [[b objectForKey: @"distance"] floatValue];
                     
                     return (key1 > key2);
                 }
                 ];
//                NSLog(@"%@", array);
//                37.291911, -121.878923
//                NSLog(@"%@", rDictionary);
                int calc = 0;
                for (int k = 0; k < [array count]; k++) {
                    if ((calc > 4) && (![[[[interestFilterArray objectAtIndex:i] objectForKey:@"value"] lowercaseString] isEqualToString:@"kiteboarding"])) {
                        k = [array count];
                        continue;
                    }
                    
                    NSMutableDictionary *dict = [array objectAtIndex:k];

                    if ([[dict objectForKey:@"id"] isEqualToString:@"wind-over-water-burlingame-4"]) {
                        continue;
                    } else if ([[dict objectForKey:@"id"] isEqualToString:@"touchstone-climbing-incorporated-berkeley"]) {
                        continue;
                    } else if ([[dict objectForKey:@"id"] isEqualToString:@"touchstone-climbing-san-jose"]) {
                        continue;
                    } else if ([[dict objectForKey:@"id"] isEqualToString:@"rosewalk-apartments-san-jose"]) {
                        continue;
                    } else if ([[dict objectForKey:@"id"] isEqualToString:@"than-phong-academy-san-jose"]) {
                        continue;
                    }
                    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dict, [[interestFilterArray objectAtIndex:i] objectForKey:@"value"], nil] forKeys:[NSArray arrayWithObjects:@"value", @"interest", nil]];
                    [placesArray addObject:paramDict];
                    
                    calc++;
                }
            }
            
            if ((placeRadius == 40000) && ([[rDictionary objectForKey:@"businesses"] count] > 0)) {
                NSMutableArray *array = [NSMutableArray arrayWithArray:[rDictionary objectForKey:@"businesses"]];
                [array sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
                 {
                     float key1 = [[a objectForKey: @"distance"] floatValue];
                     float key2 = [[b objectForKey: @"distance"] floatValue];
                     
                     return (key1 > key2);
                 }
                 ];
                //                NSLog(@"%@", array);
                //                37.291911, -121.878923
                //                NSLog(@"%@", rDictionary);
                for (int k = 0; k < [array count]; k++) {
                    if ((k > 4) && (![[[[interestFilterArray objectAtIndex:i] objectForKey:@"value"] lowercaseString] isEqualToString:@"kiteboarding"])) {
                        k = [array count];
                        continue;
                    }
                    
                    NSMutableDictionary *dict = [array objectAtIndex:k];
                    
                    if ([[dict objectForKey:@"id"] isEqualToString:@"wind-over-water-burlingame-4"]) {
                        continue;
                    } else if ([[dict objectForKey:@"id"] isEqualToString:@"touchstone-climbing-incorporated-berkeley"]) {
                        continue;
                    } else if ([[dict objectForKey:@"id"] isEqualToString:@"touchstone-climbing-san-jose"]) {
                        continue;
                    } else if ([[dict objectForKey:@"id"] isEqualToString:@"rosewalk-apartments-san-jose"]) {
                        continue;
                    }
                    //                    NSArray *category = [dict objectForKey:@"categories"];
                    //                    for (NSArray *cat in category) {
                    //                        for (NSString *str in cat) {
                    //                            if ([[str lowercaseString] isEqualToString:[[[DataManager sharedManager].interestArray objectAtIndex:i] lowercaseString]]) {
                    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dict, [[interestFilterArray objectAtIndex:i] objectForKey:@"value"], nil] forKeys:[NSArray arrayWithObjects:@"value", @"interest", nil]];
                    [placesArray addObject:paramDict];
                    //                                break;
                    //                            }
                    //                        }
                    //                    }
                }

            }
        }
    }
    
    [self sortPlaces];
    
    [self performSelector:@selector(getFavorite) withObject:nil afterDelay:0.1f];
    
//    [self getPlace];
    
//    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", nil]];
//    [[FindyAPI instance] favoriteDetail:self withSelector:@selector(getFavoriteDetail:) andOptions:paramDict];
}

- (void)getPlace {
//    NSLog(@"%@", placesArray);
    
    if (([placesArray count]) || (placeRadius >= 40000)) {
        [self sortPlaces];

        [self performSelector:@selector(getFavorite) withObject:nil afterDelay:0.1f];
//        [SVProgressHUD dismiss];
    } else {
        placeRadius *= 2;
        if (placeRadius >= 40000) {
            placeRadius = 40000;
        }
        [self getPlaces];
    }
}

- (void)filterPlaces {
//    [SVProgressHUD dismiss];

    if (placesArray != nil) {
        [placesArray removeAllObjects];
        [placesArray release];
        placesArray = nil;
    }
    
    placesArray = [[NSMutableArray alloc] init];

    int index = 0;
    for (int j = 0; j < [[DataManager sharedManager].placesArray count]; j++) {
        for (int k = 0; k < [interestFilterArray count]; k++) {
            if ([[[interestFilterArray objectAtIndex:k] objectForKey:@"valid"] isEqualToString:@"TRUE"]) {
                if ([[[interestFilterArray objectAtIndex:k] objectForKey:@"value"] isEqualToString:[[[DataManager sharedManager].placesArray objectAtIndex:j] objectForKey:@"interest"]]) {
                    [placesArray addObject:[[DataManager sharedManager].placesArray objectAtIndex:j]];
                }
                
                if ([[[[interestFilterArray objectAtIndex:k] objectForKey:@"value"] lowercaseString] isEqualToString:@"kiteboarding"]) {
                    index = k;
                }
            }
        }
    }
    
//    [self showPlaces];
}

- (void)sortPlaces{
    BOOL bKite = FALSE;
    for (int j = 0; j < [placesArray count] ; j++) {
        NSString *curID = [[[placesArray objectAtIndex:j] objectForKey:@"value"] objectForKey:@"id"];
        NSString *curInter = [[placesArray objectAtIndex:j] objectForKey:@"interest"];
        
        if ([[curInter lowercaseString] isEqualToString:@"kiteboarding"]) {
            bKite = TRUE;
        }
        
        for (int k = j + 1; k < [placesArray count]; k++) {
            
            NSString *tmpID = [[[placesArray objectAtIndex:k] objectForKey:@"value"] objectForKey:@"id"];
            
            if ([curID isEqualToString:tmpID]) {
                
                
                curInter = [curInter stringByAppendingString:[NSString stringWithFormat:@", %@",[[placesArray objectAtIndex:k] objectForKey:@"interest"]]];
                [placesArray removeObjectAtIndex:k];
                k--;
                
                NSMutableDictionary *placeDict =[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                                            [[placesArray objectAtIndex:j] objectForKey:@"value"],
                                                                                            curInter, nil]
                                                                                   forKeys:[NSArray arrayWithObjects:@"value", @"interest", nil]];
                [placesArray replaceObjectAtIndex:j withObject:placeDict];
            }
        }
    }
    
    if (bKite && newPlaceDict) {
        [placesArray addObject:[newPlaceDict retain]];
    }
    
    NSMutableArray *idArray = [[NSMutableArray alloc] init];
    for (NSDictionary *place in placesArray) {
        NSDictionary *value = [place objectForKey:@"value"];
        [idArray addObject:[[value objectForKey:@"id"] retain]];
    }
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:[idArray componentsJoinedByString:@","] forKey:@"yelp_id"];
    [[FindyAPI instance] getPlaceUser:self withSelector:@selector(placeUsers:) andOptions:paramDict];
    
//    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:[idArray componentsJoinedByString:@","] forKey:@"yelp_id"];
//    [[FindyAPI instance] getPlaceOffers:self withSelector:@selector(placeOfferResult:) andOptions:paramDict];
}

- (void)placeUsers:(NSDictionary *)response {
    for (int j = 0; j < [placesArray count] ; j++) {
        NSString *curID = [[[placesArray objectAtIndex:j] objectForKey:@"value"] objectForKey:@"id"];

        NSMutableDictionary * valueArray= [[NSMutableDictionary alloc] initWithObjectsAndKeys:[response objectForKey:curID], @"user_count", nil];
        [valueArray addEntriesFromDictionary:[[placesArray objectAtIndex:j] objectForKey:@"value"]];
        
        NSString *distance = ([[response objectForKey:curID] intValue] > 0) ? [NSString stringWithFormat:@"%0.1f", [[[[placesArray objectAtIndex:j] objectForKey:@"value"] objectForKey:@"distance"] floatValue] / 1609.34] : @"99999999999999";
        
        NSMutableDictionary *placeDict =[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[valueArray retain],
                                                                                    [[placesArray objectAtIndex:j] objectForKey:@"interest"], @"PLACE", distance,  nil]
                                                                           forKeys:[NSArray arrayWithObjects:@"value", @"interest", @"data_type", @"distance", nil]];
        [placesArray replaceObjectAtIndex:j withObject:placeDict];
    }
    
    [placesArray sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
     {
         NSString * key1 = [[a objectForKey:@"value"] objectForKey:@"distance"];
         NSString * key2 = [[b objectForKey:@"value"] objectForKey: @"distance"];
         
         return [key1 floatValue] > [key2 floatValue];
     }
     ];
    
    [placesArray sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
     {
         NSString * key1 = [a objectForKey: @"interest"];
         NSString * key2 = [b objectForKey: @"interest"];
         
         return ([key1 compare:key2]);
     }
     ];
    
    

    [self sortUsersAndPlaces];
//    [self showPlaces];
}

- (void)kiteBoardingDetail:(id)sender {
    
}

- (BOOL)checkFilterPeople {
    for (NSDictionary *content in [DataManager sharedManager].peopleArray) {
        NSString *strMatchInterest = [self getMatchingInterest:[content objectForKey:@"interests"]];
        if (![strMatchInterest isEqualToString:@""]) {
            return TRUE;
        }

    }
    return FALSE;
}

- (void)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - Arrange List
- (void)showList {
    NSLog(@"%f", contentScrollView.frame.origin.y);
    int y = 10;
    if (IS_IOS7) {
        y = (bInitialLoading == TRUE) ? -10 : 10;
    }
    curY = y;
    
//    if ((nFilterBy == 0) || (nFilterBy == 2)) {
//        if ([[DataManager sharedManager].peopleArray count]) {
//            for (int i = 0; i < [[DataManager sharedManager].peopleArray count]; i++) {
//                [self addPeople:i];
//            }
//        }
//    }
//    nFilterBy = 0;
    if ((nFilterBy == 1) || (nFilterBy == 2)) {
        [placesArray removeAllObjects];
        [placesArray release];
        
        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:@"Finding nearby results" maskType:SVProgressHUDMaskTypeClear];
        [self performSelector:@selector(getPlaces) withObject:nil afterDelay:0.1f];
    } else {
        [SVProgressHUD dismiss];
        
        [self sortUsersAndPlaces];
        
        [self performSelector:@selector(getFavorite) withObject:nil afterDelay:0.1f];
    }
    
    [self checkEmpty];
}

- (void)sortUsersAndPlaces {
    if (allArray != nil) {
        [allArray removeAllObjects];
    } else {
        allArray = [[NSMutableArray alloc] init];
    }
    if ((nFilterBy == 0) || (nFilterBy == 2)) {
        [allArray addObjectsFromArray:[DataManager sharedManager].peopleArray];
    }
    if ((nFilterBy == 1) || (nFilterBy == 2)) {
        [allArray addObjectsFromArray:placesArray];
    }
    
    [allArray sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
     {
         float key1 = [[a objectForKey: @"distance"] floatValue];
         float key2 = [[b objectForKey: @"distance"] floatValue];
         
         return (key1 > key2);
     }
     ];
    
//    NSLog(@"%@", allArray);
    [self arrangeList];
//    [self showList];
}

- (void)arrangeList {
    
    if ([[DataManager sharedManager].placesArray count] == 0) {
        [DataManager sharedManager].placesArray = [[NSMutableArray alloc] init];
    } else {
        [[DataManager sharedManager].placesArray removeAllObjects];
    }
    
    [placeOfferDict removeAllObjects];
    if ([[ DataManager sharedManager].placeOfferDict count]) {
        [placeOfferDict addEntriesFromDictionary:[DataManager sharedManager].placeOfferDict];
    }
    
    
    BOOL placeShowed = TRUE;
    for (int i = 0; i < [allArray count]; i++) {
        NSDictionary *content = [allArray objectAtIndex:i];
        if (([[content objectForKey:@"distance"] isEqualToString:@"99999999999999"]) && placeShowed) {
            
            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, curY, 300, 20)];
            [lblTitle setTextColor:UIColorFromRGB(0x4A4A4A)];
            [lblTitle setBackgroundColor:[UIColor clearColor]];
            [lblTitle setText:@"PLACES"];
            [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
            [contentScrollView addSubview:lblTitle];
            [lblTitle release];
            
            curY += 20;
            
            placeShowed = FALSE;
        }
        if ([[content objectForKey:@"data_type"] isEqualToString:@"PEOPLE"]) {
            if ([[content objectForKey:@"distance"] floatValue] < (radiusFilter / 1609.34)) {
                [self addPeople:i];
            }
        } else {
//            NSLog(@"%@", content);
            [self addPlace:i];
        }
    }
    [contentScrollView setContentSize:CGSizeMake(310, curY)];
    
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"from_invite"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ENTER_BACKGROUND"];
    [SVProgressHUD dismiss];
//    [self initFilterView];
}

#pragma mark - Add People and Place
- (void)addPeople:(int)index {
    NSDictionary *content = [allArray objectAtIndex:index];
    float y = curY;
    
    NSDate *today = [NSDate date];
    if (![[content objectForKey:@"birthyear"] isKindOfClass:[NSNull class]]) {
        float age = ((long long)[today timeIntervalSince1970] - [[[content objectForKey:@"birthyear"] objectForKey:@"sec"] longLongValue]) / 31556926.0;
        if ((age < ageFilterMin) || (age > ageFilterMax)) {
            return;
        }
    } else {
        return;
    }
    
    
    // Filter
    NSString *strMatchInterest = [self getMatchingInterest:[content objectForKey:@"interests"]];
    if ([strMatchInterest isEqualToString:@""]) {
        return;
    }
    
    //                if (bAgeContain == TRUE) {
    //                    [content objectForKey:@""];
    //                }
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopPadding.png"]];
    [topImageView setFrame:CGRectMake(0, y, 300, 5)];
    [topImageView setContentMode:UIViewContentModeScaleToFill];
    [contentScrollView addSubview:topImageView];
    [topImageView release];
    
    // Calculate Content Height
    int nHeight = 80.f;
    UIImageView *bodyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ContentPadding.png"]];
    [bodyImageView setFrame:CGRectMake(0, y + 5, 300, nHeight)];
    [bodyImageView setContentMode:UIViewContentModeScaleToFill];
    [contentScrollView addSubview:bodyImageView];
    
    // Get Profile Image
    //            UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[content objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
    //            UIImage *pImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[content objectForKey:@"pic_small"]]]];
    //            UIImageView *pImageView = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
    //            [pImageView setFrame:CGRectMake(9.f, y + 12.f, 53.f, 53.f)];
    //            [contentScrollView addSubview:pImageView];
    //            [pImageView release];
    
    AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(9.f, y + 12.f, 53.f, 53.f)];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 1;
    pImageView.imageURL = [NSURL URLWithString:[content objectForKey:@"pic_small"]];
    [contentScrollView addSubview:pImageView];
    [pImageView release];
    
    // Get Distance
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:[[[content objectForKey:@"loc"] objectAtIndex:1] floatValue]
                                                            longitude:[[[content objectForKey:@"loc"] objectAtIndex:0] floatValue]];
    
    CLLocationDistance distance = [self getDistance:[[[content objectForKey:@"loc"] objectAtIndex:1] floatValue] _longitude:[[[content objectForKey:@"loc"] objectAtIndex:0] floatValue]];
    
    UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(158.f, y + 10, 130.f, 12.f)];
    [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
    [lblMile setBackgroundColor:[UIColor clearColor]];
    [lblMile setTextAlignment:NSTextAlignmentRight];
    [lblMile setText:[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34]];
    [contentScrollView addSubview:lblMile];
    [lblMile release];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = targetLocation.coordinate.latitude;
    coordinate.longitude = targetLocation.coordinate.longitude;
    
    //        MapAnnotation *point = [[MapAnnotation alloc] initWithLocation:[content objectForKey:@"first"]
    //                                                            coordinate:coordinate];
    MapAnnotation *point = [[MapAnnotation alloc] initWithName:[content objectForKey:@"first"] pinType:@"0" coordinate:coordinate];
    [mapView addAnnotation:point];
    [point release];
    
    // Get Name
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(70.f, y + 18, 220.f, 20.f)];
    [lblName setBackgroundColor:[UIColor clearColor]];
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:TITLE_FONT_SIZE]];
    [lblName setText:([content objectForKey:@"first"] == [NSNull null]) ? @"" : [content objectForKey:@"first"]];
    [lblName setTextColor:[UIColor colorWithRed:0 green:.6f blue:.8f alpha:1.f]];
    [contentScrollView addSubview:lblName];
    [lblName sizeToFit];
    [lblName release];
    
    NSString *fbID = [content objectForKey:@"facebookId"];
    if ([mutualDict valueForKey:fbID] && [self checkFriend:friendArray _id:fbID]) {
        int nMutual = [[mutualDict objectForKey:fbID] intValue];
        if (nMutual != 0) {
            UILabel *lblMutual = [[UILabel alloc] initWithFrame:CGRectMake(lblName.frame.origin.x + lblName.frame.size.width + 5, y + 22, 220.f, 14.f)];
            [lblMutual setBackgroundColor:[UIColor clearColor]];
            [lblMutual setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
            [lblMutual setTextColor:[UIColor grayColor]];
            [lblMutual setText:[NSString stringWithFormat:@"%d mutual friends", nMutual]];
            [contentScrollView addSubview:lblMutual];
            [lblMutual release];
        }
    } else if (fbID != nil) {
        UILabel *lblMutual = [[UILabel alloc] initWithFrame:CGRectMake(lblName.frame.origin.x + lblName.frame.size.width + 15, y + 22, 220.f, 14.f)];
        [lblMutual setBackgroundColor:[UIColor clearColor]];
        [lblMutual setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
        [lblMutual setTextColor:[UIColor grayColor]];
        [lblMutual setText:@"Friend"];
        [contentScrollView addSubview:lblMutual];
        [lblMutual release];
    }
    
    
    // Get Interest
    int x = 70.f;
    
    NSString *mString = [self getMatchingInterest:[content objectForKey:@"interests"]];
    NSString *uString = [self getUnmatchingInterest:[content objectForKey:@"interests"]];
    NSString *aString = @"";
    CGSize matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:INTEREST_FONT_SIZE]];
    
    float nWidth = 120.f;
    if (matchSize.width > nWidth) {
        NSArray *mArray = [mString componentsSeparatedByString:@", "];
        mString = [mArray objectAtIndex:0];
        matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:INTEREST_FONT_SIZE]];
        int i = 0;
        while ((matchSize.width < nWidth) && (i < [mArray count])) {
            i++;
            mString = [mString stringByAppendingFormat:@", %@", [mArray objectAtIndex:i]];
            matchSize = [mString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:INTEREST_FONT_SIZE]];
        }
        
        aString = [NSString stringWithFormat:@"+%d", [mArray count] - i];
        uString = @"";
    } else {
        CGSize unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE]];
        
        if (unmatchSize.width > (nWidth - matchSize.width)) {
            NSArray *uArray = [uString componentsSeparatedByString:@", "];
            uString = [uArray objectAtIndex:0];
            unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE]];
            int i = 0;
            while ((unmatchSize.width < (nWidth - matchSize.width)) && (i < [uArray count])) {
                i++;
                uString = [uString stringByAppendingFormat:@", %@", [uArray objectAtIndex:i]];
                unmatchSize = [uString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE]];
            }
            
            aString = [NSString stringWithFormat:@"+%d", [uArray count] - i];
        }
    }
    NSString *iString = @"";
    
    NSMutableAttributedString *attributeString;
    if (IsNSStringValid(mString) && IsNSStringValid(uString)) {
        iString = [NSString stringWithFormat:@"%@, %@", mString, uString];
        if ([aString length])
            iString = [iString stringByAppendingFormat:@", %@",aString];
        attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:INTEREST_FONT_SIZE] range:NSMakeRange(0, [mString length] + 1)];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE] range:NSMakeRange([mString length] + 2, [uString length])];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:INTEREST_FONT_SIZE] range:NSMakeRange([iString length] - [aString length], [aString length])];
    } else if (IsNSStringValid(mString) && (!IsNSStringValid(uString))) {
        iString = [NSString stringWithFormat:@"%@",mString];
        if ([aString length])
            iString = [iString stringByAppendingFormat:@", %@",aString];
        attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:INTEREST_FONT_SIZE] range:NSMakeRange(0, [iString length])];
    } else if ((!IsNSStringValid(mString)) && IsNSStringValid(uString)) {
        iString = [NSString stringWithFormat:@"%@", uString];
        if ([aString length])
            iString = [iString stringByAppendingFormat:@", %@",aString];
        attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE] range:NSMakeRange(0, [iString length])];
    } else {
        iString = @"";
        attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
    }
    
    
    UILabel *lblMatchingInterest = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 45.f, 205.f, 20)];
    [lblMatchingInterest setBackgroundColor:[UIColor clearColor]];
    [lblMatchingInterest setAttributedText:attributeString];
    [contentScrollView addSubview:lblMatchingInterest];
    
    float shoutHeight = 0;
    nHeight = 70.f;
    if ([content valueForKey:@"shoutouts"] != [NSNull null]) {
        
        nHeight += 15;
        UIImageView *imgShoutMini = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShoutOutMini.png"]];
        [imgShoutMini setFrame:CGRectMake(15, y + 74, imgShoutMini.frame.size.width, imgShoutMini.frame.size.height)];
        [contentScrollView addSubview:imgShoutMini];
        
        //                int cx = lblShoutout.frame.origin.x + lblShoutout.frame.size.width + 2;
        //                    NSLog(@"%@", [content objectForKey:@"shoutouts"]);
        
        NSString *interest = [NSString stringWithFormat:@"%@:", [[[content objectForKey:@"shoutouts"] lastObject] objectForKey:@"interest"]];
        if (IsNSStringValid(interest)) {
            if (IS_IOS7) {
                interest = [interest stringByRemovingPercentEncoding];
            } else {
                interest = [interest stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
        }
        
        interest = [interest stringByReplacingOccurrencesOfString:@"%26" withString:@"&"];
        if ([interest isEqualToString:@"Ballroomdancing:"]) {
            interest = @"Ballroom Dancing:";
        }
        
        if ([interest isEqualToString:@"Rockclimbing:"]) {
            interest = @"Rock climbing:";
        }
        NSString *strShout = @"";
        if ([[[[content objectForKey:@"shoutouts"] objectAtIndex:[[content objectForKey:@"shoutouts"] count] - 1] objectForKey:@"shout"] isEqualToString:@""] == FALSE) {
            strShout = [[[content objectForKey:@"shoutouts"] objectAtIndex:[[content objectForKey:@"shoutouts"] count] - 1] objectForKey:@"shout"];
            if ([strShout characterAtIndex:[strShout length] - 1] == '\n') {
                strShout = [strShout substringToIndex:[strShout length] - 1];
            }
        }
        
        //                NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", interest, strShout]];
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \"%@\"", interest, strShout]];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [interest length])];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange([interest length] + 1, [strShout length] + 2)];
        
        UILabel *lblShoutBody = [[UILabel alloc] initWithFrame:CGRectMake(35, y + 69, 255, 40)];
        [lblShoutBody setBackgroundColor:[UIColor clearColor]];
        //                [lblShoutBody setText:strShout];
        [lblShoutBody setNumberOfLines:2];
        [lblShoutBody setAttributedText:attributeString];
        [lblShoutBody sizeToFit];
        
        [contentScrollView addSubview:lblShoutBody];
        
        shoutHeight = lblShoutBody.frame.size.height / 2.f + 5;
        nHeight += lblShoutBody.frame.size.height / 2.f + 5;
        y += lblShoutBody.frame.size.height / 2.f + 5;
        
        ////////////////////////
        NSDictionary *shoutDict = [[content objectForKey:@"shoutouts"] lastObject];
        //                    NSLog(@"%@", shoutDict);
        if (([shoutDict valueForKey:@"place_link"] && IsNSStringValid([shoutDict objectForKey:@"place_link"])) || ([shoutDict valueForKey:@"deal_link"] && IsNSStringValid([shoutDict objectForKey:@"deal_link"]))) {
            
            UILabel *lblAttach = [[UILabel alloc] initWithFrame:CGRectMake(35, y + 85, 300, 15)];
            
            NSString *attTitle = (IsNSStringValid([shoutDict valueForKey:@"place_link"])) ? @"Attached place" : @"Attached deal";
            
            NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:attTitle];
            [aString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, [aString  length])];
            [aString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:12.f] range:NSMakeRange(0, [aString  length])];
            
            [lblAttach setAttributedText:aString];
            [lblAttach setTextColor:UIColorFromRGB(0x757171)];
            [contentScrollView addSubview:lblAttach];
            [lblAttach release];
            
            y += 20;
            nHeight += 20;
            shoutHeight += 20;
            
            AsyncImageView *aImgView = [[AsyncImageView alloc] initWithFrame:CGRectMake(25.f, y + 85.f, 40.f, 40.f)];
            aImgView.contentMode = UIViewContentModeScaleAspectFill;
            aImgView.clipsToBounds = YES;
            aImgView.bCircle = 1;
            if ([shoutDict valueForKey:@"attach_image_url"] && IsNSStringValid([shoutDict valueForKey:@"attach_image_url"]))
                aImgView.imageURL = [NSURL URLWithString:[shoutDict objectForKey:@"attach_image_url"]];
            [contentScrollView addSubview:aImgView];
            [aImgView release];
            
            UILabel *lblAttachTitle = [[UILabel alloc] initWithFrame:CGRectMake(75.f, y + 90.f, 215.f, 20)];
            [lblAttachTitle setTextColor:[UIColor colorWithRed:1.f green:74 / 255.f blue:0 alpha:1.f]];
            [lblAttachTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f]];
            if ([shoutDict valueForKey:@"attach_title"] && IsNSStringValid([shoutDict valueForKey:@"attach_title"]))
                [lblAttachTitle setText:[[shoutDict objectForKey:@"attach_title"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
            [contentScrollView addSubview:lblAttachTitle];
            [lblAttachTitle release];
            
            UILabel *lblAttachDetail = [[UILabel alloc] initWithFrame:CGRectMake(75.f, y + 105.f, 215.f, 20)];
            [lblAttachDetail setTextColor:[UIColor darkGrayColor]];
            [lblAttachDetail setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.f]];
            if ([shoutDict valueForKey:@"attach_detail"] && IsNSStringValid([shoutDict valueForKey:@"attach_detail"]))
                [lblAttachDetail setText:[[shoutDict objectForKey:@"attach_detail"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
            [contentScrollView addSubview:lblAttachDetail];
            [lblAttachDetail release];
            
            //                    }
            
            shoutHeight += 45;
            y += 45;
            nHeight += 45;
            
            //                    NSLog(@"%@", shoutDict);
        }
        ////////////////////////
        
        
        NSArray *sArray = [content objectForKey:@"shoutouts"];
        
        NSMutableArray *replyArray = [self getCountAndRemoveMultiples:[[sArray objectAtIndex:[[content objectForKey:@"shoutouts"] count] - 1] objectForKey:@"replies"]];
        NSMutableArray *commentArray = [self getCommentCountAndRemoveMultiples:[[sArray objectAtIndex:[[content objectForKey:@"shoutouts"] count] - 1] objectForKey:@"comments"]];
        
        UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line.png"]];
        [lineView setFrame:CGRectMake(0, y + 90, 300, 1)];
        [contentScrollView addSubview:lineView];
        nHeight += 15;
        
        if (([[sArray objectAtIndex:[[content objectForKey:@"shoutouts"] count] - 1] valueForKey:@"comments"] != nil) || ([[sArray objectAtIndex:[[content objectForKey:@"shoutouts"] count] - 1] valueForKey:@"replies"] != nil)) {
            
            UILabel *lblReply = [[UILabel alloc] initWithFrame:CGRectMake(25, y + 101, 0, 0)];
            NSDictionary *sDict = [sArray objectAtIndex:[[content objectForKey:@"shoutouts"] count] - 1];
            
            if ([sDict valueForKey:@"replies"]) {
                [lblReply setText:[NSString stringWithFormat:@"%d Chat Replied", [[replyArray lastObject] count]]];
                [lblReply setFont:[UIFont fontWithName:@"HelveticaNeue" size:REPLIES_FONT_SIZE]];
                [lblReply sizeToFit];
                [contentScrollView addSubview:lblReply];
                [lblReply release];
                nHeight += 18;
            }
            
            if ([sDict valueForKey:@"comments"]) {
                UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(lblReply.frame.origin.x + lblReply.frame.size.width + 5, lblReply.frame.origin.y, 70, lblReply.frame.size.height)];
                [lblComment setBackgroundColor:[UIColor clearColor]];
                [lblComment setFont:[UIFont fontWithName:@"HelveticaNeue" size:REPLIES_FONT_SIZE]];
                [lblComment setText:[NSString stringWithFormat:@"%d Commented", [[commentArray lastObject] count]]];
                [lblComment sizeToFit];
                [contentScrollView addSubview:lblComment];
                [lblComment release];
                if (![sDict valueForKey:@"replies"]) {
                    nHeight += 18;
                }
                
                int cx = lblComment.frame.origin.x + lblComment.frame.size.width + 7;
                int p = 0;
                for (NSDictionary *cDict in [commentArray objectAtIndex:0]) {
                    if (p == 3) {
                        break;
                    }
                    //                                 NSLog(@"%@", [[sDict objectForKey:@"comments"] objectAtIndex:i]);
                    //                            UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[cDict objectForKey:@"comment_pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
                    //
                    //                            UIImageView *pImageView = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
                    //                            [pImageView setFrame:CGRectMake(cx, y + 98.f, 20.f, 20.f)];
                    //                            [contentScrollView addSubview:pImageView];
                    //                            [pImageView release];
                    
                    AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(cx, y + 98.f, 20.f, 20.f)];
                    pImageView.contentMode = UIViewContentModeScaleAspectFill;
                    pImageView.clipsToBounds = YES;
                    pImageView.bCircle = 1;
                    pImageView.imageURL = [NSURL URLWithString:[cDict objectForKey:@"comment_pic_small"]];
                    [contentScrollView addSubview:pImageView];
                    [pImageView release];
                    
                    p ++;
                    cx += 23;
                }
            }
            
            
        } else {
            UILabel *lblReply = [[UILabel alloc] initWithFrame:CGRectMake(0, y + 90, 300, 35)];
            [lblReply setText:@"Be the first one to reply / comment?"];
            [lblReply setBackgroundColor:[UIColor clearColor]];
            [lblReply setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
            [lblReply setTextAlignment:NSTextAlignmentCenter];
            [contentScrollView addSubview:lblReply];
            [lblReply release];
            nHeight += 18;
        }
    }
    
    [bodyImageView setFrame:CGRectMake(0, bodyImageView.frame.origin.y, 300, nHeight)];
    
    // Add Footer Image
    UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
    [footerImage setFrame:CGRectMake(0, bodyImageView.frame.origin.y + nHeight, 300, 5)];
    [contentScrollView addSubview:footerImage];
    [footerImage release];
    
    UIButton *btnSelection = [ UIButton buttonWithType:UIButtonTypeCustom];
    [btnSelection setBackgroundImage:[UIImage imageNamed:@"ButtonClickBackground.png"] forState:UIControlStateHighlighted];
    [btnSelection setFrame:CGRectMake(0, bodyImageView.frame.origin.y - 5, 300, nHeight + 10)];
    [btnSelection addTarget:self action:@selector(showOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
    [btnSelection setTag:index];
    [btnSelection setAlpha:0.5f];
    [contentScrollView addSubview:btnSelection];
    
    [bodyImageView release];
    
    y += footerImage.frame.origin.y - topImageView.frame.origin.y + 15;
    y -= shoutHeight;
    
    curY = y;
}

- (void)addPlace:(int)index {
    float y = curY;
    NSDictionary *content = [allArray objectAtIndex:index];

    [[DataManager sharedManager].placesArray addObject:[content retain]];
    int nHeight = 70.f;
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopPadding.png"]];
    [topImageView setFrame:CGRectMake(0, y, 300, 5)];
    [topImageView setContentMode:UIViewContentModeScaleToFill];
    [contentScrollView addSubview:topImageView];
    
    // Calculate Content Height
    
    UIImageView *bodyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ContentPadding.png"]];
    [bodyImageView setFrame:CGRectMake(0, y + 5, 300, nHeight)];
    [bodyImageView setContentMode:UIViewContentModeScaleToFill];
    [contentScrollView addSubview:bodyImageView];
    
    // Get Profile Image
    AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(9.f, y + 12.f, 53.f, 53.f)];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 1;
    pImageView.imageURL = [NSURL URLWithString:[[content objectForKey:@"value"] objectForKey:@"image_url"]];

    [contentScrollView addSubview:pImageView];
    [pImageView release];
    //        [pImageView release];
    
    UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(158.f, y + 7, 135.f, 12.f)];
    [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
    [lblMile setBackgroundColor:[UIColor clearColor]];
    [lblMile setTextAlignment:NSTextAlignmentRight];
    float mile = [[[content objectForKey:@"value"] objectForKey:@"distance"] floatValue] / 1609.34;
    
    [lblMile setText:[NSString stringWithFormat:@"%0.1f mi", mile]];
    //        [lblMile sizeToFit];
    [contentScrollView addSubview:lblMile];
    [lblMile release];

    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(70.f, y + 15, 220.f, 20.f)];
    [lblName setBackgroundColor:[UIColor clearColor]];
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
    [lblName setText:[[content objectForKey:@"value"] objectForKey:@"name"]];
    [lblName setTextColor:[UIColor colorWithRed:1.f green:.35f blue:0 alpha:1.f]];
    [contentScrollView addSubview:lblName];
    [lblName release];
    
    // Get Interest
    
    int x = 70.f;
    
    int nCommunity = [[[content objectForKey:@"value"] objectForKey:@"user_count"] intValue];
    
    UILabel *lblMatchingInterest = [[UILabel alloc] initWithFrame:CGRectMake(x,  y + 36, 0, 20)];
    [lblMatchingInterest setBackgroundColor:[UIColor clearColor]];
    [lblMatchingInterest setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:INTEREST_FONT_SIZE]];
    [lblMatchingInterest setText:[NSString stringWithFormat:@"%@",[content objectForKey:@"interest"]]];
    [lblMatchingInterest sizeToFit];
    [contentScrollView addSubview:lblMatchingInterest];
    if (lblMatchingInterest.frame.size.width > 200) {
        [lblMatchingInterest setFrame:CGRectMake(x, y + 36, 200, lblMatchingInterest.frame.size.height)];
    }
    
    [lblMatchingInterest release];
    
//    if (nCommunity > 0) {
        UILabel *lblCommunity = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 53, 220.f, 20.f)];
        [lblCommunity setBackgroundColor:[UIColor clearColor]];
        [lblCommunity setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
        [lblCommunity setText:(nCommunity == 0) ? @"Be the first to join this community" : (nCommunity == 1) ? [NSString stringWithFormat:@"%d person in this community", nCommunity] : [NSString stringWithFormat:@"%d people in this community", nCommunity]];
        [contentScrollView addSubview:lblCommunity];
        [lblCommunity release];
//    }
    //      wind-over-water-lessons-burlingame
//    NSLog(@"%@", [DataManager sharedManager].placeOfferDict);
//    NSLog(@"%@", [[DataManager sharedManager].placeOfferDict valueForKey:[[[content objectForKey:@"value"] objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]);
    NSLog(@"%@", [[[content objectForKey:@"value"] objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_invite"]){
        if ([placeOfferDict valueForKey:[[[content objectForKey:@"value"] objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) {
            NSDictionary *offerDict = [NSDictionary dictionaryWithObject:[[DataManager sharedManager].placeOfferDict objectForKey:[[[content objectForKey:@"value"] objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] forKey:[[[content objectForKey:@"value"] objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            float offer_y = bodyImageView.frame.origin.y + nHeight;
            
            UIImageView *imgLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfferLine.png"]];
            [imgLine setFrame:CGRectMake(10, offer_y, 279, 1)];
            [contentScrollView addSubview:imgLine];
            [imgLine release];
            
            UIImageView *imgIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfferIcon.png"]];
            [imgIcon setFrame:CGRectMake(20, ([[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] > 1) ? offer_y + 10 + ((16 * [[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] - 22) / 2.f) : offer_y + 10, 22, 22)];
            [contentScrollView addSubview:imgIcon];
            [imgIcon release];
            
            nHeight += ([[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] > 1) ? 10 + 16 * [[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] : 32;
            
            for (NSDictionary *dict in [offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]]) {
                UILabel *lblOffer = [[UILabel alloc] initWithFrame:CGRectMake(50, offer_y + 10, 250, 13)];
                [lblOffer setBackgroundColor:[UIColor clearColor]];
                [lblOffer setTextColor:[UIColor darkGrayColor]];
                [lblOffer setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.f]];
                [lblOffer setText:[dict objectForKey:@"find_text"]];
                [contentScrollView addSubview:lblOffer];
                [lblOffer release];
                
                offer_y += 16;
            }
        }
    } else {
        NSString *urlString = [NSString stringWithFormat:@"http://crazebot.com/offers.php?yelp_id=%@&auth_email=%@&auth=%@", [[[content objectForKey:@"value"] objectForKey:@"id"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [DataManager sharedManager].strEmail, [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"]];

        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:30];
        NSData *offerData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
        
        if (offerData != nil) {
            
            NSDictionary *offerDict = [[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:offerData];
            
            if (([offerDict count]) && ([[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count])) {
                //        if ([[offerDict objectForKey:@"wind-over-water-lessons-burlingame"] count]) {
                [placeOfferDict addEntriesFromDictionary:offerDict];
                [[DataManager sharedManager].placeOfferDict addEntriesFromDictionary:offerDict];
                
                float offer_y = bodyImageView.frame.origin.y + nHeight;
                
                UIImageView *imgLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfferLine.png"]];
                [imgLine setFrame:CGRectMake(10, offer_y, 279, 1)];
                [contentScrollView addSubview:imgLine];
                [imgLine release];
                
                UIImageView *imgIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfferIcon.png"]];
                [imgIcon setFrame:CGRectMake(20, ([[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] > 1) ? offer_y + 10 + ((16 * [[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] - 22) / 2.f) : offer_y + 10, 22, 22)];
                [contentScrollView addSubview:imgIcon];
                [imgIcon release];
                
//                nHeight += ([[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] > 1) ? 10 + 16 * [[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] : 32;
                nHeight += 10;
                
                for (NSDictionary *dict in [offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]]) {
                    UILabel *lblOffer = [[UILabel alloc] initWithFrame:CGRectMake(50, offer_y + 10, 220, 13)];
                    [lblOffer setNumberOfLines:10000];
                    [lblOffer setBackgroundColor:[UIColor clearColor]];
                    [lblOffer setTextColor:[UIColor darkGrayColor]];
                    [lblOffer setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.f]];
                    [lblOffer setText:[dict objectForKey:@"find_text"]];
                    [lblOffer sizeToFit];
                    [contentScrollView addSubview:lblOffer];
                    [lblOffer release];
                    
                    offer_y += lblOffer.frame.size.height + 3;
                    
                    nHeight += lblOffer.frame.size.height + 3;
                }
            }
        }
    }
    
    [bodyImageView setFrame:CGRectMake(0, bodyImageView.frame.origin.y, 300, nHeight)];
    
    // Add Footer Image
    UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
    [footerImage setFrame:CGRectMake(0, bodyImageView.frame.origin.y + nHeight, 300, 5)];
    [contentScrollView addSubview:footerImage];
    [bodyImageView release];
    
    y += nHeight + 20;
    
    UIButton *btnPlace = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPlace setFrame:CGRectMake(0, topImageView.frame.origin.y, 300, footerImage.frame.origin.y + footerImage.frame.size.height - topImageView.frame.origin.y )];
    [btnPlace addTarget:self action:@selector(placeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [btnPlace setTag:index];
    [contentScrollView addSubview:btnPlace];
    
    [footerImage release];
    [topImageView release];

    curY = y;
}
#pragma mark - Arrange Labels from result values
- (void)addNoPeopleLabel {
    float y = curY;
    UILabel *lblInvitePeople = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 300, 42)];
    [lblInvitePeople setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [lblInvitePeople setTextColor:UIColorFromRGB(0x757171)];
    [lblInvitePeople setText:@"Invite friends to find out\nwhich favorite activities you share!"];
    [lblInvitePeople setTextAlignment:NSTextAlignmentCenter];
    [lblInvitePeople setBackgroundColor:[UIColor clearColor]];
    [lblInvitePeople setNumberOfLines:2];
    [contentScrollView addSubview:lblInvitePeople];
    [lblInvitePeople release];
    
    y += 47;
    
    UIButton *btnFriend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFriend setImage:[UIImage imageNamed:@"FindFriendFB.png"] forState:UIControlStateNormal];
    [btnFriend addTarget:self action:@selector(findFriend) forControlEvents:UIControlEventTouchUpInside];
    [btnFriend setFrame:CGRectMake(0, y, 300, 44)];
    [contentScrollView addSubview:btnFriend];
    
    y += 55;
    
    curY = y;
}

- (void)addEmptyLabel {
    float y = curY;
    UILabel *lblInvitePeople = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 300, 42)];
    [lblInvitePeople setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [lblInvitePeople setTextColor:UIColorFromRGB(0x757171)];
    [lblInvitePeople setText:@"To see matching results try to adjust\nyour filters or add more activities!"];
    [lblInvitePeople setTextAlignment:NSTextAlignmentCenter];
    [lblInvitePeople setBackgroundColor:[UIColor clearColor]];
    [lblInvitePeople setNumberOfLines:2];
    [contentScrollView addSubview:lblInvitePeople];
    [lblInvitePeople release];
    
    y += 47;
    
    UIButton *btnFriend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFriend setImage:[UIImage imageNamed:@"AddInterestButton.png"] forState:UIControlStateNormal];
    [btnFriend addTarget:self action:@selector(addInterestPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnFriend setFrame:CGRectMake(0, y, 300, 40)];
    [contentScrollView addSubview:btnFriend];
    
    y += 55;
    
    curY = y;
}

- (void)addOverlayImage {
    overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:overlayButton];
    
    overlayImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (!IS_IPHONE5) {
        [overlayImg setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 20)];
    }
    [overlayImg setImage:[UIImage imageNamed:(IS_IPHONE5) ? @"Overlay_i5.png" : @"Overlay_i4.png"]];
    [self.view addSubview: overlayImg];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"INSTALLED"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, SCREEN_HEIGHT - 44, 320, 44)];
    if (!IS_IPHONE5) {
        [button setFrame:CGRectMake(0, 308, 320, 40)];
    }
    [button addTarget:self action:@selector(hideOverlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)hideOverlay:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    [overlayImg removeFromSuperview];
    [overlayButton removeFromSuperview];
    
    [button removeFromSuperview];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ENTER_BACKGROUND"]) {
        [SVProgressHUD showWithStatus:@"Finding nearby results" maskType:SVProgressHUDMaskTypeClear];
    } else {
        [SVProgressHUD dismiss];
    }
}


#pragma mark - UISlider Delegate Action

- (void)updateRangeSlider:(UISlider *)slider {
    radiusFilter = (1 + (int)(slider.value * 49.f)) * 1609.34;
    placeRadius = radiusFilter;
    [lblRadiusValue setText:[NSString stringWithFormat:@"%dmi", 1 + (int)(slider.value * 49.f)]];
    bFilterChanged = TRUE;
}

- (void)updateAgeSlider:(NMRangeSlider *)slider {
    ageFilterMin = 18 + (int)(slider.lowerValue * 52.f);
    ageFilterMax = 18 + (int)(slider.upperValue * 52.f);
    
    [lblAgeMin setText:[NSString stringWithFormat:@"%d", ageFilterMin]];
    
    [lblAgeMax setText:(ageFilterMax >= 70.f) ? [NSString stringWithFormat:@"%d+", ageFilterMax] : [NSString stringWithFormat:@"%d", ageFilterMax]];
    
    if (ageFilterMax > 70.f) {
        ageFilterMax = 200;
    }
    bFilterChanged = TRUE;
}

#pragma mark - UIbutton Actions

- (IBAction)menuSelect:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self donePicker:nil];

    if ([button isSelected]) {
        [button setSelected:NO];
        [filterScrollView setFrame:CGRectMake(0, 74 + [DataManager sharedManager].fiOS7StatusHeight, 320, (IS_IPHONE5) ? 474 : 386)];
        [contentScrollView setFrame:CGRectMake(10, 78 + [DataManager sharedManager].fiOS7StatusHeight, 310.f, 0)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.5f];
        [filterScrollView setFrame:CGRectMake(filterScrollView.frame.origin.x, filterScrollView.frame.origin.y, filterScrollView.frame.size.width, 0)];
        [contentScrollView setFrame:CGRectMake(10, 78 + [DataManager sharedManager].fiOS7StatusHeight, 310.f, SCREEN_HEIGHT - 78 - [DataManager sharedManager].fiOS7StatusHeight)];
        [UIView commitAnimations];

        if (bFilterChanged) {
            
            for (UIView *view in [contentScrollView subviews]) {
                [view removeFromSuperview];
            }
            
            
            [SVProgressHUD showWithStatus:@"Filtering" maskType:SVProgressHUDMaskTypeClear];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"INTEREST_UPDATE"]) {
                [self getUsersNearBy];
            } else {
                [self performSelector:@selector(orderTheUser) withObject:nil afterDelay:0.5f];
            }
            
            bFilterChanged = false;
        }
        
    } else {
        [filterScrollView setFrame:CGRectMake(filterScrollView.frame.origin.x, filterScrollView.frame.origin.y, filterScrollView.frame.size.width, 0)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.5f];
        [filterScrollView setFrame:CGRectMake(0, 74 + [DataManager sharedManager].fiOS7StatusHeight, 320, (IS_IPHONE5) ? 474 : 386)];
        [contentScrollView setFrame:CGRectMake(10, 78 + [DataManager sharedManager].fiOS7StatusHeight, 310.f, 0)];
        [UIView commitAnimations];
        
        [button setSelected:YES];
//        [self initFilterView];
    }
    
    return;
}


- (IBAction)ageButtonPressed:(id)sender {
    [agePicker setHidden:NO];
    [radiusPicker setHidden:YES];
    [pickerToolbar setHidden:NO];
    [self.view bringSubviewToFront:agePicker];
    [UIView beginAnimations:nil context:nil];
    
    [agePicker setFrame:CGRectMake(0, (IS_IPHONE5) ? 332 + [DataManager sharedManager].fiOS7StatusHeight : 264 + [DataManager sharedManager].fiOS7StatusHeight, 320, 216)];
    [pickerToolbar setFrame:CGRectMake(0, (IS_IPHONE5) ? 288 + [DataManager sharedManager].fiOS7StatusHeight : 224 + [DataManager sharedManager].fiOS7StatusHeight, 320.0, 44.f)];
    [btnDone setHidden:NO];
    [UIView commitAnimations];
}

- (IBAction)radiusButtonPressed:(id)sender {
    [agePicker setHidden:YES];
    [radiusPicker setHidden:NO];
    [pickerToolbar setHidden:NO];
    [self.view bringSubviewToFront:radiusPicker];
    [UIView beginAnimations:nil context:nil];
    [radiusPicker setFrame:CGRectMake(0, (IS_IPHONE5) ? 332 + [DataManager sharedManager].fiOS7StatusHeight : 264 + [DataManager sharedManager].fiOS7StatusHeight, 320, 216)];
    [pickerToolbar setFrame:CGRectMake(0, (IS_IPHONE5) ? 288 + [DataManager sharedManager].fiOS7StatusHeight : 224 + [DataManager sharedManager].fiOS7StatusHeight, 320.0, 44.f)];
    [btnDone setHidden:NO];
    [UIView commitAnimations];
}

- (IBAction)donePicker:(id)sender {
    [agePicker setHidden:YES];
    [radiusPicker setHidden:YES];
    [pickerToolbar setHidden:YES];
    [btnDone setHidden:YES];
    [UIView beginAnimations:nil context:nil];
    
    [agePicker setFrame:CGRectMake(0, (IS_IPHONE5) ? 612 : 524, 320, 216)];
    [radiusPicker setFrame:CGRectMake(0, (IS_IPHONE5) ? 612 : 524, 320, 216)];
    [pickerToolbar setFrame:CGRectMake(0, (IS_IPHONE5) ? 568 : 480, 320, 44.f)];
    
    [UIView commitAnimations];
}

- (IBAction)addInterestPressed:(id)sender {
    bFilterChanged = TRUE;
    bAddActivity = FALSE;
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"ShoutOut"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"AddInterestViewController"];
    [self.navigationController pushViewController:interstViewController animated:YES];
}

- (void)interestFilterPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    if (!button.selected) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[interestFilterArray objectAtIndex:button.tag] objectForKey:@"value"], @"value", @"FALSE", @"valid", nil];
        [interestFilterArray replaceObjectAtIndex:button.tag withObject:dict];
        
        if ([self checkSelectedInterest] == FALSE) {
            [button setSelected:YES];
            NSDictionary *dt = [NSDictionary dictionaryWithObjectsAndKeys:[[interestFilterArray objectAtIndex:button.tag] objectForKey:@"value"], @"value", @"TRUE", @"valid", nil];
            [interestFilterArray replaceObjectAtIndex:button.tag withObject:dt];
        }
    } else {
        NSDictionary *dt = [NSDictionary dictionaryWithObjectsAndKeys:[[interestFilterArray objectAtIndex:button.tag] objectForKey:@"value"], @"value", @"TRUE", @"valid", nil];
        [interestFilterArray  replaceObjectAtIndex:button.tag withObject:dt];
    }
}

- (BOOL)checkSelectedInterest {
    for (NSDictionary *dict in interestFilterArray) {
        if ([[dict objectForKey:@"valid"] isEqualToString:@"TRUE"]) {
            return TRUE;
        }
    }
    return FALSE;
}

- (IBAction)filterByButtonPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == btnFilterByPeople) {
        [btnFilterByPeople setSelected:!btnFilterByPeople.selected];
        if (btnFilterByPeople.selected) {
            nFilterBy = (btnFilterByPlace.selected) ? 2 : 0;
        } else {
            nFilterBy = (btnFilterByPlace.selected) ? 1 : 0;
            if (nFilterBy == 0) {
                [btnFilterByPeople setSelected:YES];
            }
        }
    } else if (button == btnFilterByPlace) {
        [btnFilterByPlace setSelected:!btnFilterByPlace.selected];
        if (btnFilterByPlace.selected) {
            nFilterBy = (btnFilterByPeople.selected) ? 2 : 1;
        } else {
            nFilterBy = (btnFilterByPeople.selected) ? 0 : 1;
            if (nFilterBy == 1) {
                [btnFilterByPlace setSelected:YES];
            }
        }
    }
    
    
}


- (void)shoutoutPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"ShoutOut"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    UIViewController *interstViewController = [storyboard instantiateViewControllerWithIdentifier:@"ShoutOutViewController"];
    [self.navigationController pushViewController:interstViewController animated:YES];
}


- (void)showOtherProfile:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [profileController setBMine:FALSE];
    if ([[DataManager sharedManager].othersShoutout count]) {
        [[DataManager sharedManager].othersShoutout removeAllObjects];
    }
    

    NSString *fbID = [[allArray objectAtIndex:button.tag] objectForKey:@"facebookId"];
    if ([mutualDict valueForKey:fbID]) {
        int nMutual = [[mutualDict objectForKey:fbID] intValue];
        if (nMutual != 0) {
            profileController.bFriend = TRUE;
        }
    } else if (fbID != nil) {
        profileController.bFriend = FALSE;
    }
    
    NSArray *arr = [[allArray objectAtIndex:button.tag] objectForKey:@"shoutouts"];
    if (![arr isEqual:[NSNull null]]) {
        for (NSDictionary *sDict in arr ) {
            [[DataManager sharedManager].othersShoutout addObject:sDict];
        }
    }
    
    profileController.email = [[allArray objectAtIndex:button.tag] objectForKey:@"email"];

//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ChatMessage"]) {
//        [self.navigationController pushViewController:profileController animated:NO];
//    } else {
        [self.navigationController pushViewController:profileController animated:YES];
//    }
    
}


- (void)placeSelect:(id)sender {
    UIButton *sButton = (UIButton *)sender;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    if ((newPlaceDict != nil) && ([[[[allArray objectAtIndex:[sButton tag]] objectForKey:@"value"] objectForKey:@"id"] isEqualToString:[[newPlaceDict objectForKey:@"value"] valueForKey:@"id"]])) {
        PlaceProfileViewController *profileController = (PlaceProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaceProfileViewController"];
//        NSDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:[response objectAtIndex:0]];
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"address"] forKey:@"address"]];
//        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"yelp_id"] forKey:@"id"]];
//        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:
//                                        [NSString stringWithFormat:@"%f",
//                                         [self getDistance:[[[result objectForKey:@"loc"] objectAtIndex:1] floatValue]
//                                                _longitude:[[[result objectForKey:@"loc"] objectAtIndex:0] floatValue]]]
//                                                                   forKey:@"distance"]];
//        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"pic"] forKey:@"image_url"]];
//        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"name"] forKey:@"name"]];
//        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"links"] forKey:@"links"]];
//        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[result objectForKey:@"user_count"] forKey:@"user_count"]];
//        
//        newPlaceDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"PlACE", @"99999999999999", @"Kiteboarding", dict, nil]
//                                                            forKeys:[NSArray arrayWithObjects:@"data_type", @"distance", @"interest", @"value", nil]];
        profileController.strTitle = [[newPlaceDict objectForKey:@"value"] objectForKey:@"name"];
        //    profileController.contentDictionary = [placesArray objectAtIndex:[sButton tag]];
        profileController.strInterest = [[[newPlaceDict objectForKey:@"value"] objectForKey:@"interests"] componentsJoinedByString:@","];
        profileController.strID = [[newPlaceDict objectForKey:@"value"] objectForKey:@"id"];
        profileController.placeOfferArray = [[NSMutableArray alloc] initWithArray:[placeOfferDict objectForKey:[[newPlaceDict objectForKey:@"value"] objectForKey:@"id"]]];
        profileController.distance = [[[[allArray objectAtIndex:[sButton tag]] objectForKey:@"value"] objectForKey:@"distance"] floatValue];
        [self.navigationController pushViewController:profileController animated:YES];
    } else {
        PlaceProfileViewController *profileController = (PlaceProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaceProfileViewController"];
        
        profileController.strTitle = [[[allArray objectAtIndex:[sButton tag]] objectForKey:@"value"] objectForKey:@"name"];
        profileController.strInterest = [[allArray objectAtIndex:[sButton tag]] objectForKey:@"interest"];
        profileController.strID = [[[allArray objectAtIndex:[sButton tag]] objectForKey:@"value"] objectForKey:@"id"];
        profileController.placeOfferArray = [[NSMutableArray alloc] initWithArray:[placeOfferDict objectForKey:[[[allArray objectAtIndex:[sButton tag]] objectForKey:@"value"] objectForKey:@"id"]]];
        profileController.distance = [[[[allArray objectAtIndex:[sButton tag]] objectForKey:@"value"] objectForKey:@"distance"] floatValue];
        [self.navigationController pushViewController:profileController animated:YES];
    }
}
- (IBAction)hidePicker:(id)sender {
    [self donePicker:nil];
}

- (void)findFriend {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"InviteFBFriendViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

#pragma mark - Map Kit Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MapAnnotation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
                annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
        } else {
            annotationView.annotation = annotation;
        }
        
        if ([[(MapAnnotation *)annotation pinType] intValue] == 0)
            annotationView.image = [UIImage imageNamed:@"blue pin.png"];
        else
            annotationView.image    = [UIImage imageNamed:@"orange pin.png"];
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if(![view.annotation isKindOfClass:[MKUserLocation class]]) {
        
    }
    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    for (UIView *subview in view.subviews ){
            [subview removeFromSuperview];
    }
}

#pragma mark - UIPickerView delegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == agePicker) {
        return 8;
    } else if (pickerView == radiusPicker) {
        return 7;
    }
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == agePicker) {
        return [ageFilterArray objectAtIndex:row];
    } else if (pickerView == radiusPicker) {
        return [radiusFilterArray objectAtIndex:row];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == agePicker) {
        if (row == 0) {
            ageFilterMin = 0;
            ageFilterMax = 200;
            
            [lblAge setText:@"All"];
        } else {
            NSString *range = [ageFilterArray objectAtIndex:row];
            ageFilterMin = [[range substringToIndex:2] intValue];
            ageFilterMax = [[range substringFromIndex:3] intValue];
            if (ageFilterMax == 0) {
                ageFilterMax = 200;
            }
            [lblAge setText:[ageFilterArray objectAtIndex:row]];
        }
    } else if (pickerView == radiusPicker) {
        if (row == 6) {
            radiusFilter = 50 * 1609.34;
            placeRadius = radiusFilter;
            [lblRadius setText:@"Max"];
        } else {
            NSString *value = [radiusFilterArray objectAtIndex:row];
            radiusFilter = [[value substringToIndex:(value.length - 2)] floatValue] * 1609.34;
            placeRadius = radiusFilter;
            [lblRadius setText:[radiusFilterArray objectAtIndex:row]];
        }
    }
    
    bFilterChanged = TRUE;
}

- (void)viewDidUnload {
    [self setGeoCoder:nil];
    [self setLocationManager:nil];
    [menuView release];
    menuView = nil;
    [filterByTableView release];
    filterByTableView = nil;
    [interestTableView release];
    interestTableView = nil;
    [lblInterest release];
    lblInterest = nil;
    [btnDone release];
    btnDone = nil;
    [super viewDidUnload];
}

#pragma mark - UITableViewDeletage

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == filterByTableView) {
        return [filterByTableArray count];
    } else if (tableView == interestTableView) {
        return [interestFilterArray count];
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"InterestCell";
    
    UITableViewCell *cell = nil;
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    
    if (tableView == filterByTableView) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkImage.png"]];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        cell.accessoryView = imgView;
        [imgView release];
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.f]];
        [cell.textLabel setText:[filterByTableArray objectAtIndex:indexPath.row]];
    } else if (tableView == interestTableView) {
        if ([[interestFilterArray objectAtIndex:indexPath.row] objectForKey:@"valid"]) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkImage.png"]];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            cell.accessoryView = imgView;
            [imgView release];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setAccessoryView:nil];
        }
        
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.f]];
        [cell.textLabel setText:[[interestFilterArray objectAtIndex:indexPath.row] objectForKey:@"value"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    bFilterChanged = TRUE;
    if (tableView == filterByTableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            if (nFilterBy == 0) {
                return;
            } else if (nFilterBy == 1) {
                nFilterBy = 2;
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkImage.png"]];
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [cell setAccessoryView:imgView];
                [imgView release];
            } else if (nFilterBy == 2) {
                nFilterBy = 1;
                [cell setAccessoryView:nil];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        } else if (indexPath.row == 1) {
            if (nFilterBy == 1) {
                return;
            } else if (nFilterBy == 0) {
                nFilterBy = 2;
                UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkImage.png"]];
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [cell setAccessoryView:imgView];
                [imgView release];
            } else if (nFilterBy == 2) {
                nFilterBy = 0;
                [cell setAccessoryView:nil];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    } else if (tableView == interestTableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cntSelInterest --;
            if (cntSelInterest == 0) {
                cntSelInterest = 1;
            } else {
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[interestFilterArray objectAtIndex:indexPath.row] objectForKey:@"value"], @"value", @"FALSE", @"valid", nil];
                [interestFilterArray replaceObjectAtIndex:indexPath.row withObject:dict];
            
                [cell setAccessoryView:nil];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        } else if (cell.accessoryType == UITableViewCellAccessoryNone) {
            NSDictionary *dt = [NSDictionary dictionaryWithObjectsAndKeys:[[interestFilterArray objectAtIndex:indexPath.row] objectForKey:@"value"], @"value", @"TRUE", @"valid", nil];
            [interestFilterArray replaceObjectAtIndex:indexPath.row withObject:dt];

            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkImage.png"]];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [cell setAccessoryView:imgView];
            [imgView release];
            cntSelInterest ++;
        }

    }
}

@end
