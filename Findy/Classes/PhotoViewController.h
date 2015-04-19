//
//  PhotoViewController.h
//  Findy
//
//  Created by Yuri Petrenko on 2/2/14.
//  Copyright (c) 2014 Yuri Petrenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController {
    
}

@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSString *strPhoto;

- (IBAction)doneClick:(id)sender;
@end
