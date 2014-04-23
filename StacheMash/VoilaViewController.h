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
//#import "Odnoklassniki.h"
///#import "vkLoginViewController.h"
//#import "JSONKit.h"

//Sun - Fix warnings
///odnoklssniki
static NSString * appID1 = @"App ID";
static NSString * appSecret1 = @"App Secret";
static NSString * appKey1 = @"App key";
////
@interface VoilaViewController : BaseViewController
    <MFMailComposeViewControllerDelegate,
    FacebookManagerLoginDelegate,
    FacebookShareViewControllerDelegate,FBFriendPickerDelegate, FacebookManagerDialogDelegate,
    UIAlertViewDelegate,
    SYSincerelyControllerDelegate,
UIDocumentInteractionControllerDelegate>
{
    NSString *appID;
    BOOL isAuth;
   // Odnoklassniki *_api;
}

//odnoklassniki
//@property(nonatomic, retain) Odnoklassniki *api;

//@property (strong, nonatomic) OKRequest *theNewTitle;
//@property(nonatomic, retain,getter=theNewTitle) OKRequest *newRequest;
//
@property (nonatomic, retain,) NSString *appID;



@property (strong, nonatomic) UIImage *sourceImage;
//Sun
@property (strong, nonatomic) UIImage *oriImage;

@property (strong, nonatomic) NSString *descriptiontext;

@property (readwrite) float firstWidhtVoila;
@property (readwrite) float firstHeightVoila;

//Instagram
- (void)shareIG:(id)sender;
- (void) authComplete;

@end
