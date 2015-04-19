//
//  UpdateFeedViewController.m
//  Findy
//
//  Created by iPhone on 9/21/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "UpdateFeedViewController.h"
#import "ProfileViewController.h"

@interface UpdateFeedViewController ()

@end

@implementation UpdateFeedViewController

@synthesize contentScrollView;

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
    [Flurry logEvent:@"Update_Feed"];
	// Do any additional setup after loading the view.
    
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
    [lblTitle setText:@"Updates Feed"];
    [self.view addSubview:lblTitle];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    ECSlidingViewTopNotificationMacro;
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    emailArray = [[NSMutableArray alloc] init];
    [self getUpdateFeeds];
    
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

- (void)getUpdateFeeds {
    NSMutableDictionary *authenticationCredentails =
    [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, nil]
                                       forKeys:[NSArray arrayWithObjects:@"email", nil]];
    [[FindyAPI instance] getUpdateFeed:self
                           withSelector:@selector(feedResult:)
                             andOptions:authenticationCredentails];
}

/*
 email = "lenka85@walla.com";
 first = Helena;
 last = Powell;
 "pic_small" =
 msg = Hello;
 time = 1379506149;
 to = "yuri@gamil.com";
 type = message;
 */
- (void)feedResult:(NSArray *)response {
    int y = 10;
    
    if ([emailArray count]) {
        [emailArray removeAllObjects];
    }

    int i = 0;

    if ([response count]) {
        [nonFavoriteView setHidden:YES];
        
        for (NSDictionary *content in response) {
            
            if ([content valueForKey:@"email"] == Nil) {
                continue;
            }
            
            [emailArray addObject:[content objectForKey:@"email"]];
            // Calculate Content Height
            int nHeight = 80.f;
            
            UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, 300, nHeight)];
            [backImage setBackgroundColor:[UIColor whiteColor]];
            [backImage.layer setCornerRadius:2.f];
            [backImage.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
            [backImage.layer setBorderWidth:0.5f];
            [backImage.layer setNeedsDisplayOnBoundsChange:YES];
            [contentScrollView addSubview:backImage];

            // Get Profile Image
            //            NSLog(@"%@", content);
            if (IsNSStringValid([content objectForKey:@"pic_small"])) {
//                UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[content objectForKey:@"pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
//                
//                UIImageView *pImageView = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
//                [pImageView setFrame:CGRectMake(9.f, y + 12.f, 53.f, 53.f)];
//                [contentScrollView addSubview:pImageView];
//                [pImageView release];
                
                AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(9, y + 12, 53, 53)];
                pImageView.contentMode = UIViewContentModeScaleAspectFill;
                pImageView.clipsToBounds = YES;
                pImageView.bCircle = 1;
                pImageView.imageURL = [NSURL URLWithString:[content objectForKey:@"pic_small"]];
                [contentScrollView addSubview:pImageView];
                [pImageView release];
            }
            
            
            UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(70.f, y + 18, 220.f, 20.f)];
            [lblName setBackgroundColor:[UIColor clearColor]];
            [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
            [lblName setText:([content objectForKey:@"first"] == [NSNull null]) ? @"" : [content objectForKey:@"first"]];
            [lblName setTextColor:[UIColor colorWithRed:0 green:.6f blue:.8f alpha:1.f]];
            [contentScrollView addSubview:lblName];
            [lblName release];
            
            // Get Distance
            CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:[DataManager sharedManager].latitude
                                                                 longitude:[DataManager sharedManager].longitude];
            CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:[[[content objectForKey:@"loc"] objectAtIndex:1] floatValue]
                                                                    longitude:[[[content objectForKey:@"loc"] objectAtIndex:0] floatValue]];
            
            CLLocationDistance distance = [targetLocation distanceFromLocation:curLocation];
            
            UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(158.f, y + 15, 130.f, 12.f)];
            [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
            [lblMile setBackgroundColor:[UIColor clearColor]];
            [lblMile setTextAlignment:NSTextAlignmentRight];
            [lblMile setText:[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34]];
            [contentScrollView addSubview:lblMile];
            [lblMile release];
            
            int x = 70.f;
            
//            int x = 95;
            NSString *mString = [self getMatchingInterest:[content objectForKey:@"interests"]];
            NSString *uString = [self getUnmatchingInterest:[content objectForKey:@"interests"]];
            NSString *iString = @"";
            
            NSMutableAttributedString *attributeString;
            if (IsNSStringValid(mString) && IsNSStringValid(uString)) {
                iString = [NSString stringWithFormat:@"%@, %@", mString, uString];
                attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
                [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [mString length])];
                [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange([mString length] + 1, [uString length])];
            } else if (IsNSStringValid(mString) && (!IsNSStringValid(uString))) {
                iString = [NSString stringWithFormat:@"%@",mString];
                attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
                [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [mString length])];
            } else if ((!IsNSStringValid(mString)) && IsNSStringValid(uString)) {
                iString = [NSString stringWithFormat:@"%@", uString];
                attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
                [attributeString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE] range:NSMakeRange(0, [uString length])];
            } else {
                iString = @"";
                attributeString = [[NSMutableAttributedString alloc] initWithString:iString];
            }
            
            UILabel *lblMatchingInterest = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 45.f, 205.f, 20.f)];
            [lblMatchingInterest setBackgroundColor:[UIColor clearColor]];
            [lblMatchingInterest setAttributedText:attributeString];
            [contentScrollView addSubview:lblMatchingInterest];
            
            float shoutHeight = 0;
            float yPos = 0;
            if ([content objectForKey:@"shoutouts"] != [NSNull null]) {
                UIImageView *imgShoutMini = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShoutOutMini.png"]];
                [imgShoutMini setFrame:CGRectMake(15, y + 74, imgShoutMini.frame.size.width, imgShoutMini.frame.size.height)];
                [contentScrollView addSubview:imgShoutMini];
                
                int nIndex = [[content objectForKey:@"shoutouts"] count] - 1;
                
                NSString *interest = [NSString stringWithFormat:@"%@:", [[[content objectForKey:@"shoutouts"] lastObject] objectForKey:@"interest"] ];
                if (IsNSStringValid(interest)) {
                    if (IS_IOS7) {
                        interest = [interest stringByRemovingPercentEncoding];
                    } else {
                        interest = [interest stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                }
                if ([interest isEqualToString:@"Ballroomdancing:"]) {
                    interest = @"Ballroom Dancing:";
                }
                
                if ([interest isEqualToString:@"Rockclimbing:"]) {
                    interest = @"Rock climbing:";
                }
                NSString *strShout = @"";
                if ([[[[content objectForKey:@"shoutouts"] lastObject] objectForKey:@"shout"] isEqualToString:@""] == FALSE) {
                    strShout = [[[content objectForKey:@"shoutouts"] lastObject] objectForKey:@"shout"];
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
                
                nHeight += lblShoutBody.frame.size.height;
                shoutHeight = lblShoutBody.frame.size.height;
                
                
                NSDictionary *shoutDict = [[content objectForKey:@"shoutouts"] lastObject];
                if ([shoutDict valueForKey:@"attach_title"] && IsNSStringValid([shoutDict objectForKey:@"attach_title"])) {
                    
                    UILabel *lblAttach = [[UILabel alloc] initWithFrame:CGRectMake(35, lblShoutBody.frame.origin.y + lblShoutBody.frame.size.height + 5, 300, 15)];
                    
                    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"Attached deal"];
                    [aString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, [aString  length])];
                    [aString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:12.f] range:NSMakeRange(0, [aString  length])];
                    
                    [lblAttach setAttributedText:aString];
                    [lblAttach setTextColor:UIColorFromRGB(0x757171)];
                    [contentScrollView addSubview:lblAttach];
                    [lblAttach release];
                    
                    nHeight += 20;
//                    shoutHeight += 20;
                    
                    AsyncImageView *aImgView = [[AsyncImageView alloc] initWithFrame:CGRectMake(25.f, lblAttach.frame.origin.y + lblAttach.frame.size.height + 10, 40.f, 40.f)];
                    aImgView.contentMode = UIViewContentModeScaleAspectFill;
                    aImgView.clipsToBounds = YES;
                    aImgView.bCircle = 1;
                    if ([shoutDict valueForKey:@"attach_image_url"] && IsNSStringValid([shoutDict valueForKey:@"attach_image_url"]))
                        aImgView.imageURL = [NSURL URLWithString:[shoutDict objectForKey:@"attach_image_url"]];
                    [contentScrollView addSubview:aImgView];
                    [aImgView release];
                    
                    UILabel *lblAttachTitle = [[UILabel alloc] initWithFrame:CGRectMake(75.f, lblAttach.frame.origin.y + lblAttach.frame.size.height + 15, 240.f, 20)];
                    [lblAttachTitle setTextColor:[UIColor colorWithRed:1.f green:74 / 255.f blue:0 alpha:1.f]];
                    [lblAttachTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.f]];
                    if ([shoutDict valueForKey:@"attach_title"] && IsNSStringValid([shoutDict valueForKey:@"attach_title"]))
                        [lblAttachTitle setText:[[shoutDict objectForKey:@"attach_title"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
                    [contentScrollView addSubview:lblAttachTitle];
                    [lblAttachTitle release];
                    
                    UILabel *lblAttachDetail = [[UILabel alloc] initWithFrame:CGRectMake(75.f, lblAttach.frame.origin.y + lblAttach.frame.size.height + 30, 240.f, 20)];
                    [lblAttachDetail setTextColor:[UIColor darkGrayColor]];
                    [lblAttachDetail setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.f]];
                    if ([shoutDict valueForKey:@"attach_detail"] && IsNSStringValid([shoutDict valueForKey:@"attach_detail"]))
                        [lblAttachDetail setText:[[shoutDict objectForKey:@"attach_detail"] stringByReplacingOccurrencesOfString:@"%20" withString:@" "]];
                    [contentScrollView addSubview:lblAttachDetail];
                    [lblAttachDetail release];
                    
                    //                    }
                    
//                    shoutHeight += 45;
                    nHeight += 45;
                    
                    //                    NSLog(@"%@", shoutDict);
                    
                    yPos = 65;
                }
                y += yPos;
                
                NSArray *sArray = [content objectForKey:@"shoutouts"];
                
                NSMutableArray *replyArray = [self getCountAndRemoveMultiples:[[sArray lastObject] objectForKey:@"replies"]];
                NSMutableArray *commentArray = [self getCommentCountAndRemoveMultiples:[[sArray lastObject] objectForKey:@"comments"]];
                
                UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line.png"]];
                [lineView setFrame:CGRectMake(0, y + 74 + lblShoutBody.frame.size.height + 5, 300, 1)];
                [contentScrollView addSubview:lineView];
                nHeight += 15;
                
                if (([[sArray lastObject] valueForKey:@"comments"] != nil) || ([[sArray lastObject] valueForKey:@"replies"] != nil)) {
                    
                    
                    
                    UILabel *lblReply = [[UILabel alloc] initWithFrame:CGRectMake(25, lineView.frame.origin.y + lineView.frame.size.height + 11, 0, 0)];
                    NSDictionary *sDict = [sArray lastObject];
                    if ([sDict valueForKey:@"replies"]) {
                        [lblReply setText:[NSString stringWithFormat:@"%d Chat replied", [[replyArray objectAtIndex:0] count]]];
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
                        [lblComment setText:[NSString stringWithFormat:@"%d Commented", [[commentArray objectAtIndex:0] count]]];
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
                            UIImage *pImage = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[[cDict objectForKey:@"comment_pic_small"] stringByReplacingOccurrencesOfString:@":::" withString:@"+"]]];
                            
                            UIImageView *pImageView = [[UIImageView alloc] initWithImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:pImage withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]]];
                            [pImageView setFrame:CGRectMake(cx, lblReply.frame.origin.y - 3, 20.f, 20.f)];
                            [contentScrollView addSubview:pImageView];
                            [pImageView release];
                            
                            p ++;
                            cx += 23;
                        }
                    }
                } else {
                    UILabel *lblReply = [[UILabel alloc] initWithFrame:CGRectMake(0, lineView.frame.origin.y + lineView.frame.size.height, 300, 35)];
                    [lblReply setText:@"Be the first one to reply / comment?"];
                    [lblReply setBackgroundColor:[UIColor clearColor]];
                    [lblReply setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
                    [lblReply setTextAlignment:NSTextAlignmentCenter];
                    [contentScrollView addSubview:lblReply];
                    [lblReply release];
                    nHeight += 18;
                }
                
            }
            
            y -= yPos;
            [backImage setFrame:CGRectMake(0, y, 300, nHeight + 5)];
            UIButton *btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnProfile setFrame:CGRectMake(10, y, 300, nHeight + 10)];
            [btnProfile addTarget:self action:@selector(showProfile:) forControlEvents:UIControlEventTouchUpInside];
            [btnProfile setTag:i];
            [contentScrollView addSubview:btnProfile];

            y += nHeight + 15;
            i ++;
        }
        
        [contentScrollView setContentSize:CGSizeMake(300, y)];
    } else {
        [nonFavoriteView setHidden:NO];
    }

}

- (NSString *)getMatchingInterest:(NSArray *)interestArray {
    NSMutableArray *arrInterest = [[NSMutableArray alloc] init];
    for (NSString *interest in interestArray) {
        if ([[DataManager sharedManager].interestArray containsObject:interest]) {
            [arrInterest addObject:interest];
        }
    }
    return [arrInterest componentsJoinedByString:@", "];
}

- (NSString *)getUnmatchingInterest:(NSArray *)interestArray {
    NSMutableArray *arrInterest = [[NSMutableArray alloc] init];
    for (NSString *interest in interestArray) {
        if (![[DataManager sharedManager].interestArray containsObject:interest]) {
            [arrInterest addObject:interest];
        }
    }
    return [arrInterest componentsJoinedByString:@", "];
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

- (void)dealloc {
    [contentScrollView release];
    [nonFavoriteView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setContentScrollView:nil];
    [nonFavoriteView release];
    nonFavoriteView = nil;
    [super viewDidUnload];
}

- (void)showProfile:(id)sender {
    UIButton *button = (UIButton *)sender;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [profileController setFlag:FALSE];
    
    profileController.email = [emailArray objectAtIndex:button.tag];
    
    [self.navigationController pushViewController:profileController animated:YES];
}
- (IBAction)favoriteInFindy:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

- (IBAction)favoriteInFacebook:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    
    self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"InviteFBFriendViewController"];
    
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}
@end
