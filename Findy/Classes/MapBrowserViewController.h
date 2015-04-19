//
//  MapBrowserViewController.h
//  Findy
//
//  Created by Yuri Petrenko on 1/28/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapBrowserViewController : UIViewController <MKMapViewDelegate> {
    
    
}

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) NSString *strTitle;
@property (retain, nonatomic) NSString *placeAddress;
@property (retain, nonatomic) IBOutlet UILabel *strName;

@end
