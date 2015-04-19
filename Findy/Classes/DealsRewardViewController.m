//
//  DealsRewardViewController.m
//  Findy
//
//  Created by iPhone on 10/1/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "DealsRewardViewController.h"
#import "WebBrowserViewController.h"

@interface DealsRewardViewController ()

@end

@implementation DealsRewardViewController

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
    [Flurry logEvent:@"Deals_Rewards"];
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
    [lblTitle setText:@"Deals & Rewards"];
    [self.view addSubview:lblTitle];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }

    ECSlidingViewTopNotificationMacro;
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    [menuView setFrame:CGRectMake(-1, 43 + [DataManager sharedManager].fiOS7StatusHeight, 321, 42)];
    
    [dealsTableView setFrame:CGRectMake(0, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320.f, (IS_IPHONE5) ? 504: 416)];
    [rewardsTableView setFrame:CGRectMake(0, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320.f, (IS_IPHONE5) ? 504 : 416)];
    
    [dealsTableView setHidden:NO];
    [rewardsTableView setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"deals_init_loading"]) {
        dealsTableArray = [[NSMutableArray alloc] initWithArray:[DataManager sharedManager].dealsArray];
        
        [dealsTableView setDelegate:self];
        [dealsTableView setDataSource:self];
        
        divisionArray = [[NSMutableArray alloc] init];
        dealsArray = [[NSMutableArray alloc] init];
        
        
        if ([divisionArray count]) {
            [divisionArray removeAllObjects];
        }
        
        for (NSArray* array in dealsTableArray) {
            [divisionArray addObject:[[array objectAtIndex:0] objectForKey:@"city"]];
        }
        
        [dealsTableView reloadData];
    } else {
        divisionArray = [[NSMutableArray alloc] init];
        dealsTableArray = [[NSMutableArray alloc] init];
        dealsArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude], [NSString stringWithFormat:@"%f", [DataManager sharedManager].longitude], nil] forKeys:[NSArray arrayWithObjects:@"lat", @"lng", nil]];
        [[FindyAPI instance] getLivingSocial:self withSelector:@selector(getLivingSocial:) andOptions:paramDict];
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"deals_init_loading"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [lblRewards release];
    [lblDeals release];
    [menuView release];
    [btnDeals release];
    [btnRewards release];
    [dealsTableView release];
    [rewardsTableView release];
    [lblNoRewards release];
    [super dealloc];
}
- (void)viewDidUnload {
    [lblRewards release];
    lblRewards = nil;
    [lblDeals release];
    lblDeals = nil;
    [menuView release];
    menuView = nil;
    [btnDeals release];
    btnDeals = nil;
    [btnRewards release];
    btnRewards = nil;
    [dealsTableView release];
    dealsTableView = nil;
    [rewardsTableView release];
    rewardsTableView = nil;
    [lblNoRewards release];
    lblNoRewards = nil;
    [super viewDidUnload];
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
- (IBAction)menuSelect:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if ([button isSelected]) {
        return;
    }
    
    [btnDeals setSelected:NO];
    [btnRewards setSelected:NO];
    [lblDeals setTextColor:[UIColor blackColor]];
    [lblRewards setTextColor:[UIColor blackColor]];
    
    if (button == btnDeals) {
        [lblNoRewards setHidden:YES];
        [lblDeals setTextColor:[UIColor whiteColor]];
        [rewardsTableView setHidden:YES];
        [dealsTableView setHidden:NO];
        
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude], [NSString stringWithFormat:@"%f", [DataManager sharedManager].longitude], [[DataManager sharedManager].interestArray componentsJoinedByString:@","], nil] forKeys:[NSArray arrayWithObjects:@"lat", @"lng", @"tag", nil]];
        [[FindyAPI instance] getDealsRewards:self withSelector:@selector(getDealsRewards:) andOptions:paramDict];
    } else if (button == btnRewards) {
        [lblNoRewards setHidden:NO];
        [lblRewards setTextColor:[UIColor whiteColor]];
        [rewardsTableView setHidden:NO];
        [dealsTableView setHidden:YES];
//
//        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", nil]];
//        [[FindyAPI instance] favoriteDetail:self withSelector:@selector(getFavoriteDetail:) andOptions:paramDict];
    }
    
    [button setSelected:YES];
}

- (void)getDealsRewards:(NSDictionary *)response {
    
    for (int i = 0; i < [[response objectForKey:@"deals"] count]; i++) {
        if (i == 13) {
            break;
        }
        NSDictionary *content = [[response objectForKey:@"deals"] objectAtIndex:i];
        if ([[[content objectForKey:@"merchant"] objectForKey:@"name"] rangeOfString:@".com"].location == NSNotFound) {
            
            NSArray *valueArray = [NSArray arrayWithObjects:
                                   [content objectForKey:@"largeImageUrl"],
                                   [[content objectForKey:@"merchant"] objectForKey:@"name"],
                                   [content objectForKey:@"announcementTitle"],
                                   [content objectForKey:@"dealUrl"],
                                   [[content objectForKey:@"division"] objectForKey:@"name"],
                                   [[[[content objectForKey:@"options"] objectAtIndex:0] objectForKey:@"value"] objectForKey:@"formattedAmount"],
                                   [[[[content objectForKey:@"options"] objectAtIndex:0] objectForKey:@"price"] objectForKey:@"formattedAmount"],
                                   @"GroupOn",
                                   [content objectForKey:@"id"],
                                   nil];
            NSArray *keyArray = [NSArray arrayWithObjects:@"image", @"title", @"subtitle", @"url", @"city", @"value", @"price", @"icon", @"id", nil];
            NSDictionary *dealDict = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
            [dealsArray addObject:dealDict];
        }
    }
    
    if ([divisionArray count]) {
        [divisionArray removeAllObjects];
    }
    
    for (NSDictionary* content in dealsArray) {
        if (![divisionArray containsObject:[content objectForKey:@"city"]]) {
            [divisionArray addObject:[content objectForKey:@"city"]];
        }
    }
    
    if ([dealsTableArray count]) {
        [dealsTableArray removeAllObjects];
    }
    for (int i = 0; i < [divisionArray count]; i++) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [dealsTableArray addObject:arr];
    }
    
    for (NSDictionary *content in dealsArray) {
        int nIndex = [divisionArray indexOfObject:[content objectForKey:@"city"]];
        [[dealsTableArray objectAtIndex:nIndex] addObject:content];
    }
    
    if ([[DataManager sharedManager].dealsArray count]) {
        [[DataManager sharedManager].dealsArray removeAllObjects];
    }
    [[DataManager sharedManager].dealsArray addObjectsFromArray:dealsTableArray];
    
    [dealsTableView reloadData];
}

- (NSString *)getCitiy:(NSArray *)cityArray _country:(int)country _city:(int)city {
    for (NSDictionary *cityDict in cityArray) {
        if (([[cityDict objectForKey:@"country_id"] intValue] == country) && ([[cityDict objectForKey:@"id"] intValue] == city)) {
            return [cityDict objectForKey:@"name"];
        }
    }
    
    return @"";
}

- (void)getLivingSocial:(NSDictionary *)response {
    if ([dealsArray count]) {
        [dealsArray removeAllObjects];
    }

    for (int i = 0; i < [[response objectForKey:@"deals"] count]; i++) {
        if ([dealsArray count] >= 13) {
            break;
        }
        NSDictionary *content = [[response objectForKey:@"deals"] objectAtIndex:i];
        if ([[content objectForKey:@"merchant_name"] rangeOfString:@".com"].location == NSNotFound) {
            if ([[content objectForKey:@"categories"] containsObject:@"Fitness/Active"]) {
                NSArray *valueArray = [NSArray arrayWithObjects:
                                       [[[content objectForKey:@"images"] objectAtIndex:0] objectForKey:@"size220"],
                                       [content objectForKey:@"merchant_name"], [content objectForKey:@"long_title"],
                                       [content objectForKey:@"url"],
                                       [self getCitiy:[response objectForKey:@"cities"] _country:[[content objectForKey:@"country_id"] intValue] _city:[[[content objectForKey:@"city_ids"] objectAtIndex:0] intValue]],
                                       [NSString stringWithFormat:@"$%@", [[[content objectForKey:@"options"] objectAtIndex:0] objectForKey:@"original_price"]],
                                       [NSString stringWithFormat:@"$%@", [[[content objectForKey:@"options"] objectAtIndex:0] objectForKey:@"price"]],
                                       @"Living", [NSString stringWithFormat:@"$%@", [content objectForKey:@"id"]],
                                       nil];
                NSArray *keyArray = [NSArray arrayWithObjects:@"image", @"title", @"subtitle", @"url", @"city", @"value", @"price", @"icon", @"id", nil];
                NSDictionary *dealDict = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
                [dealsArray addObject:dealDict];
            }
        }
    }
    
    for (int i = 0; i < [[response objectForKey:@"deals"] count]; i++) {
        if ([dealsArray count] >= 13) {
            break;
        }
        NSDictionary *content = [[response objectForKey:@"deals"] objectAtIndex:i];
        if ([[content objectForKey:@"merchant_name"] rangeOfString:@".com"].location == NSNotFound) {
            if ([[content objectForKey:@"categories"] containsObject:@"Entertainment"]) {
                NSArray *valueArray = [NSArray arrayWithObjects:
                                       [[[content objectForKey:@"images"] objectAtIndex:0] objectForKey:@"size220"],
                                       [content objectForKey:@"merchant_name"], [content objectForKey:@"long_title"],
                                       [content objectForKey:@"url"],
                                       [self getCitiy:[response objectForKey:@"cities"] _country:[[content objectForKey:@"country_id"] intValue] _city:[[[content objectForKey:@"city_ids"] objectAtIndex:0] intValue]],
                                       [NSString stringWithFormat:@"$%@", [[[content objectForKey:@"options"] objectAtIndex:0] objectForKey:@"original_price"]],
                                       [NSString stringWithFormat:@"$%@", [[[content objectForKey:@"options"] objectAtIndex:0] objectForKey:@"price"]],
                                       @"Living",
                                       nil];
                NSArray *keyArray = [NSArray arrayWithObjects:@"image", @"title", @"subtitle", @"url", @"city", @"value", @"price", @"icon", nil];
                NSDictionary *dealDict = [NSDictionary dictionaryWithObjects:valueArray forKeys:keyArray];
                [dealsArray addObject:dealDict];
            }
        }
    }

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", [DataManager sharedManager].latitude], [NSString stringWithFormat:@"%f", [DataManager sharedManager].longitude], [[DataManager sharedManager].interestArray componentsJoinedByString:@","], nil] forKeys:[NSArray arrayWithObjects:@"lat", @"lng", @"tag", nil]];
    [[FindyAPI instance] getDealsRewards:self withSelector:@selector(getDealsRewards:) andOptions:paramDict];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[dealsTableArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [divisionArray count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [divisionArray objectAtIndex:section];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dealsTableView.frame.size.width, dealsTableView.frame.size.height)];
    [view setBackgroundColor:[UIColor colorWithRed:0.84f green:0.84f blue:0.84f alpha:1.f]];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, dealsTableView.frame.size.width - 30, 17)];
    [title setBackgroundColor:[UIColor colorWithRed:0.84f green:0.84f blue:0.84f alpha:1.f]];
    [title setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [title setTextColor:[UIColor colorWithRed:0.29f green:0.29f blue:0.29f alpha:1.f]];
    NSString *capitalized = [[[[divisionArray objectAtIndex:section] substringToIndex:1] uppercaseString] stringByAppendingString:[[divisionArray objectAtIndex:section] substringFromIndex:1]];

    [title setText:capitalized];
    [view addSubview:title];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"InterestCell";
    
    UITableViewCell *cell = nil;
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    NSDictionary *content = [[dealsTableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, 5, 65.f, 65.f)];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 2;
    pImageView.imageURL = [NSURL URLWithString:[content objectForKey:@"image"]];
    [cell addSubview:pImageView];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(80.f, 5.f, 200.f, 18.f)];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
    [lblTitle setTextColor:[UIColor colorWithRed:1.f green:0.35f blue:0.f alpha:1.f]];
    NSString *text = [content objectForKey:@"title"];
    text = [[[text substringToIndex:1] uppercaseString] stringByAppendingString:[text substringFromIndex:1]];
    [lblTitle setText:text];
    [cell addSubview:lblTitle];
    
    UIImageView *gIcon = ([[content objectForKey:@"icon"] isEqualToString:@"GroupOn"]) ? [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconG.png"]] : [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconLiving.png"]];
    [gIcon setFrame:CGRectMake(291.f, 5.f, 24.f, 24.f)];
    [cell addSubview:gIcon];
    [gIcon release];
    
    UILabel *lblContent = [[UILabel alloc] initWithFrame:CGRectMake(80.f, 22.f, 200.f, 32.f)];
    [lblContent setFont:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE]];
    [lblContent setNumberOfLines:2];
//    announcementTitle
    [lblContent setText:[content objectForKey:@"subtitle"]];
    [lblContent sizeToFit];
    [cell addSubview:lblContent];
    
    
    NSString *valueText = [content objectForKey:@"price"];
    
    NSString *priceText = [content objectForKey:@"value"];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", priceText, valueText]];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:[NSNumber numberWithInt:2]
                            range:NSMakeRange(0,[priceText length])];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, [priceText length])];
    [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.47f green:0.81f blue:0.09f alpha:1.f] range:NSMakeRange([priceText length] + 1, [valueText length])];
    
    UILabel *lblBudget = [[UILabel alloc] initWithFrame:CGRectMake(80.f, 58.f, 225.f, 15.f)];
    [lblBudget setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:SHOUTOUT_FONT_SIZE]];
    [lblBudget setAttributedText:attributeString];
    [cell addSubview:lblBudget];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *content = [[dealsTableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSString *strUrl = ([[content objectForKey:@"icon"] isEqualToString:@"GroupOn"]) ?
    [NSString stringWithFormat:@"http://www.anrdoezrs.net/click-7190139-10804307?sid=findy&url=%@", [[content objectForKey:@"url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
    : [NSString stringWithFormat:@"http://www.jdoqocy.com/click-7190139-11173639?URL=%@", [[content objectForKey:@"url"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSString *strUrl = [[((NSString *)[content objectForKey:@"url"]) stringByReplacingOccurrencesOfString:@"www" withString:@"m"]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
    NSLog(@"%@", strUrl);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = strUrl;
    webBrowser.viewTitle = [content objectForKey:@"title"];
    webBrowser.subTitle = [content objectForKey:@"subtitle"];
    webBrowser.strType = ([[content objectForKey:@"icon"] isEqualToString:@"GroupOn"]) ? @"GROUPON" : @"LIVING";
    [self.navigationController pushViewController:webBrowser animated:YES];
}

@end
