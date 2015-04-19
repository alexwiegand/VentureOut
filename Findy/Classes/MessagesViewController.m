//
//  MessagesViewController.m
//  Findy
//
//  Created by iPhone on 9/26/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "MessagesViewController.h"
#import "ChatViewController.h"

@interface MessagesViewController ()

@end

@implementation MessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"CancelMeet"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil]
                                                                   forKeys:[NSArray arrayWithObjects:@"email", nil]];
    [[FindyAPI instance] openChat:self withSelector:@selector(openChatResult:) andOptions:dict];
}

ECSlidingViewTopNotificationHandlerMacro

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"Message"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClearMessage" object:nil];
	// Do any additional setup after loading the view.
    
    [contentTableView setFrame:CGRectMake(0, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320, (IS_IPHONE5) ? 524 : 436)];
    
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
    [lblTitle setText:@"Messages"];
    [self.view addSubview:lblTitle];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    ECSlidingViewTopNotificationMacro;
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    
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

- (void)openChatResult:(NSDictionary *)response {
    NSArray *resultArray = [response objectForKey:@"results"];
    
    NSArray *currentArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_MESSAGES"];
    if (currentArray == nil) {
        currentArray = [[NSMutableArray alloc] init];
    }
    
    contentArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *content in resultArray) {
        if ([currentArray containsObject:content]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:content];
            [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"TRUE", @"is_read", nil]];
            
            [contentArray addObject:dict];
        } else {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:content];
            [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"FALSE", @"is_read", nil]];
            
            [contentArray addObject:dict];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:resultArray forKey:@"CURRENT_MESSAGES"];
    
    [contentTableView reloadData];
}

- (void)reArrangeArray {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:contentArray];
    [contentArray removeAllObjects];
    [contentArray release];
    
    NSArray *currentArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_MESSAGES"];
    if (currentArray == nil) {
        currentArray = [[NSMutableArray alloc] init];
    }
    
    contentArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *content in tempArray) {
        if ([currentArray containsObject:content]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:content];
            [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"TRUE", @"is_read", nil]];
            
            [contentArray addObject:dict];
        } else {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:content];
            [dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"FALSE", @"is_read", nil]];
            
            [contentArray addObject:dict];
        }
    }
   
    [contentTableView reloadData];
    
}

- (void)dealloc {
    [contentTableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [contentTableView release];
    contentTableView = nil;
    [super viewDidUnload];
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contentArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"InterestCell";
    
    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
//    UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[[contentArray objectAtIndex:indexPath.row] objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
//    
//    UIImageView *pImageView = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//    [pImageView setFrame:CGRectMake(9.f, 5.f, 65.f, 65.f)];
//    [cell addSubview:pImageView];
//    [pImageView release];
    if (![[[contentArray objectAtIndex:indexPath.row] objectForKey:@"is_read"] boolValue]) {
        if (![[[contentArray objectAtIndex:indexPath.row] objectForKey:@"latest_from"] isEqualToString:[DataManager sharedManager].strEmail]) {
            [cell setBackgroundColor:UIColorFromRGB(0xD8D8D8)];
        }
    }
    
    AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, 5.f, 65, 65)];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 1;
    NSURL *imageURL = [NSURL URLWithString:[[contentArray objectAtIndex:indexPath.row] objectForKey:@"pic_small"]];
    pImageView.imageURL = imageURL;

    [cell.contentView addSubview:pImageView];
    [pImageView release];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(85.f, 15.f, 140.f, 20.f)];
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
    [lblName setTextColor:[UIColor colorWithRed:0 green:.6f blue:.8f alpha:1.f]];
    [lblName setText:[[contentArray objectAtIndex:indexPath.row] objectForKey:@"first"]];
    [cell addSubview:lblName];
    [lblName release];
    
    UILabel *lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(85.f, 40.f, 140.f, 20.f)];
    [lblMessage setFont:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE]];
    NSString *message = [[contentArray objectAtIndex:indexPath.row] objectForKey:@"latest_msg"];

    message = (IS_IOS7) ? [message stringByRemovingPercentEncoding] : [message stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *meetAtArray = [message componentsSeparatedByString:@"//"];
    if ([meetAtArray count] > 1) {
        [lblMessage setText:[meetAtArray objectAtIndex:1]];
    } else {
        [lblMessage setText:message];
    }
    
    [cell addSubview:lblMessage];
    [lblMessage release];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[[contentArray objectAtIndex:indexPath.row] objectForKey:@"time"] longLongValue]];

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
    
    UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(230.f, 15.f, 80.f, 20.f)];
    [lblTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
    [lblTime setTextColor:[UIColor grayColor]];
    
    NSString *strTime;
    if (month) {
        strTime = [NSString stringWithFormat:@"%i Months Ago", month];
    } else {
        if (day) {
            strTime = [NSString stringWithFormat:@"%i Days Ago", day];
        } else {
            if (hours) {
                strTime = [NSString stringWithFormat:@"%i Hours Ago", hours];
            } else {
                if (minutes) {
                    strTime = [NSString stringWithFormat:@"%i Minutes Ago", minutes];
                } else {
                    if (seconds) {
                        strTime = [NSString stringWithFormat:@"%i Seconds Ago", seconds];
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
    
//    NSLog(@"%02i:%02i:%02i   %02i.%02i", hours, minutes, seconds, month,day);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ChatViewController *chatController = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatController.partnerEmail = [[contentArray objectAtIndex:indexPath.row] objectForKey:@"email"];
    chatController.strTitle = [[contentArray objectAtIndex:indexPath.row] objectForKey:@"first"];
    
    for (UIView *view in [cell.contentView subviews]) {
        if ([view isKindOfClass:[AsyncImageView class]]) {
            AsyncImageView *v = (AsyncImageView *)view;
            chatController.leftFace = [[UIImage alloc] initWithData:UIImagePNGRepresentation(v.image)];
        }
    }
    chatController.bChatReply = FALSE;
    [self.navigationController pushViewController:chatController animated:YES];
}

@end
