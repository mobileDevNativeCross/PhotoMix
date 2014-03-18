//
//  MustacheCurtainView.h
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/26/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMPack;

@protocol MustacheCurtainViewDelegate <NSObject>

- (void)bannerPressedForPack: (DMPack*)pack curtainView: (id)curtainView;
- (void)buyNowPressedForPack: (DMPack*)pack curtainView: (id)curtainView;

- (void)restorePurchasesFromCurtainView: (id)curtainView;
- (void)unlockAllPressedFromCurtainView: (id)curtainView;

@end


@interface MustacheCurtainView : UIView

@property (assign, nonatomic) id<MustacheCurtainViewDelegate> delegate;
@property (assign, nonatomic, readonly) BOOL visible;

- (void)renderStaches;
- (void)redrawStacheBanners;

- (void)renderPaidPackBanners;
- (void)renderStachesForPack: (DMPack*)pack withBuyButton: (BOOL)withBuyButton description: (NSString*)description;
- (void)clearCurtain;

- (void)setClosingTarget: (id)target action: (SEL)action;
- (void)closeWithObject: (id)object;

- (void)bannerPressed: (id)sender;


@end
