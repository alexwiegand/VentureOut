//
//  ProfilePhotoViewController.m
//  Findy
//
//  Created by iPhone on 7/31/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "ProfilePhotoViewController.h"
#import "ImageResizingUtility.h"
#import "AppDelegate.h"
#import "DataManager.h"
#import "AsyncImageView.h"

@interface ProfilePhotoViewController ()

@end

@implementation ProfilePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:.93f green:.92f blue:.88f alpha:1.f];
    
    UIImageView *navigationBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(IS_IOS7) ? @"NavigationBar7.png" : @"NavigationBar.png"]];
    [navigationBar setFrame:CGRectMake(0, 0, 320.f, 44.f + [DataManager sharedManager].fiOS7StatusHeight)];
    
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"BackButton.png"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_settings"]) {
        [nextButton setImage:[UIImage imageNamed:@"DoneButton.png"] forState:UIControlStateNormal];
        [nextButton setFrame:CGRectMake(263.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 49.f, 30.f)];
    } else {
        [nextButton setImage:[UIImage imageNamed:@"NextButton.png"] forState:UIControlStateNormal];
        [nextButton setFrame:CGRectMake(290.f, 8.f + [DataManager sharedManager].fiOS7StatusHeight, 30.f, 30.f)];
    }
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 44.f)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.f]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setText:@"My Profile Photo"];
    [self.view addSubview:lblTitle];
    
    btnBackground = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBackground setFrame:CGRectMake(0, 44.f + [DataManager sharedManager].fiOS7StatusHeight, 320.f, 262.f)];
    [btnBackground setBackgroundColor:[UIColor colorWithRed:.2f green:.6f blue:.8f alpha:1.f]];
    [btnBackground addTarget:self action:@selector(setBackPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBackground];
    
    btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnProfile setFrame:CGRectMake(10.f, 285.f + [DataManager sharedManager].fiOS7StatusHeight, 80.f, 80.f)];
    [btnProfile setBackgroundImage:[UIImage imageNamed:@"ProfileButton.png"] forState:UIControlStateNormal];
    [btnProfile addTarget:self action:@selector(setProfilePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnProfile];
    
    lblBack = [[UILabel alloc] initWithFrame:CGRectMake(65.f, 145.5f + [DataManager sharedManager].fiOS7StatusHeight, 190.f, 44.f)];
    [lblBack setText:@"Tap To Add Background\nPhoto"];
    [lblBack setNumberOfLines:2];
    [lblBack setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [lblBack setBackgroundColor:[UIColor clearColor]];
    [lblBack setTextColor:[UIColor whiteColor]];
    [lblBack setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblBack];
    [lblBack release];
    
    lblProfile = [[UILabel alloc] initWithFrame:CGRectMake(16.f, 300.f + [DataManager sharedManager].fiOS7StatusHeight, 69.f, 52.f)];
    [lblProfile setText:@"Tap To\nAdd Profile\nPhoto"];
    [lblProfile setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.f]];
    [lblProfile setNumberOfLines:3];
    [lblProfile setBackgroundColor:[UIColor clearColor]];
    [lblProfile setTextColor:[UIColor whiteColor]];
    [lblProfile setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lblProfile];
    [lblProfile release];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_settings"]) {
        if ([DataManager sharedManager].imgBack != nil) {
            [lblBack setHidden:YES];
        }
        
        if ([DataManager sharedManager].imgFace != nil) {
            [lblProfile setHidden:YES];
        }
        
        [btnProfile setBackgroundImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:[DataManager sharedManager].imgFace  withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]] forState:UIControlStateNormal];
        [btnBackground setBackgroundImage:[[ImageResizingUtility instance] imageByCropping:[DataManager sharedManager].imgBack _targetSize:CGSizeMake(320, 262)] forState:UIControlStateNormal];
        
        
    }
    bDefaultLibrary = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [btnBackground setBackgroundImage:[DataManager sharedManager].imgBack forState:UIControlStateNormal];
    
    if ([DataManager sharedManager].imgBack != nil) {
        [lblBack setHidden:YES];
        [btnBackground setBackgroundImage:[[ImageResizingUtility instance] imageByCropping:[DataManager sharedManager].imgBack _targetSize:CGSizeMake(320, 262)] forState:UIControlStateNormal];
    } else {
        [lblBack setHidden:NO];
        [btnBackground setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    if ([DataManager sharedManager].imgFace != nil) {
        [lblProfile setHidden:YES];
        [btnProfile setBackgroundImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:[DataManager sharedManager].imgFace  withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]] forState:UIControlStateNormal];
    } else {
        [btnProfile setBackgroundImage:[(AppDelegate *)[[UIApplication sharedApplication] delegate] maskImage:[UIImage imageNamed:@"ProfileButton.png"] withMask:[UIImage imageNamed:@"ProfileButtonMask.png"]] forState:UIControlStateNormal];
        [lblProfile setHidden:NO];
    }
    bDefaultLibrary = FALSE;
}

- (void)backButtonPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"from_settings"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextButtonPressed:(id)sender {
    if ([DataManager sharedManager].imgFace == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo" message:@"Please set up a profile picture, it's one of our authenticity measurements to ensure the best experience" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else if ([DataManager sharedManager].imgBack == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo" message:@"Please set up a wallpaper photo to ensure a great experience, you can choose from one of the beautiful photos provided." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        
        if (([DataManager sharedManager].imgFace.size.width >= 180) || ([DataManager sharedManager].imgFace.size.height >= 180)) {
            [DataManager sharedManager].imgFace = [[ImageResizingUtility instance] imageByCropping:[DataManager sharedManager].imgFace _targetSize:CGSizeMake(180, 180)];
        }
        
        if (([DataManager sharedManager].imgBack.size.width >= 640) || ([DataManager sharedManager].imgBack.size.height >= 520)) {
            [DataManager sharedManager].imgBack = [[ImageResizingUtility instance] imageByCropping:[DataManager sharedManager].imgBack _targetSize:CGSizeMake(640, 520)];
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"from_settings"]) {
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"update_picture"];
            
            dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(taskQ, ^{
            
                    NSString *bigImageUrl = [NSString stringWithFormat:@"http://crazebot.com/userpic_small.php?email=%@", [DataManager sharedManager].strEmail];
                    NSString *smallImageUrl  = [NSString stringWithFormat:@"http://crazebot.com/userpic_big.php?email=%@", [DataManager sharedManager].strEmail];
                    
                    [[AsyncImageLoader sharedLoader] removeImageForKey:bigImageUrl];
                    [[AsyncImageLoader sharedLoader] removeImageForKey:smallImageUrl];
            
                });//end block
        
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[DataManager sharedManager].strEmail, ([DataManager sharedManager].imgBack == nil) ? @" " : [[UIImageJPEGRepresentation([DataManager sharedManager].imgBack, 1.0) base64Encoding] stringByReplacingOccurrencesOfString:@"+" withString:@":::"],
                                                                                         ([DataManager sharedManager].imgFace == nil) ? @" " : [[UIImageJPEGRepresentation([DataManager sharedManager].imgFace, 1.0) base64Encoding]  stringByReplacingOccurrencesOfString:@"+" withString:@":::"], nil]
                                                                                forKeys:[NSArray arrayWithObjects:@"email", @"pic_big_data", @"pic_small_data", nil]];
            [[FindyAPI instance] updateUserInfo:self withSelector:@selector(updateUser:) andOptions:paramDict];
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                                 bundle: nil];
            UIViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"InterestSelectViewController"];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
    }
}

- (void)updateUser:(NSDictionary *)response {
    
    if ([response objectForKey:@"success"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"from_settings"];
//        [[[AsyncImageLoader sharedLoader] cache] removeObjectForKey:[[response objectForKey:@"user_data"] objectForKey:@"pic_small"]];
        [DataManager sharedManager].strPicSmall = [[response objectForKey:@"user_data"] objectForKey:@"pic_small"];
        [DataManager sharedManager].strPicBig = [[response objectForKey:@"user_data"] objectForKey:@"pic_big"];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"update_picture"]) {
            [DataManager sharedManager].strPicSmall = [[DataManager sharedManager].strPicSmall stringByAppendingFormat:@"&%i", rand()];
            [DataManager sharedManager].strPicBig = [[DataManager sharedManager].strPicBig stringByAppendingFormat:@"&%i", rand()];
            
            
            [DataManager sharedManager].imgBack = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[DataManager sharedManager].strPicBig]]];
            [DataManager sharedManager].imgFace = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[DataManager sharedManager].strPicSmall]]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeProfileImage" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setBackPhoto {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Library", @"Scenic Photos", nil];
    [actionSheet setBackgroundColor:[UIColor blackColor]];
    [actionSheet setTag:100];
    [actionSheet showInView:self.view];
    bSelected = TRUE;
}

- (void)setProfilePhoto {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Library", nil];
    [actionSheet setBackgroundColor:[UIColor blackColor]];
    [actionSheet setTag:101];
    [actionSheet showInView:self.view];
    bSelected = FALSE;
}

//lumositi11

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            imagePicker.videoMaximumDuration = 86400.f;
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            imagePicker.videoMaximumDuration = 86400.f;
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if ((buttonIndex == 2) && (actionSheet.tag == 100)) {
        bDefaultLibrary = TRUE;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        UIViewController *profileViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectDefaultLibraryViewController"];
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    if (bSelected) {
        bgImage = image;
        [DataManager sharedManager].imgBack = bgImage;
        //        [btnBackground setBackgroundImage:image forState:UIControlStateNormal];
        //        [lblBack setHidden:YES];
        [picker dismissModalViewControllerAnimated:YES];
    } else {
        
        if ((image.size.width >= 180) || (image.size.height >= 180)) {
            image = [[ImageResizingUtility instance] imageByCropping:image _targetSize:CGSizeMake(180, 180)];
        }
        
        fcImage = image;
        [DataManager sharedManager].imgFace = fcImage;
        
        //        [btnProfile setBackgroundImage:image forState:UIControlStateNormal];
        //        [lblProfile setHidden:YES];
        [picker dismissModalViewControllerAnimated:YES];
    }
}

@end