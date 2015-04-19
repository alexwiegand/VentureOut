//
//  ImageSelectButton.m
//  Findy
//
//  Created by iPhone on 8/1/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "ImageSelectButton.h"

@implementation ImageSelectButton

@synthesize buttonSelect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        checkImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 22.f, self.frame.size.height - 22.f, 22.f, 22.f)];
        [checkImage setImage:[UIImage imageNamed:@"CheckButtonDeselect.png"]];
        [self addSubview:checkImage];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [super setBackgroundImage:image forState:state];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];

    if (selected == TRUE) {
        [checkImage setImage:[UIImage imageNamed:@"CheckButtonSelect.png"]];
    } else {
        [checkImage setImage:[UIImage imageNamed:@"CheckButtonDeselect.png"]];
    }
}

@end
