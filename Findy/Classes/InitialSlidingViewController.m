//
//  InitialSlidingViewController.m
//  Findy
//
//  Created by iPhone on 8/3/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import "InitialSlidingViewController.h"
#import "MainViewController.h"
#import "InviteFBFriendViewController.h"
#import "ChatViewController.h"

@interface InitialSlidingViewController ()

@end

@implementation InitialSlidingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIStoryboard *storyboard;
    
    storyboard = [UIStoryboard storyboardWithName:@"MainWindow" bundle:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"GOTO_CHAT"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainWindow"
                                                             bundle: nil];
        
        
        ChatViewController *chatController = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        //        chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];
        
        //        chatController.shoutOutDictionary = [[NSDictionary alloc] initWithDictionary:shoutDict];
        chatController.partnerEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"Chat_email"];
        chatController.strTitle = [DataManager sharedManager].strFirstName;
        chatController.bChatReply = FALSE;
        self.topViewController = chatController;
    } else {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FIRST_REGISTER"]) {
            UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"InviteFBFriendViewController"];
            self.topViewController = controller;
        }
        else {
            MainViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            controller.bInitialLoading = TRUE;
            self.topViewController = controller;
        }
    }
}

@end
