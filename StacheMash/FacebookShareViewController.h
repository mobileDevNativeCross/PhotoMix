//
//  FacebookShareViewController.h
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/25/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookManager.h"
#import "BaseViewController.h"

@protocol FacebookShareViewControllerDelegate <NSObject>

- (void)cancelFacebookShareViewController: (id)controller;
- (void)doneFacebookShareViewController: (id)controller;
- (void)shareAppWithFriends: (id) controller;

@end


@interface FacebookShareViewController : BaseViewController
    <FacebookManagerShareDelegate,
    UITextFieldDelegate,
    FBFriendPickerDelegate,
    UISearchBarDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    UIAlertViewDelegate>

@property (strong, nonatomic) UIImage *sourceImage;
@property (retain, nonatomic) id<FacebookShareViewControllerDelegate> delegate;

@end
