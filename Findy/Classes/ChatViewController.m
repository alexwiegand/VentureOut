//
//  ChatViewController.m
//  Findy
//
//  Created by iPhone on 8/19/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "ChatViewController.h"
#import "MeetAtViewController.h"
#import "PlaceProfileViewController.h"
#import "ProfileViewController.h"

#define LEFT_SIDE   0
#define RIGHT_SIDE  1

@interface ChatViewController ()

@end

@implementation ChatViewController

@synthesize shoutInterest, shoutoutText, bChatReply, partnerEmail, leftFace;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [_strTitle release];
    [chatScrollView release];
    [chatView release];
    [chatArray release];
    [leftFace release];
    [[NSNotificationCenter defaultCenter] removeObserver:@"AddChat"];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"In_ChatView"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"FROM_NOTIFICATION"];
    [[NSUserDefaults standardUserDefaults] setObject:chatArray forKey:[NSString stringWithFormat:@"ChatHistory_%@", partnerEmail]];
}

- (void)viewWillAppear:(BOOL)animated {
    yPos = 0;
    lastDate = -1;
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"In_ChatView"];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FROM_NOTIFICATION"] && [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"ChatHistory_%@", partnerEmail]]) {
        if (chatArray) {
            [chatArray removeAllObjects];
            [chatArray release];
        }
        chatArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"ChatHistory_%@", partnerEmail]]];
    }
    
    if (chatArray == nil) {
        chatArray = [[NSMutableArray alloc] init];
    }
    
    curDate = [NSDate date];
    
    chatView = [[MessageComposerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44)];
    [chatView setDelegate:self];
    [self.view addSubview:chatView];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ChatMessage"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CancelMeet"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CancelMeet"];
        [self addPlaceChat:[[NSUserDefaults standardUserDefaults] objectForKey:@"PlaceChat"]];
    } else {
        
        if (bChatReply) {
            placeholderText = [[NSString alloc] initWithFormat:@"Hi there, in reply to your %@ shoutout...", shoutInterest];
            [chatView setText:placeholderText _placeHolder:@""];
            //            [self initHistory];
        } else {
            placeholderText = @"Hi there, in reply to you...";
            [chatView setText:@"" _placeHolder:placeholderText];
        }
        
        if ([chatArray count]) {
            [SVProgressHUD showWithStatus:@"Loading"];
            [self performSelector:@selector(initChatViews) withObject:nil afterDelay:0.1f];
        } else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, partnerEmail, nil] forKeys:[NSArray arrayWithObjects:@"me", @"you", nil]];
            
            [[FindyAPI instance] getChat:self withSelector:@selector(getChatResult:) andOptions:dict];
        }
    }
    
    [chatScrollView setFrame:CGRectMake(0, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320, chatView.frame.origin.y - 44 - [DataManager sharedManager].fiOS7StatusHeight)];

//    [txtChat setTextColor:[UIColor lightGrayColor]];
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
    [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    [backButton addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"MeetAtButton.png"] forState:UIControlStateNormal];
    [nextButton setFrame:CGRectMake(255.5, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 58.f, 30.f)];
    [nextButton addTarget:self action:@selector(meetAtPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:_strTitle];
    [self.view addSubview:lblTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNotificationChat:) name:@"AddChat" object:nil];
}

- (void)revealMenu:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"GOTO_CHAT"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Chat_email"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        
        self.slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"GOTO_CHAT"];
}

- (void)meetAtPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"CancelMeet"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    MeetAtViewController *meetAtController = [storyboard instantiateViewControllerWithIdentifier:@"MeetAtViewController"];
    meetAtController.partnerEmail = partnerEmail;
    [self.navigationController pushViewController:meetAtController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addPlaceChat:(NSDictionary *)chatObject {
    [chatArray addObject:chatObject];
    BOOL side = TRUE;
    if ([[chatObject objectForKey:@"from"] isEqualToString:partnerEmail]) {
        side = FALSE;
    }
    
    NSString *msg = [NSString stringWithFormat:@"%@",[chatObject objectForKey:@"msg"]];
    msg = (IS_IOS7) ? [msg stringByRemovingPercentEncoding] : [msg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    yPos = chatScrollView.contentSize.height + 15;
    if (IsNSStringValid(msg)) {
        NSArray *component = [msg componentsSeparatedByString:@"//"];
        if ([component count] == 4) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[component objectAtIndex:1], @"name", [component objectAtIndex:2], @"id", [chatObject objectForKey:@"time"], @"time", nil];
            [self addPlace:dict _index:[chatArray count] - 1 _side:side];
        } else if ([component count] == 1){
            [self addChat:chatObject _side:side];
        }
        
    }
}

- (void)addNotificationChat:(NSNotification *) notification {
    NSDictionary *chatObject = [notification object];
    
    [chatArray addObject:chatObject];
    BOOL side = TRUE;
    if ([[chatObject objectForKey:@"from"] isEqualToString:partnerEmail]) {
        side = FALSE;
    }
    
    NSString *msg = [NSString stringWithFormat:@"%@",[chatObject objectForKey:@"msg"]];
    msg = (IS_IOS7) ? [msg stringByRemovingPercentEncoding] : [msg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (IsNSStringValid(msg)) {
        NSArray *component = [msg componentsSeparatedByString:@"//"];
        if ([component count] == 4) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[component objectAtIndex:1], @"name", [component objectAtIndex:2], @"id", nil];
            [self addPlace:dict _index:[chatArray count] - 1 _side:side];
        } else if ([component count] == 1){
            [self addChat:chatObject _side:side];
        }
        
    }
}

- (void)addPlace:(NSDictionary *)placeDict _index:(int)index _side:(BOOL)side{
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[placeDict objectForKey:@"time"] longLongValue]];
    NSDate *cDate = [NSDate dateWithTimeIntervalSince1970:lastDate];
    
    NSTimeInterval interval = [date timeIntervalSinceDate:cDate];
    NSInteger ti = (NSInteger)interval;
    
    if ((ti >= 60) || (lastDate == -1)) {
        UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, SCREEN_WIDTH, 12)];
        [lblTime setTextColor:[UIColor grayColor]];
        [lblTime setBackgroundColor:[UIColor clearColor]];
        [lblTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.f]];
        [lblTime setTextAlignment:NSTextAlignmentCenter];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.timeStyle = kCFDateFormatterShortStyle;
        dateFormat.dateStyle = NSDateFormatterShortStyle;
        dateFormat.doesRelativeDateFormatting = YES;  // this enables relative dates like yesterday, today, tomorrow...
        
        [lblTime setText:[dateFormat stringFromDate:date]];
        [chatScrollView addSubview:lblTime];
        [lblTime release];
        
        curDate = date;
        
        yPos += 15;
    }
    
    CGRect faceFrame;
    if (side) {
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(275, yPos, 40, 40)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
        pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        pImageView.imageURL = [NSURL URLWithString:[DataManager sharedManager].strPicSmall];
        [chatScrollView addSubview:pImageView];
        faceFrame = pImageView.frame;
        [pImageView release];
        
        UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentBtn setFrame:pImageView.frame];
        [commentBtn addTarget:self action:@selector(myProfileView:) forControlEvents:UIControlEventTouchUpInside];
        [chatScrollView addSubview:commentBtn];
    } else {
        
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, yPos, 40, 40)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
        pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        pImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://crazebot.com/userpic_small.php?email=%@", partnerEmail]];
        
        [chatScrollView addSubview:pImageView];
        faceFrame = pImageView.frame;
        [pImageView release];
        
        UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentBtn setFrame:pImageView.frame];
        [commentBtn addTarget:self action:@selector(otherProfileView:) forControlEvents:UIControlEventTouchUpInside];
        [chatScrollView addSubview:commentBtn];
    }
    
    UILabel *lblContent = [[UILabel alloc] initWithFrame:CGRectMake(82, yPos + 15, 145, 1000)];
    [lblContent setNumberOfLines:10000];
    NSString *msg = [placeDict objectForKey:@"name"];
    msg = (IS_IOS7) ? [msg stringByRemovingPercentEncoding] : [msg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([msg characterAtIndex:[msg length] - 1] == '\n') {
        msg = [msg substringToIndex:[msg length] - 1];
    }
    [lblContent setText:msg];
    [lblContent setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.f]];
    [lblContent setTextColor:UIColorFromRGB(0xFF5900)];
    [lblContent setBackgroundColor:[UIColor clearColor]];
   
    [lblContent sizeToFit];
    
    float nWidth = lblContent.frame.size.width + 35;
    float nHeight = lblContent.frame.size.height + 20;
    float y = yPos + 5;
    if (nHeight < 40) {
        nHeight = 40;
        y += (40 - lblContent.frame.size.height) / 2.f;
    } else {
        y += (nHeight - lblContent.frame.size.height) / 2.f;
    }
    float x = (side) ? 265 - lblContent.frame.size.width - 35 : 55;
    
    [lblContent setFrame:CGRectMake(x + 27, y, nWidth - 20, lblContent.frame.size.height)];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, yPos + 5, nWidth, nHeight)];
    [imgView setBackgroundColor:[UIColor whiteColor]];
    [imgView.layer setCornerRadius:2.f];
    [imgView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [imgView.layer setBorderWidth:.5f];
    [imgView.layer setMasksToBounds:YES];
    [chatScrollView addSubview:imgView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:imgView.frame];
    [button setTag:index];
    [button addTarget:self action:@selector(placeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [chatScrollView addSubview:button];
    
    UIImageView *placeImage = [[UIImageView alloc] initWithFrame:CGRectMake(x + 6, yPos + 15, 15, 20)];
    [placeImage setImage:[UIImage imageNamed:@"PinLocationInChat.png"]];
    [chatScrollView addSubview:placeImage];
    [placeImage release];
    
    
    UIImage* sourceImage = [UIImage imageNamed:@"Triangle.png"];
    UIImage* flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage
                                                scale:1.0 orientation: UIImageOrientationUpMirrored];
    UIImageView *imgTriangle = [[UIImageView alloc] initWithImage:(side) ? flippedImage : sourceImage];
    
    [imgTriangle setFrame:(side) ? CGRectMake(264, yPos + 12, 7, 7) : CGRectMake(49, yPos + 12, 7, 7)];
    [chatScrollView addSubview:imgTriangle];
    
    [chatScrollView addSubview:lblContent];
    
    float inc = imgView.frame.size.height + 10;
    inc = (inc < faceFrame.size.height) ? faceFrame.size.height + 15 : inc;
    yPos += inc + 10;
    
    [chatScrollView setContentSize:CGSizeMake(320, yPos)];
    
    [chatScrollView setContentOffset:CGPointMake(0, chatScrollView.contentSize.height - chatScrollView.frame.size.height) animated:NO];
    
    lastDate = [date timeIntervalSince1970];
}

- (void)addChat:(NSDictionary *)content _side:(BOOL)bSide{
//    NSLog(@"%@", content);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[content objectForKey:@"time"] longLongValue]];
    NSDate *cDate = [NSDate dateWithTimeIntervalSince1970:lastDate];

    NSTimeInterval interval = [date timeIntervalSinceDate:cDate];
    NSInteger ti = (NSInteger)interval;

    if ((ti >= 60) || (lastDate == -1)) {
//        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"MMMM dd, yyyy, hh:mm a"];
        //    [dateFormat setDateStyle:kCFDateFormatterLongStyle];
        UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, SCREEN_WIDTH, 12)];
        [lblTime setTextColor:[UIColor grayColor]];
        [lblTime setBackgroundColor:[UIColor clearColor]];
        [lblTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.f]];
        [lblTime setTextAlignment:NSTextAlignmentCenter];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.timeStyle = kCFDateFormatterShortStyle;
        dateFormat.dateStyle = NSDateFormatterShortStyle;
        dateFormat.doesRelativeDateFormatting = YES;  // this enables relative dates like yesterday, today, tomorrow...
        
        [lblTime setText:[dateFormat stringFromDate:date]];
        [chatScrollView addSubview:lblTime];
        [lblTime release];
        
        curDate = date;
        lastDate = [date timeIntervalSince1970];
        
        yPos += 15;
    }
    
    CGRect faceFrame;
    if (bSide) {
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(275, yPos, 40, 40)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
        pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        [pImageView setImage:[DataManager sharedManager].imgFace];
//        if (pImageView.image == nil) {
//            pImageView.imageURL = [NSURL URLWithString:[DataManager sharedManager].strPicSmall];
//        }
//
        [chatScrollView addSubview:pImageView];
        faceFrame = pImageView.frame;
        [pImageView release];
        
        UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentBtn setFrame:pImageView.frame];
        [commentBtn addTarget:self action:@selector(myProfileView:) forControlEvents:UIControlEventTouchUpInside];
        [chatScrollView addSubview:commentBtn];
        
    } else {
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(5, yPos, 40, 40)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
        pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
//
        [pImageView setImage:leftFace];
//        if (pImageView.image == nil) {
//            pImageView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://crazebot.com/userpic_small.php?email=%@", partnerEmail]];
//        }
        
        [chatScrollView addSubview:pImageView];
        faceFrame = pImageView.frame;
        [pImageView release];
        
        UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [commentBtn setFrame:pImageView.frame];
        [commentBtn addTarget:self action:@selector(otherProfileView:) forControlEvents:UIControlEventTouchUpInside];
        [chatScrollView addSubview:commentBtn];
    }
    
    
    UITextView *lblContent = [[UITextView alloc] initWithFrame:(bSide) ? CGRectMake(70, yPos + 15, 170, 1000) : CGRectMake(80, yPos + 15, 170, 1000)];
//    [lblContent setNumberOfLines:10000];
    
    NSString *msg = [content objectForKey:@"msg"];

    msg = (IS_IOS7) ? [msg stringByRemovingPercentEncoding] : [msg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if ([msg characterAtIndex:[msg length] - 1] == '\n') {
        msg = [msg substringToIndex:[msg length] - 1];
    }
    
//    CGSize size = [msg sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:14.f]
//                  constrainedToSize:CGSizeMake(170, 1000)];
    
    [lblContent setText:msg];
    [lblContent setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.f]];
    [lblContent setBackgroundColor:[UIColor clearColor]];
//    [lblContent setBackgroundColor:[UIColor lightGrayColor]];
    if (IS_IOS7) {
        [lblContent setDataDetectorTypes:UIDataDetectorTypeCalendarEvent | UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber];
        CGSize size = [msg sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15.f]
                      constrainedToSize:CGSizeMake(lblContent.frame.size.width, 1000)
                          lineBreakMode:0];
        size.height += 16;
        size.width += 16;
        CGRect rect = lblContent.frame;
        rect.size = size;
        lblContent.frame = rect;
    } else {
//        [lblContent sizeToFit];
//        [lblContent layoutIfNeeded];
        CGSize size = [msg sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15.f]
                      constrainedToSize:CGSizeMake(lblContent.frame.size.width, 1000)
                          lineBreakMode:0];
        size.height += 16;
        size.width += 16;
        CGRect rect = lblContent.frame;
        rect.size = size;
        lblContent.frame = rect;
    }
//    CGRect frame = lblContent.frame;
//    frame.size = size;
//    [lblContent setFrame:frame];
    
    [lblContent setScrollEnabled:NO];
    [lblContent setEditable:NO];
//    
    
//    CGSize sizeThatShouldFitTheContent = [lblContent sizeThatFits:lblContent.frame.size];
//    heightConstraint.constant = sizeThatShouldFitTheContent.height;

//    [lblContent setContentInset:UIEdgeInsetsMake(-3, 0, 0, 0)];

//    [lblContent sizeToFit];
    
    float nWidth = lblContent.frame.size.width + 10;

    float x = (bSide) ? 265 - lblContent.frame.size.width - 10 : 55;
    
    [lblContent setFrame:CGRectMake(x + 5, yPos + 5, nWidth - 10, lblContent.frame.size.height)];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, yPos + 5, nWidth, lblContent.frame.size.height)];
    [imgView setBackgroundColor:[UIColor whiteColor]];
    [imgView.layer setCornerRadius:2.f];
    [imgView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [imgView.layer setBorderWidth:.5f];
    [imgView.layer setMasksToBounds:YES];
    [chatScrollView addSubview:imgView];

    
    UIImage* sourceImage = [UIImage imageNamed:@"Triangle.png"];
    UIImage* flippedImage = [UIImage imageWithCGImage:sourceImage.CGImage
                                                scale:1.0 orientation: UIImageOrientationUpMirrored];
    UIImageView *imgTriangle = [[UIImageView alloc] initWithImage:(bSide) ? flippedImage : sourceImage];
    
    [imgTriangle setFrame:(bSide) ? CGRectMake(264, yPos + 12, 7, 7) : CGRectMake(49, yPos + 12, 7, 7)];
    [chatScrollView addSubview:imgTriangle];
    
    [chatScrollView addSubview:lblContent];
    
    float inc = imgView.frame.size.height + 10;
    inc = (inc < faceFrame.size.height) ? faceFrame.size.height + 15 : inc;
    yPos += inc + 10;
    
    [chatScrollView setContentSize:CGSizeMake(320, yPos)];
    [chatScrollView setContentOffset:CGPointMake(0, chatScrollView.contentSize.height - chatScrollView.frame.size.height) animated:NO];
    
    lastDate = [date timeIntervalSince1970];
}

- (void)placeSelect:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *msg = [[chatArray objectAtIndex:button.tag] objectForKey:@"msg"];
    msg = (IS_IOS7) ? [msg stringByRemovingPercentEncoding] : [msg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *paramArray = [msg componentsSeparatedByString:@"//"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    PlaceProfileViewController *profileController = (PlaceProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaceProfileViewController"];
    
    profileController.strTitle = [paramArray objectAtIndex:1];
    //    profileController.contentDictionary = [placesArray objectAtIndex:[sButton tag]];
    if ([paramArray count] == 4) {
        profileController.strInterest = [paramArray objectAtIndex:3];
    }
    
    profileController.strID = [paramArray objectAtIndex:2];
    [self.navigationController pushViewController:profileController animated:YES];
}

- (IBAction)hideKeyboard:(id)sender {
    [chatView hideKeyboard];
}

- (void)myProfileView:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PLACE_PROFILE"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"CancelMeet"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [profileController setFlag:TRUE];
    
    profileController.email = [NSString stringWithFormat:@"%@", [DataManager sharedManager].strEmail];
    
    [self.navigationController pushViewController:profileController animated:YES];
}

- (void)otherProfileView:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PLACE_PROFILE"];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"CancelMeet"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [profileController setFlag:FALSE];
    
    profileController.email = [NSString stringWithFormat:@"%@", partnerEmail];
    
    [self.navigationController pushViewController:profileController animated:YES];
}


#pragma mark - API Integration

- (void)getChatResult:(NSDictionary *)response {

    if ([chatArray count]) {
        [chatArray removeAllObjects];
    }
    
    if (!bChatReply) {
        for (UIView *view in [chatScrollView subviews]) {
            [view removeFromSuperview];
        }
    }

    NSMutableArray *dictValues = [[response objectForKey:@"results"] mutableCopy];
    [dictValues autorelease];
    
    [dictValues sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
     {
         NSString *key1 = [a objectForKey: @"time"];
         NSString *key2 = [b objectForKey: @"time"];
         
         return [key1 compare: key2];
     }
     ];
    
    for (int i = 0; i < [dictValues count]; i++) {
        NSDictionary *result = [dictValues objectAtIndex:i];
        
//        NSLog(@"%@", result);
        
        [chatArray addObject:result];
        BOOL side = TRUE;
        if ([[result objectForKey:@"from"] isEqualToString:partnerEmail]) {
            side = FALSE;
        }
        
        NSString *msg = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        msg = (IS_IOS7) ? [msg stringByRemovingPercentEncoding] : [msg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if (IsNSStringValid(msg)) {
            NSArray *component = [msg componentsSeparatedByString:@"//"];
            if ([component count] == 4) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[component objectAtIndex:1], @"name", [component objectAtIndex:2], @"id", nil];
                [self addPlace:dict _index:i _side:side];
            } else if ([component count] == 1){
                [self addChat:result _side:side];
            }
            
        }
    }
}

- (void)initChatViews {
    for (int i = 0; i < [chatArray count]; i++) {
        NSDictionary *result = [chatArray objectAtIndex:i];
        
        //        NSLog(@"%@", result);
        BOOL side = TRUE;
        if ([[result objectForKey:@"from"] isEqualToString:partnerEmail]) {
            side = FALSE;
        }
        
        NSString *msg = [NSString stringWithFormat:@"%@",[result objectForKey:@"msg"]];
        msg = (IS_IOS7) ? [msg stringByRemovingPercentEncoding] : [msg stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (IsNSStringValid(msg)) {
            NSArray *component = [msg componentsSeparatedByString:@"//"];
            if ([component count] == 4) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[component objectAtIndex:1], @"name", [component objectAtIndex:2], @"id", nil];
                [self addPlace:dict _index:i _side:side];
            } else if ([component count] == 1){
                [self addChat:result _side:side];
            }
            
        }
    }
    
    [SVProgressHUD dismiss];
}

- (void)completeReplyChat:(NSDictionary *)response {
    NSDate *today = [NSDate date];
    long time = [today timeIntervalSince1970];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, partnerEmail, [chatView getText], [NSString stringWithFormat:@"%ld", time], nil] forKeys:[NSArray arrayWithObjects:@"from", @"to", @"msg", @"time", nil]];
    
    [[FindyAPI instance] sendchat:self withSelector:@selector(completeSendChat:) andOptions:dict];
    [self addChat:dict _side:YES];

}

- (void)completeSendChat:(NSDictionary *)response {
    if (bChatReply) {
        placeholderText = [[NSString alloc] initWithFormat:@"Hi there, in reply to your %@ shoutout...", shoutInterest];
        [chatView setText:placeholderText _placeHolder:@""];
        //            [self initHistory];
    } else {
        placeholderText = @"Hi there, in reply to you...";
        [chatView setText:@"" _placeHolder:placeholderText];
    }
    [chatView setText:@"" _placeHolder:@""];
    placeholderText = @"";
    [chatView hideKeyboard];
}

#pragma mark - TextView Delegate

- (void)messageComposerSendMessageClickedWithMessage:(NSString *)message {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"INTEREST_UPDATE"];
    
    if (([message isEqualToString:@""]) || (([message isEqualToString:placeholderText]) && (!bChatReply))) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please input message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    if (bChatReply) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:partnerEmail, shoutoutText, shoutInterest, [DataManager sharedManager].strEmail, nil] forKeys:[NSArray arrayWithObjects:@"email", @"shout", @"interest", @"reply_email", nil]];
        
        [[FindyAPI instance] sendReplyChat:self withSelector:@selector(completeReplyChat:) andOptions:dict];
    } else {
        NSDate *today = [NSDate date];
        long time = [today timeIntervalSince1970];
        
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, partnerEmail, message, [NSString stringWithFormat:@"%ld", time], nil] forKeys:[NSArray arrayWithObjects:@"from", @"to", @"msg", @"time", nil]];
        
        [[FindyAPI instance] sendchat:self withSelector:@selector(completeSendChat:) andOptions:dict];

        [self addChat:dict _side:YES];
    }
}

- (void)messageComposerFrameDidChange:(CGRect)frame withAnimationDuration:(float)duration {
//    [chatScrollView setFrame:CGRectMake(0, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320, SCREEN_HEIGHT - 44 - [DataManager sharedManager].fiOS7StatusHeight - frame.size.height)];
    [chatScrollView setFrame:CGRectMake(0, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320, chatView.frame.origin.y - 44 - [DataManager sharedManager].fiOS7StatusHeight)];
    [chatScrollView setContentOffset:CGPointMake(0, chatScrollView.contentSize.height - chatScrollView.frame.size.height) animated:NO];
}

- (void)messageComposerUserTyping {
    
}


@end
