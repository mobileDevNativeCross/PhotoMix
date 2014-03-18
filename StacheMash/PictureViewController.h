//
//  PictureViewController.h
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/18/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MobclixAds.h"

#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>

#import "BaseViewController.h"
#import "MustacheCurtainView.h"
#import "StacheView.h"
#import "DataModel.h"
#import "MBProgressHUD.h"
#import "FlurryAdDelegate.h"

@interface PictureViewController : BaseViewController
    <UINavigationControllerDelegate,
    UIGestureRecognizerDelegate,
    MustacheCurtainViewDelegate,
    StacheViewDelegate,
    UIAlertViewDelegate,
    MobclixAdViewDelegate,
    DataModelPurchaseDelegate,
    RevMobAdsDelegate,
    MBProgressHUDDelegate,
    FlurryAdDelegate>

@property (strong, nonatomic) UIImage *sourceImage;
// Sun

//@property (strong, nonatomic) UIImage *originaImage;


@end
