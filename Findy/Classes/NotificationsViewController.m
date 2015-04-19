//
//  NotificationsViewController.m
//  Findy
//
//  Created by iPhone on 10/15/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "NotificationsViewController.h"
#import "ProfileViewController.h"
#import "JSONKit.h"

@interface NotificationsViewController ()

@end

@implementation NotificationsViewController

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
    [Flurry logEvent:@"Notification"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearNotification" object:nil];
    
	// Do any additional setup after loading the view.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
    [lblTitle setText:@"Notifications"];
    [self.view addSubview:lblTitle];
    
//    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
//        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
//    }
//    
    ECSlidingViewTopNotificationMacro;
    
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
}

- (void)viewWillAppear:(BOOL)animated {
    notificationsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", nil]];
    [[FindyAPI instance] getNotifications:self withSelector:@selector(getNotifications:) andOptions:paramDict];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [notificationTableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [notificationTableView release];
    notificationTableView = nil;
    [super viewDidUnload];
}

#pragma mark - Private Methods

- (void)getNotifications:(NSArray *)response {
    if (notificationsArray != nil) {
        [notificationsArray removeAllObjects];
        [notificationsArray release];
    }
    
    notificationsArray = [[NSMutableArray alloc] init];
    
    NSArray *currentArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_NOTIFICATION"];
    if (currentArray == nil) {
        currentArray = [[NSMutableArray alloc] init];
    }
    
    for (NSDictionary *content in response) {
        NSData *tmpObj = [NSKeyedArchiver archivedDataWithRootObject:content];
        if (IsNSStringValid([content objectForKey:@"first"])) {
            
            if ([currentArray containsObject:tmpObj]) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:content];
                [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"TRUE", @"is_read", nil]];
                
                [notificationsArray addObject:dict];
            } else {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:content];
                [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"FALSE", @"is_read", nil]];
                
                [notificationsArray addObject:dict];
            }
            
        }
    }
    
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:response.count];
    for (NSDictionary *personObject in response) {
        NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:personObject];
        [archiveArray addObject:personEncodedObject];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:archiveArray forKey:@"CURRENT_NOTIFICATION"];
//    NSLog(@"%@", notificationsArray);
    [notificationTableView reloadData];
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


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [notificationsArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    [lblContent setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
    
    int nIndex = [notificationsArray count] - indexPath.row - 1;
    NSDictionary *content = [notificationsArray objectAtIndex:nIndex];
    
    
    NSString *contentString = @"";
    if ([[content objectForKey:@"type"] isEqualToString:@"comment"]) {
        contentString = [NSString stringWithFormat:@"%@ commented on your shout-out!", [content objectForKey:@"first"]];
    } else if ([[[notificationsArray objectAtIndex:nIndex] objectForKey:@"type"] isEqualToString:@"favorite"]) {
        contentString = [NSString stringWithFormat:@"%@ favorited you!", [content objectForKey:@"first"]];
    } else if ([[[notificationsArray objectAtIndex:nIndex] objectForKey:@"type"] isEqualToString:@"shoutout"]) {
        contentString = [NSString stringWithFormat:@"%@ created a shout-out about %@! Check it out?", [content objectForKey:@"first"], [content objectForKey:@"interest"]];
    }
    
    CGSize size = [contentString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE] constrainedToSize:CGSizeMake(190.f, 1000)];
    NSLog(@"%f", size.height);
    if (size.height > 40) {
        return size.height + 10;
    }
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"InterestCell";
    
    UITableViewCell *cell = nil;
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    int nIndex = [notificationsArray count] - indexPath.row - 1;
    NSDictionary *content = [notificationsArray objectAtIndex:nIndex];
    
    if (IsNSStringValid([[notificationsArray objectAtIndex:nIndex] objectForKey:@"pic_small"] )) {
//        UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[[notificationsArray objectAtIndex:nIndex] objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
//        
//        UIImageView *pImageView = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//        [pImageView setFrame:CGRectMake(5, 5, 40, 40)];
//        [cell addSubview:pImageView];
//        [pImageView release];
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, 5.f, 40, 40)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
        pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        NSURL *imageURL = [NSURL URLWithString:[[notificationsArray objectAtIndex:nIndex] objectForKey:@"pic_small"]];
        pImageView.imageURL = imageURL;
        [cell addSubview:pImageView];
        [pImageView release];

    }
    
    if (![[content objectForKey:@"is_read"] boolValue]) {
        [cell setBackgroundColor:UIColorFromRGB(0xD8D8D8)];
    }
          
    UILabel *lblContent = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 180.f, 0)];
    [lblContent setNumberOfLines:5];
    [lblContent setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
    NSString *contentString = @"";
    if ([[content objectForKey:@"type"] isEqualToString:@"comment"]) {
        contentString = [NSString stringWithFormat:@"%@ commented on your shout-out!", [content objectForKey:@"first"]];
    } else if ([[[notificationsArray objectAtIndex:nIndex] objectForKey:@"type"] isEqualToString:@"favorite"]) {
        contentString = [NSString stringWithFormat:@"%@ favorited you!", [content objectForKey:@"first"]];
    } else if ([[[notificationsArray objectAtIndex:nIndex] objectForKey:@"type"] isEqualToString:@"shoutout"]) {
        contentString = [NSString stringWithFormat:@"%@ created a shout-out about %@! Check it out?", [content objectForKey:@"first"], [content objectForKey:@"interest"]];
    }
    [lblContent setText:contentString];
    [lblContent sizeToFit];
    
    if (lblContent.frame.size.height <= 40) {
        [lblContent setFrame:CGRectMake(55, 5, 180.f, 40)];
    }
    [cell addSubview:lblContent];
    [lblContent release];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[content objectForKey:@"time"] longLongValue]];
    
    //    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1379271058];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss MM/dd/yyyy"];
    
    NSDate *curDate = [NSDate date];
    
    NSTimeInterval interval = [curDate timeIntervalSinceDate:date];
    NSInteger ti = (NSInteger)interval;
    
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    NSInteger day = ti / 86400;
    NSInteger month = day / 2592000;
    
    UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(245, 0, 65.f, 50.f)];
    [lblTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
    [lblTime setTextColor:[UIColor grayColor]];
    
    NSString *strTime;
    if (month) {
        strTime = [NSString stringWithFormat:@"%i mth ago", month];
    } else {
        if (day) {
            strTime = [NSString stringWithFormat:@"%i day ago", day];
        } else {
            if (hours) {
                strTime = [NSString stringWithFormat:@"%i hrs ago", hours];
            } else {
                if (minutes) {
                    strTime = [NSString stringWithFormat:@"%i min ago", minutes];
                } else {
                    if (seconds) {
                        strTime = [NSString stringWithFormat:@"%i sec ago", seconds];
                    } else {
                        strTime = @"";
                    }
                }
            }
        }
    }
    [lblTime setText:strTime];
    [cell addSubview:lblTime];
    [lblTime release];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int nIndex = [notificationsArray count] - indexPath.row - 1;
    
    NSDictionary *content = [notificationsArray objectAtIndex:nIndex];
    NSString *email = @"";

    if ([[content objectForKey:@"type"] isEqualToString:@"comment"]) {
        NSLog(@"%@", content);
        email = [DataManager sharedManager].strEmail;
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"Comment_show"];
        [[NSUserDefaults standardUserDefaults] setObject:[content objectForKey:@"shout"] forKey:@"Comment_text"];
    } else {
        email = [content objectForKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"Comment_show"];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PLACE_PROFILE"];
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    
    if ([email isEqualToString:[DataManager sharedManager].strEmail]) {
        [profileController setFlag:TRUE];
    } else {
        [profileController setFlag:FALSE];
    }
   
    profileController.email = email;

    
    //    [profileController setContentValue:[apiResultArray objectAtIndex:button.tag]];
    [self.navigationController pushViewController:profileController animated:YES];
}
@end
