//
//  AppDelegate.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/17/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "AppDelegate.h"
#import "StartPageViewController.h"
#import "FacebookManager.h"
#import "iRate.h"
#import "Flurry.h"
#import "FlurryAds.h"
#import "DataModel.h"
#import "Mobclix.h"
#import "PictureViewController.h"
#import "NavController.h"
#import "TapjoyConnect.h"

#import "vunglepub.h"
#import "PlayHavenSDK.h"

#if !defined(DEBUG) && !NAG_SCREENS_ON
    #error "set NAG_SCREENS_ON = 1"
#endif

#define NAG_ON_START_UP @"NAG_ON_START_UP"


void exceptionHandler(NSException *exception);

@interface AppDelegate ()

@property (nonatomic, strong) StartPageViewController *startPageViewController;
@property (nonatomic, strong) NavController *navController;
@property (nonatomic, strong) NSMutableArray *jokesArray;
@property (nonatomic, strong) NSURL *iTunesURL;

- (void)logException: (NSException*)exception;

- (void)loadNotificationsJokes;
- (NSString*)randomJoke;
- (void)scheduleNotificationWithTimeInterval: (NSTimeInterval)timeInterval text: (NSString*)text;
- (void)scheduleNotifications;

@end


@implementation AppDelegate

@synthesize window = __window;
@synthesize startPageViewController = _startPageViewController;
@synthesize navController = _navController;
@synthesize jokesArray = _jokesArray;
@synthesize iTunesURL = _iTunesURL;

- (BOOL)application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions
{
    debug(@"DID finish LOADING");
    NSSetUncaughtExceptionHandler(exceptionHandler);
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor blackColor];
    
    self.startPageViewController =
    [[StartPageViewController alloc] initWithNibName: nil bundle: nil];
    
    self.navController =
    [[NavController alloc] initWithRootViewController: self.startPageViewController];
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    // start Flurry
#if MB_LUXURY
  //  [Flurry startSession: @"98PS4G4822MDYPGJ8FKQ"];
#else
    //[Flurry startSession: FLURRY_SESSION_ID];//@"9U7F7RLY1NDWQEQMUX35";
    //[FlurryAds initialize: self.window.rootViewController];
#endif
    
    //[Flurry logAllPageViews: self.navController];

#if NAG_SCREENS_ON
    
   // [self vungleStart];
    
#endif
    
//#if NAG_SCREENS_ON
//    
//    // Configure ChartBoost
//    Chartboost *cb = [Chartboost sharedChartboost];
//    
//#if MB_LUXURY
//    cb.appId = @"50f8129017ba474a09000001";
//    cb.appSignature = @"052b52d11ba5857585ca37201b9a2adb7d7f04ff";
//#else
//    cb.appId = @"4f9aa47cf876590d6b000007";
//    cb.appSignature = @"e1dc90cc81fd50156243d362d4eb72b8a8d1a3c1";
//#endif
//
//    cb.delegate = self;
//    cb.orientation = UIInterfaceOrientationPortrait;
//    
//    // Notify the beginning of a user session
//    [cb startSession];
//    
//    [cb showInterstitial: NAG_ON_START_UP];
//    
//    // Cache an interstitial
//    [cb cacheInterstitial: @"NAG_AFTER_SHARE_TO_FB"];
//    [cb cacheInterstitial: @"NAG_AFTER_SHARE_TO_TW"];
//    [cb cacheInterstitial: @"NAG_AFTER_SHARE_BY_EMAIL"];
//    [cb cacheInterstitial: @"NAG_AFTER_SAVE_TO_ALBUM"];
//    [cb cacheInterstitial: @"NAG_AFTER_SHARE_TO_BN"];
//    
//    [cb cacheMoreApps];
//    
//#endif
    
    // configure iRate
    iRate *rate = [iRate sharedInstance];

#if MB_LUXURY
    rate.appStoreID = 594894839;
#else
    rate.appStoreID = APPSTORE_RATE_ID;//499793669;
#endif
    
    rate.debug = NO;
    rate.remindButtonLabel = nil;
    rate.message = NSLocalizedString(@"Are you happy with this app?", @"iRate alert text");
    rate.rateButtonLabel = NSLocalizedString(@"Yes!", @"iRate alert - YES");
    rate.cancelButtonLabel = NSLocalizedString(@"No :(", @"iRate alert - NO");
    rate.applicationName = NSLocalizedString(@"Mustache Bash", @"App name in iRate Alert");
    
    rate.daysUntilPrompt = 1.0f/24.0f/60.0f/2.0f; // 30 secs
    
    rate.usesUntilPrompt = 3;
    rate.eventsUntilPrompt = 3;
    
    [DataModel sharedInstance];
    [FacebookManager sharedInstance];
    
    [DataModel sharedInstance].shouldShowInterstitial = YES;

    
    // MobiClix
#if MB_LUXURY
   // [Mobclix startWithApplicationId: @"dfab31c4-e3cf-41d5-8429-1934ef17d003"];
#else
    //[Mobclix startWithApplicationId: MOBCLIX_APPLICATION_ID];//@"46B44DFB-7F48-4B07-B615-C6C324C88963"];
#endif
    
    
#if NAG_SCREENS_ON
    
    // RevMob
    //[RevMobAds startSessionWithAppID:[DataModel sharedInstance].revMobFullscreenAppId];
        
    //RevMobFullscreen *revMobFullScreen = [[RevMobAds session] fullscreenWithPlacementId: @"5156fc9b26a2bb1200000053"];
   // RevMobFullscreen *revMobFullScreen = [[RevMobAds session] fullscreenWithPlacementId: REVMOB_FULLSCREEN_PLACEMENT_ID];//@"515eedc64979bf0d00000001"];
//    revMobFullScreen.delegate = self;
   // [revMobFullScreen showAd];
    
#endif
    
#if MB_LUXURY
    
    // TapjoyConnect
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectSuccess:) name:TJC_CONNECT_SUCCESS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectFail:) name:TJC_CONNECT_FAILED object:nil];
	
	//[TapjoyConnect requestTapjoyConnect:@"b49e8e4d-4106-4c57-aae8-0737ee74b4aa" secretKey:@"SmgFGkMrrdpGfavbD8VZ"];
    
#endif
    
    
#if NAG_SCREENS_ON
    
   // [[PHPublisherOpenRequest requestForApp: [DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret] send];
    
    //[[PHPublisherContentRequest requestForApp:[DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: NAG_ON_START_UP delegate: self] send];
    
  //  [self preloadPlayHaven];
    
#endif
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    debug(@"APP will resign active");
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    debug(@"APP did ENTER background");
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    debug(@"APP WILL enter FOREGROUND");

#if NAG_SCREENS_ON
    
    debug(@"showing NAG_ON_START_UP");
    if ([DataModel sharedInstance].shouldShowInterstitial){
        
       // [[PHPublisherOpenRequest requestForApp: [DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret] send];

        
//        [[Chartboost sharedChartboost] startSession];
//        [[Chartboost sharedChartboost] performSelector: @selector(showInterstitial:)  withObject: NAG_ON_START_UP afterDelay: 0.1];
        
        // RevMob
        //RevMobFullscreen *revMobFullScreen = [[RevMobAds session] fullscreenWithPlacementId: @"5156fc9b26a2bb1200000053"];
       // RevMobFullscreen *revMobFullScreen = [[RevMobAds session] fullscreenWithPlacementId:REVMOB_FULLSCREEN_PLACEMENT_ID]; //@"515eedc64979bf0d00000001"];
        //revMobFullScreen.delegate = self;
        //[revMobFullScreen showAd];
        
        // PlayHaven
        //[[PHPublisherContentRequest requestForApp: [DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: NAG_ON_START_UP delegate: self] send];
        
        //[self preloadPlayHaven];
    }
    else {
        //[DataModel sharedInstance].shouldShowInterstitial = YES;
    }
    
#endif
    
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    debug(@"APP did become ACTIVE");
    
    //[[FacebookManager sharedInstance].facebook extendAccessTokenIfNeeded];
    //[self scheduleNotifications];
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - Interstitials support

-(void)vungleStart
{
    VGUserData*  data  = [VGUserData defaultUserData];
    NSString*    appID = APP_ID;//@"499793669";
    
    // set up config data
    data.adOrientation   = VGAdOrientationPortrait;
    
    // start vungle publisher library
   // [VGVunglePub startWithPubAppID:appID userData:data];
    //[VGVunglePub logToStdout: NO];
}


- (void)preloadPlayHaven
{
  //  [[PHPublisherContentRequest requestForApp:[DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: PLAYHAVEN_PLACEMENT1 delegate: (AppDelegate*)[UIApplication sharedApplication].delegate] preload];
    
    //[[PHPublisherContentRequest requestForApp: [DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: PLAYHAVEN_PLACEMENT2 delegate: (AppDelegate*)[UIApplication sharedApplication].delegate] preload];
}


// Called when an interstitial has been received, before it is presented on screen
// Return NO if showing an interstitial is currently inappropriate, for example if the user has entered the main game mode
- (BOOL)shouldDisplayInterstitial:(NSString *)location
{
    debug(@"should display interstitial: %@", location);
    debug(@"self.navController.topViewController: %@", self.navController.topViewController);
    
    if ( [location caseInsensitiveCompare: NAG_ON_START_UP]) {
        [self.startPageViewController hideSplash];
        
        if ( [self.navController.topViewController isKindOfClass: [StartPageViewController class]]
            && self.startPageViewController.isCameraShown ) {
            return NO;
        }
        else if ( [self.navController.topViewController isKindOfClass: [PictureViewController class]] ) {
            return NO;
        }
        else {
            return YES;
        }
    }
    else {
        return YES;
    }
    
    //    if ( [self.navController.topViewController isKindOfClass: [StartPageViewController class]]
    //        && self.startPageViewController.isCameraShown ) {
    //
    //        return NO;
    //    }
    //    else if ( ![DataModel sharedInstance].canShowSocialShareNagScreens
    //             && ![self.navController.topViewController isKindOfClass: [StartPageViewController class]] ) {
    //
    //        return NO;
    //    }
    //    else {
    //
    //        [self.startPageViewController hideSplash];
    //        return YES;
    //    }
}

#pragma mark - Local Notifications

- (void)loadNotificationsJokes
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource: @"Jokes.txt"  ofType: nil];
    NSError *error = nil;
    NSString *jokesString = [NSString stringWithContentsOfFile: filePath encoding: NSUTF8StringEncoding error: &error];
    
    if ( nil != error ) {
        error(@"error reading file '%@': %@", filePath, error);
    }
    
    self.jokesArray = [NSMutableArray arrayWithArray: [jokesString componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]]];
}


- (NSString*)randomJoke
{
    int randomIndex = arc4random() % [self.jokesArray count];
    NSString *joke = [self.jokesArray objectAtIndex: randomIndex];
    [self.jokesArray removeObjectAtIndex: randomIndex];
    
    return joke;
}


- (void)scheduleNotificationWithTimeInterval: (NSTimeInterval)timeInterval text: (NSString*)text
{
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    
    if ( nil == text ) {
        text = @"We've missed you!";
    }
    
    notif.fireDate = [NSDate dateWithTimeIntervalSinceNow: timeInterval];
    notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.alertBody = text;
    notif.alertAction = @"PLAY";
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification: notif];
}


- (void)scheduleNotifications
{
	//LOCAL NOTIFICATIONS
    
    //Cancel all previous Local Notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self loadNotificationsJokes];
    
    //Set new Local Notifications
    Class cls = NSClassFromString(@"UILocalNotification");
    if (cls != nil) {
        
        debug(@"scheduling local notification");
        
        CGFloat oneDay = 60.0f*60.0f*24.0f;
        
        [self scheduleNotificationWithTimeInterval: oneDay * 3 text: [self randomJoke]];
        [self scheduleNotificationWithTimeInterval: oneDay * 7  text: [self randomJoke]];
        [self scheduleNotificationWithTimeInterval: oneDay * 15  text: [self randomJoke]];
        [self scheduleNotificationWithTimeInterval: oneDay * 30  text: [self randomJoke]];
        [self scheduleNotificationWithTimeInterval: oneDay * 60  text: [self randomJoke]];
    }
}


#pragma mark - External URLS opening

// Pre 4.2 support
- (BOOL)application: (UIApplication*)application handleOpenURL: (NSURL*)url {
    
  //  return [[FacebookManager sharedInstance].facebook handleOpenURL: url];
    return [FBSession.activeSession handleOpenURL:url];
}


// For 4.2+ support
- (BOOL)application: (UIApplication*)application
            openURL: (NSURL*)url
  sourceApplication: (NSString*)sourceApplication
         annotation: (id)annotation {
     return [FBSession.activeSession handleOpenURL:url];
 //   return [[FacebookManager sharedInstance].facebook handleOpenURL: url];
}


// Process a URL to something iPhone can handle
- (void)openReferralURL:(NSURL *)referralURL
{
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:referralURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    [conn start];
}

// Save the most recent URL in case multiple redirects occur
// "iTunesURL" is an NSURL property in your class declaration
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response) {
        NSMutableURLRequest *r = [request mutableCopy]; // original request
        [r setURL: [request URL]];
        
        self.iTunesURL = [r URL];
        if ([self.iTunesURL.host hasSuffix:@"itunes.apple.com"]) {
            [[UIApplication sharedApplication] openURL:self.iTunesURL];
        }
        
        return r;
    }
    else {
        return request;
    }
    
}


#pragma mark - FlurryAdDelegate

// implement to do something when the data is available
// currently just output debug message
- (void)dataAvailable {
    NSLog(@"Flurry data is available");
}

// implement to do something when the data is unavailable
// currently just output debug message
- (void)dataUnavailable {
    NSLog(@"Flurry data is unavailable");
}

// implement to do something when the canvas will open
// currently just output debug message
- (void)canvasWillDisplay:(NSString *)hook {
    NSLog(@"Flurry canvas will display:%@", hook);
}

// implement to do something when the canvas will close
// currently just output debug message
- (void)canvasWillClose {
    NSLog(@"Flurry canvas will close");
}

// implement to do something when the takeover will open
// currently just output debug message
- (void)takeoverWillDisplay:(NSString *)hook {
    NSLog(@"Flurry takeover will display:%@", hook);
}

// implement to do something when the takeover will close
// currently just output debug message
- (void)takeoverWillClose {
    NSLog(@"Flurry takeover will close");
}


#pragma mark - ChartboostDelegate <NSObject>

// Called before requesting an interstitial from the back-end
- (BOOL)shouldRequestInterstitial:(NSString *)location
{
    debug(@"should request Interstitial: %@", location);
    return YES;
}


// Called when an interstitial has failed to come back from the server
// This may be due to network connection or that no interstitial is available for that user
- (void)didFailToLoadInterstitial:(NSString *)location
{
    debug(@"failed loading Interstitial: %@", location);
    
    self.startPageViewController.shouldShowSplashLoading = NO;
    [self.startPageViewController hideSplash];
}

// Called when the user dismisses the interstitial
//- (void)didDismissInterstitial:(NSString *)location;

// Same as above, but only called when dismissed for a close
- (void)didCloseInterstitial:(NSString *)location
{
    debug(@"did close: %@, cache again!", location);
    [[Chartboost sharedChartboost] cacheInterstitial: location];
}

// Same as above, but only called when dismissed for a click
//- (void)didClickInterstitial:(NSString *)location;


// Called when an interstitial has been received and cached.
- (void)didCacheInterstitial:(NSString *)location
{
    debug(@"didCache: %@", location);
}


- (BOOL)shouldRequestInterstitialsInFirstSession
{
    return NO;
}


// Called when an more apps page has been received, before it is presented on screen
// Return NO if showing the more apps page is currently inappropriate
- (BOOL)shouldDisplayMoreApps
{
    debug(@"shouldDisplayMoreApps ?");
    return YES;
}


// Called before requesting the more apps view from the back-end
// Return NO if when showing the loading view is not the desired user experience
- (BOOL)shouldDisplayLoadingViewForMoreApps
{
    debug(@"shouldDisplayLoadingViewForMoreApps ?");
    return YES;
}

// Called when the user dismisses the more apps view
//- (void)didDismissMoreApps;

// Same as above, but only called when dismissed for a close
- (void)didCloseMoreApps
{
    [[Chartboost sharedChartboost] cacheMoreApps];
}

// Same as above, but only called when dismissed for a click
- (void)didClickMoreApps
{
    debug(@"DID click more apps");
}

// Called when a more apps page has failed to come back from the server
- (void)didFailToLoadMoreApps
{
    error(@"didFailToLoadMoreApps");
}

// Called when the More Apps page has been received and cached
- (void)didCacheMoreApps
{
    debug(@"didCacheMoreApps");
}



#pragma mark - RevMobAdsDelegate


- (void)revmobAdDidReceive
{
    debug(@"did receive RevMob Ad");
}


- (void)revmobAdDidFailWithError:(NSError *)error
{
    error(@"did fail to receive RevMob Ad with error: %@", error);
}


- (void)revmobUserClickedInTheCloseButton
{
    debug(@"user closed RevMob AD");
}


- (void)revmobUserClickedInTheAd
{
    debug(@"user clicked in RevMob AD");
}


#pragma mark TapjoyConnect Observer methods

-(void) tjcConnectSuccess:(NSNotification*)notifyObj
{
	debug(@"Tapjoy Connect Succeeded");
}

-(void) tjcConnectFail:(NSNotification*)notifyObj
{
	debug(@"Tapjoy Connect Failed");
}


#pragma mark - PHPublisherContentRequestDelegate

-(void)requestWillGetContent:(PHPublisherContentRequest *)request{
    debug(@"PH Delegate - Getting content for placement: %@", request.placement);
}

-(void)requestDidGetContent:(PHPublisherContentRequest *)request{
    debug(@"PH Delegate - Got content for placement: %@", request.placement);
}

-(void)request:(PHPublisherContentRequest *)request contentWillDisplay:(PHContent *)content{
    debug(@"PH Delegate - Preparing to display content: %@",content);
}

-(void)request:(PHPublisherContentRequest *)request contentDidDisplay:(PHContent *)content{
    
    debug(@"PH Delegate - Displayed content: %@",content);
}

-(void)request:(PHPublisherContentRequest *)request contentDidDismissWithType:(PHPublisherContentDismissType *)type{
    debug(@"PH Delegate - [OK] User dismissed request: %@ of type %@",request, type);
    
    [[PHPublisherContentRequest requestForApp: [DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: request.placement delegate: self] preload];
}

-(void)request:(PHPublisherContentRequest *)request didFailWithError:(NSError *)error{
    error(@"PH Delegate - failed with error: %@", error);
}


#pragma mark - Exception Handling

void exceptionHandler(NSException *exception)
{
    [Flurry logError: @"Uncaught exception" message: @"Crash!" exception: exception];
    
#if DEBUG    
	[(AppDelegate*)[UIApplication sharedApplication].delegate logException: exception];
#endif
}


- (void)logException:(NSException*)exception
{
	NSArray *addresses = [exception callStackReturnAddresses];
	NSString *logging=[NSString stringWithFormat:@"********************\nException"];
	UIDevice *d=[UIDevice currentDevice];
	NSDictionary *info=[[NSBundle mainBundle]infoDictionary];
	NSString *locale = [[NSLocale currentLocale] localeIdentifier];
	NSString *version = [info objectForKey:@"CFBundleVersion"];
	
    logging=[logging stringByAppendingFormat:@"\n*********\nModel:\t\t%@\nLocalized:\t%@\nSystemName:\t%@\nSystemVersion:\t%@\nVersion:\t%@\nLocale:\t\t%@",d.model,d.localizedModel,d.systemName,d.systemVersion,version,locale];
    
	logging=[logging stringByAppendingFormat:@"\n*********\nName:\t\t%@\nReason:\t\t%@\nUserInfo:\n",exception.name,exception.reason];
	
	//Append the dictionary
	for(NSObject *key in [exception.userInfo allKeys])
	{
		logging=[logging stringByAppendingFormat:@"\nuserInfo: %@ => %@\n",key,[exception.userInfo objectForKey:key]];
	}
	
    if (addresses)
	{
		NSString *command = @"*********\nGet stack trace with (leave app running): /usr/bin/atos -p ";
        NSString *pid = [[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] stringValue];
		
		command = [command stringByAppendingString:pid];
		command = [command stringByAppendingString:@" "];
		
		for(NSNumber *number in addresses)
		{
			command = [command stringByAppendingFormat:@" %u", [number intValue]];
		}
		
		logging=[logging stringByAppendingString:command];
		debug(@"%@", logging);
    }
	else
	{
		logging=[logging stringByAppendingString:@"*********\nNo stack trace available"];
        debug(@"%@", logging);
    }	
}



@end
