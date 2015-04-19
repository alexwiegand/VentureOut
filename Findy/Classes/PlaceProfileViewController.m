//
//  PlaceProfileViewController.m
//  Findy
//
//  Created by iPhone on 9/5/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "PlaceProfileViewController.h"
#import "SuggestPlaceViewController.h"
#import "WebBrowserViewController.h"
#import "MapBrowserViewController.h"
#import "ProfileViewController.h"
#import "LessonOfferViewController.h"
#import "DiscountOfferViewController.h"
#import "JSONKit.h"

@interface PlaceProfileViewController ()

@end

@implementation PlaceProfileViewController
@synthesize strTitle, contentDictionary, strID, strInterest, placeOfferArray, distance;

- (void)dealloc {
    [strTitle release];
    [contentDictionary release];
    [contentScrollView release];
    [placeOfferArray release];
    [lblHit release];
    [super dealloc];
}
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
    [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    [backButton addTarget:self action:@selector(backMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30.f, 10.5f + [DataManager sharedManager].fiOS7StatusHeight, 260.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:strTitle];
    [lblTitle sizeToFit];
    
    [self changeLabelFont:lblTitle _fontName:@"HelveticaNeue-Bold" _fontSize:18.f _width:240.f];

    [lblTitle setFrame:CGRectMake(30 + (260.f - lblTitle.frame.size.width) / 2.f, (44 - lblTitle.frame.size.height) / 2.f + [DataManager sharedManager].fiOS7StatusHeight, lblTitle.frame.size.width, lblTitle.frame.size.height)];

    [self.view addSubview:lblTitle];

    [lblHit setHidden:YES];
    
    if (placeOfferArray == nil) {
        [self getOffers];
    }
    
    if ([strID rangeOfString:@"findy-"].location != NSNotFound) {
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObject:strID forKey:@"yelp_id"];
        [[FindyAPI instance] placeDetail:self withSelector:@selector(getKitePlace:) andOptions:paramDict];
    } else {
        [SVProgressHUD showWithStatus:@"Getting Place Info" maskType:SVProgressHUDMaskTypeClear];
        NSString *urlString = [NSString stringWithFormat:@"http://api.yelp.com/v2/business/%@?ll=%f,%f", strID, [DataManager sharedManager].latitude, [DataManager sharedManager].longitude];
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
//            NSLog(@"%@", rDictionary);
            contentDictionary = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:strInterest, rDictionary, nil] forKeys:[NSArray arrayWithObjects:@"interest", @"value", nil]];
            [self showData];
            [SVProgressHUD dismiss];
        }];
    }
    
}

- (void)getOffers {
    NSLog(@"%@", [DataManager sharedManager].placeOfferDict);
    placeOfferArray = [[NSMutableArray alloc] initWithArray:[[DataManager sharedManager].placeOfferDict objectForKey:strID]];
//    NSString *urlString = [NSString stringWithFormat:@"http://crazebot.com/offers.php?yelp_id=%@&auth_email=%@&auth=%@", [strID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [DataManager sharedManager].strEmail, [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_value"]];
//    
//    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
//                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                          timeoutInterval:30];
//    NSData *offerData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
//    
//    if (offerData != nil) {
//        
//        NSDictionary *offerDict = [[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:offerData];
//        
//        if (([offerDict count]) && ([[offerDict objectForKey:strID] count])) {
//            //        if ([[offerDict objectForKey:@"wind-over-water-lessons-burlingame"] count]) {
//            placeOfferArray = [[NSMutableArray alloc] initWithArray:[offerDict objectForKey:strID]];
//            [[DataManager sharedManager].placeOfferDict addEntriesFromDictionary:offerDict];
//            
//            float offer_y = bodyImageView.frame.origin.y + nHeight;
//            
//            UIImageView *imgLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfferLine.png"]];
//            [imgLine setFrame:CGRectMake(10, offer_y, 279, 1)];
//            [contentScrollView addSubview:imgLine];
//            [imgLine release];
//            
//            UIImageView *imgIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfferIcon.png"]];
//            [imgIcon setFrame:CGRectMake(20, ([[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] > 1) ? offer_y + 10 + ((16 * [[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] - 22) / 2.f) : offer_y + 10, 22, 22)];
//            [contentScrollView addSubview:imgIcon];
//            [imgIcon release];
//            
//            nHeight += ([[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] > 1) ? 10 + 16 * [[offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]] count] : 32;
//            
//            for (NSDictionary *dict in [offerDict objectForKey:[[content objectForKey:@"value"] objectForKey:@"id"]]) {
//                UILabel *lblOffer = [[UILabel alloc] initWithFrame:CGRectMake(50, offer_y + 10, 250, 13)];
//                [lblOffer setBackgroundColor:[UIColor clearColor]];
//                [lblOffer setTextColor:[UIColor darkGrayColor]];
//                [lblOffer setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.f]];
//                [lblOffer setText:[dict objectForKey:@"find_text"]];
//                [contentScrollView addSubview:lblOffer];
//                [lblOffer release];
//                
//                offer_y += 16;
//            }
//        }
//    }
}

- (void)getKitePlace:(NSDictionary *)response {

    titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320.f, 150.f)];
    [contentScrollView addSubview:titleImageView];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[response objectForKey:@"pic"]]]];
    [titleImageView setImage:[[ImageResizingUtility instance] imageByCropping:image _targetSize:CGSizeMake(320, 150)]];
    [titleImageView release];
    
    favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteButton setFrame:CGRectMake(138.f, 150.f, 176.f, 35.f)];
    [favoriteButton setImage:[UIImage imageNamed:@"JoinCommunityButton.png"] forState:UIControlStateNormal];
    [favoriteButton setImage:[UIImage imageNamed:@"JoinCommunityDisable.png"] forState:UIControlStateSelected];
    [favoriteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [favoriteButton addTarget:self action:@selector(favoritePlace:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:favoriteButton];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView startAnimating];
    [contentScrollView addSubview:indicatorView];
    
    for (NSDictionary *dict in [DataManager sharedManager].favoritePlaceArray) {
        if ([[dict objectForKey:@"yelp_id"] rangeOfString:@"findy-"].location != NSNotFound) {
            [favoriteButton setSelected:YES];
        }
    }
    
    float y = 194.f;
    float infoHeight = 100;
    
    UIImageView *infoBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, infoHeight)];
    [infoBack setBackgroundColor:[UIColor whiteColor]];
    [contentScrollView addSubview:infoBack];
    [infoBack release];
    
    y += 5.f;
    UILabel *lblInfoTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 300, 15)];
    [lblInfoTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblInfoTitle setBackgroundColor:[UIColor clearColor]];
    [lblInfoTitle setTextColor:[UIColor darkGrayColor]];
    [lblInfoTitle setText:@"INFO PAGE"];
    [contentScrollView addSubview:lblInfoTitle];
    [lblInfoTitle release];
    
    y += lblInfoTitle.frame.size.height;
    
    UIButton *btnPhone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPhone setFrame:CGRectMake(15, y, 300, 30)];
    [btnPhone setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnPhone.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [btnPhone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    infoUrl = [[NSString alloc] initWithString:[[response objectForKey:@"links"] objectForKey:@"info page"]];
    NSArray *arrUrl = [[[response objectForKey:@"links"] objectForKey:@"info page"] componentsSeparatedByString:@"/"];
    NSString *strPhone = [NSString stringWithFormat:@"%@",[arrUrl objectAtIndex:2]];
    if (([strPhone isEqualToString:@"(null)"]) || ([strPhone isEqualToString:@""])) {
        strPhone = @"";
    } else {
        [btnPhone addTarget:self action:@selector(gotoInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    [btnPhone setTitle:strPhone forState:UIControlStateNormal];
    
    
    [contentScrollView addSubview:btnPhone];
    
    y += btnPhone.frame.size.height;
    
    UIImageView *phoneLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, y, 305, 1)];
    [phoneLine setImage:[UIImage imageNamed:@"PlaceProfileLine.png"]];
    [contentScrollView addSubview:phoneLine];
    
    y += phoneLine.frame.size.height + 5;
    
    UILabel *lblURLTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 300, 15)];
    [lblURLTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblURLTitle setBackgroundColor:[UIColor clearColor]];
    [lblURLTitle setTextColor:[UIColor darkGrayColor]];
    [lblURLTitle setText:@"WIND CONDITIONS"];
    [contentScrollView addSubview:lblURLTitle];
    [lblURLTitle release];
    
    y += lblURLTitle.frame.size.height;

    btnUrl = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnUrl setFrame:CGRectMake(15, y, 300, 30)];
    [btnUrl setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnUrl.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [btnUrl setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnUrl addTarget:self action:@selector(gotoWind:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:btnUrl];
    windUrl = [[NSString alloc] initWithString:[[response objectForKey:@"links"] objectForKey:@"wind conditions"]];
    NSArray *arrWind = [[[response objectForKey:@"links"] objectForKey:@"wind conditions"] componentsSeparatedByString:@"/"];
    NSString *strWind = [NSString stringWithFormat:@"%@",[arrWind objectAtIndex:2]];
    [btnUrl setTitle:strWind forState:UIControlStateNormal];
    
    y += btnUrl.frame.size.height;
    UIImageView *urlLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, y, 305, 1)];
    [urlLine setImage:[UIImage imageNamed:@"PlaceProfileLine.png"]];
    [contentScrollView addSubview:urlLine];
    
    // More Info
    y += urlLine.frame.size.height + 5;
//    UILabel *lblMoreInfo = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 100, 30)];
//    [lblMoreInfo setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
//    [lblMoreInfo setBackgroundColor:[UIColor clearColor]];
//    [lblMoreInfo setTextColor:[UIColor darkGrayColor]];
//    [lblMoreInfo setText:@"MORE INFO ON"];
//    [contentScrollView addSubview:lblMoreInfo];
//    [lblMoreInfo release];
//    
//    UIButton *btnYelp = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnYelp setFrame:CGRectMake(150, y, 57, 28)];
//    [btnYelp setImage:[UIImage imageNamed:@"YelpLogo.png"] forState:UIControlStateNormal];
//    [btnYelp addTarget:self action:@selector(gotoYelp:) forControlEvents:UIControlEventTouchUpInside];
//    [contentScrollView addSubview:btnYelp];
//    
//    y += 35;
//    UIImageView *addressLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, y, 305, 1)];
//    [addressLine setImage:[UIImage imageNamed:@"PlaceProfileLine.png"]];
//    [contentScrollView addSubview:addressLine];
//    
//    // Address
//    y += addressLine.frame.size.height + 5;
    
    UILabel *lblAddressTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 300, 15)];
    [lblAddressTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblAddressTitle setBackgroundColor:[UIColor clearColor]];
    [lblAddressTitle setTextColor:[UIColor darkGrayColor]];
    [lblAddressTitle setText:@"ADDRESS"];
    [contentScrollView addSubview:lblAddressTitle];
    [lblAddressTitle release];
    
    if (distance == 0) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.geoCoder geocodeAddressString:[response objectForKey:@"address"] completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:[DataManager sharedManager].latitude
                                                                 longitude:[DataManager sharedManager].longitude];
            CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude
                                                                    longitude:placemark.location.coordinate.longitude];
            
            distance = [targetLocation distanceFromLocation:curLocation];
            
            CGSize size = [[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
            
            UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(310.f - size.width, y + 1, size.width, size.height)];
            [lblMile setBackgroundColor:[UIColor clearColor]];
            [lblMile setText:[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34]];
            [lblMile setBackgroundColor:[UIColor clearColor]];
            [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
            [lblMile setTextColor:[UIColor darkGrayColor]];
            [contentScrollView addSubview:lblMile];
            [contentScrollView bringSubviewToFront:lblMile];
            [lblMile release];
            
            UIImageView *imgHouse = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LocationIcon.png"]];
            [imgHouse setFrame:CGRectMake(291.f - size.width, y + 2.5, 14, 15)];
            [contentScrollView addSubview:imgHouse];
            [contentScrollView bringSubviewToFront:imgHouse];
            [imgHouse release];
        }];
    } else {
        CGSize size = [[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
        
        UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(310.f - size.width, y + 1, size.width, size.height)];
        [lblMile setBackgroundColor:[UIColor clearColor]];
        [lblMile setText:[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34]];
        [lblMile setBackgroundColor:[UIColor clearColor]];
        [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
        [lblMile setTextColor:[UIColor darkGrayColor]];
        [contentScrollView addSubview:lblMile];
        [contentScrollView bringSubviewToFront:lblMile];
        [lblMile release];
        
        UIImageView *imgHouse = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LocationIcon.png"]];
        [imgHouse setFrame:CGRectMake(291.f - size.width, y + 2.5, 14, 15)];
        [contentScrollView addSubview:imgHouse];
        [contentScrollView bringSubviewToFront:imgHouse];
        [imgHouse release];
    }
    
    y += lblAddressTitle.frame.size.height;
    
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, y + 5, 290, 46)];
    [lblAddress setBackgroundColor:[UIColor clearColor]];
    [lblAddress setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [lblAddress setNumberOfLines:1000];
    NSString *addressText = [response objectForKey:@"address"];

    [lblAddress setText:addressText];
    [lblAddress sizeToFit];
    [contentScrollView addSubview:lblAddress];
    [lblAddress release];
    
    UIButton *btnAddress = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAddress setFrame:CGRectMake(10, y, 300, lblAddress.frame.size.height)];
    [btnAddress addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:btnAddress];
    
    y += lblAddress.frame.size.height + 20;
    
    [infoBack setFrame:CGRectMake(0, infoBack.frame.origin.y, SCREEN_WIDTH, y - infoBack.frame.origin.y)];
    
    y += 10;
    y = infoBack.frame.origin.y + infoBack.frame.size.height + 20;
    
    if ([placeOfferArray count]) {
        y -= 15;
        
        UILabel *lblOfferTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 20)];
        [lblOfferTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
        [lblOfferTitle setBackgroundColor:[UIColor clearColor]];
        [lblOfferTitle setTextColor:[UIColor darkGrayColor]];
        [lblOfferTitle setText:@"OFFERS FOR COMMUNITY MEMBERS ONLY"];
        [contentScrollView addSubview:lblOfferTitle];
        [lblOfferTitle release];
        
        y += 25;
        
        for (int k = 0; k < [placeOfferArray count]; k++) {
            NSDictionary * offerDict = [placeOfferArray objectAtIndex:k];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[UIImage imageNamed:@"NormalButton.png"] forState:UIControlStateNormal];
            [button setFrame:CGRectMake(0, y, 320, 46.0)];
            if ([[offerDict objectForKey:@"type"] isEqualToString:@"lesson"]) {
                [button addTarget:self action:@selector(lessonOffer:) forControlEvents:UIControlEventTouchUpInside];
            } else if ([[offerDict objectForKey:@"type"] isEqualToString:@"discount"]) {
                [button addTarget:self action:@selector(discountOffer:) forControlEvents:UIControlEventTouchUpInside];
            }
            [button setTag:k];
            [contentScrollView addSubview: button];
            
            UIImageView *imgIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfferIcon.png"]];
            [imgIcon setFrame:CGRectMake(20, y + 13, 22, 22)];
            [contentScrollView addSubview:imgIcon];
            [imgIcon release];
            
            UILabel *lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(50, y + 6, 250, 34)];
            [lblDetail setNumberOfLines:2];
            [lblDetail setBackgroundColor:[UIColor clearColor]];
            [lblDetail setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.f]];
            [lblDetail setTextColor:[UIColor darkGrayColor]];
            [lblDetail setText:[offerDict objectForKey:@"profile_text"]];
            [contentScrollView addSubview:lblDetail];
            [lblDetail release];
            
            y += 51;
        }
        y += 15;
    }

    if (placeUserArray == nil) {
        placeUserArray = [[NSMutableArray alloc] init];
    }
    
    [placeUserArray removeAllObjects];
    [placeUserArray addObjectsFromArray:[response objectForKey:@"users"]];
    
    tblPlaceUser = [[UITableView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
    if ([placeUserArray count]) {
        
        lblSuggestTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, y , 280, 32)];
        [lblSuggestTitle setTextColor:[UIColor darkGrayColor]];
        [lblSuggestTitle setNumberOfLines:1];
        [lblSuggestTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
        [lblSuggestTitle setBackgroundColor:[UIColor clearColor]];
        [lblSuggestTitle setText:@"PEOPLE IN THIS COMMUNITY"];
        [contentScrollView addSubview:lblSuggestTitle];
        [lblSuggestTitle sizeToFit];
        float font = 10.f;
        while (lblSuggestTitle.frame.size.width > 280) {
            font -= .5f;
            [lblSuggestTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:font]];
            [lblSuggestTitle sizeToFit];
        }
        //    [lblSuggestTitle setFrame:CGRectMake(20, y, 280, 32)];
        [lblSuggestTitle release];
        
        y += lblSuggestTitle.frame.size.height + 5;
        
        [tblPlaceUser setFrame:CGRectMake(0, y, SCREEN_WIDTH, 48 * [placeUserArray count] - 1)];
    }
    
    yPos = y;
    
    [tblPlaceUser setDataSource:self];
    [tblPlaceUser setDelegate:self];
    [tblPlaceUser setScrollEnabled:NO];
    [contentScrollView addSubview:tblPlaceUser];
    
    y += tblPlaceUser.frame.size.height;
    
    
    [lblHit setHidden:NO];
    [lblHit setFrame:CGRectMake(31.f, y + 10, 258, 36)];
//
    [contentScrollView setContentSize:CGSizeMake(320, yPos + tblPlaceUser.frame.size.height + 80)];
    
    [tblPlaceUser reloadData];
}

- (void)backMenu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [contentScrollView release];
    contentScrollView = nil;
    [lblHit release];
    lblHit = nil;
    [super viewDidUnload];
}

#pragma mark - Methods

- (void)changeLabelFont:(UILabel *)lblTemp _fontName:(NSString *)fontName _fontSize:(float)nFontSize _width:(float)width {
    while (lblTemp.frame.size.width > width) {
        [lblTemp setFont:[UIFont fontWithName:fontName size:nFontSize]];
        [lblTemp sizeToFit];
        nFontSize -= 0.5f;
    }
}
- (void)changeButtonFont:(UIButton *)lblTemp _fontName:(NSString *)fontName _fontSize:(float)nFontSize _width:(float)width {
    while (lblTemp.titleLabel.frame.size.width > width) {
        [lblTemp.titleLabel setFont:[UIFont fontWithName:fontName size:nFontSize]];
        [lblTemp.titleLabel sizeToFit];
        nFontSize -= 0.5f;
    }
}

- (void)favoritePlace:(id)sender {
    NSString *interest = [[contentDictionary objectForKey:@"interest"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    NSMutableDictionary *kitePlace = [[NSUserDefaults standardUserDefaults] objectForKey:@"KITE_PLACE"];
    NSArray *array = ([strID rangeOfString:@"findy-"].location != NSNotFound) ? [NSArray arrayWithObjects:[DataManager sharedManager].strEmail, [[kitePlace objectForKey:@"value"] objectForKey:@"id"], strTitle, [kitePlace objectForKey:@"interest"], [[kitePlace objectForKey:@"value"] objectForKey:@"image_url"], nil] :[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, [[contentDictionary objectForKey:@"value"] objectForKey:@"id"], strTitle, interest, [[contentDictionary objectForKey:@"value"] objectForKey:@"image_url"], nil];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:array forKeys:[NSArray arrayWithObjects:@"email", @"yelp_id", @"name", @"interest", @"pic_small", nil]];
    if ([favoriteButton isSelected]) {
        for (NSDictionary *dict in [DataManager sharedManager].favoritePlaceArray) {
            if ([[dict objectForKey:@"yelp_id"] isEqualToString:[paramDict objectForKey:@"yelp_id"]]) {
                [[DataManager sharedManager].favoritePlaceArray removeObject:dict];
                break;
            }
        }
        
        [[FindyAPI instance] removeFavoritePlace:self withSelector:@selector(selectFavorite:) andOptions:paramDict];
        [favoriteButton setSelected:NO];
        
        for (NSDictionary *dict in placeUserArray) {
            if ([[dict objectForKey:@"email"] isEqualToString:[paramDict objectForKey:@"email"]]) {
                [placeUserArray removeObject:dict];
                
                if ([placeUserArray count]) {
                    [lblSuggestTitle setHidden:NO];
                    [tblPlaceUser setHidden:NO];
                    
                    [tblPlaceUser setFrame:CGRectMake(0, tblPlaceUser.frame.origin.y, SCREEN_WIDTH, 48 * [placeUserArray count] - 1)];
                    [tblPlaceUser setDelegate:self];
                    [tblPlaceUser setDataSource:self];
                    
                    float y = yPos;
                    y += tblPlaceUser.frame.size.height;
                    
                    [lblHit setHidden:NO];
                    [lblHit setFrame:CGRectMake(31.f, tblPlaceUser.frame.origin.y + tblPlaceUser.frame.size.height + 20, 258, 36)];
                    
                    [contentScrollView setContentSize:CGSizeMake(320, yPos + tblPlaceUser.frame.size.height + 80)];
                } else {
                    [lblSuggestTitle setHidden:YES];
                    [tblPlaceUser setHidden:YES];
                }
                
                break;
            }
        }
        if ([placeUserArray count] == 0) {
            [tblPlaceUser setFrame:CGRectMake(0, tblPlaceUser.frame.origin.y, SCREEN_WIDTH, 0)];
            [lblHit setHidden:NO];
            [lblHit setFrame:CGRectMake(31.f, yPos, 258, 36)];
            
            [contentScrollView setContentSize:CGSizeMake(320, yPos + tblPlaceUser.frame.size.height + 80)];
        }
    } else {
        [lblSuggestTitle setHidden:NO];
        [tblPlaceUser setHidden:NO];
        
        [[DataManager sharedManager].favoritePlaceArray addObject:paramDict];
        [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"favorite_place_count"] + 1 forKey:@"favorite_place_count"];
        
        int favCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"favorite_place_count"];
        
        if ((([[[DataManager sharedManager] favoritePlaceArray] count] == 1) && ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_FIRST_FAVORITE_PLACE"])) || (favCount == 5)){
//            [[Kiip sharedInstance] saveMoment:@"Joining a Community :)" withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
//                if (error) {
//                    NSLog(@"something's wrong");
//                    // handle with an Alert dialog.
//                }
//                if (poptart) {
//                    [poptart show];
//                }
//                if (!poptart) {
//                    // handle logic when there is no reward to give.
//                }
//            }];
        }
        
        
        [[FindyAPI instance] addFavoritePlace:self withSelector:@selector(selectFavorite:) andOptions:paramDict];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, [DataManager sharedManager].strFirstName, [DataManager sharedManager].strPicSmall, nil] forKeys:[NSArray arrayWithObjects:@"email", @"first", @"pic_small", nil]];
        float y = yPos;
        
        if (placeUserArray == nil) {
            
            lblSuggestTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, y , 280, 32)];
            [lblSuggestTitle setTextColor:[UIColor darkGrayColor]];
            [lblSuggestTitle setNumberOfLines:1];
            [lblSuggestTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
            [lblSuggestTitle setBackgroundColor:[UIColor clearColor]];
            [lblSuggestTitle setText:@"PEOPLE IN THIS COMMUNITY"];
            [contentScrollView addSubview:lblSuggestTitle];
            [lblSuggestTitle sizeToFit];
            float font = 10.f;
            while (lblSuggestTitle.frame.size.width > 280) {
                font -= .5f;
                [lblSuggestTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:font]];
                [lblSuggestTitle sizeToFit];
            }
            //    [lblSuggestTitle setFrame:CGRectMake(20, y, 280, 32)];
            [lblSuggestTitle release];
            
            y += lblSuggestTitle.frame.size.height + 5;
            
            // Table View
            tblPlaceUser = [[UITableView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
            [tblPlaceUser setDataSource:self];
            [tblPlaceUser setDelegate:self];
            [contentScrollView addSubview:tblPlaceUser];
            
            // Reload Data
            placeUserArray = [[NSMutableArray alloc] init];
        }
        
        [placeUserArray addObject:dict];
        [tblPlaceUser setFrame:CGRectMake(0, tblPlaceUser.frame.origin.y, SCREEN_WIDTH, 48 * [placeUserArray count] - 1)];
        [tblPlaceUser setDelegate:self];
        [tblPlaceUser setDataSource:self];
        
        y += tblPlaceUser.frame.size.height;
        
        [lblHit setHidden:NO];
        [lblHit setFrame:CGRectMake(31.f, tblPlaceUser.frame.origin.y + tblPlaceUser.frame.size.height + 20, 258, 36)];
        y += 36;
        
        [contentScrollView setContentSize:CGSizeMake(320, yPos + tblPlaceUser.frame.size.height + 80)];

        
        
        [favoriteButton setSelected:YES];
        
        [tblPlaceUser reloadData];
    }
    
    [contentScrollView setContentSize:CGSizeMake(320, yPos + tblPlaceUser.frame.size.height + 80)];
}

- (void)selectFavorite:(NSDictionary *)response {
    
}

- (void)suggestPlace:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    SuggestPlaceViewController *suggestController = (SuggestPlaceViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SuggestPlaceViewController"];
    suggestController.interest = [contentDictionary objectForKey:@"interest"];
    [self.navigationController pushViewController:suggestController animated:YES];
}

- (void)showData {
//    NSLog(@"%@", contentDictionary);
    titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320.f, 150.f)];
//    UIImage *pImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[contentDictionary objectForKey:@"value"] objectForKey:@"image_url"]]]];
//    if (pImage == nil) {
//        pImage = [UIImage imageNamed:@"EmptyPlaceImage.png"];
//    }
//    [titleImageView setImage:pImage];
    [contentScrollView addSubview:titleImageView];
    [titleImageView release];
    
    favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteButton setFrame:CGRectMake(138.f, 150.f, 176.f, 35.f)];
    [favoriteButton setImage:[UIImage imageNamed:@"JoinCommunityButton.png"] forState:UIControlStateNormal];
    [favoriteButton setImage:[UIImage imageNamed:@"JoinCommunityDisable.png"] forState:UIControlStateSelected];
    [favoriteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [favoriteButton addTarget:self action:@selector(favoritePlace:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:favoriteButton];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView startAnimating];
    [contentScrollView addSubview:indicatorView];

    for (NSDictionary *dict in [DataManager sharedManager].favoritePlaceArray) {
        if ([[dict objectForKey:@"yelp_id"] isEqualToString:[[contentDictionary objectForKey:@"value"] objectForKey:@"id"]]) {
            [favoriteButton setSelected:YES];
        }
    }
    
    float y = 194.f;
    float infoHeight = 100;
    
    UIImageView *infoBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, infoHeight)];
    [infoBack setBackgroundColor:[UIColor whiteColor]];
    [contentScrollView addSubview:infoBack];
    [infoBack release];
    
    y += 5.f;
    UILabel *lblPhoneTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 300, 15)];
    [lblPhoneTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblPhoneTitle setBackgroundColor:[UIColor clearColor]];
    [lblPhoneTitle setTextColor:[UIColor darkGrayColor]];
    [lblPhoneTitle setText:@"PHONE"];
    [contentScrollView addSubview:lblPhoneTitle];
    [lblPhoneTitle release];
    
    y += lblPhoneTitle.frame.size.height;

    UIButton *btnPhone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPhone setFrame:CGRectMake(15, y, 300, 30)];
    [btnPhone setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnPhone.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [btnPhone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    NSString *strPhone = [NSString stringWithFormat:@"%@",[[contentDictionary objectForKey:@"value"] objectForKey:@"display_phone"]];
    if (([strPhone isEqualToString:@"(null)"]) || ([strPhone isEqualToString:@""])) {
        strPhone = @"";
    } else {
        [btnPhone addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
    }
    [btnPhone setTitle:strPhone forState:UIControlStateNormal];
    
    
    [contentScrollView addSubview:btnPhone];
    
    y += btnPhone.frame.size.height;

    UIImageView *phoneLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, y, 305, 1)];
    [phoneLine setImage:[UIImage imageNamed:@"PlaceProfileLine.png"]];
    [contentScrollView addSubview:phoneLine];
    
    y += phoneLine.frame.size.height + 5;
    
    UILabel *lblURLTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 300, 15)];
    [lblURLTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblURLTitle setBackgroundColor:[UIColor clearColor]];
    [lblURLTitle setTextColor:[UIColor darkGrayColor]];
    [lblURLTitle setText:@"HOME PAGE"];
    [contentScrollView addSubview:lblURLTitle];
    [lblURLTitle release];
    
    y += lblURLTitle.frame.size.height;
    
    btnUrl = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnUrl setFrame:CGRectMake(15, y, 300, 30)];
    [btnUrl setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnUrl.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [btnUrl setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnUrl addTarget:self action:@selector(gotoUrl:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:btnUrl];
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.yelp.com/biz/%@", [[contentDictionary objectForKey:@"value"] objectForKey:@"id"]];

    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url
                                                                   cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                               timeoutInterval:60];
    [urlRequest setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                   NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSString *tmpStr = [NSString stringWithFormat:@"%@", dataStr];
                                   NSRange range = [tmpStr rangeOfString:@"<meta property=\"place:location:longitude\" content=\""];
                                   NSString *longitude = nil;
                                   if (range.location != NSNotFound) {
                                       longitude = [tmpStr substringFromIndex:range.location + 51];
                                       range = [longitude rangeOfString:@"\">"];
                                       longitude = [longitude substringToIndex:range.location];
                                       fLng = [longitude floatValue];
                                   }
                                   
                                   range = [tmpStr rangeOfString:@"<meta property=\"place:location:latitude\" content=\""];
                                   NSString *latitude = nil;
                                   if (range.location != NSNotFound) {
                                       latitude = [tmpStr substringFromIndex:range.location + 50];
                                       range = [latitude rangeOfString:@"\">"];
                                       latitude = [latitude substringToIndex:range.location];
                                       fLat = [latitude floatValue];
                                   }
                                   
                                   NSString *imgUrl = nil;

                                   range = [dataStr rangeOfString:@"Business website"];
                                   if (range.location != NSNotFound)
                                   {
                                       imgUrl=[dataStr substringFromIndex:range.location];

                                       range = [imgUrl rangeOfString:@"biz_redir?url="];
                                       imgUrl=[imgUrl substringFromIndex:range.location + 14];
                                       range = [imgUrl rangeOfString:@"&amp;src_bizid="];
                                       imgUrl=[imgUrl substringToIndex:range.location];
                                       
                                       imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
                                       imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
                                       imgUrl = [imgUrl stringByReplacingOccurrencesOfString:@"%3D" withString:@"="];
                                       imgUrl = [imgUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                       
                                       NSArray *comp = [imgUrl componentsSeparatedByString:@"http://"];
                                       
                                       if ([comp count] > 2) {
                                           imgUrl = [NSString stringWithFormat:@"https://%@", [comp objectAtIndex:2]];
                                       }
                                       
                                       NSArray *arrUrl = [imgUrl componentsSeparatedByString:@"/"];
                                       homePageURL = [[NSString alloc] initWithString:imgUrl];
                                       
                                       [btnUrl setTitle:[arrUrl objectAtIndex:2] forState:UIControlStateNormal];
//                                       [self changeButtonFont:btnUrl _fontName:@"HelveticaNeue" _fontSize:16.f _width:290.f];
                                   }
                               } else {
                                   
                               }
                               
                           }];
    
    y += btnUrl.frame.size.height;
    UIImageView *urlLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, y, 305, 1)];
    [urlLine setImage:[UIImage imageNamed:@"PlaceProfileLine.png"]];
    [contentScrollView addSubview:urlLine];
    
    // More Info
    y += urlLine.frame.size.height + 5;
    UILabel *lblMoreInfo = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 100, 30)];
    [lblMoreInfo setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblMoreInfo setBackgroundColor:[UIColor clearColor]];
    [lblMoreInfo setTextColor:[UIColor darkGrayColor]];
    [lblMoreInfo setText:@"MORE INFO ON"];
    [contentScrollView addSubview:lblMoreInfo];
    [lblMoreInfo release];
    
    UIButton *btnYelp = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnYelp setFrame:CGRectMake(150, y, 57, 28)];
    [btnYelp setImage:[UIImage imageNamed:@"YelpLogo.png"] forState:UIControlStateNormal];
    [btnYelp addTarget:self action:@selector(gotoYelp:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:btnYelp];
    
    y += 35;
    UIImageView *addressLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, y, 305, 1)];
    [addressLine setImage:[UIImage imageNamed:@"PlaceProfileLine.png"]];
    [contentScrollView addSubview:addressLine];
    
    // Address
    y += addressLine.frame.size.height + 5;
    
    UILabel *lblAddressTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, y, 300, 15)];
    [lblAddressTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblAddressTitle setBackgroundColor:[UIColor clearColor]];
    [lblAddressTitle setTextColor:[UIColor darkGrayColor]];
    [lblAddressTitle setText:@"ADDRESS"];
    [contentScrollView addSubview:lblAddressTitle];
    [lblAddressTitle release];
   
    
    if (distance == 0) {
//        NSLog(@"%@", contentDictionary);
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.geoCoder geocodeAddressString:[[[[contentDictionary objectForKey:@"value"] objectForKey:@"location"] objectForKey:@"display_address"] componentsJoinedByString:@","] completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:[DataManager sharedManager].latitude
                                                                 longitude:[DataManager sharedManager].longitude];
            CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude
                                                                    longitude:placemark.location.coordinate.longitude];
            
            distance = [targetLocation distanceFromLocation:curLocation];
            
            CGSize size = [[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
            
            UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(310.f - size.width, y + 1, size.width, size.height)];
            [lblMile setBackgroundColor:[UIColor clearColor]];
            [lblMile setText:[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34]];
            [lblMile setBackgroundColor:[UIColor clearColor]];
            [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
            [lblMile setTextColor:[UIColor darkGrayColor]];
            [contentScrollView addSubview:lblMile];
            [lblMile release];
            
            UIImageView *imgHouse = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LocationIcon.png"]];
            [imgHouse setFrame:CGRectMake(291.f - size.width, y + 2.5, 14, 15)];
            [contentScrollView addSubview:imgHouse];
        }];
    } else {
        CGSize size = [[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
        
        UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(310.f - size.width, y + 1, size.width, size.height)];
        [lblMile setBackgroundColor:[UIColor clearColor]];
        [lblMile setText:[NSString stringWithFormat:@"%0.1f mi", distance / 1609.34]];
        [lblMile setBackgroundColor:[UIColor clearColor]];
        [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:SHOUTOUT_FONT_SIZE]];
        [lblMile setTextColor:[UIColor darkGrayColor]];
        [contentScrollView addSubview:lblMile];
        [lblMile release];
        
        UIImageView *imgHouse = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LocationIcon.png"]];
        [imgHouse setFrame:CGRectMake(291.f - size.width, y + 2.5, 14, 15)];
        [contentScrollView addSubview:imgHouse];
    }
    
    y += lblAddressTitle.frame.size.height;
    
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, y + 5, 290, 46)];
    [lblAddress setBackgroundColor:[UIColor clearColor]];
    [lblAddress setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    NSArray *addressArray = [[[contentDictionary objectForKey:@"value"] objectForKey:@"location"] objectForKey:@"display_address"];
    [lblAddress setNumberOfLines:[addressArray count]];
    NSString *addressText = [addressArray objectAtIndex:0];
    for (int i = 1; i < [addressArray count]; i++) {
        addressText = [NSString stringWithFormat:@"%@\n%@", addressText, [addressArray objectAtIndex:i]];
    }
    
    [lblAddress setText:addressText];
    [lblAddress sizeToFit];
    [contentScrollView addSubview:lblAddress];
    [lblAddress release];
    
    UIButton *btnAddress = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAddress setFrame:CGRectMake(10, y, 300, lblAddress.frame.size.height)];
    [btnAddress addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:btnAddress];
    
    y += lblAddress.frame.size.height + 20;
    
    [infoBack setFrame:CGRectMake(0, infoBack.frame.origin.y, SCREEN_WIDTH, y - infoBack.frame.origin.y)];
    
    y += 10;
    y = infoBack.frame.origin.y + infoBack.frame.size.height + 20;
    
    if ([placeOfferArray count]) {
        y -= 15;
        
        UILabel *lblOfferTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 20)];
        [lblOfferTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
        [lblOfferTitle setBackgroundColor:[UIColor clearColor]];
        [lblOfferTitle setTextColor:[UIColor darkGrayColor]];
        [lblOfferTitle setText:@"OFFERS FOR COMMUNITY MEMBERS ONLY"];
        [contentScrollView addSubview:lblOfferTitle];
        [lblOfferTitle release];
        
        y += 25;
        
        for (int k = 0; k < [placeOfferArray count]; k++) {
            NSDictionary * offerDict = [placeOfferArray objectAtIndex:k];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundImage:[UIImage imageNamed:@"NormalButton.png"] forState:UIControlStateNormal];
            [button setFrame:CGRectMake(0, y, 320, 46.0)];
            if ([[offerDict objectForKey:@"type"] isEqualToString:@"lesson"]) {
                [button addTarget:self action:@selector(lessonOffer:) forControlEvents:UIControlEventTouchUpInside];
            } else if ([[offerDict objectForKey:@"type"] isEqualToString:@"discount"]) {
                [button addTarget:self action:@selector(discountOffer:) forControlEvents:UIControlEventTouchUpInside];
            }
            [button setTag:k];
            [contentScrollView addSubview: button];
            
            UIImageView *imgIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"OfferIcon.png"]];
            [imgIcon setFrame:CGRectMake(20, y + 13, 22, 22)];
            [contentScrollView addSubview:imgIcon];
            [imgIcon release];
            
            UILabel *lblDetail = [[UILabel alloc] initWithFrame:CGRectMake(50, y + 6, 250, 34)];
            [lblDetail setNumberOfLines:2];
            [lblDetail setBackgroundColor:[UIColor clearColor]];
            [lblDetail setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.f]];
            [lblDetail setTextColor:[UIColor darkGrayColor]];
            [lblDetail setText:[offerDict objectForKey:@"profile_text"]];
            [contentScrollView addSubview:lblDetail];
            [lblDetail release];
            
            y += 51;
        }
        y += 15;
    }
    
    
    [lblHit setHidden:NO];
    [lblHit setFrame:CGRectMake(31.f, y, 258, 36)];
    
//    UIImageView *suggestBack = [[UIImageView alloc] init];
//    [suggestBack setBackgroundColor:[UIColor whiteColor]];
//    [suggestBack setFrame:CGRectMake(0, y, 320, 64)];
//    [contentScrollView addSubview:suggestBack];
//    [suggestBack release];
//    
//    NSString *interest = [contentDictionary objectForKey:@"interest"];
//    if (IsNSStringValid([contentDictionary objectForKey:@"interest"])) {
//        interest = [[contentDictionary objectForKey:@"interest"] uppercaseString];
//    }
    
    yPos = y;
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[contentDictionary objectForKey:@"value"] objectForKey:@"id"],@"yelp_id", nil];
    [[FindyAPI instance] placeUsers:self withSelector:@selector(placeUserResult:) andOptions:paramDict];
    
    /*
    UILabel *lblSuggestTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, y , 280, 32)];
    [lblSuggestTitle setTextColor:[UIColor darkGrayColor]];
    [lblSuggestTitle setNumberOfLines:2];
    [lblSuggestTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblSuggestTitle setText:[NSString stringWithFormat:@"KNOW ANOTHER PLACE FOR %@", interest]];
    [contentScrollView addSubview:lblSuggestTitle];
    [lblSuggestTitle sizeToFit];
    float font = 10.f;
    while (lblSuggestTitle.frame.size.width > 280) {
        font -= .5f;
        [lblSuggestTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:font]];
        [lblSuggestTitle sizeToFit];
    }
    [lblSuggestTitle setFrame:CGRectMake(20, y, 280, 32)];
    [lblSuggestTitle release];
    
    UILabel *lblSuggest = [[UILabel alloc] initWithFrame:CGRectMake(20, y + 30, 100, 28)];
    [lblSuggest setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [lblSuggest setTextColor:UIColorFromRGB(0xFF4A00)];
    [lblSuggest setText:@"Suggest it!"];
    [contentScrollView addSubview:lblSuggest];
    [lblSuggest release];
    
    UIButton *btnSuggest = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSuggest setFrame:CGRectMake(20, y, 280, 64)];
    [btnSuggest addTarget:self action:@selector(suggestPlace:) forControlEvents:UIControlEventTouchUpInside];
    [contentScrollView addSubview:btnSuggest];
    
    y += 10;
     */
    
//    [self.geoCoder geocodeAddressString:@"ABC" completionHandler:^(NSArray *placemarks, NSError *error) {
//        
//    }];
    
/*    // Hours Of Operation
    y += bodyImageView.frame.size.height + 20;
    
    UILabel *lblHoursTitle = [[UILabel alloc] initWithFrame:CGRectMake(13, y, 300, 15)];
    [lblHoursTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
    [lblHoursTitle setBackgroundColor:[UIColor clearColor]];
    [lblHoursTitle setTextColor:[UIColor darkGrayColor]];
    [lblHoursTitle setText:@"HOURS OF OPERATION"];
    [contentScrollView addSubview:lblHoursTitle];
    [lblHoursTitle release];
    
    y += 15 + 5;
        
    UIImageView *hrsTopImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopPadding.png"]];
    [hrsTopImageView setFrame:CGRectMake(10, y, 300, 5)];
    [hrsTopImageView setContentMode:UIViewContentModeScaleToFill];
    [contentScrollView addSubview:hrsTopImageView];
    [hrsTopImageView release];
    
    // Calculate Content Height
    UIImageView *hrsbodyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ContentPadding.png"]];
    [hrsbodyImageView setFrame:CGRectMake(10, y + 5, 300, 46)];
    [hrsbodyImageView setContentMode:UIViewContentModeScaleToFill];
    [contentScrollView addSubview:hrsbodyImageView];
 
//    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, y + 5, 290, 46)];
//    [lblAddress setBackgroundColor:[UIColor clearColor]];
//    [lblAddress setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
//    NSArray *addressArray = [[[contentDictionary objectForKey:@"value"] objectForKey:@"location"] objectForKey:@"display_address"];
//    [lblAddress setNumberOfLines:[addressArray count]];
//    NSString *addressText = [addressArray objectAtIndex:0];
//    for (int i = 1; i < [addressArray count]; i++) {
//        addressText = [NSString stringWithFormat:@"%@\n%@", addressText, [addressArray objectAtIndex:i]];
//    }
//    
//    [lblAddress setText:addressText];
//    [lblAddress sizeToFit];
//    [contentScrollView addSubview:lblAddress];
//    [lblAddress release];
//    
//    [bodyImageView setFrame:CGRectMake(10, bodyImageView.frame.origin.y, 300, lblAddress.frame.size.height)];
//    
    // Add Footer Image
    UIImageView *hrsFooterImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
    [hrsFooterImage setFrame:CGRectMake(10, hrsbodyImageView.frame.origin.y + 46, 300, 5)];
    [contentScrollView addSubview:hrsFooterImage];
    [hrsFooterImage release];
    
    [contentScrollView setContentSize:CGSizeMake(320, hrsFooterImage.frame.origin.y + 15)];
    
    */
    
    [contentScrollView setContentSize:CGSizeMake(320, yPos + tblPlaceUser.frame.size.height + 80)];

    urlString = [NSString stringWithFormat:@"http://www.yelp.com/biz_photos/%@", [[contentDictionary objectForKey:@"value"] objectForKey:@"id"]];
    url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                                            timeoutInterval:60];
    [request setHTTPMethod:@"GET"];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data != nil && [(NSHTTPURLResponse*)response statusCode] == 200) {
                                   NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSString *imgUrl = nil;
                                   NSRange range = [dataStr rangeOfString:@"selected-photo-main"];
                                   if (range.location != NSNotFound)
                                   {
                                       imgUrl=[dataStr substringFromIndex:range.location];
                                       range = [imgUrl rangeOfString:@"<img src=\""];
                                       imgUrl=[imgUrl substringFromIndex:range.location + 10];
                                       range = [imgUrl rangeOfString:@"\""];
                                       imgUrl=[imgUrl substringToIndex:range.location];
                                       imgUrl = [NSString stringWithFormat:@"http:%@", imgUrl];
                                       
                                       UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]]];
                                       [titleImageView setImage:[[ImageResizingUtility instance] imageByCropping:image _targetSize:CGSizeMake(320, 150)]];
                                       
                                       [indicatorView stopAnimating];
                                   }
                               } else {
                                   
                               }
                               
                           }];

}

- (void)lessonOffer:(id)sender {
    UIButton *button = (UIButton *)sender;
//    NSLog(@"%@", [placeOfferArray objectAtIndex:button.tag]);
    if ([favoriteButton isSelected]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        LessonOfferViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LessonOfferViewController"];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[placeOfferArray objectAtIndex:button.tag]];
        [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:strID forKey:@"yelp_id"]];
        viewController.contentDict = [dict retain];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Offers are available for community members only! Please hit the Join Community button to become a community member." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}

- (void)discountOffer:(id)sender {
    UIButton *button = (UIButton *)sender;
//    NSLog(@"%@", [placeOfferArray objectAtIndex:button.tag]);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    DiscountOfferViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DiscountOfferViewController"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[placeOfferArray objectAtIndex:button.tag]];
    [dict addEntriesFromDictionary:[NSDictionary dictionaryWithObject:strID forKey:@"yelp_id"]];
    viewController.contentDict = [dict retain];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)placeUserResult:(NSArray *)response {
    [lblHit setHidden:NO];
    if ([response count]) {
        float y = yPos;
        
        lblSuggestTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, y , 280, 32)];
        [lblSuggestTitle setTextColor:[UIColor darkGrayColor]];
        [lblSuggestTitle setNumberOfLines:1];
        [lblSuggestTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
        [lblSuggestTitle setBackgroundColor:[UIColor clearColor]];
        [lblSuggestTitle setText:@"PEOPLE IN THIS COMMUNITY"];
        [contentScrollView addSubview:lblSuggestTitle];
        [lblSuggestTitle sizeToFit];
        float font = 10.f;
        while (lblSuggestTitle.frame.size.width > 280) {
            font -= .5f;
            [lblSuggestTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:font]];
            [lblSuggestTitle sizeToFit];
        }
        //    [lblSuggestTitle setFrame:CGRectMake(20, y, 280, 32)];
        [lblSuggestTitle release];
        
        y += lblSuggestTitle.frame.size.height + 5;
        
        yPos = y;
        
        // Table View
        tblPlaceUser = [[UITableView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
        [tblPlaceUser setDataSource:self];
        [tblPlaceUser setDelegate:self];
        [tblPlaceUser setScrollEnabled:NO];
//        [tblPlaceUser setUserInteractionEnabled:NO];
        [contentScrollView addSubview:tblPlaceUser];
        
        // Reload Data
        if (placeUserArray == nil) {
            placeUserArray = [[NSMutableArray alloc] init];
        }
        
        [placeUserArray removeAllObjects];
        [placeUserArray addObjectsFromArray:response];
        [tblPlaceUser setFrame:CGRectMake(0, tblPlaceUser.frame.origin.y, SCREEN_WIDTH, 48 * [placeUserArray count] - 1)];
        [tblPlaceUser setDelegate:self];
        [tblPlaceUser setDataSource:self];
        
        y += tblPlaceUser.frame.size.height;
        
//        yPos = y;
        [lblHit setHidden:NO];
        [lblHit setFrame:CGRectMake(31.f, tblPlaceUser.frame.origin.y + tblPlaceUser.frame.size.height + 20, 258, 36)];
//        yPos += 36;
        
        [contentScrollView setContentSize:CGSizeMake(320, yPos + tblPlaceUser.frame.size.height + 80)];
        
        [tblPlaceUser reloadData];
    }
    
    
    
}


- (void)callPhone:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call" message:@"Do you want to call?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

- (void)gotoYelp:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = [[contentDictionary objectForKey:@"value"] objectForKey:@"url"];
    webBrowser.viewTitle = strTitle;
    webBrowser.strType = @"";
    [self.navigationController pushViewController:webBrowser animated:YES];
}

- (void)gotoInfo:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = [NSString stringWithFormat:@"%@", infoUrl];
    webBrowser.viewTitle = strTitle;
    webBrowser.strType = @"";
    [self.navigationController pushViewController:webBrowser animated:YES];
}

- (void)gotoWind:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = [NSString stringWithFormat:@"%@", windUrl];
    webBrowser.viewTitle = strTitle;
    webBrowser.strType = @"";
    [self.navigationController pushViewController:webBrowser animated:YES];
}

- (void)gotoUrl:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    webBrowser.urlString = [NSString stringWithFormat:@"%@", homePageURL];
    webBrowser.viewTitle = strTitle;
    webBrowser.strType = @"";
    [self.navigationController pushViewController:webBrowser animated:YES];
}

- (void)showMap:(id)sender {
//    place:location:latitude
//    NSLog(@"%@", contentDictionary);
    NSDictionary *kitePlace = [[NSUserDefaults standardUserDefaults] objectForKey:@"KITE_PLACE"];
    NSString *kID = [[kitePlace objectForKey:@"value"] objectForKey:@"id"];
    NSString* addressText = ([strID isEqualToString:kID]) ? [[kitePlace objectForKey:@"value"] objectForKey:@"address"] : [NSString stringWithFormat:@"%@@%f,%f", [[contentDictionary objectForKey:@"value"] objectForKey:@"name"], fLat, fLng];
//    if ([[[contentDictionary objectForKey:@"value"] objectForKey:@"id"] isEqualToString:@"lands-end-trail-san-francisco"]) {
//        addressText = ([strID isEqualToString:@"findy-3rd-ave-kiteboarding-spot"]) ? @"2401 E 3rd Ave. Foster City, CA, 940404, United States" : [NSString stringWithFormat:@"%@,%@", [[contentDictionary objectForKey:@"value"] objectForKey:@"name"], [[[contentDictionary objectForKey:@"value"] objectForKey:@"location"] objectForKey:@"city"]];
//    }


//    addressText = [addressText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
//    MapBrowserViewController *mapBrowser = [storyboard instantiateViewControllerWithIdentifier:@"MapBrowserViewController"];
//    mapBrowser.placeAddress = addressText;
//    mapBrowser.strTitle = [NSString stringWithFormat:@"%@ - %@", strTitle, addressText];
//    [self.navigationController pushViewController:mapBrowser animated:YES];
    
    WebBrowserViewController *webBrowser = [storyboard instantiateViewControllerWithIdentifier:@"WebBrowserViewController"];
    NSString* urlText = [NSString stringWithFormat:@"https://maps.google.com/maps?q=%@", addressText];
    webBrowser.urlString = urlText;
    webBrowser.strType = @"";
    webBrowser.viewTitle = strTitle;
    [self.navigationController pushViewController:webBrowser animated:YES];
////    NSString* urlText = [NSString stringWithFormat:@"comgooglemaps://?daddr=%@", [addressText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlText]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[[contentDictionary objectForKey:@"value"] objectForKey:@"display_phone"]]];
        [[UIApplication sharedApplication] openURL:URL];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [placeUserArray count];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }

    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, 180, 48.f)];
    [lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.f]];
    [lblName setText:[[placeUserArray objectAtIndex:indexPath.row] objectForKey:@"first"]];
    [cell addSubview:lblName];
    [lblName release];
    
    AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(5.5, 5.5, 37, 37)];
    pImageView.contentMode = UIViewContentModeScaleAspectFill;
    pImageView.clipsToBounds = YES;
    pImageView.bCircle = 1;
    NSURL *imageURL = [NSURL URLWithString:[[placeUserArray objectAtIndex:indexPath.row] objectForKey:@"pic_small"]];
    pImageView.imageURL = imageURL;
    [cell addSubview:pImageView];
    [pImageView release];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                         bundle: nil];
    
    ProfileViewController *profileController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    [profileController setFlag:FALSE];

    profileController.email = [[placeUserArray objectAtIndex:indexPath.row] objectForKey:@"email"];
    if ([profileController.email isEqualToString:[DataManager sharedManager].strEmail]) {
        [profileController setBMine:TRUE];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PLACE_PROFILE"];
    }
    
    [self.navigationController pushViewController:profileController animated:YES];
}

@end

