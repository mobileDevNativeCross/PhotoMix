//
//  InfoViewController.h
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/27/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "FacebookManager.h"
#import "BaseViewController.h"
#import "WebViewController.h"

@interface InfoViewController : BaseViewController
    <MFMailComposeViewControllerDelegate,
    MFMessageComposeViewControllerDelegate,
    FacebookManagerLoginDelegate,
    WebViewControllerDelegate>

@end
