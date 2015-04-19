//
//  SuggestPlaceViewController.m
//  Findy
//
//  Created by iPhone on 11/17/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "SuggestPlaceViewController.h"

@interface SuggestPlaceViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lblInterest;
@property (retain, nonatomic) IBOutlet UITextField *txtPlaceName;
@property (retain, nonatomic) IBOutlet UITextField *txtLocation;

@end

@implementation SuggestPlaceViewController
@synthesize interest;

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
    
    self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
    
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    [backButton addTarget:self action:@selector(backMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"Suggest a Place!"];
    
    [self.view addSubview:lblTitle];
    
    [self.lblInterest setText:interest];
    [self.txtLocation setText:[DataManager sharedManager].strCity];
    
	// Do any additional setup after loading the view.
    /*
    NSString *urlString = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&radius_filter=%f&ll=%f,%f",[[DataManager sharedManager].interestArray objectAtIndex:i], radiusFilter, [DataManager sharedManager].latitude, [DataManager sharedManager].longitude];
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@" & " withString:@","];
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@","];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:@"hirq2-YQaGOjQvw6mTp-XQ" secret:@"FyfSMc-25pAa2_eGAPkxm5_pEv0"] autorelease];
    OAToken *token = [[[OAToken alloc] initWithKey:@"3H_Er0KrO6ZO6ZguVqjdS84kArT69wa8" secret:@"Zf76165ehF2MabZu-ruCPFEK-Vk"] autorelease];
    
    id<OASignatureProviding, NSObject> provider = [[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease];
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        NSDictionary * rDictionary = [[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:responseData];
        
        if ([rDictionary valueForKey:@"businesses"])
            //                    for (int j = 0; j < [[rDictionary objectForKey:@"businesses"] count]; j++) {
            for (NSDictionary *dict in [rDictionary objectForKey:@"businesses"]) {
                NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:dict, [[DataManager sharedManager].interestArray objectAtIndex:i], nil] forKeys:[NSArray arrayWithObjects:@"value", @"interest", nil]];
                [placesArray addObject:paramDict];
            }
        if (i == [interestFilterArray count] - 1) {
            [self sortPlaces];
        }
    }];
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_lblInterest release];
    [_txtPlaceName release];
    [_txtLocation release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLblInterest:nil];
    [self setTxtPlaceName:nil];
    [self setTxtLocation:nil];
    [super viewDidUnload];
}

- (void)backMenu:(id)sender {
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)suggestResult:(NSDictionary *)response {
    [SVProgressHUD showSuccessWithStatus:@"Thank you"];
    [self performSelector:@selector(backMenu:) withObject:nil afterDelay:.5f];
}

- (IBAction)suggestPlace:(id)sender {
    if ([self.txtPlaceName.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please input place name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    if ([self.txtLocation.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please input address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    NSString *strPlaceName = [self.txtPlaceName.text stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSString *strLocation = [self.txtLocation.text stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, strPlaceName, self.lblInterest.text, strLocation, nil] forKeys:[NSArray arrayWithObjects:@"email", @"name", @"interest", @"address", nil]];
    [[FindyAPI instance] suggestPlace:self withSelector:@selector(suggestResult:) andOptions:paramDict];
}
@end
