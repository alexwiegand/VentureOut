//
//  ImageResizingUtility.m
//  Findy
//
//  Created by iPhone on 8/1/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "ImageResizingUtility.h"

@implementation ImageResizingUtility

/**
 * Singleton accessor.
 */
////////////////////////////////////////////////////////////////////////////////
+ (ImageResizingUtility *) instance {
	static ImageResizingUtility *sharedInstance;
	
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[ImageResizingUtility alloc] init];
        }
		
		return sharedInstance;
	}
	
	return nil;
}   // ImageResizingUtility::instance

/*
 *  Resize Image in Rect
 *  Parameters
 *  imageToCrop : Image Object
 */


- (UIImage*)imageByCropping:(UIImage *)imageToCrop _targetSize:(CGSize)targetSize{
    
    UIImage *newImage = nil;
    CGSize imageSize = imageToCrop.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [imageToCrop drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
    
    
//    UIImage *image = [UIImage imageWithCIImage:[imageToCrop CGImage] scale:(320.0 / imageToCrop.size.width) orientation:UIImageOrientationDown];
//    
//    float height = imageToCrop.size.height;
//    float y;
//    if (height > 155) {
//        y = (height - 155) / 2.0;
//    } else {
//        return image;
//    }
//    CGRect rect = CGRectMake(0, y, 320, 155);
//    
//    CGImageRef tmp = CGImageCreateWithImageInRect([imageToCrop CGImage], newSize);
//    
////    //create a context to do our clipping in
//////    UIGraphicsBeginImageContext(rect.size);
////    CGContextRef currentContext = UIGraphicsGetCurrentContext();
////    
////    //create a rect with the size we want to crop the image to
////    //the X and Y here are zero so we start at the beginning of our
////    //newly created context
////    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
////    CGContextClipToRect( currentContext, clippedRect);
////    
////    //create a rect equivalent to the full size of the image
////    //offset the rect by the X and Y we want to start the crop
////    //from in order to cut off anything before them
////    CGRect drawRect = CGRectMake(rect.origin.x * -1,
////                                 rect.origin.y * -1,
////                                 imageToCrop.size.width,
////                                 imageToCrop.size.height);
////    
////    //draw the image to our clipped context using our offset rect
////    CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
////    
////    //pull the image from our cropped context
////    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
////    
////    //pop the context to get back to the default
////    UIGraphicsEndImageContext();
////    
////    //Note: this is autoreleased
////    return cropped;
}

@end
