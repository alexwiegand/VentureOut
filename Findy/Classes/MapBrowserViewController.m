//
//  MapBrowserViewController.m
//  Findy
//
//  Created by Yuri Petrenko on 1/28/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import "MapBrowserViewController.h"
#import "JSONKit.h"

@interface MapBrowserViewController ()

@end

@implementation MapBrowserViewController

@synthesize placeAddress, strTitle, strName;

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
    
    [strName setText:strTitle];
    [self changeLabelFont:strName _fontName:@"HelveticaNeue-Bold" _fontSize:18.f _width:240.f];
    
    [strName setFrame:CGRectMake(30 + (260.f - strName.frame.size.width) / 2.f, (44 - strName.frame.size.height) / 2.f + [DataManager sharedManager].fiOS7StatusHeight, strName.frame.size.width, strName.frame.size.height)];
    
    CLLocationCoordinate2D loc = [self geoCodeUsingAddress:placeAddress];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = loc;
    point.title = strTitle;
    
    [self.mapView addAnnotation:point];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    [strName release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setMapView:nil];
    [self setStrName:nil];
    [super viewDidUnload];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeLabelFont:(UILabel *)lblTemp _fontName:(NSString *)fontName _fontSize:(float)nFontSize _width:(float)width {
    while (lblTemp.frame.size.width > width) {
        [lblTemp setFont:[UIFont fontWithName:fontName size:nFontSize]];
        [lblTemp sizeToFit];
        nFontSize -= 0.5f;
    }
}

- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    esc_addr = [esc_addr stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    esc_addr = [esc_addr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSLog(@"%@", esc_addr);
    
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSData *result = [NSData dataWithContentsOfURL:[NSURL URLWithString:req]];

    NSDictionary *resultDict = [[JSONDecoder decoderWithParseOptions:JKParseOptionStrict] objectWithData:result];
    if ([[resultDict objectForKey:@"status"] isEqualToString:@"OK"]) {
        if ([[resultDict valueForKey:@"results"] valueForKey:@"geometry"]) {
            if ([[[resultDict valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"]) {
                NSDictionary *locationDict = [[[resultDict valueForKey:@"results"] valueForKey:@"geometry"] objectAtIndex:0];
                latitude = [[[locationDict objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
                longitude = [[[locationDict objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
}

@end
