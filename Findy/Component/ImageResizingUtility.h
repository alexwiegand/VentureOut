//
//  ImageResizingUtility.h
//  Findy
//
//  Created by iPhone on 8/1/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageResizingUtility : NSObject

+ (ImageResizingUtility *) instance;

/*
 *  Resize Image in Rect
 *  Parameters
 *  imageToCrop : Image Object
 */

- (UIImage*)imageByCropping:(UIImage *)imageToCrop _targetSize:(CGSize)targetSize;

@end
