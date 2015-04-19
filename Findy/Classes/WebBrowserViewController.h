//
//  WebBrowserViewController.h
//  Findy
//
//  Created by iPhone on 11/22/13.
//  Copyright (c) 2013 CommonCraze, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface WebBrowserViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate> {

}

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *viewTitle;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) NSString *strType;
@end
