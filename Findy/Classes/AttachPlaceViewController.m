//
//  AttachPlaceViewController.m
//  Findy
//
//  Created by Alexander Wiegand on 3/24/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import "AttachPlaceViewController.h"

@interface AttachPlaceViewController ()

@end

@implementation AttachPlaceViewController

@synthesize kitePlace;

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
    
    kitePlace = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"KITE_PLACE"]];
    
    BOOL bShowed = FALSE;
    for (NSString *dict in [DataManager sharedManager].interestArray) {
        if ([dict isEqualToString:@"Kiteboarding"]) {
            bShowed = TRUE;
            break;
        } else {
            bShowed = FALSE;
        }
    }
    
    placesArray = [[NSMutableArray alloc] initWithArray:[DataManager sharedManager].placesArray];

    [placesArray sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
     {
         NSString * key1 = [[a objectForKey:@"value"] objectForKey:@"distance"];
         NSString * key2 = [[b objectForKey:@"value"] objectForKey: @"distance"];
         
         return [key1 floatValue] > [key2 floatValue];
     }
     ];
    
    [placesArray sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b)
     {
         NSString * key1 = [a objectForKey: @"interest"];
         NSString * key2 = [b objectForKey: @"interest"];
         
         return ([key1 compare:key2]);
     }
     ];
    
//    
//    if (bKite) {
//        [placesArray addObject:[kitePlace retain]];
//    }
    
    
//    int count = [[DataManager sharedManager].placesArray count];
//    if (kitePlace != nil) {
//     count = ([[[[[DataManager sharedManager].placesArray lastObject] objectForKey:@"interest"] lowercaseString] isEqualToString:@"kiteboarding"]) ? [[DataManager sharedManager].placesArray count] + 1 : [[DataManager sharedManager].placesArray count];
//    }
//    if (([[DataManager sharedManager].placesArray count] == 0) && (kitePlace != nil)) {
//        count ++;
//    }
    
    float y = 10.f;
    for (int i = 0; i < [placesArray count]; i++) {
        
        NSDictionary *content = [placesArray objectAtIndex:i];

        int nHeight = 70.f;
               
        UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopPadding.png"]];
        [topImageView setFrame:CGRectMake(0, y, 300, 5)];
        [topImageView setContentMode:UIViewContentModeScaleToFill];
        [scrollView addSubview:topImageView];
        
        // Calculate Content Height
        
        UIImageView *bodyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ContentPadding.png"]];
        [bodyImageView setFrame:CGRectMake(0, y + 5, 300, nHeight)];
        [bodyImageView setContentMode:UIViewContentModeScaleToFill];
        [scrollView addSubview:bodyImageView];
        
        // Get Profile Image
        AsyncImageView *pImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(9.f, y + 12.f, 53.f, 53.f)];
        pImageView.contentMode = UIViewContentModeScaleAspectFill;
		pImageView.clipsToBounds = YES;
        pImageView.bCircle = 1;
        pImageView.imageURL = [NSURL URLWithString:[[content objectForKey:@"value"] objectForKey:@"image_url"]];
        //        [pImageView setImageWithURL:[NSURL URLWithString:[[content objectForKey:@"value"] objectForKey:@"image_url"]] placeholderImage:[UIImage imageNamed:@"EmptyPlaceImage.png"]];
        [scrollView addSubview:pImageView];
        [pImageView release];
        //        [pImageView release];
        
        UILabel *lblMile = [[UILabel alloc] initWithFrame:CGRectMake(158.f, y + 7, 135.f, 12.f)];
        [lblMile setFont:[UIFont fontWithName:@"HelveticaNeue" size:MILES_FONT_SIZE]];
        [lblMile setBackgroundColor:[UIColor clearColor]];
        [lblMile setTextAlignment:NSTextAlignmentRight];
        [lblMile setText:[NSString stringWithFormat:@"%0.1f mi", [[[content objectForKey:@"value"] objectForKey:@"distance"] floatValue] / 1609.34]];
        //        [lblMile sizeToFit];
        [scrollView addSubview:lblMile];
        [lblMile release];
        
        //        CLLocationCoordinate2D coordinate;
        //        coordinate.latitude = targetLocation.coordinate.latitude;
        //        coordinate.longitude = targetLocation.coordinate.longitude;
        
        //        MapAnnotation *point = [[MapAnnotation alloc] initWithLocation:[content objectForKey:@"first"]
        //                                                            coordinate:coordinate];
        
        //        MapAnnotation *point = [[MapAn    notation alloc] initWithName:[[content objectForKey:@"value"] objectForKey:@"name"] pinType:@"1" coordinate:coordinate];
        //        [mapView addAnnotation:point];
        //        [point release];
        //
        // Get Name
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(70.f, y + 15, 220.f, 20.f)];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:TITLE_FONT_SIZE]];
        [lblName setText:[[content objectForKey:@"value"] objectForKey:@"name"]];
        [lblName setTextColor:[UIColor colorWithRed:1.f green:.35f blue:0 alpha:1.f]];
        [scrollView addSubview:lblName];
        [lblName release];
        
        // Get Interest
        
        int x = 70.f;
        UILabel *lblMatchingInterest = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 35 , 0, 20)];
        [lblMatchingInterest setBackgroundColor:[UIColor clearColor]];
        [lblMatchingInterest setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:INTEREST_FONT_SIZE]];
        [lblMatchingInterest setText:[NSString stringWithFormat:@"%@",[content objectForKey:@"interest"]]];
        [lblMatchingInterest sizeToFit];
        [scrollView addSubview:lblMatchingInterest];
        if (lblMatchingInterest.frame.size.width > 200) {
            [lblMatchingInterest setFrame:CGRectMake(x, y + 40, 200, lblMatchingInterest.frame.size.height)];
        }
        
        [lblMatchingInterest release];
        
        int nCommunity = [[[content objectForKey:@"value"] objectForKey:@"user_count"] intValue];
        
        UILabel *lblCommunity = [[UILabel alloc] initWithFrame:CGRectMake(x, y + 53, 220.f, 20.f)];
        [lblCommunity setBackgroundColor:[UIColor clearColor]];
        [lblCommunity setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
        [lblCommunity setText:(nCommunity == 0) ? @"Be the first to join this community" : (nCommunity == 1) ? [NSString stringWithFormat:@"%d person in this community", nCommunity] : [NSString stringWithFormat:@"%d people in this community", nCommunity]];
        [scrollView addSubview:lblCommunity];
        [lblCommunity release];
        
        // Get Shoutout
        //        if (content objectForKey:@") {
        //            ￼
        //        }
        
        [bodyImageView setFrame:CGRectMake(0, bodyImageView.frame.origin.y, 300, nHeight)];
        
        // Add Footer Image
        UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BottomPadding"]];
        [footerImage setFrame:CGRectMake(0, bodyImageView.frame.origin.y + nHeight, 300, 5)];
        [scrollView addSubview:footerImage];
        [bodyImageView release];
        
        y += nHeight + 20;
        
        UIButton *btnPlace = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnPlace setFrame:CGRectMake(0, topImageView.frame.origin.y, 300, footerImage.frame.origin.y + footerImage.frame.size.height - topImageView.frame.origin.y )];
        [btnPlace addTarget:self action:@selector(placeSelect:) forControlEvents:UIControlEventTouchUpInside];
        [btnPlace setTag:i];
        [scrollView addSubview:btnPlace];
        
        [footerImage release];
        [topImageView release];
//        j++;
    }
    
    [scrollView setContentSize:CGSizeMake(310.f, y + 30)];
}

- (void)viewWillAppear:(BOOL)animated {
    [scrollView setFrame:CGRectMake(10, 44 + [DataManager sharedManager].fiOS7StatusHeight, 320, (IS_IPHONE5) ? 524 : 416)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)placeSelect:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSDictionary *content;

        content = [[placesArray objectAtIndex:button.tag] objectForKey:@"value"];
    
        NSDictionary *kitePlace = [[NSUserDefaults standardUserDefaults] objectForKey:@"KITE_PLACE"];
    NSString *kID = [[kitePlace objectForKey:@"value"] objectForKey:@"id"];
        NSString *strPlace;
        if ([[content valueForKey:@"location"] valueForKey:@"display_address"]) {
            strPlace = [[[content objectForKey:@"location"] objectForKey:@"display_address"] componentsJoinedByString:@" "];
        } else {
            if ([[content objectForKey:@"id"] isEqualToString:kID]) {
                strPlace = [content objectForKey:@"address"];
            } else {
                strPlace = @"";
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"is_place"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [content  objectForKey:@"image_url"]] forKey:@"Attach_Image"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [content objectForKey:@"id"]] forKey:@"Attach_Url"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [content objectForKey:@"name"]] forKey:@"Attach_Title"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", ([[content objectForKey:@"id"] isEqualToString:kID])? [[content objectForKey:@"links"] objectForKey:@"info page"] : [content objectForKey:@"url"]] forKey:@"Attach_Place_Url"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", strPlace] forKey:@"Attach_Detail"];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [scrollView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [scrollView release];
    scrollView = nil;
    [super viewDidUnload];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
