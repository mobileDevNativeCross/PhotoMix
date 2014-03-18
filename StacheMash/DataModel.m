//
//  DataModel.m
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/23/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "AppDelegate.h"
#import "DataModel.h"
#import "DMPack.h"
#import "DMStache.h"
#import "Flurry.h"
#import "NSArray+Functional.h"


static const NSInteger kShouldShowMustacheColorInstructionCount = 3;

static NSString *kNSUserDefaultsMustacheColorInstructionsShownCount = @"kNSUserDefaultsMustacheColorInstructionsShownCount";
static NSString *kNSUserDefaultsDidShowPictureEditInstructions = @"kNSUserDefaultsDidShowPictureEditInstructions";
static NSString *kNSUserDefaultsInvitedFriendsCount = @"kNSUserDefaultsInvitedFriendsCount";
static NSString *kNSUserDefaultsGotFreePack = @"kNSUserDefaultsGotFreePack";


static NSString *kNSUserDefaultsShouldShowBannerAds = @"kNSUserDefaultsShouldShowBannerAds";

static NSString *kRemoveAdsProductId = @"com.brightnewt.mustachebash.remove_banner_ad";
static NSString *kUnlockAllProductId = @"com.brightnewt.mustachebash.unlock_all_packs";


@interface DataModel ()

- (BOOL)userDefaultsBoolFlagWithName: (NSString*)flagName;
- (void)setUserDefaultsBoolFlagWithName: (NSString*)flagName toValue: (BOOL)value;
- (BOOL)userDefaultsIntegerFlagWithName: (NSString*)flagName;
- (void)setUserDefaultsIntegerFlagWithName: (NSString*)flagName toValue: (NSInteger)value;

- (BOOL)keyExistsInUserDefaults: (NSString*)key;

- (NSURL*)applicationDocumentsDirectory;
- (NSString*)mustachePlistPath;
- (void)copyMustachePlistToDocuments;
- (NSArray*)loadPacksList;
- (void)loadStachesIntoPack: (DMPack*)pack;

- (NSSet*)productIDs;
- (void)updatePlistWithBoughtProductIdentifier: (NSString*)productId;
- (BOOL)markAsBoughtProductWithIdentifier: (NSString*)productId;
- (void)showNoiTunesProductsError;
- (BOOL) markPackAsVisible: (DMPack *) pack;


@end


@implementation DataModel

@synthesize packsArray = __packsArray;
@synthesize paymentManager = __paymentManager;
@synthesize purchaseDelegate = __purchaseDelegate;

@synthesize redrawMusctaheCurtain = __redrawMusctaheCurtain;
@synthesize redrawPacksCurtain = __redrawPacksCurtain;
@synthesize revMobFullscreenAppId = __revMobFullscreenAppId;
@synthesize revMobPopupAppId = __revMobPopupAppId;

@synthesize shouldShowInterstitial = _shouldShowInterstitial;

@synthesize currentFBFriend = _currentFBFriend;
@synthesize amountInvitedFriends = _amountInvitedFriends;

@dynamic didShowMustacheColorInstructions;
@dynamic shouldShowMustacheColorInstructions;
@dynamic didShowPictureEditInstructions;
@dynamic shouldShowBannerAds;

@synthesize hostReach = __hostReach;


#pragma mark - @property (assign, nonatomic) BOOL didShowMustacheColorInstructions

- (BOOL)didShowMustacheColorInstructions
{
    return 0 < [self userDefaultsIntegerFlagWithName: kNSUserDefaultsMustacheColorInstructionsShownCount];
}


- (void)setDidShowMustacheColorInstructions: (BOOL)flag
{
    NSInteger currentCount = [self userDefaultsIntegerFlagWithName: kNSUserDefaultsMustacheColorInstructionsShownCount];
    [self setUserDefaultsIntegerFlagWithName: kNSUserDefaultsMustacheColorInstructionsShownCount toValue: currentCount + 1];
}


#pragma mark - @property (assign, nonatomic) BOOL shouldShowMustacheColorInstructions

- (BOOL)shouldShowMustacheColorInstructions
{
    return [self userDefaultsIntegerFlagWithName: kNSUserDefaultsMustacheColorInstructionsShownCount] < kShouldShowMustacheColorInstructionCount;
}


#pragma mark - @property (assign, nonatomic) BOOL didShowPictureEditInstructions

- (BOOL)didShowPictureEditInstructions
{
    return [self userDefaultsBoolFlagWithName: kNSUserDefaultsDidShowPictureEditInstructions];
}


- (void)setDidShowPictureEditInstructions: (BOOL)flag
{
    [self setUserDefaultsBoolFlagWithName: kNSUserDefaultsDidShowPictureEditInstructions toValue: flag];
}


#pragma mark - @property (assign, nonatomic) BOOL shouldShowBannerAds

- (BOOL)shouldShowBannerAds
{
    return [self userDefaultsBoolFlagWithName: kNSUserDefaultsShouldShowBannerAds];
}


- (void)setShouldShowBannerAds: (BOOL)flag
{
    [self setUserDefaultsBoolFlagWithName: kNSUserDefaultsShouldShowBannerAds toValue: flag];
}


#pragma mark - @property (assign, nonatomic) BOOL allMustachesUnlocked

- (BOOL)allMustachesUnlocked
{
    for ( DMPack *pack in self.packsArray ) {
        if ( ![pack.bought boolValue] ) {
            return NO;
        }
    }
    
    return YES;
}


#pragma mark - @property (readonly, nonatomic) NSArray *packsArray;

- (NSArray*)packsArray
{
    if ( nil == __packsArray ) {
        __packsArray = [self loadPacksList];
    }
    return __packsArray;
}


#pragma mark - @property (readonly, nonatomic) NSArray *visiblePacks;

- (NSArray*)visiblePacks
{
    return [self.packsArray filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"SELF.visible = YES"]];
}


#pragma LifyCycle

+(DataModel*)sharedInstance
{
    static dispatch_once_t predicate;
    static DataModel *sharedModel = nil;
    
    dispatch_once(&predicate, ^{
        sharedModel = [[DataModel alloc] init];
    });
    
    return sharedModel;
}


- (id)init
{
    self = [super init];
    if ( self ) {
        [self copyMustachePlistToDocuments];
        
        
#ifndef MB_LUXURY
        __paymentManager = [[InAppStorePaymentManager alloc] init];
        self.paymentManager.delegate = self;
#endif
        
        self.redrawMusctaheCurtain = NO;
        self.redrawPacksCurtain = NO;
        self.currentFBFriend = nil;
        
        if ( ![self keyExistsInUserDefaults: kNSUserDefaultsShouldShowBannerAds] ) {
            self.shouldShowBannerAds = YES;
        }
        
        // Reachability
        __hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
        [self registerForNetworkReachabilityNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object:nil];

    }
    
    return self;
}


#pragma mark - Public

- (NSArray*)purchasedPacks
{
    return [self.packsArray filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"SELF.visible = YES"]];
}


- (NSArray*)nonPurchasedPacks
{
    return [self.packsArray filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"SELF.bought = NO"]];
}


- (NSSet*)productIDs
{
    NSMutableSet *products = [[NSMutableSet alloc] init];
    for ( DMPack *pack in self.packsArray ) {
        if ( 0 < [pack.IAP_id length] ) {
            [products addObject: pack.IAP_id];
        }
    }
    [products addObject: kRemoveAdsProductId];
    [products addObject: kUnlockAllProductId];
    
    return products;
}


- (SKProduct*)productForPack: (DMPack*)pack
{
    return [self productWithIdentifier: pack.IAP_id];
}


- (SKProduct*)productWithIdentifier: (NSString*)productId
{
    for ( SKProduct *product in self.paymentManager.products ) {
        if ( [product.productIdentifier isEqualToString: productId] ) {
            return  product;
        }
    }
    
    return nil;    
}

- (DMPack*)packWithIdentifier: (NSString*)productId
{
    for ( DMPack *pack in self.packsArray ) {
        if ( [pack.IAP_id isEqualToString: productId] ) {
            return pack;
        }
    }
    
    return nil;
}


#pragma mark - Purchase Actions

- (void)purchasePack: (DMPack*)pack
{
    if ( [pack.bought boolValue] ) {
        warn(@"pack is already bought");
        return;
    }
    
    if ( 0 == [pack.IAP_id length] ) {
        error(@"empty pack.IAP_id");
        return;
    }
    
    if ( nil != [self productForPack: pack] ) {
        debug(@"starting payment");
        [self.paymentManager makePaymentWithProductIdentifier: pack.IAP_id];
    }
    else {
        error(@"could not find product with id: %@", pack.IAP_id);
        [self showNoiTunesProductsError];
    }
}


- (void)restorePurchases
{
    debug(@"NOW will RESTORE");
    [self.paymentManager restorePurchases];
}


- (void)removeBannerAd
{
    if ( !self.shouldShowBannerAds ) {
        warn(@"banners are already disabled");
        return;
    }
    
    if ( nil != [self productWithIdentifier: kRemoveAdsProductId] ) {
        debug(@"starting payment");
        [self.paymentManager makePaymentWithProductIdentifier: kRemoveAdsProductId];
    }
    else {
        error(@"could not find product with id: %@", kRemoveAdsProductId);
        [self showNoiTunesProductsError];
    }
}


- (void)purchaseUnlockAllMustaches
{
    if ( self.allMustachesUnlocked ) {
        warn(@"All Mustaches are unlocked");
        return;
    }
    
    if ( nil != [self productWithIdentifier: kUnlockAllProductId] ) {
        debug(@"starting payment for unlocking all mustaches");
        [self.paymentManager makePaymentWithProductIdentifier: kUnlockAllProductId];
    }
    else {
        error(@"could not find product with id: %@", kUnlockAllProductId);
        [self showNoiTunesProductsError];
    }
}

- (void)unlockAllMustaches
{
    for ( DMPack *pack in self.packsArray ) {
        pack.bought = [NSNumber numberWithBool: YES];
    }
    
    self.redrawMusctaheCurtain = YES;
    self.redrawPacksCurtain = YES;
    
    NSMutableDictionary* packsPlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: [self mustachePlistPath]];
    
    [(NSArray*)[packsPlistDict objectForKey: @"packs"] run: ^(NSMutableDictionary *pack){
        [pack setObject: [NSNumber numberWithBool: YES] forKey: @"bought"];
    }];
    
    [packsPlistDict writeToFile: [self mustachePlistPath] atomically: YES];
}

- (NSInteger) getInvitedFriends
{
    return [self userDefaultsIntegerFlagWithName: kNSUserDefaultsInvitedFriendsCount];
}

- (NSInteger) saveInvitedFriends: (NSInteger) newFriends
{
    NSInteger totalUsers = [self userDefaultsIntegerFlagWithName: kNSUserDefaultsInvitedFriendsCount];
    totalUsers += newFriends;
    [self setUserDefaultsIntegerFlagWithName: kNSUserDefaultsInvitedFriendsCount toValue: totalUsers];
    return totalUsers;
}

- (void) presentFreePack
{
    [self setUserDefaultsIntegerFlagWithName: kNSUserDefaultsInvitedFriendsCount toValue: 0];
    [self setUserDefaultsIntegerFlagWithName: kNSUserDefaultsGotFreePack toValue: 1];
    [self purchasePackManually];
}


- (void) purchasePackManually
{
    DMPack *pack = [self.packsArray selectFirst: ^(DMPack *pack) {
        return [pack.path isEqualToString: @"ugly"];
    }];
    
    if ( nil != pack && ![pack.visible boolValue] )
        [self markPackAsVisible: pack];
}


- (BOOL) userHasFreePack
{
    return (BOOL) [self userDefaultsIntegerFlagWithName: kNSUserDefaultsGotFreePack];
}

- (void)showNoiTunesProductsError
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                    message: NSLocalizedString(@"Unable to retrieve product from iTunes Store. Check your internet connection and try again.", @"No products for IAP error - alert text")
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString( @"Dismiss", @"")
                                          otherButtonTitles: nil];
    [alert show];
}


#pragma mark - InAppStorePaymentManagerProtocol

- (void)didPurchaseProductWithIdentifier: (NSString*)productId
{
    if ( [self markAsBoughtProductWithIdentifier: productId] ) {
        SKProduct *product = [self productWithIdentifier: productId];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Purchase complete", @"alert title")
                                                        message: [NSString stringWithFormat: NSLocalizedString(@"%@ has been purchased!", @"purchase alert text"), product.localizedTitle]
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString( @"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        
        if ( [productId isEqualToString: kRemoveAdsProductId] ) {
            [Flurry logEvent: @"PurchasedNoBanners"];
        }
        else if ( [productId isEqualToString: kUnlockAllProductId] ) {
            [Flurry logEvent: @"PurchasedUnlockAll"];
        }
        else {
            [Flurry logEvent: @"PurchasedPack"
                       withParameters: [NSDictionary dictionaryWithObjectsAndKeys: product.localizedTitle, @"PackName", nil]
                                timed: NO];
        }
    }
    else {
        error(@"didn't find product with id: %@", productId);
    }
}


- (void)didRestoreProductWithIdentifier: (NSString*)productId
{
    [self markAsBoughtProductWithIdentifier: productId];
}


- (BOOL)markAsBoughtProductWithIdentifier: (NSString*)productId 
{
    if ( [productId isEqualToString: kRemoveAdsProductId] ) {
        self.shouldShowBannerAds = NO;
        [self.purchaseDelegate removeAdBanner];
        
        return YES;
    }
    else if ( [productId isEqualToString: kUnlockAllProductId] ) {
        [self unlockAllMustaches];
        [self.purchaseDelegate updateMustacheCurtain];
        
        return YES;
    }
    else {
        DMPack *pack = [self packWithIdentifier: productId];
        
        if ( nil != pack ){
            pack.bought = [NSNumber numberWithBool: YES];
            self.redrawMusctaheCurtain = YES;
            self.redrawPacksCurtain = YES;
            
            [self updatePlistWithBoughtProductIdentifier: productId];
            [self.purchaseDelegate updateMustacheCurtain];
            
            return YES;
        }
        else {
            error(@"didn't find product with id: %@", productId);
            return NO;
        }
    }
}


- (BOOL) markPackAsVisible: (DMPack *)pack
{
    if ( nil != pack ){
        pack.visible = [NSNumber numberWithBool: YES];
        self.redrawMusctaheCurtain = YES;
        self.redrawPacksCurtain = YES;
        
        NSMutableDictionary* packsPlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: [self mustachePlistPath]];
        
        NSMutableDictionary *plistPack = [(NSArray*)[packsPlistDict objectForKey: @"packs"] selectFirst: ^(NSDictionary *p) {
            return [p[@"path"] isEqualToString: pack.path];
        }];

        [plistPack setObject: [NSNumber numberWithBool: YES] forKey: @"visible"];
        [packsPlistDict writeToFile: [self mustachePlistPath] atomically: YES];
        
        [self.purchaseDelegate updateMustacheCurtain];
        
        return YES;
    }
    else {
        error(@"didn't find product");
        return NO;
    }
}


- (void)updatePlistWithBoughtProductIdentifier: (NSString*)productId
{
    NSMutableDictionary* packsPlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: [self mustachePlistPath]];
    
    for ( NSMutableDictionary *pack in [packsPlistDict objectForKey: @"packs"] ) {
        NSString *IAP_id = [pack objectForKey: @"IAP_id"];
        
        if ( [IAP_id isEqualToString: productId] ) {
            [pack setObject: [NSNumber numberWithBool: YES] forKey: @"bought"];
            [packsPlistDict writeToFile: [self mustachePlistPath] atomically: YES];
            return;
        }
    }
    
    warn(@"didn't find product with IAP id: %@ in plist", productId);
}



#pragma mark - User defaults flags

- (BOOL)userDefaultsBoolFlagWithName: (NSString*)flagName
{
	NSNumber *flag = [[NSUserDefaults standardUserDefaults] objectForKey: flagName];
	return [flag boolValue];
}


- (void)setUserDefaultsBoolFlagWithName: (NSString*)flagName toValue: (BOOL)value
{
	NSNumber *flag = [NSNumber numberWithBool: value];
	
	[[NSUserDefaults standardUserDefaults] setObject: flag forKey: flagName];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)userDefaultsIntegerFlagWithName: (NSString*)flagName
{
	NSNumber *flag = [[NSUserDefaults standardUserDefaults] objectForKey: flagName];
	return [flag integerValue];
}


- (void)setUserDefaultsIntegerFlagWithName: (NSString*)flagName toValue: (NSInteger)value
{
	NSNumber *flag = [NSNumber numberWithInt: value];
	
	[[NSUserDefaults standardUserDefaults] setObject: flag forKey: flagName];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)keyExistsInUserDefaults: (NSString*)key
{
    return nil != [[NSUserDefaults standardUserDefaults] objectForKey: key];
}



#pragma mark - Pack lists loading

- (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

- (NSString*)mustachePlistName
{
#if MB_LUXURY
    return @"MustachePacks_Luxury.plist";
#else
    return @"MustachePacks.plist";
#endif
}

- (NSString*)mustachePlistPath
{
    return [[[self applicationDocumentsDirectory] URLByAppendingPathComponent: [self mustachePlistName]] path];
}


- (NSString*)mustachePlistSourcePath
{
#if MB_LUXURY
    return [[NSBundle mainBundle] pathForResource: @"MustachePacks_Luxury" ofType: @"plist"];
#else
    return [[NSBundle mainBundle] pathForResource: @"MustachePacks" ofType: @"plist"];
#endif
}


- (void)copyMustachePlistToDocuments
{
    if ( ![[NSFileManager defaultManager] fileExistsAtPath: [self mustachePlistPath]] ) {
        warn(@"no %@ in document. Copying", [self mustachePlistName]);
        
        NSError *error = nil;
        NSString *sourcePath = [self mustachePlistSourcePath];
        
        [[NSFileManager defaultManager] copyItemAtPath: sourcePath
                                                toPath: [self mustachePlistPath]
                                                 error: &error];
        
        if ( error ) {
            error(@"error copying file:\n %@\n to path:\n%@", sourcePath, [self mustachePlistPath]);
        }
        else {
            debug(@"%@ copied ok to: %@", [self mustachePlistName], [self mustachePlistPath]);
        }
    }
    else {
        debug(@"%@ IS in documents", [self mustachePlistName]);
        debug(@"checking versions");
        
        //extract bundle plist version
        NSDictionary* packsDictBundle = [[NSMutableDictionary alloc] initWithContentsOfFile: [self mustachePlistSourcePath]];
        CGFloat packsDictBundleVersion = [(NSNumber*)packsDictBundle[@"version"] floatValue];
        debug(@"bundle plist version: %f", packsDictBundleVersion);
        
        // checking version
        NSDictionary* packsDictDisk = [[NSMutableDictionary alloc] initWithContentsOfFile: [self mustachePlistPath]];
        CGFloat packsDictDiskVersion =  [(NSNumber*)packsDictDisk[@"version"] floatValue];
        debug(@"disk plist version: %f", packsDictDiskVersion);
        
        if ( packsDictDiskVersion < packsDictBundleVersion ) {
            debug(@"migrate here");
            
            NSMutableDictionary* mergedPacksDict = [[NSMutableDictionary alloc] init];
            mergedPacksDict[@"version"] = packsDictBundle[@"version"];
            
            NSArray *packsBundleArray = packsDictBundle[@"packs"];
            NSArray *packsDiskArray = packsDictDisk[@"packs"];
            NSMutableArray *mergedPacksArray = [[NSMutableArray alloc] init];
            
            for ( NSDictionary *plistPack in packsBundleArray ) {
                NSMutableDictionary *mergedPack = [NSMutableDictionary dictionaryWithDictionary: plistPack];
                
                NSDictionary *diskPack = [packsDiskArray selectFirst: ^(NSDictionary *dict) {
                    return [(NSString*)dict[@"path"] isEqual: (NSString*)plistPack[@"path"]];
                }];
                
                if ( nil != diskPack ) {
                    debug(@"merging pack: '%@'", mergedPack[@"path"]);
                    
                    mergedPack[@"bought"] = diskPack[@"bought"];
                    
                    if ( nil != diskPack[@"visible"] ) {
                        mergedPack[@"visible"] = diskPack[@"visible"];
                    }
                }
                else {
                    debug(@"copying pack: '%@'", mergedPack[@"path"]);
                }
                [mergedPacksArray addObject: mergedPack];
            }
            
            mergedPacksDict[@"packs"] = mergedPacksArray;
            BOOL result = [mergedPacksDict writeToFile: [self mustachePlistPath] atomically: YES];
            debug(@"written merged plist: %d", result);
        }
    }
}


- (NSArray*)loadPacksList
{
    NSDictionary* packsPlistDict = [[NSMutableDictionary alloc] initWithContentsOfFile: [self mustachePlistPath]];
    
    NSArray *packsPlistArray = [packsPlistDict objectForKey: @"packs"];
    NSMutableArray *packsArray = [[NSMutableArray alloc] init];
    
    for ( NSDictionary *plistPack in packsPlistArray ) {
        DMPack *pack = [[DMPack alloc] initWithDictionary: plistPack];
        [self loadStachesIntoPack: pack];
        [packsArray addObject: pack];
    }
    
    return packsArray;
}


- (void)loadStachesIntoPack: (DMPack*)pack
{
    if ( nil == pack ) {
        error(@"nil pack supplied");
        return;
    }
    
    NSDictionary *packPlistDict =
    [[NSMutableDictionary alloc] initWithContentsOfFile:
     [[NSBundle mainBundle] pathForResource: @"Pack"
                                     ofType: @"plist"
                                inDirectory: [NSString stringWithFormat: @"staches/%@", pack.path]]];
    
    NSArray *stachesPlistArray = [packPlistDict objectForKey: @"staches"];
    NSMutableArray *stachesArray = [[NSMutableArray alloc] init];
    
    for ( NSDictionary *plistStache in stachesPlistArray ) {
        DMStache *stache = [[DMStache alloc] initWithDictionary: plistStache];
        [stachesArray addObject: stache];
    }
    
    pack.staches = stachesArray;
    pack.banners = [packPlistDict objectForKey: @"banners"];
}


#pragma mark - @property (strong, nonatomic, readonly) NSString *revMobFullscreenAppId;

- (NSString*)revMobFullscreenAppId
{
    
#if MB_LUXURY
    return @"50f81212e94bb20e0000004d";
#else
    //return @"4f9d8cbf2909c200080090bb";
    return @"5156fc9b26a2bb120000004d"; //@"5156fc9b26a2bb120000004d";
#endif

}


#pragma mark - @property (strong, nonatomic, readonly) NSString *revMobPopupAppId;

- (NSString*)revMobPopupAppId
{
    return @"4ff8aa455d33df00050002b3";
}

#pragma mark - @property (strong, nonatomic, readonly) NSString *globlyLink;

- (NSString*)globlyLink
{
    
#if MB_LUXURY
    return @"http://glob.ly/3Ov";
#else
    return @"http://glob.ly/2nr";
#endif
    
}


#pragma mark - @property (strong, nonatomic, readonly) NSString *playHavenToken;

- (NSString*)playHavenToken
{
    //return @"5c9a7e2f94c642f59eb3c47bc1394488";
    return PLAYHAVEN_TOKEN;
}

#pragma mark - @property (strong, nonatomic, readonly) NSString *playHavenSecret;

- (NSString*)playHavenSecret
{
    return PLAYHAVEN_SECRET;//@"5a623f521594470bbde5b3aaa8a0c7d4";
}


#pragma mark - Reachability

- (void)applicationWillEnterForeground: (NSNotification *)notification
{
    [self registerForNetworkReachabilityNotifications];
}

- (void)applicationDidEnterBackground: (NSNotification *)notification
{
    [self unsubscribeFromNetworkReachabilityNotifications];
}


- (void)registerForNetworkReachabilityNotifications
{
    debug(@"register for reachability");
    [self.hostReach startNotifier];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}


- (void)unsubscribeFromNetworkReachabilityNotifications
{
    debug(@"unsubscribe from reachability");
    [self.hostReach stopNotifier];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (BOOL)isNetworkReachable
{
    return [self.hostReach isReachable];
}


- (void)reachabilityChanged:(NSNotification *)note
{
    debug(@"REACHABILITY changed is network reachable: %d", [self isNetworkReachable]);

#ifndef MB_LUXURY
    if ( [self isNetworkReachable] ) {
        [self checkStoreKitProducts];
    }
#endif
    
}


- (void)checkStoreKitProducts
{
    if ( [self.paymentManager.products count] != [[self productIDs] count] ) {
        debug(@"Requesting products from Apple");
        [self.paymentManager requestProductsFromApple: [self productIDs]];
    }
}


@end
