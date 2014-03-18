//
//  DataModel.h
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/23/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppStorePaymentManager.h"
#import "FacebookManager.h"
#import "Reachability.h"


@class DMPack;

@protocol DataModelPurchaseDelegate <NSObject>

- (void)updateMustacheCurtain;
- (void)removeAdBanner;

@end


@interface DataModel : NSObject <InAppStorePaymentManagerProtocol>

+(DataModel*)sharedInstance;

@property (assign, nonatomic) BOOL didShowMustacheColorInstructions;
@property (assign, readonly, nonatomic) BOOL shouldShowMustacheColorInstructions;
@property (assign, nonatomic) BOOL didShowPictureEditInstructions;
@property (assign, nonatomic) BOOL shouldShowBannerAds;
@property (assign, nonatomic, readonly) BOOL allMustachesUnlocked;

@property (strong, readonly, nonatomic) NSArray *packsArray;
@property (strong, readonly, nonatomic) NSArray *visiblePacks;
@property (strong, readonly, nonatomic) InAppStorePaymentManager *paymentManager;

@property (assign, nonatomic) BOOL redrawMusctaheCurtain;
@property (assign, nonatomic) BOOL redrawPacksCurtain;

@property (assign, nonatomic) id<DataModelPurchaseDelegate> purchaseDelegate;
@property (strong, nonatomic, readonly) NSString *revMobFullscreenAppId;
@property (strong, nonatomic, readonly) NSString *revMobPopupAppId;
@property (strong, nonatomic, readonly) NSString *globlyLink;

@property (assign, nonatomic) BOOL shouldShowInterstitial;

@property (strong, nonatomic) id<FBGraphUser> currentFBFriend;
@property (assign, nonatomic) NSInteger amountInvitedFriends;

@property (strong, nonatomic, readonly) NSString *playHavenToken;
@property (strong, nonatomic, readonly) NSString *playHavenSecret;

@property (strong, readonly, nonatomic) Reachability *hostReach;


- (NSArray*)purchasedPacks;
- (NSArray*)nonPurchasedPacks;

- (SKProduct*)productForPack: (DMPack*)pack;
- (SKProduct*)productWithIdentifier: (NSString*)productId;
- (DMPack*)packWithIdentifier: (NSString*)productId;

- (void)purchasePack: (DMPack*)pack;
- (void)restorePurchases;
- (void)removeBannerAd;
- (void)purchaseUnlockAllMustaches;

- (NSInteger) saveInvitedFriends: (NSInteger) newFriends;
- (BOOL) userHasFreePack;
- (void) presentFreePack;
- (NSInteger) getInvitedFriends;


@end
