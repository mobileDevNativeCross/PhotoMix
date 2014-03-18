//
//  InfoViewController.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/27/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "InfoViewController.h"
#import "GUIHelper.h"
#import "Flurry.h"
#import "DETweetComposeViewController.h"
#import "UIDevice+DETweetComposeViewController.h"
#import "HighlightedButton.h"
#import "InfoScreenButton.h"
#import "AppDelegate.h"
#import "DataModel.h"

@interface InfoViewController ()
{
    EFacebookAPICall _currentAPICall;
}

@property (strong, nonatomic) InfoScreenButton *shareEmailButton;
@property (strong, nonatomic) InfoScreenButton *shareFacebookButton;
@property (strong, nonatomic) InfoScreenButton *shareTwitterButton;
@property (strong, nonatomic) InfoScreenButton *contactSupportButton;
@property (strong, nonatomic) InfoScreenButton *reviewOnAppstoreButton;
@property (strong, nonatomic) InfoScreenButton *inviteFriendsButton;
@property (strong, nonatomic) InfoScreenButton *followFbButton;
@property (strong, nonatomic) InfoScreenButton *followTwButton;
@property (strong, nonatomic) InfoScreenButton *facebookLogout;
@property (strong, nonatomic) InfoScreenButton *legalButton;
@property (strong, nonatomic) InfoScreenButton *smsButton;
@property (strong, nonatomic) InfoScreenButton *tieClipButton;
@property (strong, nonatomic) InfoScreenButton *restoreButton;


- (UIButton*)buttonWithImageNamed: (NSString*)imageName target: (id)target action: (SEL)action;
- (void)drawInfoButtons: (NSArray*)buttons withCenterHeight: (CGFloat)centerHeight;

- (void)goBack: (id)sender;

- (void)shareEmail: (id)sender;
- (void)contactSupport: (id)sender;
- (void)shareFacebook: (id)sender;
- (void)shareTwitter: (id)sender;
- (void)reviewOnAppstore: (id)sender;
- (void)inviteFriends: (id)sender;
- (void)followFacebook: (id)sender;
- (void)followTwitter: (id)sender;
- (void)addTweetContent: (id)tcvc;
- (void)openLegal: (id)sender;
- (void)openSMSComposer: (id)sender;
//- (void)openTsaiClip: (id)sender;
- (void)restorePurchases: (id)sender;
@end


@implementation InfoViewController

@synthesize shareEmailButton = _shareEmailButton;
@synthesize shareFacebookButton = _shareFacebookButton;
@synthesize shareTwitterButton = _shareTwitterButton;
@synthesize contactSupportButton = _contactSupportButton;
@synthesize reviewOnAppstoreButton = _reviewOnAppstoreButton;
@synthesize inviteFriendsButton = _inviteFriendsButton;
@synthesize followFbButton = _followFbButton;
@synthesize followTwButton = _followTwButton;
@synthesize facebookLogout = _facebookLogout;
@synthesize legalButton = _legalButton;
@synthesize smsButton = _smsButton;
//@synthesize tieClipButton = _tieClipButton;
@synthesize restoreButton = _restoreButton;

- (id)initWithNibName: (NSString*)nibNameOrNil bundle: (NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    [self createNavBar];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    // SHARE by Facebook button
    CGFloat shareFacebookLabelWidth = 0.0;
    if ([language isEqualToString: @"zh-Hant"])
        shareFacebookLabelWidth = 20.0;
   
    self.shareFacebookButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Share-to-FB"
                                                                  target: self
                                                                  action: @selector(shareFacebook:)]
                                        text: NSLocalizedString(@"Share to Facebook", @"Info screen button title")
     
                         labelWidthExtension: shareFacebookLabelWidth];
    
    
    // SHARE by TWITTER button
   
    self.shareTwitterButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Share-to-TW"
                                                                  target: self
                                                                  action: @selector(shareTwitter:)]
                                        text: NSLocalizedString(@"Share to Twitter", @"Info screen button title")
                         labelWidthExtension: 0.0];
    
    // SHARE by EMAIL button   
    self.shareEmailButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Email-Friends"
                                                                  target: self
                                                                  action: @selector(shareEmail:)]
                                        text: NSLocalizedString(@"Email to Friends", @"Info screen button title")
                         labelWidthExtension: 0.0];
    
    // INVITE Facebook Friends button   
    self.inviteFriendsButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Invite-FB"
                                                                  target: self
                                                                  action: @selector(inviteFriends:)]
                                        text: NSLocalizedString(@"Invite Facebook friends", @"Info screen button title")
                         labelWidthExtension: 40.0];
    
    // CONTACT SUPPORT button
    CGFloat contactSupportLabelWidth = 0.0;
    if ([language isEqualToString: @"zh-Hans"])
        contactSupportLabelWidth = 4.0;
    
    self.contactSupportButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Contact-Support"
                                                                  target: self
                                                                  action: @selector(contactSupport:)]
                                        text: NSLocalizedString(@"Contact Support", @"Info screen button title")
                         labelWidthExtension: contactSupportLabelWidth];
    
    // REVIEW on APPSTORE button
    CGFloat reviewOnAppstoreLabelWidth = 10.0;
    if ([language isEqualToString: @"zh-Hans"] || [language isEqualToString: @"zh-Hant"])
        reviewOnAppstoreLabelWidth = 20.0;
    
    self.reviewOnAppstoreButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Review-App"
                                                                  target: self
                                                                  action: @selector(reviewOnAppstore:)]
                                        text: NSLocalizedString(@"Review on Appstore", @"Info screen button title")
                         labelWidthExtension: reviewOnAppstoreLabelWidth];
    
    // Facebook logout
    self.facebookLogout =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Logout-FB"
                                                                  target: [FacebookManager sharedInstance]
                                                                  action: @selector(logOut)]
                                        text: NSLocalizedString(@"Logout of Facebook", @"Info screen button title")
                         labelWidthExtension: 0.0];
    
    self.facebookLogout.button.enabled = [[FacebookManager sharedInstance] isLoggedIn];

    //follow FaceBook
    CGFloat followFbLabelWidth = 0.0;
    if ([language isEqualToString: @"zh-Hant"])
        followFbLabelWidth = 12.0;

    self.followFbButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Follow-on-FB"
                                                                  target: self
                                                                  action: @selector(followFacebook:)]
                                        text: NSLocalizedString(@"Follow on Facebook", @"Info screen button title")
                         labelWidthExtension: followFbLabelWidth];
    
    //follow Twitter
    self.followTwButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Follow-on-TW"
                                                                  target: self
                                                                  action: @selector(followTwitter:)]
                                        text: NSLocalizedString(@"Follow on Twitter", @"Info screen button title")
                         labelWidthExtension:  0.0];
    
    // DRAW rows
    CGFloat firstRowY = 100;
    CGFloat rowDelta = 100;
    //Sun - iPad support
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
     {
         firstRowY += 100;
         rowDelta += 120;
     }
    
    
    NSArray *row1 = [NSArray arrayWithObjects: self.shareFacebookButton, self.shareTwitterButton, self.shareEmailButton, nil];
    [self drawInfoButtons: row1 withCenterHeight: firstRowY];
    
    NSArray *row2 = [NSArray arrayWithObjects: self.inviteFriendsButton, self.contactSupportButton, self.reviewOnAppstoreButton, nil];
    [self drawInfoButtons: row2 withCenterHeight: firstRowY + rowDelta];
    
    NSArray *row3 = [NSArray arrayWithObjects: self.facebookLogout, self.followFbButton, self.followTwButton, nil];
    [self drawInfoButtons: row3 withCenterHeight: firstRowY + 2 * rowDelta];
    
    // Legal button
    self.legalButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Legal"
                                                                  target: self
                                                                  action: @selector(openLegal:)]
                                        text: NSLocalizedString(@"Legal", @"Info screen button title")
                         labelWidthExtension: 0.0];
    [self.view addSubview: self.legalButton];
    
    // SMS button
    //if ( [MFMessageComposeViewController canSendText] ) {
    self.smsButton = [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed:@"sms"
                                                                                       target: self
                                                                                       action: @selector(openSMSComposer:)]
                                                                 text: NSLocalizedString(@"Share via SMS", @"Info screen button title")
                                                  labelWidthExtension: 0.0];
        [self.view addSubview: self.smsButton];
     //}
    
    // Tie clip Button
//    self.tieClipButton =
//    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Tie-clip"
//                                                                  target: self
//                                                                  action: @selector(openTsaiClip:)]
//                                        text: NSLocalizedString(@"Moustache Tie Clips", @"Info screen button title")
//                         labelWidthExtension: 20.0];
//    [self.view addSubview: self.tieClipButton];
    self.restoreButton =
    [[InfoScreenButton alloc] initWithButton: [self buttonWithImageNamed: @"Review-App"
                                                                  target: self
                                                                  action: @selector(restorePurchases:)]
                                        text: NSLocalizedString(@"Restore Purchases", @"Restore Purchases")
     
                         labelWidthExtension: 10.0];
    #ifndef MB_LUXURY
        [self.view addSubview: self.restoreButton];
    #endif
    
    // DRAW row 4
    NSMutableArray *row4 = [[NSMutableArray alloc] init];
    [row4 addObject: self.legalButton];
    if ( nil != self.smsButton ) {
        [row4 addObject: self.smsButton];
    }
    
    #ifndef MB_LUXURY
        [row4 addObject: self.restoreButton];
    #endif
    
    [self drawInfoButtons: row4 withCenterHeight: firstRowY + 3 * rowDelta];

    // Copyright label
    UILabel *copyrightLabel;
    //iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        copyrightLabel = [[UILabel alloc] initWithFrame:
                                   CGRectMake(170, [GUIHelper getBottomYForView: self.legalButton] + 60, 420, 40)];
        copyrightLabel.font = [UIFont systemFontOfSize: 18];
    }
    else
    {
        copyrightLabel = [[UILabel alloc] initWithFrame:
                                   CGRectMake( 0, [GUIHelper getBottomYForView: self.legalButton] + 30, 320, 20)];
        copyrightLabel.font = [UIFont systemFontOfSize: 10];
        
    }
    copyrightLabel.textColor = [UIColor colorWithRed: 0.17 green: 0.1 blue: 0.04 alpha: 1.0];
    copyrightLabel.backgroundColor = [UIColor clearColor];
    copyrightLabel.text = NSLocalizedString( @"© BrightNewt 2013", @"Info screen copyright");
    copyrightLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: copyrightLabel];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    debug(@"Facebook share: did unload");
}


- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    [FacebookManager sharedInstance].loginDelegate = self;
    self.facebookLogout.button.enabled = [[FacebookManager sharedInstance] isLoggedIn];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (BOOL)shouldAutorotate
{
    return NO;
}


#pragma mark View

- (void)createNavBar
{
    [super createNavBar];
    [self createLeftNavBarButtonWithTitle: NSLocalizedString(@"Close", @"Info screen nav bar button") target: self action: @selector(goBack:)];
    
    NSString *title;
    CGFloat fontSize;
    
#if MB_LUXURY
    title = [NSString stringWithFormat: NSLocalizedString(@"Mustache Bash Luxury v%@", @"Info screen nav bar title"),
             [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    fontSize = 16.0;
#else
    title = [NSString stringWithFormat: NSLocalizedString(@"Mustache Bash v%@", @"Info screen nav bar title"),
             [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    fontSize = 20.0;
    // Sun - ipad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        fontSize = 40.0;
    }
#endif
    [self createNavBarTitleWithText: title fontSize: fontSize];
    
    CGRect navBarTitleLabelFrame = self.navBarTitleLabel.frame;
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString: @"zh-Hant"] || [language isEqualToString: @"zh-Hans"])
        navBarTitleLabelFrame.origin.x += 30;

    navBarTitleLabelFrame.size.width += 70;
    // Sun - ipad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        navBarTitleLabelFrame.size.width += 80;
    }
        
    self.navBarTitleLabel.frame = navBarTitleLabelFrame;
}

- (UIButton*)buttonWithImageNamed: (NSString*)imageName
                           target: (id)target
                           action: (SEL)action
{
    if ( nil == imageName ) {
        error(@"nil image supplied");
        return nil;
    }
    
    UIImage *buttonImage = [UIImage imageNamed: imageName];
    UIImage *buttonPressedImage = [UIImage imageNamed: [NSString stringWithFormat: @"%@-pressed", imageName]];
    // Sun - iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        buttonImage = [UIImage imageNamed: [NSString stringWithFormat: @"%@-ipad", imageName]];
        buttonPressedImage = [UIImage imageNamed: [NSString stringWithFormat: @"%@-ipad-pressed", imageName]];
    }
    
	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [button setImage: buttonImage forState: UIControlStateNormal];
    
    [button setImage: buttonPressedImage forState: UIControlStateHighlighted];
    button.frame= CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    
	[button addTarget: target action: action forControlEvents: UIControlEventTouchUpInside];

    return button;
}


- (void)drawInfoButtons: (NSArray*)buttons withCenterHeight: (CGFloat)centerHeight
{
    if ( [buttons count] < 1 || 3 < [buttons count] ) {
        error(@"inappropriate number of buttons supplied: %d", [buttons count]);
        return;
    }
    
    int count = [buttons count];
    switch ( count ) {
        case 3:
        {
            //iPad support
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                UIView *btn1 = [buttons objectAtIndex: 0];
                btn1.center = CGPointMake(round(70.0 + 0.5 * btn1.bounds.size.width), centerHeight);
                
                UIView *btn2 = [buttons objectAtIndex: 1];
                btn2.center = CGPointMake(390, centerHeight);
                
                UIView *btn3 = [buttons objectAtIndex: 2];
                btn3.center = CGPointMake(round(790 - 70.0 - 0.5 * btn1.bounds.size.width), centerHeight);
            }
            else{
                UIView *btn1 = [buttons objectAtIndex: 0];
                btn1.center = CGPointMake(round(25.0 + 0.5 * btn1.bounds.size.width), centerHeight);
                
                UIView *btn2 = [buttons objectAtIndex: 1];
                btn2.center = CGPointMake(160, centerHeight);
                
                UIView *btn3 = [buttons objectAtIndex: 2];
                btn3.center = CGPointMake(round(320 - 25.0 - 0.5 * btn3.bounds.size.width), centerHeight);
            }
                      
            
            break;
        }
        case 2:
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                UIView *btn1 = [buttons objectAtIndex: 0];
                btn1.center = CGPointMake(round(75.0 + 0.5 * btn1.bounds.size.width), centerHeight);
                
                UIView *btn2 = [buttons objectAtIndex: 1];
                btn2.center = CGPointMake(400, centerHeight);
            }
            else{
                UIView *btn1 = [buttons objectAtIndex: 0];
                btn1.center = CGPointMake(round(25.0 + 0.5 * btn1.bounds.size.width), centerHeight);
                
                UIView *btn2 = [buttons objectAtIndex: 1];
                btn2.center = CGPointMake(160, centerHeight);
            }

            
            break;
        }
        case 1:
        {
            UIView *btn1 = [buttons objectAtIndex: 0];
            btn1.center = CGPointMake(160, centerHeight);
            
            break;
        }   
        default:
            error(@"unsupported count: %d", count);
            break;
    }
    
    for ( UIView *btn in buttons ) {
        [self.view addSubview: btn];
    }
}


#pragma mark - Actions

- (void)goBack: (id)sender
{
    [Flurry logEvent: @"GoBackToStartPage"];
    [self.parentViewController dismissModalViewControllerAnimated: YES];
}


- (void)shareEmail: (id)sender
{
    [Flurry logEvent: @"AppEmailToFriend"];
    
    if ( [self canSendMail] ) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setSubject: NSLocalizedString(@"StacheBash - coolest iphone app ever", @"Info screen - share app by email - subject")];
        
        NSString *message = [NSString stringWithFormat: NSLocalizedString(@"Share app by email from Info screen with glob.ly %@", @"Info screen - share app by email - body"), [DataModel sharedInstance].globlyLink];
        [controller setMessageBody: message
                            isHTML: NO];
        [controller setMailComposeDelegate: self];
        
        [self presentModalViewController: controller animated: YES];
    }
}


- (void)contactSupport: (id)sender 
{
    [Flurry logEvent: @"AppContactSupport"];
    
    if ( [self canSendMail] ) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"];
        
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        [controller setToRecipients: [NSArray arrayWithObject: @"support@mustachebashapp.com"]];
        [controller setSubject:
         [NSString stringWithFormat: NSLocalizedString(@"Feedback - StacheBash ver %@", @"Info screen - contact support - email subject"), version]];
        
        [controller setMessageBody: NSLocalizedString(@"Hi there,\n", @"Info screen - contact support - email body") isHTML: NO];
        [controller setMailComposeDelegate: self];
        
        [self presentModalViewController: controller animated: YES];
    }
}





- (void)shareFacebook: (id)sender
{
    [Flurry logEvent: @"AppShareToFb"];
    
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
        [[FacebookManager sharedInstance] performSelector: @selector(apiDialogFeedUser)
                                               withObject: nil
                                               afterDelay: 0.05];
    }
    else {
        debug(@"share to facebook - initiating login");
        _currentAPICall = kDialogFeedUser;
        
        [FacebookManager sharedInstance].loginDelegate = self;
        [[FacebookManager sharedInstance] logIn];
    }
    
}

- (void)shareTwitter: (id)sender
{
    [Flurry logEvent: @"AppShareToTw"];
    
    Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
    
    if ( nil != tweeterClass ) {   // iOS5.0 twitter
        if ( [TWTweetComposeViewController canSendTweet] ) {
            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            [self addTweetContent: tweetViewController];
                        
            tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                if( TWTweetComposeViewControllerResultDone == result ) {
                    // the user finished composing a tweet
                }
                else if( TWTweetComposeViewControllerResultCancelled == result ) {
                    // the user cancelled composing a tweet
                }
                
                [self dismissViewControllerAnimated: YES completion: nil];
            };
            
            [self presentViewController: tweetViewController animated: YES completion: nil];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"") 
                                                            message: NSLocalizedString(@"You need to setup at least 1 twitter account or allow the app to send tweets on your behalf. Please check Twitter in Settings application", @"Info screen - share via twitter - error alert text")
                                                           delegate: nil 
                                                  cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }
    else { // DETweeter
        DETweetComposeViewControllerCompletionHandler completionHandler = ^(DETweetComposeViewControllerResult result) {
            switch (result) {
                case DETweetComposeViewControllerResultCancelled:
                    debug(@"Twitter Result: Cancelled");
                    break;
                case DETweetComposeViewControllerResultDone:
                    debug(@"Twitter Result: Sent");
                    break;
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
    
    [tcvc setInitialText: NSLocalizedString(@"Check out this hilarious app @mustachebashapp!", @"Info screen - share app via twitter - tweet text") ];
    [tcvc addImage: [UIImage imageNamed: @"Icon.png"]];
    
    //[tcvc addURL: [NSURL URLWithString: @"http://bit.ly/MustacheBash_tw"]];
    [tcvc addURL: [NSURL URLWithString: [DataModel sharedInstance].globlyLink]];
}


- (void)reviewOnAppstore: (id)sender
{
    [Flurry logEvent: @"AppReviewOnStore"];
    
#if MB_LUXURY
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=594894839"]];
#else
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=499793669"]];
    
#endif
    
//    [(AppDelegate*)[UIApplication sharedApplication].delegate openReferralURL: [NSURL URLWithString: @"http://glob.ly/2nr"]];
}



- (void)inviteFriends: (id)sender
{
    [Flurry logEvent: @"AppInviteFbFriends"];
    
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
    if ( [[FacebookManager sharedInstance] isLoggedIn] ) {
        [[FacebookManager sharedInstance] performSelector: @selector(apiDialogRequestsSendToMany:)
                                               withObject: nil
                                               afterDelay: 0.05];
    }
    else {
        debug(@"intite friends - initiating login");
        _currentAPICall = kDialogRequestsSendToMany;
        debug(@"initiating login with _currentAPICall: %d", _currentAPICall);
        
        [FacebookManager sharedInstance].loginDelegate = self;
        [[FacebookManager sharedInstance] logIn];
    }
}



- (void)followFacebook: (id)sender
{
    [Flurry logEvent: @"AppFollowFb"];
 
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"fb://profile/299379506798067"]]; // FB App tied fan page
    }
    else
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://www.facebook.com/mustachebashapppage"]];

}


- (void)followTwitter: (id)sender
{
    [Flurry logEvent: @"AppFollowTw"];
    //[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://twitter.com/#!/mustachebashapp"]];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"https://twitter.com/brightnewt"]];
}


- (void)openLegal: (id)sender
{
    [Flurry logEvent: @"OpenLegal"];
    
    WebViewController *legalController = [[WebViewController alloc] initWithNibName: nil bundle: nil];
    legalController.title = NSLocalizedString(@"Terms Of Use", @"Legal screen - Nav Bar title");
    legalController.url = [NSURL URLWithString: @"http://www.mustachebashapp.com/terms-of-use/"];
    legalController.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: legalController];
    [self presentModalViewController: navController animated: YES];
}


- (void)openSMSComposer: (id)sender
{
    [Flurry logEvent: @"AppSMSToFriend"];
    
    if ( ![MFMessageComposeViewController canSendText] ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                        message: NSLocalizedString(@"Weird, but you cannot send an sms.", @"Info screen - sms - error alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString( @"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.body = [NSString stringWithFormat: NSLocalizedString( @"Share app by sms with glob.ly link %@", @"Info screen - SMS body text" ), [DataModel sharedInstance].globlyLink];
    controller.messageComposeDelegate = self;
    [self presentModalViewController: controller animated: YES];
}


//- (void)openTsaiClip: (id)sender
//{
//    [Flurry logEvent: @"OpenTsaiClip"
//               withParameters: [NSDictionary dictionaryWithObjectsAndKeys: @"InfoScreen", @"screen", nil]];
//    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://zfer.us/fl2Rl?d=http://www.tsaiclip.com/products/moustache-tie-clip"]];
//}

- (void) restorePurchases:(id)sender
{
    [Flurry logEvent: @"RestorePurchases"];
    [[DataModel sharedInstance] restorePurchases];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController: (MFMailComposeViewController*)controller
          didFinishWithResult: (MFMailComposeResult)result
                        error: (NSError*)error
{
	[self dismissModalViewControllerAnimated: YES]; 
	
	if ( MFMailComposeResultFailed == result ) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"") 
														message: [NSString stringWithFormat: NSLocalizedString(@"Error sending email: %@", @""), [error localizedDescription]]
													   delegate: nil 
											  cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles: nil]; 
		[alert show];
	}
	else if ( MFMailComposeResultSent == result ) {
        debug(@"email SENT");
	}
}


#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated: YES]; 
	
	if ( MessageComposeResultFailed == result ) {
        error(@"sms sending FAILED");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"") 
														message: [NSString stringWithFormat: NSLocalizedString(@"Error sending sms. Try again!", @"") ]
													   delegate: nil 
											  cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles: nil]; 
		[alert show];
	}
	else if ( MessageComposeResultSent == result ) {
        debug(@"sms SENT");
	}
    else if ( MessageComposeResultCancelled == result ) {
        debug(@"sms CANCELLED");
	}
}


#pragma mark - FacebookManagerLoginDelegate

#pragma mark - FacebookManagerLoginDelegate

- (void)facebookDidLogIn
{
    debug(@"did LOG IN. _currentAPICall: %d", _currentAPICall);
    switch ( _currentAPICall ) {
        case kDialogFeedUser:
            [self performSelector: @selector(shareFacebook:) withObject: self afterDelay: 0.1f];
            break;
        case kDialogRequestsSendToMany:
            [self performSelector: @selector(inviteFriends:) withObject: self afterDelay: 0.1f];
            break;
        default:
            error(@"unsupported _currentAPICall: %d", _currentAPICall);
            break;
    }
    self.facebookLogout.button.enabled = YES;
}


- (void)facebookDidNotLogin: (BOOL)cancelled;
{
    if ( !cancelled ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                        message: NSLocalizedString(@"Failed to authorize with Facebook", @"")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
}


- (void)facebookDidLogOut
{
    self.facebookLogout.button.enabled = NO;
}


#pragma mark - WebViewControllerDelegate

- (void)cancelWebViewController: (id)sender
{
    [self.modalViewController dismissModalViewControllerAnimated: YES];
    //[self. dismissViewControllerAnimated:YES completion:NULL];
}


@end
