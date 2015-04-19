//
//  MapAnnotation.h
//  Findy
//
//  Created by iPhone on 8/5/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation> {

}

- (id)initWithName:(NSString *)name pinType:(NSString *)pintype coordinate:(CLLocationCoordinate2D)coord;
// Other methods and properties.
- (NSString *)pinType;

@end