//
//  ProfilePhotoViewController.h
//  Findy
//
//  Created by iPhone on 7/31/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePhotoViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIButton *btnBackground;
    UIButton *btnProfile;
    UILabel *lblBack;
    UILabel *lblProfile;
    
    UIImage *bgImage;
    UIImage *fcImage;
    BOOL bSelected;
    BOOL bDefaultLibrary;
}

@end