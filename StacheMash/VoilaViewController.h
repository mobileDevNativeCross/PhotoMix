//
//  VoilaViewController.h
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/21/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Sincerely/Sincerely.h>

#import "FacebookShareViewController.h"
#import "FacebookManager.h" 
#import "BaseViewController.h"

//Sun - Fix warnings

@interface VoilaViewController : BaseViewController
    <MFMailComposeViewControllerDelegate,
    FacebookManagerLoginDelegate,
    FacebookShareViewControllerDelegate,FBFriendPickerDelegate, FacebookManagerDialogDelegate,
    UIAlertViewDelegate,
    SYSincerelyControllerDelegate,
    UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIImage *sourceImage;
//Sun
@property (strong, nonatomic) UIImage *oriImage;

//Instagram
- (void)shareIG:(id)sender;

@end
