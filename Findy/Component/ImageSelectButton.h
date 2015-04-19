//
//  ImageSelectButton.h
//  Findy
//
//  Created by iPhone on 8/1/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSelectButton : UIButton {
    UIImageView *checkImage;
}

@property (readwrite) BOOL buttonSelect;

@end
