//
//  MustacheCurtainView.m
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/26/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#include <stdlib.h>
#import <QuartzCore/QuartzCore.h>

#import "MustacheCurtainView.h"
#import "GUIHelper.h"
#import "HighlightedButton.h"
#import "MustachePackView.h"
#import "DMPack.h"
#import "DataModel.h"
#import "MustacheHighlightedButton.h"
#import "GUIHelper.h"

static const CGFloat kRedBgYMargin = 12.0;
static const CGFloat kRedBgWidth = 280.0;
static const CGFloat kYellowBgMargin = 5.0;


@interface MustacheCurtainView ()

@property (strong, nonatomic) UIImageView *closeButtonImageView;
@property (strong, nonatomic) UITapGestureRecognizer *closingTapGesture;

@property (assign, nonatomic) id closingTarget;
@property (assign, nonatomic) SEL closingAction;

@property (strong, nonatomic) UIScrollView *contentView;
@property (assign, nonatomic) CGRect packViewBaseRect;
@property (strong, nonatomic) NSMutableArray *renderedBanners;
@property (strong, nonatomic) DMPack *renderedPack;
@property (strong, nonatomic) NSMutableArray *renderedPackViews;

@property (strong, nonatomic) UIView *redBgView;
@property (strong, nonatomic) UIImageView *yellowImageBgView;


- (NSArray*)banneredPacks: (NSArray*)packsArray;
- (DMPack*)randomBannerPackFromArray: (NSArray*)packsArray;
- (void)renderBannerForPack: (DMPack*)pack withIndex: (int)index;


// ACTIONS
- (void)bannerPressed: (id)sender;
- (void)buyNowPressed: (id)sender;
- (void)restorePurchasesPressed: (id)sender;

- (void)handleTap: (UITapGestureRecognizer*)sender;

@end


@implementation MustacheCurtainView

@synthesize delegate = __delegate;

@synthesize closeButtonImageView = _closeButtonImageView;
@synthesize closingTapGesture = _closingTapGesture;
@synthesize closingTarget = _closingTarget;
@synthesize closingAction = _closingAction;
@synthesize contentView = _contentView;
@synthesize packViewBaseRect = _packViewBaseRect;
@synthesize renderedBanners = _renderedBanners;
@synthesize renderedPack = _renderedPack;
@synthesize renderedPackViews = _renderedPackViews;
@synthesize redBgView = _redBgView;
@synthesize yellowImageBgView = _yellowImageBgView;

@dynamic visible;


- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if ( self ) {
        // image BG view
        UIImageView *imageBgView = [[UIImageView alloc] initWithFrame: self.bounds];
        // Sun -ipad support
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            imageBgView.image = [UIImage imageNamed: @"bg-1@2x.png"];
        }else{
            imageBgView.image = [UIImage imageNamed: @"bg-1.png"];
        }
        
        imageBgView.userInteractionEnabled = YES;
        imageBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview: imageBgView];
        // Sun - iPad support
        CGFloat redBgWidth = kRedBgWidth, redBgYMargin = kRedBgYMargin;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            redBgWidth = 2.34 * kRedBgWidth;
            redBgYMargin = 3 * kRedBgYMargin;
        }
        self.redBgView = [[UIView alloc] initWithFrame: CGRectMake(0.5 * (self.frame.size.width - redBgWidth),
                                                                   redBgYMargin,
                                                                   redBgWidth,
                                                                   self.frame.size.height - 2 * redBgYMargin)];
        
//        self.redBgView = [[UIView alloc] initWithFrame: CGRectMake(0.5 * (self.frame.size.width - kRedBgWidth),
//                                                                      kRedBgYMargin,
//                                                                      kRedBgWidth,
//                                                                      self.frame.size.height - 2 * kRedBgYMargin)];
        
        self.redBgView.backgroundColor = [UIColor colorWithRed: 0.75 green: 0.18 blue: 0.09 alpha: 1.0];
        self.redBgView.layer.cornerRadius = 5.0;
        [self addSubview: self.redBgView];
        
        // YELLOW BG
        // iPad support
        CGFloat yellowBgWidth = kYellowBgMargin;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            yellowBgWidth = 2 * kYellowBgMargin;
           
        }

        self.yellowImageBgView = [[UIImageView alloc] initWithFrame:
                                  CGRectMake(0, 0,
                                             self.redBgView.frame.size.width - 2 * yellowBgWidth,
                                             self.redBgView.frame.size.height - 2 * yellowBgWidth)];
        
        // iPad support
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.yellowImageBgView.image = [UIImage imageNamed: @"bg-@2x.png"];
        }else{
            self.yellowImageBgView.image = [UIImage imageNamed: @"bg-.png"];
        }
        
        self.yellowImageBgView.contentMode = UIViewContentModeScaleAspectFill;
        self.yellowImageBgView.clipsToBounds = YES;
        self.yellowImageBgView.center = self.redBgView.center;
        self.yellowImageBgView.userInteractionEnabled = YES;
        [self addSubview: self.yellowImageBgView];
        
        // SCROLL view
        self.contentView = [[UIScrollView alloc] initWithFrame: self.yellowImageBgView.frame];
        self.contentView.userInteractionEnabled = YES;
        self.contentView.canCancelContentTouches = NO;
        self.contentView.delaysContentTouches = YES;
        self.contentView.showsVerticalScrollIndicator = NO;
        self.contentView.alwaysBounceVertical = YES;
        [self addSubview: self.contentView];
        
        // DRAW content
        self.packViewBaseRect = self.yellowImageBgView.bounds;
        
        // CLOSE button
        // Sun - iPad support
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.closeButtonImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"close-ipad.png"]];
        }else{
            self.closeButtonImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"close.png"]];
        }
        
        self.closeButtonImageView.center = CGPointMake([GUIHelper getRightXForView: self.redBgView] - 5,
                                                       self.redBgView.frame.origin.y + 8);
        self.closeButtonImageView.userInteractionEnabled = YES;
        [self addSubview: self.closeButtonImageView];
        
        // TAP gesture
        self.closingTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTap:)];
        [self.closeButtonImageView addGestureRecognizer: self.closingTapGesture];
    }
    return self;
}


- (void)layoutSubviews
{
    CGRect parentFrame = self.superview.frame;
    if ( parentFrame.size.width != self.frame.size.width ) {
        CGRect newFrame;
        newFrame.origin = CGPointMake(0, -parentFrame.size.height);
        newFrame.size = parentFrame.size;
        self.frame = newFrame;
        
        self.redBgView.frame = CGRectMake(0.5 * (self.frame.size.width - kRedBgWidth),
                                          kRedBgYMargin,
                                          kRedBgWidth,
                                          self.frame.size.height - 2 * kRedBgYMargin);
        
        self.yellowImageBgView.frame = CGRectMake(0, 0,
                                                  self.redBgView.frame.size.width - 2 * kYellowBgMargin,
                                                  self.redBgView.frame.size.height - 2 * kYellowBgMargin);
        self.yellowImageBgView.center = self.redBgView.center;
        
        self.contentView.frame = self.yellowImageBgView.frame;
        self.closeButtonImageView.center = CGPointMake([GUIHelper getRightXForView: self.redBgView] - 5,
                                                       self.redBgView.frame.origin.y + 8);
    }
}


#pragma mark - Public

- (void)renderStaches
{
    CGFloat prevPackBottom = 0.0;
    
    self.renderedPackViews = [[NSMutableArray alloc] init];
    
    for ( DMPack *pack in [[DataModel sharedInstance] purchasedPacks] ) {
        MustachePackView *packView = [[MustachePackView alloc] initWithFrame: self.packViewBaseRect
                                                                        pack: pack
                                                               parentCurtain: self
                                                                  bannerPack: nil
                                                              buttonsEnabled: [pack.bought boolValue]
                                                            shouldRenderLock: ![pack.bought boolValue]];

        CGRect newFrame = packView.frame;
        newFrame.origin.y = prevPackBottom + 5; 
        packView.frame = newFrame;
        [self.contentView addSubview: packView];
        [self.renderedPackViews addObject: packView];
        
        // ADD Unlock All Mustaches BUTTON
        if ( [pack.path isEqualToString: @"free"] && ![DataModel sharedInstance].allMustachesUnlocked ) {
            UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
            // Sun - ipad support
            NSString *fingerName = @"btn-fingered.png", *fingerPressName = @"btn-fingered-press.png";
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                fingerName = @"btn-fingered-ipad.png";
                fingerPressName = @"btn-fingered-ipad-press.png";
            }
            UIImage *buttonImage = [UIImage imageNamed: fingerName];
            
            [button setBackgroundImage: buttonImage forState: UIControlStateNormal];
            [button setBackgroundImage: [UIImage imageNamed: fingerPressName] forState: UIControlStateHighlighted];
            
            button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
            button.center = CGPointMake(0.5 * self.contentView.bounds.size.width, [GUIHelper getBottomYForView: packView] + buttonImage.size.height);
            
            [button addTarget: self action: @selector(unlockAllPressed:) forControlEvents: UIControlEventTouchUpInside];
            [self.contentView addSubview: button];
            
            // Button LABEL
            UILabel *label = [[UILabel alloc] initWithFrame: button.bounds];
            
            label.textAlignment = UITextAlignmentCenter;
            // Sun - ipad support
            int btnSize = 20;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                btnSize = 40;
            }

            label.font = [UIFont fontWithName: @"Anderson Thunderbirds Are GO!" size: btnSize];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            label.text = NSLocalizedString(@"Unlock All", @"");
            [button addSubview: label];
            
            prevPackBottom = [GUIHelper getBottomYForView: button] + 0.5 * buttonImage.size.height;
        }
        else {
            prevPackBottom = [GUIHelper getBottomYForView: packView];
        }
    }
    
    self.contentView.contentSize = CGSizeMake(self.contentView.bounds.size.width, prevPackBottom);
}


- (void)redrawStacheBanners
{
    NSArray *banneredPackArray = [self banneredPacks: [[DataModel sharedInstance] nonPurchasedPacks]];
    for ( MustachePackView *packView in self.renderedPackViews ) {
        [packView renderBannerForPack: [self randomBannerPackFromArray: banneredPackArray]];
    }
}


- (void)renderPaidPackBanners
{
    if ( nil == self.renderedBanners ) {
        self.renderedBanners = [[NSMutableArray alloc] init];
    }
    else {
        [self.renderedBanners removeAllObjects];
    }
    
    NSArray *banneredPackArray = [self banneredPacks: [DataModel sharedInstance].packsArray];
    [banneredPackArray enumerateObjectsUsingBlock: ^(DMPack* pack, NSUInteger idx, BOOL *stop) {
        [self renderBannerForPack: pack withIndex: idx];
    }];
    
    // RESTORE button
    //Sun - ipad support
    NSString *restoreName = @"btn-restore.png", *restorePressName = @"btn-restore-press.png";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        restoreName = @"btn-restore-ipad.png";
        restorePressName = @"btn-restore-ipad-press.png";
    }
    UIImage *buttonImage = [UIImage imageNamed: restoreName];
    UIImage *buttonPressedImage = [UIImage imageNamed: restorePressName];
	
	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [button setBackgroundImage: buttonImage forState: UIControlStateNormal];
    [button setBackgroundImage: buttonPressedImage forState: UIControlStateHighlighted];
    
	button.frame= CGRectMake(0.5 * (self.contentView.bounds.size.width - buttonImage.size.width),
                             [GUIHelper getBottomYForView: [self.renderedBanners lastObject]] + 20,
                             buttonImage.size.width,
                             buttonImage.size.height);
    [button addTarget: self action: @selector(restorePurchasesPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.contentView addSubview: button];
    
    self.contentView.contentSize = CGSizeMake(self.contentView.contentSize.width,
                                              [GUIHelper getBottomYForView: button] + 20);
}


- (void)renderStachesForPack: (DMPack*)pack withBuyButton: (BOOL)withBuyButton description: (NSString*)description
{
    if ( nil == pack ) {
        error(@"nil pack supplied");
        return;
    }
    
    [self clearCurtain];
    self.renderedPack = pack;
    
    // BUY NOW button
    UIButton *buyButton;
    if ( withBuyButton ) {
        //Sun - ipad support
        NSString *buyName = @"btn-buy-now.png", *buyPressName = @"btn-buy-now-press.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            buyName = @"btn-buy-now-ipad.png";
            buyPressName = @"btn-buy-now-ipad-press.png";
        }
        buyButton = [UIButton buttonWithType: UIButtonTypeCustom];
        UIImage *buyButtonImage = [UIImage imageNamed: buyName];
        
        [buyButton setBackgroundImage: buyButtonImage forState: UIControlStateNormal];
        [buyButton setBackgroundImage: [UIImage imageNamed: buyPressName] forState: UIControlStateHighlighted];
        buyButton.frame = CGRectMake(0, 0, buyButtonImage.size.width, buyButtonImage.size.height);
        buyButton.center = CGPointMake(0.5 * self.contentView.bounds.size.width, 0.5 * buyButtonImage.size.height + 3);
        
        [buyButton addTarget: self action: @selector(buyNowPressed:) forControlEvents: UIControlEventTouchUpInside];
        
        [self.contentView addSubview: buyButton];
    }
    
    // PACK view 
    MustachePackView *packView = [[MustachePackView alloc] initWithFrame: self.packViewBaseRect
                                                                    pack: pack
                                                           parentCurtain: self
                                                              bannerPack: nil
                                                          buttonsEnabled: NO
                                                        shouldRenderLock: NO];
    CGRect newFrame = packView.frame;
    newFrame.origin.y = ( withBuyButton ? [GUIHelper getBottomYForView: buyButton] + 5.0 : 5.0 );
    packView.frame = newFrame;
    [self.contentView addSubview: packView];
        
    if ( 0 < [description length] ) {
        CGSize constraintSize, offset;
        constraintSize.width  = newFrame.size.width;
        constraintSize.height = MAXFLOAT;
        
        UIFont *descriptionFont = [UIFont boldSystemFontOfSize: 14];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            descriptionFont = [UIFont boldSystemFontOfSize: 20];
        }
        
        offset = [description sizeWithFont: descriptionFont
                         constrainedToSize: constraintSize];
        
        CGFloat sideMargin = 5.0;
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:
                                     CGRectMake(sideMargin, [GUIHelper getBottomYForView: packView] + 5.0,
                                                newFrame.size.width - 2 * sideMargin, offset.height)];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.text = description;
        descriptionLabel.font = descriptionFont;
        descriptionLabel.textAlignment = UITextAlignmentLeft;
        
        [self.contentView addSubview: descriptionLabel];
        
        self.contentView.contentSize = CGSizeMake(self.contentView.bounds.size.width,
                                                  [GUIHelper getBottomYForView: descriptionLabel]);
    }
    else {
        self.contentView.contentSize = CGSizeMake(self.contentView.bounds.size.width,
                                                  [GUIHelper getBottomYForView: packView]);
    }
}


- (void)clearCurtain
{
    for ( UIView* view in [self.contentView subviews] ){
        [view removeFromSuperview];
    }
}


#pragma mark - Class extension

- (NSArray*)banneredPacks: (NSArray*)packsArray
{
    NSMutableArray *banneredPackArray = [[NSMutableArray alloc] init];
    for ( DMPack *pack in packsArray ) {
        if ( 0 < [pack.banners count] ) {
            [banneredPackArray addObject: pack];
        }
    }
    return banneredPackArray;
}


- (DMPack*)randomBannerPackFromArray: (NSArray*)packsArray
{
    if ( 0 == [packsArray count] ) {
        error(@"empty packsArray provided");
        return nil;
    }
    
    return [packsArray objectAtIndex: arc4random() % [packsArray count]];
}


- (void)renderBannerForPack: (DMPack*)pack withIndex: (int)index
{
    NSArray *images = [pack imagesForBanners];
    UIImage *bannerImage;
    
    if ( 0 == [images count] ) {
        error(@"no banners for pack: %@", pack.name);
        return;
    }    
    else {
        bannerImage = [images objectAtIndex: index % 2];
    }
    
    // CREATE
	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    [button setImage: bannerImage forState: UIControlStateNormal];
    
    // POSITION
    CGFloat originY = 0.0;
    UIButton *lastBannerButton = [self.renderedBanners lastObject];
    if ( nil == lastBannerButton ) {
        originY += 2;
    }
    else {
        originY = [GUIHelper getBottomYForView: lastBannerButton] + 2;
    }
    
	button.frame= CGRectMake(1, originY, bannerImage.size.width, bannerImage.size.height);
    
    // CHECK image
    if ( [pack.bought boolValue] ) {
        //Sun - ipad support
        NSString *checkName = @"check.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
           checkName = @"check-ipad.png";
        }

        UIImageView *checkImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: checkName]];
        checkImageView.center = CGPointMake(button.bounds.size.width - 0.5 * checkImageView.bounds.size.width,
                                            0.5 * button.bounds.size.height);
        [button addSubview: checkImageView];
    }
    
    [button addTarget: self action: @selector(bannerPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.renderedBanners addObject: button];
    [self.contentView addSubview: button];
}


#pragma mark - Actions

- (void)bannerPressed: (id)sender
{
    if ( [sender isKindOfClass: [UIButton class]] ) {
//        [self.delegate bannerPressedForPack: [[DataModel sharedInstance].packsArray objectAtIndex: [self.renderedBanners indexOfObject: sender] + 1]
//                               curtainView: self];
         [self.delegate bannerPressedForPack: [[DataModel sharedInstance].packsArray objectAtIndex: [self.renderedBanners indexOfObject: sender] + 2]
                                curtainView: self];
    }
    // OPEN pack from banner
//    else if ( [sender isKindOfClass: [MustachePackView class]] ) {
//        [self.delegate bannerPressedForPack: [(MustachePackView*)sender bannerPack] curtainView: self];
//    }
    // OPEN pack from locked 
//    else if ( [sender isKindOfClass: [MustachePackView class]] ) {
//        [self.delegate bannerPressedForPack: [(MustachePackView*)sender pack] curtainView: self];
//    }
    else if ( [sender isKindOfClass: [MustachePackView class]] ) {
        [self.delegate buyNowPressedForPack: [(MustachePackView*)sender pack] curtainView: self];
    }
}


- (void)buyNowPressed: (id)sender
{
    [self.delegate buyNowPressedForPack: self.renderedPack curtainView: self];
}


- (void)restorePurchasesPressed: (id)sender
{
    debug(@"WILL restore");
    [self.delegate restorePurchasesFromCurtainView: self];
}

- (void)unlockAllPressed: (id)sende
{
    [self.delegate unlockAllPressedFromCurtainView: self];
}


#pragma mark - Closing action

// supressing compile time warning in the handleTap: method
// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown

- (void)handleTap: (UITapGestureRecognizer*)sender
{
    if ( self.closingTapGesture == sender
        && UIGestureRecognizerStateEnded == sender.state ){
        if ( nil != self.closingTarget && nil != self.closingAction ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            
            [self.closingTarget performSelector: self.closingAction withObject: self];
            
#pragma clang diagnostic pop            
        }
        else {
            error(@"close target-action not set correctly");
        }
    }
}


- (void)closeWithObject: (id)object
{
    if ( nil != self.closingTarget && nil != self.closingAction ) {
        MustacheHighlightedButton *highButton;
        
        if ( [object isKindOfClass: [UIButton class]] ) {
            UIButton *button = (UIButton*)object;
            highButton = (MustacheHighlightedButton*)button.superview;
            
            if ( ![highButton isKindOfClass: [MustacheHighlightedButton class]] ) {
                error(@"Cannot get staches - highButton is of class: %@", NSStringFromClass([highButton class]));
                return;
            }
        }
        else {
            error(@"Cannot get staches - object is of class: %@", NSStringFromClass([object class]));
            return;
        }
        
        [self.closingTarget performSelectorOnMainThread: self.closingAction
                                             withObject: highButton
                                          waitUntilDone: NO];
    }
    else {
        error(@"close target-action not set correctly");
    }
}


- (void)setClosingTarget: (id)target action: (SEL)action 
{
    self.closingTarget = target;
    self.closingAction = action;
}


#pragma mark - @property (assign, nonatomic, readonly) BOOL visible;

- (BOOL)visible
{
    return ( 0 <= self.frame.origin.y );
}


@end
