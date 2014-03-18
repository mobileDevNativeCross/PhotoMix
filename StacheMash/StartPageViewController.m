//
//  StartPageViewController.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/17/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//


#import <UIKit/UIImagePickerController.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "AppDelegate.h"
#import "StartPageViewController.h"
#import "PictureViewController.h"
#import "InfoViewController.h"
#import "GUIHelper.h"
#import "FacebookManager.h"
#import "ASIHTTPRequest.h"

#import "iRate.h"

#import "Flurry.h"

#import "Chartboost.h"

static NSTimeInterval kTimerTimeout = 7.0;


@interface StartPageViewController ()
{
    EFacebookAPICall _currentAPICall;
    UIImagePickerController *picker;
    BOOL cameraFront;
    UIButton *toggleCamera;
    UIButton *t;
    UIButton *tvc;
    UIButton *takepicture;
    UIButton *usePhoto;
}

@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIButton *coolStuffButton;
@property (strong, nonatomic) UIButton *takePictureButton;
@property (strong, nonatomic) UIButton *openLibraryButton;

@property (strong, nonatomic) UIImageView *splashScreen;
@property (strong, nonatomic) NSTimer *timeoutTimer;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL showingFriendPicker;

@property (retain, nonatomic) PHNotificationView *notificationView;

//Quang ipad
@property (retain, nonatomic) UIPopoverController *popover;

//End

// FB friend profile picture hud
@property (nonatomic, strong) MBProgressHUD *hud;


- (void)closeModalViews: (NSNotification*)info;

- (void)goInfo: (id)sender;
- (void)goCoolStuff: (id)sender;
- (void)goToStache: (id)sender;

- (void)pickImageFromLibrary: (id)sender;
- (void)takePicture: (id)sender;
- (void)openImagePickerWithSourceType: (UIImagePickerControllerSourceType)sourceType;

@end



@implementation StartPageViewController

@synthesize infoButton = _infoButton;
@synthesize coolStuffButton = _coolStuffButton;
@synthesize takePictureButton = _takePictureButton;
@synthesize openLibraryButton = _openLibraryButton;
@synthesize splashScreen = _splashScreen;
@synthesize shouldShowSplashLoading = __shouldShowSplashLoading;
@synthesize timeoutTimer = _timeoutTimer;
@synthesize isCameraShown = __isCameraShown;

@synthesize friendPickerController = _friendPickerController;
@synthesize searchBar = _searchBar;
@synthesize searchText = _searchText;
@synthesize showingFriendPicker = _showingFriendPicker;
@synthesize notificationView = _notificationView;

@synthesize hud = _hud;
//Quang ipad

@synthesize popover = _popover;

//end



#pragma mark - Initialization


- (id)initWithNibName: (NSString*)nibNameOrNil bundle: (NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if ( self ) {
        self.wantsFullScreenLayout = YES;
        self.shouldShowSplashLoading = YES;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].applicationFrame];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.isCameraShown = NO;
    
    // BG image
    UIImageView *bgImageVIew = [[UIImageView alloc] initWithFrame: self.view.bounds];
    
#if MB_LUXURY
    //iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        bgImageVIew.image = [UIImage imageNamed: @"MBLuxury-home-568h.png"];
    }
    else if ( [GUIHelper isPhone5] ) {
        bgImageVIew.image = [UIImage imageNamed: @"MBLuxury-home-568h.png"];
    }
    else {
        bgImageVIew.image = [UIImage imageNamed: @"MBLuxury-home.png"];
    }
#else
    //iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if ([GUIHelper isIPadretina])
            bgImageVIew.image = [UIImage imageNamed: @"splash-bg-ipad@2x~ipad.png"];
        else
            bgImageVIew.image = [UIImage imageNamed: @"splash-bg-ipad.png"];
    }
    else if ( [GUIHelper isPhone5] ) {
        bgImageVIew.image = [UIImage imageNamed: @"splash-bg-568h.png"];
    }
    else {
        bgImageVIew.image = [UIImage imageNamed: @"splash-bg.png"];
    }
#endif
    
    [self.view addSubview: bgImageVIew];
    
    // INFO button
    UIImage *infoButtonImage, *infoButtonImagePressed;
    // iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        infoButtonImage		= [UIImage imageNamed: @"btn-i-ipad.png"];
        infoButtonImagePressed	= [UIImage imageNamed: @"btn-i-ipad-press.png"];
    }else{
        infoButtonImage		= [UIImage imageNamed: @"btn-i.png"];
	    infoButtonImagePressed	= [UIImage imageNamed: @"btn-i-press.png"];
    }
	
	self.infoButton = [UIButton buttonWithType: UIButtonTypeCustom];
	[self.infoButton setBackgroundImage: infoButtonImage forState: UIControlStateNormal];
	[self.infoButton setBackgroundImage: infoButtonImagePressed forState: UIControlStateHighlighted];
    //iPad support
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.infoButton.frame= CGRectMake(122, 90,  infoButtonImage.size.width,   infoButtonImage.size.height);
    }
    else
    {
        self.infoButton.frame= CGRectMake(35, 45, infoButtonImage.size.width, infoButtonImage.size.height);
    }
    
	//self.infoButton.frame= CGRectMake(35, 45, infoButtonImage.size.width, infoButtonImage.size.height);
	
	[self.infoButton addTarget: self action: @selector(goInfo:) forControlEvents: UIControlEventTouchUpInside];
    //  [self.view addSubview: self.infoButton];
    
    // COOL STUFF button
    UIImage *coolButtonImage, *coolButtonImagePressed;
    // iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        //coolButtonImage		= [UIImage imageNamed: @"btn-more-ipad.png"];
        //coolButtonImagePressed	= [UIImage imageNamed: @"btn-more-ipad-press.png"];
    }else{
        // coolButtonImage		= [UIImage imageNamed: @"btn-more.png"];
	    //coolButtonImagePressed = [UIImage imageNamed: @"btn-more-press.png"];
    }
    self.coolStuffButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.coolStuffButton setBackgroundImage: coolButtonImage forState: UIControlStateNormal];
	[self.coolStuffButton setBackgroundImage: coolButtonImagePressed forState: UIControlStateHighlighted];
    
    //iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.coolStuffButton.frame= CGRectMake(510, 90, coolButtonImage.size.width, coolButtonImage.size.height);
    }
    else
    {
        self.coolStuffButton.frame = CGRectMake(225, 45, coolButtonImage.size.width,  coolButtonImage.size.height);
    }
    
    [self.coolStuffButton addTarget: self
                             action: @selector(goCoolStuff:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    //   [self.view addSubview: self.coolStuffButton];
    
    self.notificationView = [[PHNotificationView alloc] initWithApp:  [DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: PLAYHAVEN_PLACEMENT1];
    self.notificationView.center = CGPointMake(50, 30);
    //  [self.coolStuffButton addSubview: self.notificationView];
    
    CGFloat buttonsOriginY = 325;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        buttonsOriginY += 300;
    }
    else
    {
        if ( [GUIHelper isPhone5] ) {
            buttonsOriginY += 33;
        }
    }
    
    // TAKE PICTURE button
    UIImage *takePictureButtonImage, *takePictureButtonImagePressed;
    // iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        takePictureButtonImage		= [UIImage imageNamed: @"btn-take-picture-ipad.png"];
        takePictureButtonImagePressed	= [UIImage imageNamed: @"btn-take-picture-ipad-press.png"];
    }else{
        
        takePictureButtonImage         = [UIImage imageNamed: @"btn-take-picture.png"];
        takePictureButtonImagePressed  = [UIImage imageNamed: @"btn-take-picture-press.png"];
    }
    self.takePictureButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.takePictureButton setBackgroundImage: takePictureButtonImage forState: UIControlStateNormal];
	[self.takePictureButton setBackgroundImage: takePictureButtonImagePressed forState: UIControlStateHighlighted];
    
    //iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.takePictureButton.frame = CGRectMake(378, buttonsOriginY,
                                                  takePictureButtonImage.size.width,
                                                  takePictureButtonImage.size.height);
    }
    else
    {
        self.takePictureButton.frame = CGRectMake(160, buttonsOriginY,
                                                  takePictureButtonImage.size.width,
                                                  takePictureButtonImage.size.height);
    }
    
    [self.takePictureButton addTarget: self
                               action: @selector(takePicture:)
                     forControlEvents: UIControlEventTouchUpInside];
    
    //[self.view addSubview: self.takePictureButton];
    
    // OPEN LIBRARY button
    UIImage *openLibraryButtonImage, *openLibraryButtonImagePressed;
    // iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        openLibraryButtonImage		= [UIImage imageNamed: @"btn-open-picture-ipad.png"];
        openLibraryButtonImagePressed	= [UIImage imageNamed: @"btn-open-picture-ipad-press.png"];
    }else{
        
        openLibraryButtonImage		= [UIImage imageNamed: @"btn-open-picture.png"];
	    openLibraryButtonImagePressed = [UIImage imageNamed: @"btn-open-picture-press.png"];
    }
    self.openLibraryButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.openLibraryButton setBackgroundImage: openLibraryButtonImage forState: UIControlStateNormal];
	[self.openLibraryButton setBackgroundImage: openLibraryButtonImagePressed forState: UIControlStateHighlighted];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.openLibraryButton.frame = CGRectMake(40, buttonsOriginY,
                                                  openLibraryButtonImage.size.width,
                                                  openLibraryButtonImage.size.height);
    }
    else
    {
        self.openLibraryButton.frame = CGRectMake(3, buttonsOriginY,
                                                  openLibraryButtonImage.size.width,
                                                  openLibraryButtonImage.size.height);
    }
    //    self.openLibraryButton.frame = CGRectMake(3, buttonsOriginY,
    //                                                                                                openLibraryButtonImage.size.width,
    //                                                                                              openLibraryButtonImage.size.height);
    
    [self.openLibraryButton addTarget: self
                               action: @selector(pickImageFromLibrary:)
                     forControlEvents: UIControlEventTouchUpInside];
    
    // [self.view addSubview: self.openLibraryButton];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(closeModalViews:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    // FB PICTURE button
    UIImage *fbPictureButtonImage, *fbPictureButtonImagePressed;
    // iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        fbPictureButtonImage		= [UIImage imageNamed: @"btn-pickfriend-ipad.png"];
        fbPictureButtonImagePressed	= [UIImage imageNamed: @"btn-pickfriend-ipad-press.png"];
    }else{
        fbPictureButtonImage         = [UIImage imageNamed: @"btn-pickfriend.png"];
        fbPictureButtonImagePressed  = [UIImage imageNamed: @"btn-pickfriend-press.png"];
    }
    UIButton *fbPictureButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [fbPictureButton setBackgroundImage: fbPictureButtonImage forState: UIControlStateNormal];
	[fbPictureButton setBackgroundImage: fbPictureButtonImagePressed forState: UIControlStateHighlighted];
    
    fbPictureButton.frame = CGRectMake(0.5 * (self.view.frame.size.width - fbPictureButtonImage.size.width), [GUIHelper getBottomYForView:self.takePictureButton] + ([GUIHelper isPhone5]? 30 : 5),
                                       fbPictureButtonImage.size.width,
                                       fbPictureButtonImage.size.height);
    [fbPictureButton addTarget: self
                        action: @selector(getFBPicture:)
              forControlEvents: UIControlEventTouchUpInside];
    
    //[self.view addSubview: fbPictureButton];
    
    //    // HAPPY BIRTHDAY button
    //    UIButton *happyBirthdayButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    //    [happyBirthdayButton setTitle: @"Happy Birthday" forState: UIControlStateNormal];
    //    happyBirthdayButton.frame = CGRectMake(0, 0, 200, 50);
    //    happyBirthdayButton.center = CGPointMake(160, 430);
    //    [happyBirthdayButton addTarget: self action: @selector(happyBirhthday:) forControlEvents: UIControlEventTouchUpInside];
    //
    //    [self.view addSubview: happyBirthdayButton];
    
    
    // Start screen postponement
#if NAG_SCREENS_ON
    
    if ( self.shouldShowSplashLoading ) {
        debug(@"adding SPLASH loading");
        
        UIImage *splashImage;
        CGFloat spinnerFactor;
#if MB_LUXURY
        // iPad support
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            splashImage = [UIImage imageNamed: @"MBLuxury-default-Portrait~ipad.png"];
        }
        else if ( [GUIHelper isPhone5] ) {
            splashImage = [UIImage imageNamed: @"MBLuxury-default-568h@2x.png"];
        }
        else {
            splashImage = [UIImage imageNamed: @"MBLuxury-default.png"];
        }
        
        spinnerFactor = 0.85;
#else
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            splashImage = [UIImage imageNamed: @"Default-Portrait~ipad.png"];
        }
        
        else if ( [GUIHelper isPhone5] ) {
            splashImage = [UIImage imageNamed: @"Default-568h@2x.png"];
            spinnerFactor = 0.85;
        }
        else {
            splashImage = [UIImage imageNamed: @"Default.png"];
            spinnerFactor = 0.9;
        }
#endif
        
        self.splashScreen = [[UIImageView alloc] initWithFrame: self.view.bounds];
        self.splashScreen.image = splashImage;//showing splash
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        
        spinner.center = CGPointMake(0.5 * self.splashScreen.frame.size.width, spinnerFactor * self.splashScreen.frame.size.height);
        [spinner startAnimating];
        [self.splashScreen addSubview: spinner];
        
        [self.view addSubview: self.splashScreen];
        
        debug(@"setting timer to %f secs", kTimerTimeout);
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval: kTimerTimeout
                                                             target: self
                                                           selector: @selector(timeoutTimerFired:)
                                                           userInfo: nil
                                                            repeats: NO];
    }
    
#endif
    [self openImagePickerWithSourceType: UIImagePickerControllerSourceTypeCamera];
   
   

    
    usePhoto=[UIButton buttonWithType:UIButtonTypeCustom];
    [usePhoto setTitle:@"Use Photo" forState:UIControlStateNormal];
    usePhoto.frame  = CGRectMake((self.view.frame.size.width-120)/2, 505, 120, 40);
    [usePhoto addTarget:self action:@selector(usePhoto:) forControlEvents:UIControlEventTouchUpInside];
    // [picker.view addSubview:usePhoto];
    //  usePhoto.hidden = YES;
    
}
-(void)usePhoto:(id)sender{
    //[picker dismissViewControllerAnimated:NO completion:NULL];
}
-(void)toggleCamera:(id)sender{
    if(cameraFront){
        [picker dismissViewControllerAnimated:NO completion:NULL];
        picker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
        
        [self presentViewController:picker animated:NO completion:NULL ];
        
        cameraFront = 0;
    }
    else{
        [picker dismissViewControllerAnimated:NO completion:NULL];
        picker.cameraDevice=UIImagePickerControllerCameraDeviceFront;
        [self presentViewController:picker animated:NO completion:NULL ];
        cameraFront = 1;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    debug(@"START: did unload");
    
    self.infoButton = nil;
    self.coolStuffButton = nil;
    self.takePictureButton = nil;
    self.openLibraryButton = nil;
    self.notificationView = nil;
}


- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    [[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation: UIStatusBarAnimationNone];
    
    //[self.notificationView test];
    [self.notificationView refresh];
}


- (void)viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.showingFriendPicker) {
        [self addSearchBarToFriendPickerView];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)closeModalViews: (NSNotification*)info
{
    if ( nil != self.modalViewController &&
        [self.modalViewController isKindOfClass: [UIImagePickerController class]] ) {
        
        [self.modalViewController dismissModalViewControllerAnimated: NO];
    }
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


#pragma mark - Public

- (void)timeoutTimerFired:(NSTimer*)theTimer
{
    if ( self.timeoutTimer == theTimer ) {
        debug(@"timeoutTimer timer fired");
        [self hideSplash];
    }
    else {
        error(@"unknown timer fired");
    }
}


- (void)hideSplash
{
    if ( nil != self.timeoutTimer ) {
        debug(@"invalidating timer");
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    }
    
    if ( nil != self.splashScreen ) {
        debug(@"hiding Splash");
        [self.splashScreen removeFromSuperview];
        self.splashScreen = nil;
    }
}


#pragma mark - FB Layout

- (void)addSearchBarToFriendPickerView
{
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}

#pragma mark - Actions

- (void)goInfo: (id)sender
{
    debug(@"INFO pressed");
    
    InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName: nil bundle: nil];
    infoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    NavController *navController = [[NavController alloc] initWithRootViewController: infoViewController];
    navController.navigationBarHidden = YES;
    
    
    [self.navigationController presentModalViewController: navController animated: YES];
}


- (void)goCoolStuff: (id)sender
{
    debug(@"COOL STUFF pressed");
    [Flurry logEvent: @"OpenCoolStuff"];
    
    if( [FacebookManager sharedInstance].isFacebookReachable ) {
        
        [[PHPublisherContentRequest requestForApp:[DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: PLAYHAVEN_PLACEMENT1 delegate: (AppDelegate*)[UIApplication sharedApplication].delegate] send];
        
        //        [[Chartboost sharedChartboost] showMoreApps];
        
        //        [FlurryAppCircle openCatalog: @"COOL_STUFF_CATALOG_HOOK"
        //                   canvasOrientation: @"portrait"
        //                      canvasAnimated: YES];
        //        [FlurryAppCircle
        //         openTakeover:@"COOL_STUFF_CATALOG_HOOK"
        //         orientation:@"portrait"
        //         rewardImage:nil
        //         rewardMessage:nil
        //         userCookies:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString( @"Error", @"" )
                                                        message: NSLocalizedString( @"Internet connection required to see More apps", @"Alert title" )
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString( @"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
}



- (void)goToStache: (id)sender
{
    PictureViewController *pictureViewController = [[PictureViewController alloc] initWithNibName: nil bundle: nil];
    pictureViewController.sourceImage = [UIImage imageNamed: @"sri_kobzar.jpg"];
    [self.navigationController pushViewController: pictureViewController animated: YES];
}


#pragma mark - Pictures taking

- (void)pickImageFromLibrary: (id)sender
{
    [Flurry logEvent: @"PickImage"];
    
    [self openImagePickerWithSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
    
}


- (void)takePicture: (id)sender
{
    [Flurry logEvent: @"TakeImage"];
    
    [self openImagePickerWithSourceType: UIImagePickerControllerSourceTypeCamera];
    
}


- (void)openImagePickerWithSourceType: (UIImagePickerControllerSourceType)sourceType
{
    if ( ![UIImagePickerController isSourceTypeAvailable: sourceType] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString( @"Error", @"" )
                                                        message: NSLocalizedString( @"We are sorry, but this functionality is not available at your device.", @"No camera eror" )
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString( @"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.showsCameraControls = YES;
    t = [[UIButton alloc]initWithFrame:CGRectMake(0, 498, 320, 70)];
    
    [t setBackgroundColor:[UIColor blackColor]];
    
    tvc = [[UIButton alloc]initWithFrame:CGRectMake(0, 498, 320, 70)];
    
  //  [tvc setBackgroundColor:[UIColor greenColor]];
    // [tvc bringSubviewToFront:picker.view];
    
    //customizing
    // [t addSubview:tvc];
    self.isCameraShown = YES;
    
    
    //Sun - iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:(UIViewController *)picker];
        CGRect takePhotoRect;
        takePhotoRect.origin = self.view.frame.origin;
        takePhotoRect.size.width = 1;
        takePhotoRect.size.height = 1;
        [self.popover setPopoverContentSize:CGSizeMake(320.0, 216.0)];
        
        [self.popover presentPopoverFromRect:takePhotoRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else{
        [self presentViewController:picker animated:YES completion:NULL ];
    }
    
    
}
- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated {
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
    } else {
        
        UIButton *import = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        import.frame = CGRectMake(0 ,0,90,170);
        [import setTitle:@"import" forState:UIControlStateNormal];
        [import setTitleEdgeInsets:UIEdgeInsetsMake(20.0f, -60.0f, 0.0f, 0.0f)];
        import.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:22.0];
        [import addTarget:self action:@selector(showLibrary:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithCustomView:import];
        
        // [[UIBarButtonItem alloc] initWithTitle:@"import" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
        
        
        viewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:button];
        viewController.navigationItem.title = @"";
        
        viewController.navigationController.navigationBarHidden = NO; // important
        viewController.navigationController.navigationBar.barTintColor = [UIColor clearColor];
        viewController.navigationController.navigationBar.translucent = NO;
        
        
        
        
        UIButton *buttonc = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView *helpV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"help_new.png"]];
        helpV.frame = CGRectMake(270 ,15,35,35);
        
       
        
        
       // [buttonc setImage:[UIImage imageNamed:@"help_new.png"] forState:UIControlStateNormal];
        [buttonc addTarget:self action:@selector(help:) forControlEvents:UIControlEventTouchUpInside]; //adding action
        
        buttonc.frame = CGRectMake(0 ,20,120,90);
        buttonc.layer.borderWidth = 3;
       // buttonc.layer.borderColor = [UIColor greenColor].CGColor;
       // [buttonc setTitleEdgeInsets:UIEdgeInsetsMake(20.0f, -50.0f, 0.0f, 0.0f)];
        UIBarButtonItem* help = [[UIBarButtonItem alloc] initWithCustomView:buttonc];
        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:help];
        [picker.view addSubview:helpV];
       
//       [t  sendSubviewToBack:self.view];
        [self AddView];
    }
}
-(void)AddView
{
    toggleCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    toggleCamera.frame = CGRectMake(260, 515, 40, 40);
    [toggleCamera addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];

    [toggleCamera setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [picker.view addSubview:toggleCamera];
    
    
    
    takepicture = [UIButton buttonWithType:UIButtonTypeCustom];
    [takepicture setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    takepicture.frame = CGRectMake( (self.view.frame.size.width-65)/2,500,65,65);
    [takepicture addTarget:self action:@selector(takePicture1:) forControlEvents:UIControlEventTouchUpInside];
    [picker.view addSubview:t];
    
    [picker.view addSubview:takepicture];
    
    [picker.view addSubview:toggleCamera];
}
-(void)takePicture1:(id)sender{
    [picker takePicture];
    toggleCamera.hidden  = YES ;
    usePhoto.hidden = NO;
    UIView *hiddeVc  =  [[UIView alloc]initWithFrame:CGRectMake(0, 240, 320, 370)];
    hiddeVc.backgroundColor = [UIColor redColor];
    // [picker.view addSubview:hiddeVc];
    //[hiddeVc bringSubviewToFront:picker.view];
    t.frame = CGRectMake(0, 498, 320, 70);
    t.hidden = YES;
    //    t.backgroundColor  = [UIColor
    takepicture.hidden = !takepicture.hidden;
    
    
}
-(void)help:(id)sender{
    NSLog(@"HELP");
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) showCamera: (id) sender {
    toggleCamera.hidden  = !toggleCamera.hidden;
    takepicture.hidden  = !takepicture.hidden ;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
}

- (void) showLibrary: (id) sender {
    takepicture.hidden = YES;
    toggleCamera.hidden  = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void) getFBPicture: (id) sender
{
    [Flurry logEvent: @"PickFBFriendImage"];
    
    if ( ![[FacebookManager sharedInstance] isFacebookReachable] ) {
        error(@"no route to Facebook - cannot share");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
                                                        message: NSLocalizedString(@"You need to be connected to Internet to interact with Facebook.", @"Info screen - share facebook - no connection error alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    debug(@"sharing to facebook");
    if ( [[FacebookManager sharedInstance] isLoggedIn] ) {
        
        if (self.friendPickerController == nil) {
            // Create friend picker, and get data loaded into it.
            self.friendPickerController = [[FBFriendPickerViewController alloc] init];
            self.friendPickerController.title = @"Pick Friends";
            self.friendPickerController.delegate = self;
            self.friendPickerController.allowsMultipleSelection = NO;
        }
        
        [self.friendPickerController loadData];
        [self.friendPickerController clearSelection];
        self.showingFriendPicker = YES;
        
        
        [self.friendPickerController
         presentModallyFromViewController:self
         animated:YES
         handler:^(FBViewController *sender, BOOL donePressed) {
             [self addSearchBarToFriendPickerView];
             if (donePressed) {
                 [Flurry logEvent: @"PickedFBFriendImage"];
                 
                 for (id<FBGraphUser> user in self.friendPickerController.selection) {
                     
                     self.hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
                     self.hud.delegate = self;
                     self.hud.labelText = NSLocalizedString(@"Getting your friend's pic…", @"HUD title");
                     
                     
                     __unsafe_unretained __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"https://graph.facebook.com/%@/picture?width=640&height=640", user[@"id"]]]];
                     [request setCompletionBlock: ^{
                         
                         [DataModel sharedInstance].currentFBFriend = user;
                         
                         debug(@"Get Picture request completed");
                         debug(@"data len: %d", [[request responseData] length]);
                         if ([[request responseData] length] > 0){
                             UIImage *pickedImage = [[UIImage alloc] initWithData:[request responseData]];
                             [MBProgressHUD hideHUDForView: self.view animated: YES];
                             PictureViewController *pictureViewController = [[PictureViewController alloc] initWithNibName: nil bundle: nil];
                             pictureViewController.sourceImage = pickedImage;
                             [self.navigationController pushViewController: pictureViewController animated: YES];
                         }
                         else
                         {
                             [MBProgressHUD hideHUDForView: self.view animated: YES];
                             
                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                                                 message: NSLocalizedString(@"Can't get your friend pic", @"")
                                                                                delegate: nil
                                                                       cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                                                       otherButtonTitles: nil, nil];
                             [alertView show];
                             
                             
                             
                         }
                     }];
                     
                     [request setFailedBlock: ^{
                         [MBProgressHUD hideHUDForView: self.view animated: YES];
                         
                         debug(@"Get Picture request  failed with error: %@", request.error);
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                                             message: NSLocalizedString(@"Can't get your friend pic", @"")
                                                                            delegate: nil
                                                                   cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                                                   otherButtonTitles: nil, nil];
                         [alertView show];
                         
                     }];
                     
                     [request setStartedBlock: ^{
                         debug(@"Get Picture request started");
                     }];
                     
                     [request startAsynchronous];
                     break;
                 }
             }
         }];
    }
    else {
        debug(@"share to facebook - initiating login");
        _currentAPICall = kAPIFriendsForDialogRequests;
        
        [FacebookManager sharedInstance].loginDelegate = self;
        [[FacebookManager sharedInstance] logIn];
    }
}


- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}


- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    if (self.searchText && ![self.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:self.searchText
                          options:NSCaseInsensitiveSearch];
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)imagePickerController: (UIImagePickerController*)picker didFinishPickingMediaWithInfo: (NSDictionary*)info
{
    //[picker dismissModalViewControllerAnimated: YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
    
    
    self.isCameraShown = NO;
    
    UIImage *pickedImage = [info objectForKey: @"UIImagePickerControllerOriginalImage"];
    
    PictureViewController *pictureViewController = [[PictureViewController alloc] initWithNibName: nil bundle: nil];
    pictureViewController.sourceImage = pickedImage;
    [self.navigationController pushViewController: pictureViewController animated: YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1 {
    [picker dismissViewControllerAnimated:NO completion:^{
        [self openImagePickerWithSourceType: UIImagePickerControllerSourceTypeCamera];
         [self AddView];
      //  [self viewDidLoad];
    }];
    //
    // picker.cameraDevice=UIImagePickerControllerCameraDeviceFront;
    
    //   [picker takePicture];
}
#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
	self.hud = nil;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
    [self.friendPickerController updateView];
}


- (void)facebookViewControllerCancelWasPressed:(id)sender {
    self.showingFriendPicker = NO;
}


- (void)facebookViewControllerDoneWasPressed:(id)sender {
    self.showingFriendPicker = NO;
}


#pragma mark - FacebookManagerLoginDelegate

- (void)facebookDidLogIn
{
    debug(@"did LOG IN");
    [self getFBPicture: nil];
}


- (void)facebookDidNotLogin: (BOOL)cancelled;
{
    
    
    if ( !cancelled ) {
        float currentVersion = 6.0;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion)
        {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Warning", @"")
                                                                     message: NSLocalizedString(@"To use Facebook you must allow the app in Settings->Facebook", @"Facebook authorization failure - alert text")
                                                                    delegate: nil
                                                           cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                                           otherButtonTitles: nil];
            [errorAlertView show];
            
        }
    }
}


- (void)facebookDidLogOut
{
    debug(@"did LOG OUT");
}


@end
