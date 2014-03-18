//
//  MustachePackView.h
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/26/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMPack;
@class MustacheCurtainView;

@interface MustachePackView : UIView

- (id)initWithFrame: (CGRect)frame
               pack: (DMPack*)pack
      parentCurtain: (MustacheCurtainView*)mustacheCurtainView
         bannerPack: (DMPack*)bannerPack
     buttonsEnabled: (BOOL)buttonsEnabled
   shouldRenderLock: (BOOL)shouldRenderLock;

@property (strong, readonly, nonatomic) DMPack *pack;
@property (strong, readonly, nonatomic) DMPack *bannerPack;

- (void)renderBannerForPack: (DMPack*)pack;

@end
