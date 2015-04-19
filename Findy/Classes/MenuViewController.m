//
//  MenuViewController.m
//  Findy
//
//  Created by iPhone on 8/3/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "ChatViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

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
    [Flurry logEvent:@"Menu View"];
	// Do any additional setup after loading the view.
    [self.slidingViewController setAnchorRightRevealAmount:284.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;

    NSString *key = @"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]) {
        key = @"facebookId";
    } else {
        key = @"email";
    }
    
//    [btnFindMenu setHighlighted:YES];
    selectedButton = btnFindMenu;
//    UIImage *picSmall = nil;
    
//    [imgProfile setImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:[DataManager sharedManager].imgFace withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];

    pImageView = [[AsyncImageView alloc] initWithFrame:imgProfile.frame];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 1;
    pImageView.imageURL = [NSURL URLWithString:[DataManager sharedManager].strPicSmall];
    [menuScroll addSubview:pImageView];
    
    [DataManager sharedManager].imgFace = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[DataManager sharedManager].strPicSmall]]];[DataManager sharedManager].imgBack = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[DataManager sharedManager].strPicBig]]];
//    [imgProfile setImage:[DataManager sharedManager].imgFace];
//    NSLog(@"%@", [DataManager sharedManager].strEmail);
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FACEBOOK_LOGIN"]) {
//        [imgProfile setImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:[DataManager sharedManager].imgFace withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//    } else {
//        [imgProfile setImage:[(AppDelegate *) [[UIApplication sharedApplication] delegate] maskImage:[DataManager sharedManager].imgFace withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//    }
    
    if (!IS_IPHONE5) {
        [menuScroll setContentSize:CGSizeMake(284, 520)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeProfileImage) name:@"ChangeProfileImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearNotificationNumber:) name:@"ClearNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMessageNumber:) name:@"ClearMessage" object:nil];
    
    // Push Notification message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileMenuPressed:) name:@"MyProfile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealsMenuPressed:) name:@"GotoDeal" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoChatView::) name:@"GotoChatView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoOtherProfile:) name:@"GotoOtherProfile" object:nil];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", nil]];
    [[FindyAPI instance] getNotifications:self withSelector:@selector(getNotifications:) andOptions:paramDict];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil]
                                                                   forKeys:[NSArray arrayWithObjects:@"email", nil]];
    [[FindyAPI instance] openChat:self withSelector:@selector(openChatResult:) andOptions:dict];
}

- (void)clearNotificationNumber:(id)sender {
    [nLabel setText:@"0"];
    [nBack setHidden:YES];
    [nLabel setHidden:YES];
}

- (void)clearMessageNumber:(id)sender {
    [notifcationBack setHidden:YES];
    [notificationLabel setHidden:YES];
    [notificationLabel setText:@"0"];
}

- (void)openChatResult:(NSDictionary *)response {
    
    NSArray *currentArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_MESSAGES"];
    if (currentArray == nil) {
        currentArray = [[NSMutableArray alloc] init];
    }

    int nNot = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MESSAGE_NUMBER"] intValue];

    for (NSDictionary *content in [response objectForKey:@"results"]) {
        if (![currentArray containsObject:content]) {
            if (![[content objectForKey:@"latest_from"] isEqualToString:[DataManager sharedManager].strEmail]) {
                nNot ++;
            }
        }
    }
    
    if (nNot != 0) {
        [notifcationBack setHidden:NO];
        [notificationLabel setHidden:NO];
        [notificationLabel setText:[NSString stringWithFormat:@"%d", nNot]];
        [notificationLabel sizeToFit];
        
        CGRect rect = notifcationBack.frame;
        CGSize size = rect.size;
        while (nNot >= 10) {
            size.width *= 1.2f;
            size.height *= 1.2f;
            nNot /= 10;
        }
        
        [notifcationBack setFrame:CGRectMake(rect.origin.x + (rect.size.width - size.width) / 2.f, rect.origin.y + (rect.size.height - size.height) / 2.f, size.width, size.height)];
        
//        [notificationLabel setCenter:CGPointMake(rect.origin.x + (size.width - notificationLabel.frame.size.width) / 2.f, rect.origin.y + (size.height - notificationLabel.frame.size.height ) / 2.f)];
        [notificationLabel setCenter:notifcationBack.center];
        
    } else {
        [notifcationBack setHidden:YES];
        [notificationLabel setHidden:YES];
    }
}

- (void)getNotifications:(NSArray *)response {
    
    NSArray *currentArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"CURRENT_NOTIFICATION"];
    if (currentArray == nil) {
        currentArray = [[NSMutableArray alloc] init];
    }
    
    int nNot = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NOTIFICATION_NUMBER"] intValue];
    
    for (NSDictionary *content in response) {
        if (![currentArray containsObject:content]) {
            nNot ++;
        }
    }

    //    NSLog(@"%@", notificationsArray);
    if (nNot != 0) {
        [nBack setHidden:NO];
        [nLabel setHidden:NO];
        [nLabel setText:[NSString stringWithFormat:@"%d", nNot]];
    } else {
        [nBack setHidden:YES];
        [nLabel setHidden:YES];
    }
}


- (void)changeProfileImage {
    [pImageView removeFromSuperview];
    [pImageView release];
    pImageView = Nil;
    
    pImageView = [[AsyncImageView alloc] initWithFrame:imgProfile.frame];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 1;
    pImageView.imageURL = [NSURL URLWithString:[DataManager sharedManager].strPicSmall];
    [menuScroll addSubview:pImageView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findMenuPressed:(id)sender {
    [selectedButton setHighlighted:NO];
    [btnFindMenu setHighlighted:YES];
    selectedButton = btnFindMenu;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (IBAction)profileMenuPressed:(id)sender {
    [selectedButton setHighlighted:NO];
    [btnProfileMenu setHighlighted:YES];
    selectedButton = btnProfileMenu;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [profileController setBMine:TRUE];
    self.slidingViewController.topViewController = profileController;

    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (IBAction)updateMenuPressed:(id)sender {
    [selectedButton setHighlighted:NO];
    [btnUpdateFeedMenu setHighlighted:YES];
    selectedButton = btnUpdateFeedMenu;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"UpdateFeedViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (IBAction)dealsMenuPressed:(id)sender {
    [selectedButton setHighlighted:NO];
    [btnDealsMenu setHighlighted:YES];
    selectedButton = btnDealsMenu;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"DealsRewardViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (IBAction)favoriteMenuPressed:(id)sender {
    [selectedButton setHighlighted:NO];
    [btnFavoriteMenu setHighlighted:YES];
    selectedButton = btnFavoriteMenu;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"FavoritesViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}
- (IBAction)myCommunityPressed:(id)sender {
    [selectedButton setHighlighted:NO];
    [btnMyCommunity setHighlighted:YES];
    selectedButton = btnMyCommunity;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyCommunityViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
    
}

- (IBAction)messageMenuPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"MESSAGE_NUMBER"];
    [selectedButton setHighlighted:NO];
    [btnMessagesMenu setHighlighted:YES];
    selectedButton = btnMessagesMenu;
    
    [notifcationBack setHidden:YES];
    [notificationLabel setHidden:YES];
    [notificationLabel setText:@"0"];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"MessagesViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (IBAction)notificationMenuPressed:(id)sender {
    [nLabel setText:@"0"];
    [nBack setHidden:YES];
    [nLabel setHidden:YES];

    [selectedButton setHighlighted:NO];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (IBAction)settingsMenuPressed:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (IBAction)inviteMyFriendPressed:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"InviteFBFriendViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (void)showAlert:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Menu" message:string delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];

}
- (void)dealloc {
    [imgProfile release];
    [btnFindMenu release];
    [btnProfileMenu release];
    [btnUpdateFeedMenu release];
    [btnDealsMenu release];
    [btnFavoriteMenu release];
    [btnMessagesMenu release];
    [menuScroll release];
    [notifcationBack release];
    [notificationLabel release];
    [nLabel release];
    [nBack release];
    [super dealloc];
}
- (void)viewDidUnload {
    [menuScroll release];
    menuScroll = nil;
    [notifcationBack release];
    notifcationBack = nil;
    [notificationLabel release];
    notificationLabel = nil;
    [nLabel release];
    nLabel = nil;
    [nBack release];
    nBack = nil;
    [super viewDidUnload];
}

#pragma mark - Push Notification

- (void)gotoOtherProfile:(NSNotification *)notification {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSDictionary *commentObject = [notification object];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    if ([[commentObject objectForKey:@"email"] isEqualToString:[DataManager sharedManager].strEmail]) {
        [profileController setBMine:TRUE];
    } else {
        [profileController setBMine:FALSE];
    }
    
    profileController.email = [commentObject objectForKey:@"email"];
    
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = profileController;
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
    
}

- (void)gotoChatView:(NSNotification *) notification {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"FROM_NOTIFICATION"];
    NSDictionary *chatObject = [notification object];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    
    ChatViewController *chatController = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    //        chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];
    
    //        chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];
    chatController.partnerEmail = [chatObject objectForKey:@"from"];
    chatController.strTitle = [chatObject objectForKey:@"first"];
    chatController.bChatReply = FALSE;
    

    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = chatController;
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}


@end
