//
//  MapAnnotation.m
//  Findy
//
//  Created by iPhone on 8/5/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "MapAnnotation.h"

@interface MapAnnotation ()
@property (nonatomic, copy) NSString *pinType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation MapAnnotation

- (id)initWithName:(NSString *)name pinType:(NSString *)pintype coordinate:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        self.title = name;
        self.pinType = pintype;
        self.coordinate = coord;
    }
    return self;
}

- (NSString *)pinType {
    return _pinType;
}


@end
