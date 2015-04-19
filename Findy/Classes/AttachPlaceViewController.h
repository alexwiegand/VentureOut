//
//  AttachPlaceViewController.h
//  Findy
//
//  Created by Alexander Wiegand on 3/24/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachPlaceViewController : UIViewController {
    
    IBOutlet UIScrollView *scrollView;
    NSMutableDictionary *kitePlace;
    
    NSMutableArray *placesArray;
}

@property (nonatomic, retain) NSMutableDictionary *kitePlace;

@end
