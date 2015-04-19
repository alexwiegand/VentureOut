//
//  MeetAtViewController.m
//  Findy
//
//  Created by iPhone on 12/3/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "MeetAtViewController.h"

@interface MeetAtViewController ()
@property (retain, nonatomic) IBOutlet UITableView *placeTable;

@end

@implementation MeetAtViewController

@synthesize partnerEmail;

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
    [backButton setFrame:CGRectMake(7.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 52.f, 30.f)];
    [backButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"Meet At"];
    [self.view addSubview:lblTitle];
    
    [_placeTable setFrame:(IS_IPHONE5) ? CGRectMake(0, 88 + [DataManager sharedManager].fiOS7StatusHeight, 320, 460) : CGRectMake(0, 88 + [DataManager sharedManager].fiOS7StatusHeight, 320, 372)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)revealMenu:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"CancelMeet"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [_placeTable release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPlaceTable:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate
#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchArray count];
    } else {
        return [[DataManager sharedManager].placesArray count];
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"InterestCell";
    
    UITableViewCell *cell = nil;
	cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    
    NSDictionary *placeDict = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        placeDict = [searchArray objectAtIndex:indexPath.row];
    } else {
        placeDict = [[[DataManager sharedManager].placesArray objectAtIndex:indexPath.row] objectForKey:@"value"];
    }
    
    [cell.imageView setImage:[UIImage imageNamed:@"PinLocationInChat.png"]];
    cell.textLabel.text = [placeDict objectForKey:@"name"];
    
    cell.detailTextLabel.text = ([[placeDict objectForKey:@"id"] rangeOfString:@"findy-"].location == NSNotFound) ? [placeDict objectForKey:@"address"] : [[[placeDict objectForKey:@"location"] objectForKey:@"display_address"] componentsJoinedByString:@", "];
    [cell.detailTextLabel setTextColor:[UIColor grayColor]];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *placeDict = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        placeDict = [searchArray objectAtIndex:indexPath.row];
    } else {
        placeDict = [[[DataManager sharedManager].placesArray objectAtIndex:indexPath.row] objectForKey:@"value"];
    }
    
//    [[NSUserDefaults standardUserDefaults] setObject:placeDict forKey:@"Selected_Place"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *txt = [NSString stringWithFormat:@"meetat://%@//%@//%@", [placeDict objectForKey:@"name"], [placeDict objectForKey:@"id"], [[[DataManager sharedManager].placesArray objectAtIndex:indexPath.row] objectForKey:@"interest"]];
    NSDate *today = [NSDate date];
    long time = [today timeIntervalSince1970];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, partnerEmail, txt, [NSString stringWithFormat:@"%ld", time], nil] forKeys:[NSArray arrayWithObjects:@"from", @"to", @"msg", @"time", nil]];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"PlaceChat"];
    [[FindyAPI instance] sendchat:self withSelector:@selector(completeSendChat:) andOptions:dict];
}

- (void)completeSendChat:(NSDictionary *)response {
//    NSLog(@"%@", response);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchDisplayController delegate methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    searchActivity = [[NSString alloc] initWithString:searchString];
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    if (searchArray != nil) {
        [searchArray removeAllObjects];
        [searchArray release];
        searchArray = nil;
    }
    
    searchArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *placeDict in [DataManager sharedManager].placesArray) {
        NSDictionary *content = [placeDict objectForKey:@"value"];
        NSString *name = [content objectForKey:@"name"];
        if ([[name uppercaseString] rangeOfString:[searchText uppercaseString]].location != NSNotFound) {
            [searchArray addObject:content];
        }
    }
}


@end
