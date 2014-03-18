//
//  AppDelegate.h
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/17/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlurryAdDelegate.h"
#import "Chartboost.h"
#import <RevMobAds/RevMobAds.h>
#import <RevMobAds/RevMobAdsDelegate.h>
#import "PlayHavenSDK.h"


// IDs for Advert SDKs
// Mustache Bash area

//Flurry startSession
#define FLURRY_SESSION_ID @"9U7F7RLY1NDWQEQMUX35"

//rate.appStoreID
#define APPSTORE_RATE_ID 499793669

#define APP_ID @"499793669"
//Mobclix 
#define MOBCLIX_APPLICATION_ID @"46B44DFB-7F48-4B07-B615-C6C324C88963"

//RevMobFullscreen 
#define REVMOB_FULLSCREEN_PLACEMENT_ID @"515eedc64979bf0d00000001"

//revMobBannerView
#define REVMOB_BANNER_ID @"5156fc9b26a2bb1200000051"

//playHavenToken   
#define PLAYHAVEN_TOKEN @"5c9a7e2f94c642f59eb3c47bc1394488"
//playHavenSecret
#define PLAYHAVEN_SECRET @"5a623f521594470bbde5b3aaa8a0c7d4"

//playHaven placement
#define PLAYHAVEN_PLACEMENT1 @"more_games"
#define PLAYHAVEN_PLACEMENT2 @"nag_on_return_to_front"

//postcard id
#define SINCELERY_ID @"IM7VVSK8F4CAFLMC3QZBGD8IC37SMMS928VYY602"

// Facebook app id
#define FACEBOOK_APP_ID @"238923342858696"

#define INSTAGRAM_CAPTION @"@brightnewt #mustachebash"



#define NAG_SCREENS_ON 1

@interface AppDelegate : UIResponder
    <UIApplicationDelegate,
    FlurryAdDelegate,
    ChartboostDelegate,
    RevMobAdsDelegate,
    PHPublisherContentRequestDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)openReferralURL:(NSURL *)referralURL;

@end
