//
//  MutualFriendViewController.m
//  Findy
//
//  Created by Yuri Petrenko on 1/26/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import "MutualFriendViewController.h"

@interface MutualFriendViewController ()

@end

@implementation MutualFriendViewController
@synthesize uID;

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

    NSString * query = [NSString stringWithFormat:@"SELECT uid1, uid2 FROM friend where uid1 = %@ and uid2 in (SELECT uid2 FROM friend where uid1=me())", uID];
    NSDictionary *queryParam = @{ @"q": query };
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {

                              if (error) {
                                  
                              } else {
                                  NSMutableArray *idArray = [[NSMutableArray alloc] init];
                                  NSLog(@"%@", result);
                                  for (NSDictionary *dict in [result objectForKey:@"data"]) {
                                      [idArray addObject:[dict objectForKey:@"uid2"]];
                                  }
                                  
                                  NSString *q = [NSString stringWithFormat:@"SELECT uid,name,email,first_name,middle_name,last_name,pic_square FROM user where uid IN (%@)", [idArray componentsJoinedByString:@","]];
                                  NSDictionary *qParam = @{@"q":q};
                                  
                                  [FBRequestConnection startWithGraphPath:@"/fql"
                                                               parameters:qParam
                                                               HTTPMethod:@"GET"
                                                        completionHandler:^(FBRequestConnection *connection,
                                                                            id result,
                                                                            NSError *error) {
                                                            if (error) {
                                                                
                                                            } else {
                                                                friendArray = [[NSMutableArray alloc] initWithArray:[result objectForKey:@"data"]];
                                                                
                                                                NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[idArray componentsJoinedByString:@","], nil]
                                                                                                                                    forKeys:[NSArray arrayWithObjects:@"email", nil]];
                                                                [[FindyAPI instance] getUserExist:self withSelector:@selector(showData:) andOptions:paramDict];
                                                            }
                                                        }];
                              }
                          }];
}

- (void)showData:(NSDictionary *)response {
    NSLog(@"%@", response);
    if (ISNSArrayValid([response objectForKey:@"fids"])) {
        fidDict = [[NSMutableDictionary alloc] initWithDictionary:[response objectForKey:@"fids"]];
        
        [friendTableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)favoriteResult:(NSDictionary *)response {
    if ([[response objectForKey:@"success"] boolValue]) {
        [SVProgressHUD showSuccessWithStatus:@"Favorite Success"];
        [curButton setSelected:!curButton.selected];
    }
}

- (void)favoriteClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    curButton = button;
//    curButton = button;
    NSString *userID = [NSString stringWithFormat:@"%@", [[friendArray objectAtIndex:button.tag] objectForKey:@"uid"]];
    NSString *email = [[fidDict objectForKey:userID] objectForKey:@"email"];

    if (button.selected) {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                                       [DataManager sharedManager].strEmail,
                                                                                       email, nil]
                                                                              forKeys:[NSArray arrayWithObjects:
                                                                                       @"email", @"favorite", nil]];
        [[FindyAPI instance] removeFavorite:self withSelector:@selector(favoriteResult:) andOptions:paramDict];
        [[DataManager sharedManager].favoritesArray removeObject:email];
    } else {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:
                                                                                       [DataManager sharedManager].strEmail,
                                                                                       email, nil]
                                                                              forKeys:[NSArray arrayWithObjects:
                                                                                       @"email", @"favorite", nil]];
        [[FindyAPI instance] addFavorite:self withSelector:@selector(favoriteResult:) andOptions:paramDict];
        
        [[DataManager sharedManager].favoritesArray addObject:email];
    }
}

- (void)inviteClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    curButton = button;
    [button setSelected:YES];
    NSString *userID = [NSString stringWithFormat:@"%@", [[friendArray objectAtIndex:button.tag] objectForKey:@"uid"]];
    
    NSString *text = @"I'm inviting you to try Findy!";
    
    NSMutableDictionary* params =   [[NSMutableDictionary dictionaryWithObjectsAndKeys:userID, @"to", [NSString stringWithFormat:@"%@", @"354986367951475"], @"app_id", nil] retain];

    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
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
                                                              [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"INVITE_FRIEND_COUNT"] + 1 forKey:@"INVITE_FRIEND_COUNT"];
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
    return [friendArray count];
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
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 180, 35)];
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:INTEREST_FONT_SIZE]];
    [lblName setText:[[friendArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
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
    pImageView.imageURL = [NSURL URLWithString:[[friendArray objectAtIndex:indexPath.row] objectForKey:@"pic_square"]] ;
    [cell addSubview:pImageView];
    [pImageView release];
    
    
    NSString *uid = [NSString stringWithFormat:@"%@", [[friendArray objectAtIndex:indexPath.row] objectForKey:@"uid"]];
    uid = [uid stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL bStatus = [[[fidDict objectForKey:uid] objectForKey:@"status"] boolValue];

    if (bStatus) {
        UIButton *btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"FavoriteButton.png"] forState:UIControlStateNormal];
        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"FavoriteDisableButton.png"] forState:UIControlStateSelected];
        [btnFavorite setFrame:CGRectMake(233, 8.5, 84, 33)];
        [btnFavorite setTag:indexPath.row];
        [btnFavorite addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnFavorite];

//        if ([[DataManager sharedManager].favoritesArray containsObject:[[friendArray objectAtIndex:indexPath.row] objectForKey:@"email"]]) {
        
            [btnFavorite setSelected:YES];
//        }
    } else {
        UIButton *btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"InviteButton.png"] forState:UIControlStateNormal];
        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"InviteDisableButton.png"] forState:UIControlStateSelected];
        [btnFavorite setFrame:CGRectMake(233, 8.5, 84, 33)];
        [btnFavorite setTag:indexPath.row];
        [btnFavorite addTarget:self action:@selector(inviteClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnFavorite];
    }
    

//    UIButton *btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"InviteButton.png"] forState:UIControlStateNormal];
//        [btnFavorite setBackgroundImage:[UIImage imageNamed:@"InviteDisableButton.png"] forState:UIControlStateSelected];
//        [btnFavorite setFrame:CGRectMake(233, 7.5, 96, 35)];
//        [btnFavorite setTag:indexPath.row];
//        [btnFavorite addTarget:self action:@selector(inviteClick:) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:btnFavorite];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
     - (void)dealloc {
         [friendTableView release];
         [super dealloc];
     }
     - (void)viewDidUnload {
         [friendTableView release];
         friendTableView = nil;
         [super viewDidUnload];
     }
@end
