//
//  VoilaViewController.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/21/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "AppDelegate.h"
#import "VoilaViewController.h"
#import "iRate.h"
#import "Flurry.h"
#import "DETweetComposeViewController.h"
#import "UIDevice+DETweetComposeViewController.h"
#import "Chartboost.h"
#import "DataModel.h"
#import "RevMobAds.h"
#import "YRDropdownView.h"
#import "vunglepub.h"
// Sun - add
#import "GUIHelper.h"

static const NSInteger kFBInvitedUsersCountToGetPack = 5;


@interface VoilaViewController ()
{
    EFacebookAPICall _currentAPICall;
    BOOL _isYRDrodownShown;
    BOOL _isFirstApperance;
}

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIAlertView *errorAlertView;
@property (strong, nonatomic) UIAlertView *successAlertView;
@property (strong, nonatomic) UIAlertView *optionAlertView;
@property (strong, nonatomic) MFMailComposeViewController *sendByEmailController;
@property (strong, nonatomic) MFMailComposeViewController *shareToBNEmailController;
@property (strong, nonatomic) UIButton *printButton;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) NavController *facebookShareViewNavController;
@property (strong, nonatomic) UIAlertView *inviteFBFriends;
//Instagram
@property(nonatomic, retain)     UIDocumentInteractionController* docController;
- (void)shareIG:(id)sender;

- (void)showNagScreen: (NSString*)nagScreenName;

- (void)goBack: (id)sender;
- (void)startOver: (id)sender;

- (void)saveToLibrary: (id)sender;
- (void)imageSavedToPhotosAlbum: (UIImage*)image
       didFinishSavingWithError: (NSError*)error
                    contextInfo: (void*)contextInfo;

- (void)shareByEmail: (id)sender;
- (void)shareToFacebook: (id)sender;

- (void)shareToTwitter: (id)sender;
- (void)addTweetContent: (id)tcvc;
- (void)closeModalViews: (NSNotification*)info;


@end



@implementation VoilaViewController

@synthesize sourceImage = __sourceImage;
@synthesize imageView = _imageView;
@synthesize errorAlertView = _errorAlertView;
@synthesize successAlertView = _successAlertView;
@synthesize optionAlertView = _optionAlertView;
@synthesize sendByEmailController = _sendByEmailController;
@synthesize shareToBNEmailController = _shareToBNEmailController;
@synthesize printButton = _printButton;
@synthesize friendPickerController = _friendPickerController;
@synthesize facebookShareViewNavController = _facebookShareViewNavController;
//Sun
@synthesize oriImage = _oriImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isYRDrodownShown = NO;
        _isFirstApperance = YES;
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
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create BOTTOM TOOLBAR
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    //Sun - iPad support
    NSString *arrLName = @"arrow-L", *fbookName = @"fbook", *twitterName = @"twitter", *emailName = @"email";
    NSString *saveName = @"save", *instagramName = @"instagram", *homeName = @"home";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        arrLName = @"arrow-L-ipad";
        fbookName = @"fbook-ipad";
        twitterName = @"twitter-ipad";
        emailName = @"email-ipad";
        saveName = @"save-ipad";
        instagramName = @"instagram-ipad";
        homeName = @"home-ipad";
    }

    [buttonsArray addObject: [self buttonWithImageNamed: arrLName target: self action: @selector(goBack:)]];
    [buttonsArray addObject: [self buttonWithImageNamed: fbookName target: self action: @selector(shareToFacebook:)]];
    [buttonsArray addObject: [self buttonWithImageNamed: twitterName target: self action: @selector(shareToTwitter:)]];
    [buttonsArray addObject: [self buttonWithImageNamed: emailName target: self action: @selector(shareByEmail:)]];
    [buttonsArray addObject: [self buttonWithImageNamed: saveName target: self action: @selector(saveToLibrary:)]];
     //Instagram
    [buttonsArray addObject: [self buttonWithImageNamed: instagramName target: self action: @selector(shareIG:)]];
    [buttonsArray addObject: [self buttonWithImageNamed: homeName target: self action: @selector(startOver:)]];
    [self createBottomToolbarWithButtons: buttonsArray];
    
    [[iRate sharedInstance] logEvent: NO];
    
    // IMAGE view
    if ( nil == self.imageView ) {
        self.imageView = [[UIImageView alloc] initWithFrame:
                          CGRectMake( 0, 0,
                                     self.view.frame.size.width,
                                     self.toolbar.frame.origin.y)];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.image = self.sourceImage;
        [self.view addSubview: self.imageView];
    }

    // PRINT ME button
    //Sun - ipad support
    NSString *printName = @"PrintMe-button-send.png";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        printName = @"PrintMe-button-send-ipad.png";
    }
    UIImage *printMeImg = [UIImage imageNamed: printName];
    self.printButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    self.printButton.frame = CGRectMake(0, 0, printMeImg.size.width, printMeImg.size.height);

    [self.printButton setImage: printMeImg forState: UIControlStateNormal];
    
    // Sun - ipad support

    self.printButton.center = CGPointMake(self.view.frame.size.width - printMeImg.size.width / 2.0 - 6,
                                     printMeImg.size.height / 2.0 + 10);

    [self.printButton addTarget: self action: @selector(sendPostcard:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: self.printButton];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(closeModalViews:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    debug(@"VOILA: did unload");
    
    self.imageView = nil;
    self.successAlertView = nil;
    self.errorAlertView = nil;
    self.optionAlertView = nil;
}


- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    self.printButton.center = [self centerForPrintButtonWithOrientation: self.interfaceOrientation];
}


- (void)viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
    
    if ( _isFirstApperance && [[FacebookManager sharedInstance] isFacebookReachable] && ![[DataModel sharedInstance] userHasFreePack]) {
        [self performSelector:@selector(showFBNotification) withObject:nil afterDelay:0.4];
        _isFirstApperance = NO;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(interfaceOrientation));
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateBottomToolbarToInterfaceOrientation: interfaceOrientation];
    
    self.printButton.center = [self centerForPrintButtonWithOrientation: interfaceOrientation];

}



#pragma mark - Custom View

- (CGPoint)centerForPrintButtonWithOrientation: (UIInterfaceOrientation)orientation
{
    // Sun - iPad support
    CGFloat verticalShift =  ( _isYRDrodownShown ? 60 : 0);;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        verticalShift = ( _isYRDrodownShown ? 135 : 0);
    }
    
    return CGPointMake(self.view.frame.size.width - self.printButton.frame.size.width / 2.0 - 6,
                       self.printButton.frame.size.height / 2.0 + 10 + verticalShift);
}


- (void)showFBNotification
{
    YRDropdownView *view =
    [YRDropdownView showDropdownInView:self.view
                                 title:@""
                                detail:@""
                                 image:nil
                              animated:YES
                             hideAfter:6.0];
    
    _isYRDrodownShown = YES;
    //ipad
    NSString *fbBanner = @"banner.png";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        fbBanner = @"banner@2x.png";
    }
    view.backgroundImage = [UIImage imageNamed:fbBanner];
    self.printButton.center = [self centerForPrintButtonWithOrientation: self.interfaceOrientation];
    
    [view setTapBlock: ^{
        [self shareToFacebook: nil];
    }];
    
    [view setHideBlock: ^{
        _isYRDrodownShown = NO;
        self.printButton.center = [self centerForPrintButtonWithOrientation: self.interfaceOrientation];
    }];
}


- (void)showNagScreen: (NSString*)nagScreenName;
{
    
#if NAG_SCREENS_ON
    
//    RevMobFullscreen *revMobFullScreen = [[RevMobAds session] fullscreen];
//    revMobFullScreen.delegate = (AppDelegate*)[UIApplication sharedApplication];
//    [revMobFullScreen showAd];
//    
//    if ( 0 == [nagScreenName length] ) {
//        error(@"empty nag screen name supplied");
//        return;
//    }
//    
//    Chartboost *cb = [Chartboost sharedChartboost];
//    [cb showInterstitial: nagScreenName];
    
    debug(@"ad available: %d", [VGVunglePub adIsAvailable]);
    if ( [VGVunglePub adIsAvailable] ) {
        [VGVunglePub playModalAd: self animated: YES];
    }
    
    [Flurry logEvent: @"ShowNagScreenAfterShareEvent"
               withParameters: [NSDictionary dictionaryWithObjectsAndKeys: nagScreenName, @"NagScreenName", nil]];
#endif
    
}


#pragma mark - Actions

- (void)closeModalViews: (NSNotification*)info
{
    if (self.modalViewController != self.facebookShareViewNavController)
        [self.modalViewController dismissModalViewControllerAnimated: NO];
}


- (void)goBack: (id)sender
{
    [Flurry logEvent: @"BackToEditStache"];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated: YES];
}


- (void)startOver: (id)sender
{
    [Flurry logEvent: @"StartOver"];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated: NO];
    
#if NAG_SCREENS_ON
    
//    [[Chartboost sharedChartboost] showInterstitial: @"NAG_ON_START_UP"];
    
    RevMobFullscreen *revMobFullScreen = [[RevMobAds session] fullscreenWithPlacementId:REVMOB_FULLSCREEN_PLACEMENT_ID]; // @"515eedc64979bf0d00000001"];
    revMobFullScreen.delegate = (AppDelegate*)[UIApplication sharedApplication];
    [revMobFullScreen showAd];
    
    [[PHPublisherContentRequest requestForApp: [DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: PLAYHAVEN_PLACEMENT2 delegate: (AppDelegate*)[UIApplication sharedApplication].delegate] send];
#endif
    
}


- (void)saveToLibrary: (id)sender
{
    [Flurry logEvent: @"PicSaveToLib"];
    CGFloat imageWidth,imageHeight;
    imageWidth = self.oriImage.size.width;
    imageHeight = self.oriImage.size.height;
    
    // Fixing export to camera roll
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if([GUIHelper isIPadretina]){
            
            (imageWidth <= 1536 ? imageWidth = 1536 : imageWidth);
            (imageHeight <= 2008 ? imageHeight = 2008 : imageWidth);
        }else{
            (imageWidth <= 768 ? imageWidth = 768 : imageWidth);
            (imageHeight <= 1004 ? imageHeight = 1004 : imageWidth);
        }
    }
    else{
        if([GUIHelper isPhone5]){
            (imageWidth <= 640 ? imageWidth = 640 : imageWidth);
            (imageHeight <= 1136 ? imageHeight = 1136 : imageWidth);
        }else{
            (imageWidth <= 320 ? imageWidth = 320 : imageWidth);
            (imageHeight <= 480 ? imageHeight = 480 : imageWidth);

        }
    }
    
       
    UIImage *scaledImage = [GUIHelper imageByScaling: self.imageView.image toSize: CGSizeMake(imageWidth, imageHeight)];
    //return scaledImage;
    
//    UIImageWriteToSavedPhotosAlbum(self.imageView.image,
//                                   self,
//                                   @selector(imageSavedToPhotosAlbum:
//                                             didFinishSavingWithError:
//                                             contextInfo:),
//                                   nil);
    UIImageWriteToSavedPhotosAlbum(scaledImage,
                                   self,
                                   @selector(imageSavedToPhotosAlbum:
                                             didFinishSavingWithError:
                                             contextInfo:),
                                   nil);

}


- (void)imageSavedToPhotosAlbum: (UIImage*)image
       didFinishSavingWithError: (NSError*)error
                    contextInfo: (void*)contextInfo
{
    if ( error ) {
        self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                        message: [error localizedDescription]
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [self.errorAlertView show];
    }
    else {
        self.successAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Stachebashed!", @"Successful Save to photo album - alert title")
                                                        message: NSLocalizedString(@"Your picture was saved successfully.", @"Successful Save to photo album - alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        self.successAlertView.delegate = self;
        [self.successAlertView show];
    }
} 


- (void)shareByEmail: (id)sender
{
    [Flurry logEvent: @"PicSendByEmail"];
    
    if ( [self canSendMail] ) {
        self.sendByEmailController = [[MFMailComposeViewController alloc] init];
        [self.sendByEmailController setSubject: NSLocalizedString(@"Stachebashed!", @"Share picture by email - subject")];
        
        NSString *message = [NSString stringWithFormat: NSLocalizedString(@"Share by email with glob.ly link %@", @"Share picture by email - body"), [DataModel sharedInstance].globlyLink];
        
        [self.sendByEmailController setMessageBody: message isHTML: NO];
        [self.sendByEmailController setMailComposeDelegate: self];
        
        
        [self.sendByEmailController addAttachmentData: UIImageJPEGRepresentation(self.imageView.image, 0.8)
                             mimeType: @"image/jpeg"
                             fileName: @"Staches.jpg"];
        
        [self presentModalViewController: self.sendByEmailController animated: YES];
    }
}


- (void)shareToFacebook: (id)sender
{
    [Flurry logEvent: @"PicShareToFb"];
    
    if ( ![[FacebookManager sharedInstance] isFacebookReachable] ) {
        error(@"no route to Facebook - cannot post picture");
        self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
                                                         message: NSLocalizedString(@"You need to be connected to Internet to share on Facebook.", @"")
                                                        delegate: nil
                                               cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                               otherButtonTitles: nil];
        [self.errorAlertView show];
        return;
    }
    
    debug(@"sharing to facebook");
    if ( [[FacebookManager sharedInstance] isLoggedIn] ) {
        FacebookShareViewController *vc = [[FacebookShareViewController alloc] initWithNibName: nil bundle: nil];
        vc.sourceImage = self.imageView.image;
        vc.delegate = self;
        [FacebookManager sharedInstance].shareDelegate = vc;
        
        self.facebookShareViewNavController = [[NavController alloc] initWithRootViewController: vc];
        self.facebookShareViewNavController.navigationBarHidden = YES;
        
        [self presentModalViewController: self.facebookShareViewNavController animated: YES];
    }
    else {
        debug(@"initiating login");
        [FacebookManager sharedInstance].loginDelegate = self;
        [[FacebookManager sharedInstance] logIn];
    }

    
// POSTPONED until we get how to link FBSheet share to MB Community page
//    if ( nil != NSClassFromString(@"SLComposeViewController") ) {   // iOS6 FaceBook
//        
//        if([SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook]) {
//            
//            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//            
//            SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
//                if (result == SLComposeViewControllerResultCancelled) {
//                    debug(@"Cancelled");
//                }
//                else {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Stachebashed!", @"Facebook alert title")
//                                                                    message: NSLocalizedString(@"Your picture was posted successfully.", @"Facebook alert notification text")
//                                                                   delegate: self
//                                                          cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
//                                                          otherButtonTitles: nil];
//                    [alert show];
//                }
//                
//                [controller dismissViewControllerAnimated:YES completion:Nil];
//            };
//            controller.completionHandler =myBlock;
//            
//            [controller setInitialText: NSLocalizedString(@"Stachebashed!", @"Facebook alert title")];
//            [controller addURL: [NSURL URLWithString: @"http://glob.ly/2nr"]];
//            [controller addImage: self.imageView.image];
//            
//            [self presentViewController:controller animated:YES completion:Nil];
//        }
//        else {
//            error(@"no FB accoutn setup");
//        }
//    }
//    else {
//        if ( ![[FacebookManager sharedInstance] isFacebookReachable] ) {
//            error(@"no route to Facebook - cannot post picture");
//            self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
//                                                             message: NSLocalizedString(@"You need to be connected to Internet to share on Facebook.", @"")
//                                                            delegate: nil
//                                                   cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
//                                                   otherButtonTitles: nil];
//            [self.errorAlertView show];
//            return;
//        }
//        
//        debug(@"sharing to facebook");
//        if ( [[FacebookManager sharedInstance] isLoggedIn] ) {
//            FacebookShareViewController *vc = [[FacebookShareViewController alloc] initWithNibName: nil bundle: nil];
//            vc.sourceImage = self.imageView.image;
//            vc.delegate = self;
//            
//            NavController *navController = [[NavController alloc] initWithRootViewController: vc];
//            navController.navigationBarHidden = YES;
//            
//            [FacebookManager sharedInstance].shareDelegate = vc;
//            [self presentModalViewController: navController animated: YES];
//        }
//        else {
//            debug(@"initiating login");
//            [FacebookManager sharedInstance].loginDelegate = self;
//            [[FacebookManager sharedInstance] logIn];
//        }
//    }
}


- (void)shareToTwitter: (id)sender
{
    [Flurry logEvent: @"PicShareToTw"];
    
    Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
    
    if ( nil != tweeterClass ) {  // iOS5.0 Twitter
        if ( [TWTweetComposeViewController canSendTweet] ) {
            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            [self addTweetContent: tweetViewController];
            
            tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                switch (result) {
                    case TWTweetComposeViewControllerResultCancelled:
                        debug(@"Twitter Result: Cancelled");
                        break;
                    case TWTweetComposeViewControllerResultDone:
                    {
                        debug(@"Twitter Result: Sent");
                        [self showNagScreen: @"NAG_AFTER_SHARE_TO_TW"];
                        break;
                    }
                }
                
                [self dismissViewControllerAnimated: YES completion: nil];
            };
            
            [self presentViewController: tweetViewController animated: YES completion: nil];
        }
        else {
            error(@"CANNOT send twitter - setup account");
            self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"") 
                                                            message: NSLocalizedString(@"You need to setup at least 1 twitter account or allow the app to send tweets on your behalf. Please check Twitter in Settings application", @"No twiter account alert text")
                                                           delegate: nil 
                                                  cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                                  otherButtonTitles: nil];
            [self.errorAlertView show];
        }
    }
    else { // DETweeter
        DETweetComposeViewControllerCompletionHandler completionHandler = ^(DETweetComposeViewControllerResult result) {
            switch (result) {
                case DETweetComposeViewControllerResultCancelled:
                    debug(@"Twitter Result: Cancelled");
                    break;
                case DETweetComposeViewControllerResultDone:
                {
                    debug(@"Twitter Result: Sent");
                    [self showNagScreen: @"NAG_AFTER_SHARE_TO_TW"];
                    break;
                }
            }
            [self dismissModalViewControllerAnimated: YES];
        };
        
        DETweetComposeViewController *tcvc = [[DETweetComposeViewController alloc] init];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self addTweetContent: tcvc];
        tcvc.completionHandler = completionHandler;
        [self presentModalViewController: tcvc animated: YES];
    }
}


- (void)addTweetContent: (id)tcvc
{
    if ( nil == tcvc ) {
        error(@"nil twitter controller supplied");
        return;
    }
    
    [tcvc setInitialText: NSLocalizedString(@"Check out my mustache! via @mustachebashapp", 
                                            @"Default twitter text for mustached picture sharing")];
    [tcvc addImage: self.imageView.image];
}


//- (void)shareWithBN: (id)sender
//{
//    [Flurry logEvent: @"ShareWithBrightNewtPressed"];
//    
//    self.optionAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Send to BrightNewt" , @"Send to BrightNewt - alert title") 
//                                                    message: NSLocalizedString(@"You can send your picture to BrightNewt and find it on Mustache Bash Facebook Page" , @"Send to BrightNewt - alert text") 
//                                                   delegate: nil 
//                                          cancelButtonTitle: NSLocalizedString(@"Not this time", @"Send to BrightNewt - alert no button")
//                                          otherButtonTitles: NSLocalizedString(@"Send it", @"Send to BrightNewt - alert yes button"), nil];
//    self.optionAlertView.delegate = self;
//    [self.optionAlertView show];
//}


- (void)sendPostcard: (id)sender
{
    debug(@"sourceIamge size: %@", NSStringFromCGSize(self.sourceImage.size));
    
    NSString *appKey;
    
#if MB_LUXURY
    appKey = @"D68H3W6BIPH5Z02C9WDVGGDZG8XTZDUFSDCQB137";
#else
//    @"48I7JB96B7992KN7KE574RI2XCL8M0UKB9SLEK6S"// - MINE
    appKey = SINCELERY_ID;//@"IM7VVSK8F4CAFLMC3QZBGD8IC37SMMS928VYY602"; //@"IM7VVSK8F4CAFLMC3QZBGD8IC37SMMS928VYY602"; // - AUSTIN
#endif
    
      
    SYSincerelyController *controller = [[SYSincerelyController alloc] initWithImages:[NSArray arrayWithObject: self.sourceImage]
                                                product:SYProductTypePostcard
                                                applicationKey:appKey
                                                delegate:self];
    
    
    
    controller.shouldSkipCrop = YES;
    
    
    if (controller) {
        //[self presentModalViewController:controller animated: YES];
        [self  presentViewController:controller animated:YES completion:NULL];
        //[controller release];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView: (UIAlertView*)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex
{
    if ( alertView == self.optionAlertView ) {
        if ( buttonIndex != alertView.cancelButtonIndex ) {
            debug(@"sending email");
            
            [Flurry logEvent: @"ShareWithBrightNewtEmailOpen"];
            
            if ( [self canSendMail] ) {
                self.shareToBNEmailController = [[MFMailComposeViewController alloc] init];
                [self.shareToBNEmailController setSubject: NSLocalizedString(@"Stachebashed to BrightNewt", @"Send to BrightNewt - email subject")];
                
                [self.shareToBNEmailController setToRecipients: [NSArray arrayWithObject: @"support@mustachebashapp.com"]];
                [self.shareToBNEmailController setMessageBody: NSLocalizedString(@"Hi there,\n\n here's my stachebashed picture for Bright Newt contest", @"Send to BrightNewt - email body")
                                    isHTML: NO];
                [self.shareToBNEmailController setMailComposeDelegate: self];
                
                [self.shareToBNEmailController addAttachmentData: UIImageJPEGRepresentation(self.imageView.image, 0.8)
                                     mimeType: @"image/jpeg"
                                     fileName: @"Staches.jpg"];
                
                [self presentModalViewController: self.shareToBNEmailController animated: YES];
            }
        }
        else {
            debug(@"canceled email sending");
            [Flurry logEvent: @"ShareWithBrightNewtCancelled"];
        }
    }
    else if ( alertView == self.successAlertView ) {
        [self showNagScreen: @"NAG_AFTER_SAVE_TO_ALBUM"];
    }
    else if (alertView == self.inviteFBFriends)
    {
        if ( buttonIndex != alertView.cancelButtonIndex ) {
            [self shareAppWithFriends: nil];
        }
        else {
            [Flurry logEvent: @"InviteFBFriendsRejected"];
        }
    }
}


#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController: (MFMailComposeViewController*)controller
          didFinishWithResult: (MFMailComposeResult)result
                        error: (NSError*)error
{
	[self dismissModalViewControllerAnimated: YES]; 
	
	if ( MFMailComposeResultFailed == result ) {
		self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"") 
														message: [NSString stringWithFormat: NSLocalizedString(@"Error sending email: %@", @"email error alert text"), [error localizedDescription]]
													   delegate: nil 
											  cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles: nil]; 
		[self.errorAlertView show];
	}
	else {
        if ( controller == self.shareToBNEmailController ) {
            [self showNagScreen: @"NAG_AFTER_SHARE_TO_BN"];
        }
        else if ( controller == self.sendByEmailController ) {
            [self showNagScreen: @"NAG_AFTER_SHARE_BY_EMAIL"];
        }
        else {
            error(@"Unknown email controller");
        }
	}
}


#pragma mark - FacebookManagerLoginDelegate

- (void)facebookDidLogIn
{
    debug(@"did LOG IN");
    [self shareToFacebook: self];
}


- (void)facebookDidNotLogin: (BOOL)cancelled;
{
    if ( !cancelled ) {
        self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                        message: NSLocalizedString(@"Failed to authorize with Facebook", @"Facebook authorization failure - alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [self.errorAlertView show];
    }
}


- (void)facebookDidLogOut
{
    debug(@"did LOG OUT");
}



#pragma mark - FacebookShareViewControllerDelegate

- (void)cancelFacebookShareViewController: (id)controller
{
    [self.modalViewController dismissModalViewControllerAnimated: YES];
    [FacebookManager sharedInstance].shareDelegate = nil;
}

- (void)doneFacebookShareViewController: (id)controller
{
#if NAG_SCREENS_ON
    [self showNagScreen: @"NAG_AFTER_SHARE_TO_FB"];
#endif
    [self.modalViewController dismissModalViewControllerAnimated: YES];
    [FacebookManager sharedInstance].shareDelegate = nil;
}


-(void)shareAppWithFriends: (id)controller
{
    [Flurry logEvent: @"InviteFbFriends"];
    if (controller != nil){
        [self.modalViewController dismissModalViewControllerAnimated: YES];
        [FacebookManager sharedInstance].shareDelegate = nil;
    }
    if ( ![[FacebookManager sharedInstance] isFacebookReachable] ) {
        error(@"no route to Facebook - cannot post picture");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
                                                        message: NSLocalizedString(@"You need to be connected to Internet to interact with Facebook.", @"Info screen - share facebook - no connection error alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    debug(@"invite via facebook");
    //    if ( [[FacebookManager sharedInstance] isLoggedIn] ) {
    _currentAPICall = kDialogRequestsSendToMany;
    
    NSSet *fields = [NSSet setWithObjects:@"installed", nil];
    if (self.friendPickerController == nil) {
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        //Sun - Fix warnings
        
        self.friendPickerController.delegate = self;
    }
    
    self.friendPickerController.fieldsForRequest = fields;
    [self.friendPickerController loadData];
    [FacebookManager sharedInstance].dialogDelegate = self;
    
    [[FacebookManager sharedInstance] performSelector: @selector(apiDialogRequestsSendToMany:)
                                           withObject: self.friendPickerController.selection
                                           afterDelay: 0.05];
    
    //    }
    //    else {
    //        debug(@"intite friends - initiating login");
    //        _currentAPICall = kDialogRequestsSendToMany;
    //        debug(@"initiating login with _currentAPICall: %d", _currentAPICall);
    //
    //        //    [FacebookManager sharedInstance].loginDelegate = self;
    //        [[FacebookManager sharedInstance] logIn];
    //    }
}


- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    if ( _currentAPICall == kDialogRequestsSendToMany){
        BOOL notInstalled = [user objectForKey:@"installed"] == nil;
        return notInstalled;
    }
    return YES;
}



- (void)facebookDidSendToFriends: (NSArray *) friends
{
    
    [Flurry logEvent: @"InviteFBFriendsDone" withParameters: @{@"count" : [NSString stringWithFormat: @"%d", [friends count]]}];
    
    NSInteger friendsToInviteLeft = kFBInvitedUsersCountToGetPack - [[DataModel sharedInstance] saveInvitedFriends: [friends count]];
    if (friendsToInviteLeft <= 0)
    {
        [[DataModel sharedInstance] presentFreePack];
        [Flurry logEvent: @"UserGotFreePack"];
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Congrats!", @"User got a free pack alert title")
                                                               message: NSLocalizedString(@"Enjoy your Secret pack!", @"Alert description : user got free pack")
                                                              delegate: self
                                                     cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                                     otherButtonTitles: nil];
        
        
        [successAlert show];
        
    }
    else
    {
        self.inviteFBFriends = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Oops!", @"Need more users to invite alert title")
                                                          message: [NSString stringWithFormat: NSLocalizedString(@"You need to invite %d more friends to get a Secret pack", @"You need to invite %d more friends to get a Secret pack"), friendsToInviteLeft]
                                                         delegate: self
                                                cancelButtonTitle:@"Later"
                                                otherButtonTitles:@"Invite more!", nil];
        
        [self.inviteFBFriends show];
    }
}


- (void)facebookDidFailWithError: (NSError*)error
{
    
}


#pragma mark - SYSincerelyControllerDelegate

- (void)sincerelyControllerDidFinish:(SYSincerelyController *)controller
{
    debug(@"postcard sent");
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sincerelyControllerDidCancel:(SYSincerelyController *)controller
{
    debug(@"postcard cancelled");
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sincerelyControllerDidFailInitiationWithError:(NSError *)error
{
    debug(@"postcard failed init: %@", error);
}  

//Instaram
- (void)shareIG:(id)sender
{
    [Flurry logEvent: @"PicShareToIg"];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        UIImage* instaImage = self.imageView.image;
        NSString* imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
        NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
        //_docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]]; //bug
        //fixed
        self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        _docController.delegate=self;
        _docController.UTI = @"com.instagram.exclusivegram";
        //Add caption
        self.docController.annotation = [NSDictionary dictionaryWithObject:INSTAGRAM_CAPTION forKey:@"InstagramCaption"];
       
        //iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [_docController presentOpenInMenuFromRect:[sender frame] inView:self.view animated:YES];
        }
        else{
            [_docController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
        }

        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
                                                        message: NSLocalizedString(@"Instagram unavailable. You need to install Instagram in your device in order to share this image.", @"Info screen - share Instagram - no instagram error alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        return;
        
        
    }
}



@end
