//
//  InviteFBFriendViewController.m
//  Findy
//
//  Created by iPhone on 10/11/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "InviteFBFriendViewController.h"

@interface InviteFBFriendViewController ()

@end

@implementation InviteFBFriendViewController

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
    [Flurry logEvent:@"Invite_FB"];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
     
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
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
    [lblTitle setText:@"Find My Friends!"];
    [self.view addSubview:lblTitle];
    
    favoriteArray = [[NSMutableArray alloc] init];
    inviteArray = [[NSMutableArray alloc] init];
    emailArray = [[NSMutableArray alloc] init];
    
    ECSlidingViewTopNotificationMacro;
    
    float y = 44 + [DataManager sharedManager].fiOS7StatusHeight;
    [contentScrollView setFrame:CGRectMake(0, y, 320, SCREEN_HEIGHT - y)];
    
    
    favoriteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, 320, 0)];
    [favoriteTableView setDelegate:self];
    [favoriteTableView setDataSource:self];
    [contentScrollView addSubview:favoriteTableView];
    [favoriteTableView reloadData];
    [favoriteTableView setScrollEnabled:NO];
    
    
    inviteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, 320, 0)];
    [inviteTableView setDelegate:self];
    [inviteTableView setDataSource:self];
    [inviteTableView setScrollEnabled:NO];
    [contentScrollView addSubview:inviteTableView];
    [inviteTableView reloadData];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loaded_inviteFB"]) {
        friendArray = [[NSMutableArray alloc] initWithArray:[DataManager sharedManager].fbFriendArray];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"loaded_inviteFB"];
        [self showData:[DataManager sharedManager].fbFriendDict];
    } else {
        [self getFriendList];
    }
}

- (void)getFriendList {
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        friendArray = [[NSMutableArray alloc] initWithArray:[result  objectForKey:@"data"]];
        if ([friendArray count] > 0) {
            NSDictionary<FBGraphUser>* f = [friendArray objectAtIndex:0];
            NSString *strEmail = [f objectForKey:@"id"];
            for (int i = 1; i < [friendArray count]; i++) {
                NSDictionary<FBGraphUser>* friend = [friendArray objectAtIndex:i];
                strEmail = [NSString stringWithFormat:@"%@,%@", strEmail, [friend objectForKey:@"id"]];
            }
            [DataManager sharedManager].fbFriendArray = [[NSMutableArray alloc] initWithArray:friendArray];
            [[DataManager sharedManager].fbFriendArray addObjectsFromArray:friendArray];
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:strEmail, nil]
                                                                                forKeys:[NSArray arrayWithObjects:@"email", nil]];
            [[FindyAPI instance] getUserExist:self withSelector:@selector(showData:) andOptions:paramDict];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextButtonPressed:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_setting"]) {
        [self.navigationController popViewControllerAnimated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"from_invite"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"from_invite"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        
        self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }
}
//- (void)sortAlphabet:(NSMutableArray *)Arr {
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    for(int i =0;i<[Arr count];i++)
//    {
//        NSDictionary<FBGraphUser>* friend = [Arr objectAtIndex:i];
//        [dict setValue:[Arr objectAtIndex:i] forKey:friend.name];
//    }
//    
//    return dict;
//}

- (void)showData:(NSDictionary *)response {
    [DataManager sharedManager].fbFriendDict = [[NSMutableDictionary alloc] initWithDictionary:response];
    for (NSDictionary<FBGraphUser>* friend in friendArray) {
        if ([[[[response objectForKey:@"fids"] objectForKey:[friend objectForKey:@"id"]] objectForKey:@"status"] boolValue] == FALSE) {
            [inviteArray addObject:friend];
//            [inviteArray sortUsingSelector:@selector(id)];
        } else {
            [emailArray addObject:[[[response objectForKey:@"fids"] objectForKey:[friend objectForKey:@"id"]] objectForKey:@"email"]];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:friend];
            [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[[response objectForKey:@"fids"] objectForKey:[friend objectForKey:@"id"]] objectForKey:@"email"] forKey:@"email"]];
            [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[[[response objectForKey:@"fids"] objectForKey:[friend objectForKey:@"id"]] objectForKey:@"interests"] forKey:@"interest"]];
            [favoriteArray addObject:dict];
//            [favoriteArray sortUsingSelector:@selector(first_name)];
        }
    }
    
    NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"first_name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [inviteArray sortUsingDescriptors:[NSMutableArray arrayWithObjects:alphaDesc, nil]];
    [favoriteArray sortUsingDescriptors:[NSArray arrayWithObjects:alphaDesc, nil]];
    
    float y = 10;
    
    if (IS_IOS7) {
        y = ([[NSUserDefaults standardUserDefaults] boolForKey:@"FIRST_REGISTER"]) ? 0 : 10;
    }
    
    if (([favoriteArray count] != 0) && (![[NSUserDefaults standardUserDefaults] boolForKey:@"from_setting"])) {
        UILabel *lblFavoriteTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 320, 15)];
        [lblFavoriteTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
        [lblFavoriteTitle setText:@"Friends on Findy to Favorite"];
        [lblFavoriteTitle setTextAlignment:NSTextAlignmentCenter];
        [lblFavoriteTitle setBackgroundColor:[UIColor clearColor]];
        [contentScrollView addSubview:lblFavoriteTitle];
        [lblFavoriteTitle release];
        
        y += 15 + 5;
        UIButton *btnFavoriteAll = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnFavoriteAll setBackgroundImage:[UIImage imageNamed:@"FavoriteAllButton.png"] forState:UIControlStateNormal];
        [btnFavoriteAll setFrame:CGRectMake(60.f, y, 200.f, 43.f)];
        [btnFavoriteAll addTarget:self action:@selector(favoriteAllClick:) forControlEvents:UIControlEventTouchUpInside];
        [contentScrollView addSubview:btnFavoriteAll];
        
        y += 43.f + 10;
        int height = 50 * [favoriteArray count];
//        if ([favoriteArray count] == 1) {
//            height = 50;
//        }
        [favoriteTableView setFrame:CGRectMake(0, y, 320, height)];
        [favoriteTableView reloadData];
        
        UIImageView *pImg1= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaddingLing.png"]];
        [pImg1 setFrame:CGRectMake(0, favoriteTableView.frame.origin.y - 1, SCREEN_WIDTH, 1)];
        [contentScrollView addSubview:pImg1];
        [pImg1 release];
        
        UIImageView *pImg2= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaddingLing.png"]];
        [pImg2 setFrame:CGRectMake(0, favoriteTableView.frame.origin.y + favoriteTableView.frame.size.height, SCREEN_WIDTH, 1)];
        [contentScrollView addSubview:pImg2];
        [pImg2 release];
        
        y += favoriteTableView.frame.size.height + 5;
    }
    
    y += 10;
    
    UILabel *lblInviteTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 320, 15)];
    [lblInviteTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
    [lblInviteTitle setText:@"Friends to Invite"];
    [lblInviteTitle setTextAlignment:NSTextAlignmentCenter];
    [lblInviteTitle setBackgroundColor:[UIColor clearColor]];
    [contentScrollView addSubview:lblInviteTitle];
    [lblInviteTitle release];
    
    y += 15 + 5;
    UIButton *btnInviteAll = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnInviteAll setBackgroundImage:[UIImage imageNamed:@"InviteAllButton.png"] forState:UIControlStateNormal];
    [btnInviteAll setFrame:CGRectMake(60.f, y, 200.f, 43.f)];
    [btnInviteAll addTarget:self action:@selector(inviteAllClick:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:btnInviteAll];
    
    y += 43 + 10;
//    NSLog(@"%f, %f", contentScrollView.frame.size.height, y);
    [inviteTableView setFrame:CGRectMake(0, y, 320, 50 * [inviteArray count])];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:.01f];
    
    UIImageView *pImg3= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaddingLing.png"]];
    [pImg3 setFrame:CGRectMake(0, inviteTableView.frame.origin.y - 1, SCREEN_WIDTH, 1)];
    [contentScrollView addSubview:pImg3];
    [pImg3 release];
    
    UIImageView *pImg4= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaddingLing.png"]];
    [pImg4 setFrame:CGRectMake(0, inviteTableView.frame.origin.y + inviteTableView.frame.size.height, SCREEN_WIDTH, 1)];
    [contentScrollView addSubview:pImg4];
    [pImg4 release];
    
    [contentScrollView setContentSize:CGSizeMake(320, y + inviteTableView.frame.size.height)];
}

- (void)reloadData {
    [inviteTableView reloadData];
}

- (void)dealloc {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"from_setting"];
    [contentScrollView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"from_setting"];
    [contentScrollView release];
    contentScrollView = nil;
    [super viewDidUnload];
}

#pragma mark - Button Click Action

- (void)favoriteClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    curButton = button;
    if (button.selected) {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                                       [DataManager sharedManager].strEmail,
                                                                                       [[favoriteArray objectAtIndex:button.tag] objectForKey:@"email"], nil]
                                                                              forKeys:[NSArray arrayWithObjects:
                                                                                       @"email", @"favorite", nil]];
        [[FindyAPI instance] removeFavorite:self withSelector:@selector(favoriteResult:) andOptions:paramDict];
        [[DataManager sharedManager].favoritesArray removeObject:[[favoriteArray objectAtIndex:button.tag] objectForKey:@"email"]];
    } else {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                                       [DataManager sharedManager].strEmail,
                                                                                       [[favoriteArray objectAtIndex:button.tag] objectForKey:@"email"], nil]
                                                                              forKeys:[NSArray arrayWithObjects:
                                                                                       @"email", @"favorite", nil]];
        [[FindyAPI instance] addFavorite:self withSelector:@selector(favoriteResult:) andOptions:paramDict];
        
        [[DataManager sharedManager].favoritesArray addObject:[[favoriteArray objectAtIndex:button.tag] objectForKey:@"email"]];
    }
}

- (void)favoriteAllClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                                   [DataManager sharedManager].strEmail,
                                                                                   [emailArray componentsJoinedByString:@","], nil]
                                                                          forKeys:[NSArray arrayWithObjects:
                                                                                   @"email", @"favorite", nil]];
    [[FindyAPI instance] addFavorite:self withSelector:@selector(favoriteResult:) andOptions:paramDict];
    
    [[DataManager sharedManager].favoritesArray addObjectsFromArray:emailArray];
    [favoriteTableView reloadData];
}

- (void)favoriteResult:(NSDictionary *)response {
    if ([[response objectForKey:@"success"] boolValue]) {
        [SVProgressHUD showSuccessWithStatus:@"Favorite Success"];
        [curButton setSelected:!curButton.selected];
    }
}

- (void)inviteClick:(id)sender {
    UIButton *button = (UIButton *)sender ;
    
    NSString *userID = [NSString stringWithFormat:@"%@", [[inviteArray objectAtIndex:button.tag] objectForKey:@"id"]];
    NSString *text = [NSString stringWithFormat:@"I'm inviting you to try Findy!"];
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:userID, @"to", [NSString stringWithFormat:@"%@", @"354986367951475"], @"app_id", nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                  message:text
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              [button setSelected:NO];
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              if ([[resultURL absoluteString] isEqualToString:@"fbconnect://success?error_code=4201&error_message=User+canceled+the+Dialog+flow"]) {
                                                                  [button setSelected:NO];
                                                                  
                                                              } else {
                                                                  [Flurry logEvent:@"Invite_Facebook_User"];
                                                                  [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"INVITE_FRIEND_COUNT"] + 1 forKey:@"INVITE_FRIEND_COUNT"];
                                                                  if (([[NSUserDefaults standardUserDefaults] integerForKey:@"INVITE_FRIEND_COUNT"] != 0) && ([[NSUserDefaults standardUserDefaults] integerForKey:@"INVITE_FRIEND_COUNT"] % 5 == 0) ){
//                                                                      [[Kiip sharedInstance] saveMoment:@"Inviting Your Friends!" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
//                                                                          if (error) {
//                                                                              NSLog(@"something's wrong");
//                                                                              // handle with an Alert dialog.
//                                                                          }
//                                                                          if (poptart) {
//                                                                              [poptart show];
//                                                                              
//                                                                          }
//                                                                          if (!poptart) {
//                                                                              // handle logic when there is no reward to give.
//                                                                          }
//                                                                      }];
                                                                  }
                                                                  
                                                                  [button setSelected:YES];
                                                              }
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}];
}

- (void)inviteAllClick:(id)sender {
    
    NSMutableArray *idArray = [[NSMutableArray alloc] init];
    for (NSDictionary<FBGraphUser>* friend in inviteArray) {
        [idArray addObject:[NSString stringWithFormat:@"%@", [friend objectForKey:@"id"]]];
    }
    
    NSString *text = [NSString stringWithFormat:@"I'm inviting you to try Findy!"];
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:[idArray componentsJoinedByString:@","], @"suggestions", nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                  message:text
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              [Flurry logEvent:@"Invite_Facebook_User"];
                                                              [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"INVITE_FRIEND_COUNT"] + [inviteArray count] forKey:@"INVITE_FRIEND_COUNT"];
                                                              if (([[NSUserDefaults standardUserDefaults] integerForKey:@"INVITE_FRIEND_COUNT"] != 0) && ([[NSUserDefaults standardUserDefaults] integerForKey:@"INVITE_FRIEND_COUNT"] % 5 == 0) ){
//                                                                  [[Kiip sharedInstance] saveMoment:@"Inviting Your Friends!" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
//                                                                      if (error) {
//                                                                          NSLog(@"something's wrong");
//                                                                          // handle with an Alert dialog.
//                                                                      }
//                                                                      if (poptart) {
//                                                                          [poptart show];
//                                                                          
//                                                                      }
//                                                                      if (!poptart) {
//                                                                          // handle logic when there is no reward to give.
//                                                                      }
//                                                                  }];
                                                              }
                                                              
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == favoriteTableView) {
        return [favoriteArray count];
    } else if (tableView == inviteTableView) {
        return [inviteArray count];
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"InterestCell";
    
    UITableViewCell *cell = nil;
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];

    if (tableView == favoriteTableView) {
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 180, 35)];
        [lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE]];
        [lblName setText:[[favoriteArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
        [cell addSubview:lblName];
        [lblName release];
        
        UILabel *lblInterest = [[UILabel alloc] initWithFrame:CGRectMake(45, 30, 180, 20)];
        [lblInterest setTextColor:[UIColor lightGrayColor]];
        [lblInterest setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
        if (ISNSArrayValid([[favoriteArray objectAtIndex:indexPath.row] objectForKey:@"interest"])) {
            [lblInterest setText:[[[favoriteArray objectAtIndex:indexPath.row] objectForKey:@"interest"] componentsJoinedByString:@", "]];
        }
        
        [cell addSubview:lblInterest];
        [lblInterest release];
        
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(3.5, 8.5, 33, 33)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
		pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        pImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [[favoriteArray objectAtIndex:indexPath.row] objectForKey:@"id"]]] ;
        [cell addSubview:pImageView];
        [pImageView release];
        
        UIButton *btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"FavoriteButton.png"] forState:UIControlStateNormal];
        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"FavoriteDisableButton.png"] forState:UIControlStateSelected];
        [btnFavorite setFrame:CGRectMake(233, 8.5, 84, 33)];
        [btnFavorite setTag:indexPath.row];
        [btnFavorite addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnFavorite];
        
        if ([[DataManager sharedManager].favoritesArray containsObject:[[favoriteArray objectAtIndex:indexPath.row] objectForKey:@"email"]]) {
            [btnFavorite setSelected:YES];
        }
    } else if (tableView == inviteTableView) {

        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 190, 40)];
        [lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE]];
        [lblName setText:[[inviteArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
        [cell addSubview:lblName];
        [lblName release];
        
        UILabel *lblComment = [[UILabel alloc] initWithFrame:CGRectMake(45, 25, 190, 20)];
        [lblComment setTextColor:[UIColor grayColor]];
        [lblComment setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
        [lblComment setText:@"Invite via Facebook"];
        [cell addSubview:lblComment];
        [lblComment release];
        
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(3.5, 8.5, 33, 33)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
		pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        pImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [[inviteArray objectAtIndex:indexPath.row] objectForKey:@"id"]]] ;
        [cell addSubview:pImageView];
        [pImageView release];
        
        UIButton *btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"InviteButton.png"] forState:UIControlStateNormal];
        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"InviteDisableButton.png"] forState:UIControlStateSelected];
        [btnFavorite setFrame:CGRectMake(221, 7.5, 96, 35)];
        [btnFavorite setTag:indexPath.row];
        [btnFavorite addTarget:self action:@selector(inviteClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnFavorite];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
