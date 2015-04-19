//
//  MainViewController.h
//  Findy
//
//  Created by iPhone on 7/31/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "OAuthConsumer.h"
#import "NMRangeSlider.h"

@interface MainViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIButton *listButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIButton *filterButton;
    IBOutlet UILabel *lblList;
    IBOutlet UILabel *lblMap;
    IBOutlet UILabel *lblFilter;
    
    IBOutlet UIScrollView *contentScrollView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIScrollView *filterScrollView;
    
    //FILTER VIEW OBJECTS
    
    IBOutlet UIButton *btnAddInterest;
    IBOutlet UILabel *lblAge;
    IBOutlet UILabel *lblRadius;
    IBOutlet UILabel *lblAgeTitle;
    IBOutlet UILabel *lblRadiusTitle;
    IBOutlet UIImageView *imgInterestFooter;
    
    IBOutlet UIView *viewAgeFilter;
    IBOutlet UIView *viewRadiusFilter;
    IBOutlet UIButton *btnDone;

    IBOutlet UIButton *btnFilterByPeople;
    IBOutlet UIButton *btnFilterByPlace;
    IBOutlet UIPickerView *agePicker;
    IBOutlet UIPickerView *radiusPicker;
    IBOutlet UIToolbar *pickerToolbar;
    IBOutlet UIView *menuView;
    IBOutlet UITableView *filterByTableView;
    IBOutlet UITableView *interestTableView;
    IBOutlet UILabel *lblInterest;
    
    NSMutableArray *filterByTableArray;
    NSMutableArray *interestTableArray;
    NSMutableArray *interestSelectArray;
    NSMutableArray *allArray;
    int cntSelInterest;
    int nFilterBy;
    
    NSArray *apiResultArray;
    NSArray *ageFilterArray;
    NSArray *radiusFilterArray;
    NSMutableArray *interestFilterArray;
    NSMutableArray *friendArray;
    NSMutableDictionary *mutualDict;
    int ageFilterMin;
    int ageFilterMax;
    float radiusFilter;
    NSMutableData *_responseData;
    NSMutableArray *placesArray;
    NSMutableArray *placesPosArray;
    int curY;
    
    BOOL bFilterChanged;
    BOOL bInitialLoading;
    
    UIImageView *pImg3, *pImg4;
    
    NSMutableDictionary *newPlaceDict;
    
    UIImageView *overlayImg;
    UIButton *overlayButton;
    
    BOOL bAddActivity;
    
    NSMutableDictionary *placeOfferDict;
    
    NMRangeSlider *ageSlider;
    UISlider *radiusSlider;
    
    UILabel *lblAgeMin;
    UILabel *lblAgeMax;
    UILabel *lblRadiusValue;
    float placeRadius;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) IBOutlet CLGeocoder *geoCoder;
@property (retain, nonatomic) IBOutlet CLLocationManager *locationManager;
@property (readwrite) BOOL bInitialLoading;

- (void)revealMenu:(id)sender;
- (IBAction)menuSelect:(id)sender;
- (IBAction)ageButtonPressed:(id)sender;
- (IBAction)radiusButtonPressed:(id)sender;
- (IBAction)filterByButtonPressed:(id)sender;
- (IBAction)donePicker:(id)sender;
- (IBAction)addInterestPressed:(id)sender;

@end
