//
//  InterestSelectViewController.m
//  Findy
//
//  Created by iPhone on 7/31/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "InterestSelectViewController.h"
#import "InitialSlidingViewController.h"
#import "DataManager.h"
#import "FindyAPI.h"

@interface InterestSelectViewController ()

@end

@implementation InterestSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
     
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"DoneButton.png"] forState:UIControlStateNormal];
    [nextButton setFrame:CGRectMake(263.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 49.f, 30.f)];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"Add Favorite Activities"];
    [self.view addSubview:lblTitle];
  
    
//    popularArray = [[NSMutableArray alloc] init];
    fArray = [[NSMutableArray alloc] initWithObjects:@"Archery", @"Cycling", @"Fitness and Workout", @"Golf", @"Hiking", @"Kiteboarding", @"Martial Arts", @"Mountain biking", @"Photography", @"Rock climbing", @"Running", @"Salsa dancing", @"Scuba diving", @"Surfing", @"Tennis", @"Yoga", nil];
    ppArray = [[NSMutableArray alloc] initWithObjects:@"Archery", @"Cycling", @"Fitness and Workout", @"Golf", @"Hiking", @"Kiteboarding", @"Martial Arts", @"Mountain biking", @"Photography", @"Rock climbing", @"Running", @"Salsa dancing", @"Scuba diving", @"Surfing", @"Tennis", @"Yoga", nil];
    selectedArray = [[NSMutableArray alloc] init];
    [[FindyAPI instance] getAllCraze:self withSelector:@selector(getAllCraze:) andOptions:nil];

    //    popularArray = [[NSMutableArray alloc] initWithObjects:@"Archery", @"Fitness and Workout", @"Football", @"Golf", @"Hang gliding", @"Jogging", @"Movies", @"Sailing", nil];
//    selectedArray = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", nil];
//    [_interestTable reloadData];
}

- (void)getAllCraze:(NSMutableDictionary *)response {

    popularArray = [[NSMutableArray alloc] initWithArray:[[response objectForKey:@"Parents"] objectForKey:@"Activities"]];
    [popularArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    interestArray = [[NSMutableArray alloc] init];
    [self initTable];
}

- (void)initTable {
    
    if (sectionArray != nil) {
        [sectionArray removeAllObjects];
        [sectionArray release];
        sectionArray = nil;
    }
    
    if (ppArray != nil) {
        [ppArray removeAllObjects];
        [ppArray addObjectsFromArray:fArray];
    }
    
    [popularArray removeObjectsInArray:interestArray];
    [ppArray removeObjectsInArray:interestArray];
    
    sectionArray = [[NSMutableArray alloc] init];
    [interestArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [ppArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    for (int i = 0; i < [popularArray count]; i++) {
        NSString *interest = [popularArray objectAtIndex:i];
        if ((![interestArray containsObject:interest]) && (![ppArray containsObject:interest])) {
            
            NSString *fChar = [interest substringToIndex:1];
            
            if (![sectionArray containsObject:fChar]) {
                [sectionArray addObject:[fChar uppercaseString]];
            }
            
        }
    }
    
    [self configureArray:popularArray];
    
    [_interestTable reloadData];
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

    if ([interestArray count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select at least one activity." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    if ([DataManager sharedManager].interestArray) {
        [[DataManager sharedManager].interestArray removeAllObjects];
    }
    
    if ([DataManager sharedManager].imgFace == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Your profile image on Facebook is required" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [[DataManager sharedManager].interestArray addObjectsFromArray:interestArray];

    NSString *strToken = @"";
    strToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
    
    if (!IsNSStringValid(strToken)) strToken = @"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]) {
        NSString *backData = [[UIImageJPEGRepresentation([DataManager sharedManager].imgBack, 1.0) base64Encoding] stringByReplacingOccurrencesOfString:@"+" withString:@":::"];
        NSString *faceData =  [[UIImageJPEGRepresentation([DataManager sharedManager].imgFace, 1.0) base64Encoding] stringByReplacingOccurrencesOfString:@"+" withString:@":::"];
        
        NSString *key = @"FindyiPhoneApp";
        
        NSData *eData = [[[DataManager sharedManager].strEmail dataUsingEncoding: NSASCIIStringEncoding] AESEncryptWithPassphrase:key];
        
        [Base64 initialize];
        NSString *password = [Base64 encode:eData];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"USER_PASSWORD"];
        
        
        NSMutableDictionary *authenticationCredentails = [[NSMutableDictionary alloc] init];
        
        if (IsNSStringValid([DataManager sharedManager].strEmail)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strEmail forKey:@"email"]];
        }
        if (IsNSStringValid(password)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:password forKey:@"password"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strFirstName)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strFirstName forKey:@"first"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strLastName)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strLastName forKey:@"last"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strBirthday)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strBirthday forKey:@"birthyear"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strGender)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strGender forKey:@"gender"]];
        }
        if (IsNSStringValid([DataManager sharedManager].fbID)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].fbID forKey:@"facebookId"]];
        }
        if ([[FBSession activeSession] isOpen]) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[[FBSession activeSession] accessTokenData] accessToken] forKey:@"facebookaccesstoken"]];
        }
        [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:([DataManager sharedManager].imgBack == nil) ? @" " : backData forKey:@"pic_big_data"]];
        [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:([DataManager sharedManager].imgFace == nil) ? @" " : faceData forKey:@"pic_small_data"]];
        [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f",[DataManager sharedManager].longitude] forKey:@"long"]];
        [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude ] forKey:@"lat"]];
        if (ISNSArrayValid([DataManager sharedManager].interestArray)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[DataManager sharedManager].interestArray componentsJoinedByString:@","] forKey:@"craze"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strCity)) {
            NSLog(@"------%@", [DataManager sharedManager].strCity);
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strCity forKey:@"city"]];
        }
        if (IsNSStringValid(strToken)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:strToken forKey:@"devicetoken"]];
        }

//        authenticationCredentails =
//        [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
//                                                    [DataManager sharedManager].strEmail,
//                                                    password,
//                                                    @" ",
//                                                    [DataManager sharedManager].strFirstName,
//                                                    [DataManager sharedManager].strLastName,
//                                                    @" ",
//                                                    [DataManager sharedManager].strBirthday,
//                                                    [DataManager sharedManager].strGender,
//                                                    [DataManager sharedManager].fbID,
//                                                    @" ",
//                                                    ([DataManager sharedManager].imgBack == nil) ? @" " : backData,
//                                                    ([DataManager sharedManager].imgFace == nil) ? @" " : faceData,
//                                                    [NSString stringWithFormat:@"%f",[DataManager sharedManager].longitude],
//                                                    [NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude ],
//                                                    [[DataManager sharedManager].interestArray componentsJoinedByString:@","],
//                                                    [DataManager sharedManager].strCity,
//                                                    strToken, nil]
//                                           forKeys:[NSArray arrayWithObjects:
//                                                    @"email",
//                                                    @"password",
//                                                    @"twitter",
//                                                    @"first",
//                                                    @"last",
//                                                    @"zip",
//                                                    @"birthyear",
//                                                    @"gender",
//                                                    @"facebookId",
//                                                    @"facebookaccesstoken",
//                                                    @"pic_big",
//                                                    @"pic_small",
//                                                    @"long",
//                                                    @"lat",
//                                                    @"craze", @"city", @"devicetoken", nil]];

        [[FindyAPI instance] RegisterUserForObject:self
                                      withSelector:@selector(authFacebookResult:)
                                        andOptions:authenticationCredentails];
    } else {
        
        NSMutableDictionary *authenticationCredentails = [[NSMutableDictionary alloc] init];
        if (IsNSStringValid([DataManager sharedManager].strEmail)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strEmail forKey:@"email"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strPassword)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strPassword forKey:@"password"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strFirstName)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strFirstName forKey:@"first"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strLastName)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strLastName forKey:@"last"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strBirthday)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strBirthday forKey:@"birthyear"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strGender)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strGender forKey:@"gender"]];
        }

        [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:([DataManager sharedManager].imgBack == nil) ? @" " : [[UIImageJPEGRepresentation([DataManager sharedManager].imgBack, 1.0) base64Encoding] stringByReplacingOccurrencesOfString:@"+" withString:@":::"] forKey:@"pic_big_data"]];
        [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:([DataManager sharedManager].imgFace == nil) ? @" " : [[UIImageJPEGRepresentation([DataManager sharedManager].imgFace, 1.0) base64Encoding]  stringByReplacingOccurrencesOfString:@"+" withString:@":::"] forKey:@"pic_small_data"]];
        [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f",[DataManager sharedManager].longitude] forKey:@"long"]];
        [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude ] forKey:@"lat"]];
        if (ISNSArrayValid([DataManager sharedManager].interestArray)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[DataManager sharedManager].interestArray componentsJoinedByString:@","] forKey:@"craze"]];
        }
        if (IsNSStringValid([DataManager sharedManager].strCity)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[DataManager sharedManager].strCity forKey:@"city"]];
        }
        if (IsNSStringValid(strToken)) {
            [authenticationCredentails addEntriesFromDictionary:[NSDictionary dictionaryWithObject:strToken forKey:@"devicetoken"]];
        }
        
//        authenticationCredentails =
//        [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
//                                                    [DataManager sharedManager].strEmail,
//                                                    [DataManager sharedManager].strPassword,
//                                                    @" ",
//                                                    [DataManager sharedManager].strFirstName,
//                                                    [DataManager sharedManager].strLastName,
//                                                    @" ",
//                                                    [DataManager sharedManager].strBirthday,
//                                                    [DataManager sharedManager].strGender,
//                                                    @" ",
//                                                    @" ",
//                                                    ([DataManager sharedManager].imgBack == nil) ? @" " : [[UIImageJPEGRepresentation([DataManager sharedManager].imgBack, 1.0) base64Encoding] stringByReplacingOccurrencesOfString:@"+" withString:@":::"],
//                                                    ([DataManager sharedManager].imgFace == nil) ? @" " : [[UIImageJPEGRepresentation([DataManager sharedManager].imgFace, 1.0) base64Encoding]  stringByReplacingOccurrencesOfString:@"+" withString:@":::"],
//                                                    [NSString stringWithFormat:@"%f",[DataManager sharedManager].longitude],
//                                                    [NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude ],
//                                                    [[DataManager sharedManager].interestArray componentsJoinedByString:@","],
//                                                    [DataManager sharedManager].strCity,
//                                                    strToken,
//                                                    nil]
//                                           forKeys:[NSArray arrayWithObjects:
//                                                    @"email",
//                                                    @"password",
//                                                    @"twitter",
//                                                    @"first",
//                                                    @"last",
//                                                    @"zip",
//                                                    @"birthyear",
//                                                    @"gender",
//                                                    @"facebookId",
//                                                    @"facebookaccesstoken",
//                                                    @"pic_big",
//                                                    @"pic_small",
//                                                    @"long",
//                                                    @"lat",
//                                                    @"craze",
//                                                    @"city", @"devicetoken", nil]];

        [[FindyAPI instance] RegisterUserForObject:self
                                   withSelector:@selector(authenticationResult:)
                                     andOptions:authenticationCredentails];
    }
}

- (void) authFacebookResult:(NSDictionary*) response {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
    if ([response objectForKey:@"success"]) {
        
        if (!IsNSStringValid([DataManager sharedManager].strPicBig)) {
            [DataManager sharedManager].strPicBig = [NSString stringWithFormat:@"http://crazebot.com/userpic_big.php?email=%@", [DataManager sharedManager].strEmail];
        }
        if (!IsNSStringValid([DataManager sharedManager].strPicSmall)) {
            [DataManager sharedManager].strPicSmall = [NSString stringWithFormat:@"http://crazebot.com/userpic_small.php?email=%@", [DataManager sharedManager].strEmail];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"FACEBOOK_REGISTER"];
        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"auth"] forKey:@"auth_value"];
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"FIRST_REGISTER"];

        InitialSlidingViewController *slideView = [[InitialSlidingViewController alloc] init];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:slideView] animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Register" message:@"We got an error to register!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void) authenticationResult:(NSDictionary*) response {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
    if ([response objectForKey:@"success"]) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"EMAIL_SIGNIN"];
        [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strEmail forKey:@"USER_EMAIL"];
        [[NSUserDefaults standardUserDefaults] setObject:[DataManager sharedManager].strPassword forKey:@"USER_PASSWORD"];
        InitialSlidingViewController *slideView = [[InitialSlidingViewController alloc] init];
        [self.navigationController setViewControllers:[NSArray arrayWithObject:slideView] animated:YES];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"EMAIL_SIGNIN"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Register" message:[response objectForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    if ([searchText isEqualToString:@""]) {
        [suggestView setHidden:YES];
        return;
    }
    
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];
    if (searchResults != nil) {
        [searchResults removeAllObjects];
        [searchResults release];
    }
    
    //    [popularArray addObjectsFromArray:interestArray];
    [ppArray  removeObjectsInArray:popularArray];
    
    [popularArray addObjectsFromArray:ppArray];
    searchResults = [[NSMutableArray alloc] initWithArray:[popularArray filteredArrayUsingPredicate:resultPredicate]];
    
    [ppArray removeObjectsInArray:searchResults];
    
    if ([searchResults count] == 0) {
        [suggestView setHidden:NO];
        [self.view bringSubviewToFront:suggestView];
    } else {
        [suggestView setHidden:YES];
    }
    
    if (sectionArray != nil) {
        [sectionArray removeAllObjects];
        [sectionArray release];
        sectionArray = nil;
    }
    
    sectionArray = [[NSMutableArray alloc] init];
    [interestArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [searchResults sortUsingSelector:@selector(caseInsensitiveCompare:)];
    for (int i = 0; i < [searchResults count]; i++) {
        NSString *interest = [searchResults objectAtIndex:i];
        
        NSString *fChar = [interest substringToIndex:1];
        
        if (![sectionArray containsObject:fChar]) {
            [sectionArray addObject:[fChar uppercaseString]];
        }
    }
    
    
    [self configureSearchResult:searchResults];
}

- (void)configureSearchResult:(NSArray *)array {
    NSInteger index, sectionTitlesCount = [sectionArray count];
    
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
	// Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
	}
    
    [popularArray removeObjectsInArray:interestArray];
    [ppArray removeObjectsInArray:interestArray];
    
    for (NSString *section in array) {
        if (![interestArray containsObject:section]) {
            NSString *fChar = [section substringToIndex:1];
            
            NSInteger sectionNumber = [sectionArray indexOfObject:fChar];
            
            NSMutableArray *sectionTimeZones = newSectionsArray[sectionNumber];
            
            [sectionTimeZones addObject:section];
        }
	}
    
    NSLog(@"%@", newSectionsArray);
    
    for (index = 0; index < sectionTitlesCount; index++) {
        
		NSMutableArray *sArray = newSectionsArray[index];
        if ([sArray count] == 0) {
            [newSectionsArray removeObjectAtIndex:index];
            sectionTitlesCount --;
            index --;
        } else {
            [sArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
            
            // Replace the existing array with the sorted array.
            newSectionsArray[index] = sArray;
        }
	}
    
    sectionArray = [[NSMutableArray alloc] initWithArray:newSectionsArray];
}


- (void)configureArray:(NSMutableArray *)array {
    NSInteger index, sectionTitlesCount = [sectionArray count];
    
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
	// Set up the sections array: elements are mutable arrays that will contain the time zones for that section.
	for (index = 0; index < sectionTitlesCount; index++) {
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[newSectionsArray addObject:array];
	}
    
    [popularArray removeObjectsInArray:interestArray];
    [ppArray removeObjectsInArray:interestArray];
    
    for (NSString *section in array) {
        if ((![interestArray containsObject:section]) && (![ppArray containsObject:section])) {
            NSString *fChar = [section substringToIndex:1];
            
            NSInteger sectionNumber = [sectionArray indexOfObject:fChar];
            
            NSMutableArray *sectionTimeZones = newSectionsArray[sectionNumber];
            
            [sectionTimeZones addObject:section];
        }
	}
    
    for (index = 0; index < sectionTitlesCount; index++) {
        
		NSMutableArray *sArray = newSectionsArray[index];
        if ([sArray count] == 0) {
            [newSectionsArray removeObjectAtIndex:index];
            sectionTitlesCount --;
            index --;
        } else {
            [sArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
            
            // Replace the existing array with the sorted array.
            newSectionsArray[index] = sArray;
        }
	}
    
    //    sectionArray = newSectionsArray;
    if ([interestArray count]) {
        sectionArray = [[NSMutableArray alloc] initWithArray:[[[NSMutableArray arrayWithObject:interestArray] arrayByAddingObject:ppArray] arrayByAddingObjectsFromArray:newSectionsArray]];
    } else if ([ppArray count]) {
        sectionArray = [[NSMutableArray alloc] initWithArray:[[NSMutableArray arrayWithObject:ppArray] arrayByAddingObjectsFromArray:newSectionsArray]];
    } else {
        sectionArray = [[NSMutableArray alloc] initWithArray:newSectionsArray];
    }

}

- (int)inCurrentInterest:(NSString *)interest {
    for (int i = 0; i < [[DataManager sharedManager].interestArray count]; i++) {
        NSString *inter = [[DataManager sharedManager].interestArray objectAtIndex:i];
        if ([inter isEqualToString:interest]) {
            return i;
        }
    }
    
    return -1;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[sectionArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSArray *sArray = [sectionArray objectAtIndex:section];
        if ([sArray count]) {
            NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
            return str;
        } else {
            return nil;
        }
    } else {
        if (section == 0) {
            if ([interestArray count]) {
                return @"MY ACTIVITIES";
            } else {
                if ([ppArray count]) {
                    return @"POPULAR";
                } else {
                    NSArray *sArray = [sectionArray objectAtIndex:section];
                    if ([sArray count]) {
                        NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
                        return str;
                    } else {
                        return nil;
                    }
                }
            }
        } else if (section == 1) {
            if ([interestArray count]) {
                if ([ppArray count]) {
                    return @"POPULAR";
                } else {
                    NSArray *sArray = [sectionArray objectAtIndex:section];
                    if ([sArray count]) {
                        NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
                        return str;
                    } else {
                        return nil;
                    }
                }
            } else {
                
                NSArray *sArray = [sectionArray objectAtIndex:section];
                if ([sArray count]) {
                    NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
                    return str;
                } else {
                    return nil;
                }
            }
        } else {
            NSArray *sArray = [sectionArray objectAtIndex:section];
            if ([sArray count]) {
                NSString *str = [[[sArray objectAtIndex:0] substringToIndex:1] uppercaseString];
                return str;
            } else {
                return nil;
            }
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"InterestCell";
    
    UITableViewCell *cell = nil;
	cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.f]];
    
    cell.textLabel.text = [[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        if ((![[NSUserDefaults standardUserDefaults] boolForKey:@"ShoutOut"]) && (indexPath.section == 0) && ([interestArray count] != 0)) {
            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonSelect.png"]];
        } else {
            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonDeselect.png"]];
        }
    }
    
    return cell;
}

- (BOOL)checkInterestCount {
    if ([interestArray count] >= 10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You can select only 10 activities" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        
        return true;
    }
    
    return false;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (![self checkInterestCount]) {
            [interestArray addObject:[[[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] retain]];
            
            [self.searchDisplayController setActive:NO animated:YES];
            [tableView setScrollsToTop:YES];
        }
    } else {
        if ((indexPath.section == 0) && ([interestArray count] != 0)) {
            [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonDeselect.png"]];
            NSString *interest = [[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            
            if ([fArray containsObject:interest]) {
                [ppArray addObject:[interest retain]];
            } else {
                [popularArray addObject:[interest retain]];
            }
            
            int nIndex = [interestArray indexOfObject:interest];
            [interestArray removeObjectAtIndex:nIndex];
        } else {
            if (![self checkInterestCount]) {
                [cell.imageView setImage:[UIImage imageNamed:@"CheckButtonSelect.png"]];
                [interestArray addObject:[[[sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] retain]];
            }
        }
    }
    
    [self initTable];
}

- (void)dealloc {
    [_interestTable release];
    [popularArray release];
    [selectedArray release];
    [_topView release];
    [suggestView release];
    [super dealloc];
}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    searchActivity = [[NSString alloc] initWithString:searchString];
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
//    if ([searchResults count] == 0) {
//        [suggestView setHidden:YES];
//    }
    
    [self initTable];
}


- (void)viewDidUnload {
    [self setTopView:nil];
    [suggestView release];
    suggestView = nil;
    [super viewDidUnload];
}

- (IBAction)suggestActivity:(id)sender {
    UIAlertView *inputActivity = [[UIAlertView alloc] init];
    [inputActivity setAlertViewStyle:UIAlertViewStylePlainTextInput];
	[inputActivity setDelegate:self];
	[inputActivity setTitle:@"Suggest Activity"];
	[inputActivity addButtonWithTitle:@"Cancel"];
	[inputActivity addButtonWithTitle:@"Suggest"];
    [inputActivity textFieldAtIndex:0].text = searchActivity;
    [inputActivity show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:[alertView textFieldAtIndex:0].text forKey:@"craze"];
        [[FindyAPI instance] suggestActivity:self withSelector:@selector(suggestResult:) andOptions:paramDict];
    }
}

- (void)suggestResult:(NSDictionary *)response {

}

- (void)searchBarCancelButtonClicked:(UISearchBar *) aSearchBar {
//	[aSearchBar resignFirstResponder];
    [self.searchDisplayController setActive:NO animated:YES];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    //if we only try and resignFirstResponder on textField or searchBar,
    //the keyboard will not dissapear (at least not on iPad)!
    [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:self.searchDisplayController.searchBar afterDelay: 0.1];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // The user clicked the [X] button or otherwise cleared the text.
    if ([searchText isEqualToString:@""]) {
        
        [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:searchBar afterDelay:0.1f];
    }
}
@end
