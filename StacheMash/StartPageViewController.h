//
//  StartPageViewController.h
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/17/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookManager.h"
#import "BaseViewController.h"
#import "MBProgressHUD.h"

@interface StartPageViewController : BaseViewController
    <UIImagePickerControllerDelegate,
        UINavigationControllerDelegate,
        UINavigationControllerDelegate,
        FBFriendPickerDelegate,
        FacebookManagerLoginDelegate,
        MBProgressHUDDelegate,
        UISearchBarDelegate>

@property (nonatomic, assign) BOOL shouldShowSplashLoading;
@property (nonatomic, assign) BOOL isCameraShown;

- (void)hideSplash;

@end
