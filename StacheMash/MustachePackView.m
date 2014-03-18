//
//  MustachePackView.m
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/26/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "MustachePackView.h"
#import "DMPack.h"
#import "DMStache.h"
#import "HighlightedButton.h"
#import "GUIHelper.h"
#import "MustacheHighlightedButton.h"
#import "MustacheCurtainView.h"
#import "JTLabel.h"


@interface MustachePackView ()

@property (strong, nonatomic) UIImageView *greenBar;
@property (strong, nonatomic) UIButton *bannerButton;

@property (assign, nonatomic) MustacheCurtainView *mustacheCurtainView;
@property (assign, nonatomic) BOOL buttonsEnabled;
@property (assign, nonatomic) BOOL shouldRenderLock;


- (void)renderStaches;
- (void)renderBanner;
- (void)increaseFrameToHeight: (CGFloat)newHeight;
- (UIImage*)bannerImage;

- (void)bannerPressed: (id)sender;

@end



@implementation MustachePackView

@synthesize pack = __pack;
@synthesize bannerPack = __bannerPack;

@synthesize greenBar = _greenBar;
@synthesize mustacheCurtainView = _mustacheCurtainView;
@synthesize buttonsEnabled = _buttonsEnabled;
@synthesize bannerButton = _bannerButton;
@synthesize shouldRenderLock = _shouldRenderLock;

- (id)initWithFrame: (CGRect)frame
               pack: (DMPack*)pack
      parentCurtain: (MustacheCurtainView*)mustacheCurtainView
         bannerPack: (DMPack*)bannerPack
     buttonsEnabled: (BOOL)buttonsEnabled
   shouldRenderLock: (BOOL)shouldRenderLock
{
    self = [super initWithFrame: frame];
    
    if ( self ) {
        __pack = pack;
        __bannerPack = bannerPack;
        
        self.mustacheCurtainView = mustacheCurtainView;
        self.buttonsEnabled = buttonsEnabled;
        self.shouldRenderLock = shouldRenderLock;
        
        // PACK NAME bar
        // Sun -ipad
        NSString *lineName = @"line-txt.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            lineName = @"line-txt-ipad.png";
        }
        self.greenBar = [[UIImageView alloc] initWithImage: [UIImage imageNamed: lineName]];
        self.greenBar.center = CGPointMake(0.5 * self.bounds.size.width, 0.5 * self.greenBar.bounds.size.height);
        [self addSubview: self.greenBar];
        
        // PACK NAME text
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if ([language isEqualToString: @"zh-Hant"] || [language isEqualToString: @"zh-Hans"])
        {
            UILabel *packNameLabel = [[UILabel alloc] initWithFrame:
                                      CGRectMake(0, 
                                                 0,
                                                 self.greenBar.bounds.size.width,
                                                 self.greenBar.bounds.size.height)];
            packNameLabel.text = NSLocalizedString(pack.name,@"");
            //Sun - ipad support
            int barSize = 14;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                barSize = 28;
            }
            packNameLabel.font = [UIFont systemFontOfSize: barSize];
            packNameLabel.textColor = [UIColor colorWithRed: 0.92 green: 0.87 blue: 0.63 alpha: 1.0];
            packNameLabel.backgroundColor = [UIColor clearColor];
            packNameLabel.textAlignment = UITextAlignmentCenter;
            packNameLabel.center = CGPointMake(0.5 * self.greenBar.bounds.size.width , 0.5 * self.greenBar.bounds.size.height);
            [self.greenBar addSubview: packNameLabel];
            
        }
        else {
            //Sun - ipad support
            int barFontSize = 14;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                barFontSize = 28;
            }

            UIFont *font = [UIFont fontWithName: @"Anderson Thunderbirds Are GO!" size: barFontSize];
            CGSize labelSize = [[pack.name uppercaseString] sizeWithFont: font];
            labelSize.width *= 1.25; //to compensate width increase due non-zero kerning 
        
            JTLabel *packNameLabel = [[JTLabel alloc] initWithFrame:
                                  CGRectMake(0.5 * (self.greenBar.bounds.size.width - labelSize.width), 
                                             0.5 * (self.greenBar.bounds.size.height - labelSize.height),
                                             labelSize.width,
                                             labelSize.height)];
            packNameLabel.font = font;
            packNameLabel.textColor = [UIColor colorWithRed: 0.92 green: 0.87 blue: 0.63 alpha: 1.0];
            packNameLabel.backgroundColor = [UIColor clearColor];
        
            packNameLabel.text = [NSLocalizedString(pack.name,@"") uppercaseString];
            packNameLabel.kerning = 1.0;
            [self.greenBar addSubview: packNameLabel];
        }
        
        
        [self renderStaches];
        
        if ( nil != self.bannerPack ) {
            [self renderBanner];
        }

    }
    return self;
}


- (void)renderStaches
{
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    for ( DMStache *stache in self.pack.staches ) {
        [buttonsArray addObject: [[MustacheHighlightedButton alloc] initWitStache: stache fromPack: self.pack]];
    }
    
    if ( 0 == [buttonsArray count] ) {
        error(@"empty buttonsArray");
        return;
    }
    
    int buttonsInRow = 3;
    int rowsCount = [buttonsArray count] / buttonsInRow;
    rowsCount = (0 == rowsCount ? 1 : rowsCount);    

    MustacheHighlightedButton *lastButton = [buttonsArray objectAtIndex: [buttonsArray count] - 1];
    for ( int row = 0; row < rowsCount; row++ ) {
        for ( int column = 0; column < buttonsInRow; column++ ) {
            if ( [buttonsArray count] <= row + column ) {
                break;
            }
            
            MustacheHighlightedButton *highButton= [buttonsArray objectAtIndex: buttonsInRow * row + column];
            
            CGRect newFrame = highButton.frame;
            newFrame.origin = CGPointMake(column * (highButton.frame.size.width + 3) + 1, // x
                                          [GUIHelper getBottomYForView: self.greenBar] + 2 // Y
                                          + row * (3 + highButton.frame.size.height));
            highButton.frame = newFrame;
            
            [highButton.button addTarget: self.mustacheCurtainView
                                  action: @selector(closeWithObject:)
                        forControlEvents: UIControlEventTouchUpInside];
            
            [self addSubview: highButton];
            
            if ( self.shouldRenderLock ) {
                //Sun - ipad support
                NSString *lockName = @"lockbrown.png";
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
                    lockName = @"lockbrown-ipad.png";
                }
                UIImageView *lockImage = [[UIImageView alloc] initWithFrame: newFrame];
                lockImage.image = [UIImage imageNamed: lockName];
                [self addSubview: lockImage];
            }
        }
    }
    
    [self increaseFrameToHeight: [GUIHelper getBottomYForView: lastButton]];
    
    if ( !self.buttonsEnabled ) {
        UIView *overlayView = [[UIView alloc] initWithFrame: self.frame];
        
        if ( self.shouldRenderLock ) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleLockedTap:)];
            [overlayView addGestureRecognizer: tapGesture];
        }
        
        [self addSubview: overlayView];
    }
}


- (void)renderBanner
{
    if ( nil == self.bannerButton ) {
        UIImage *bannerImage = [self bannerImage];
        
        self.bannerButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [self.bannerButton setImage: bannerImage forState: UIControlStateNormal];
        
        self.bannerButton.frame= CGRectMake(1, self.bounds.size.height + 2, bannerImage.size.width, bannerImage.size.height);
        [self.bannerButton addTarget: self action: @selector(bannerPressed:) forControlEvents: UIControlEventTouchUpInside];
        
        [self addSubview: self.bannerButton];
        [self increaseFrameToHeight: [GUIHelper getBottomYForView: self.bannerButton]];
    }
    else {
        [self.bannerButton setImage: [self bannerImage] forState: UIControlStateNormal];
    }
}


- (UIImage*)bannerImage
{
    NSArray *images = [self.bannerPack imagesForBanners];
    
    if ( 0 == [images count] ) {
        error(@"no banners for pack: %@", self.bannerPack.name);
        return nil;
    }    
    else if ( 1 == [images count] ) {
        return [images objectAtIndex: 0];
    }
    else {
        return [images objectAtIndex: arc4random() % [images count]];
    } 
}


- (void)increaseFrameToHeight: (CGFloat)newHeight
{
    CGRect newFrame = self.frame;
    newFrame.size.height = newHeight;
    self.frame = newFrame;
}


- (void)bannerPressed: (id)sender
{
    debug(@"banner pressed");
    [self.mustacheCurtainView bannerPressed: self];
}


- (void)handleLockedTap: (UITapGestureRecognizer*)tapGesture
{
    if ( UIGestureRecognizerStateEnded == tapGesture.state ) {
        [self bannerPressed: tapGesture];
    }
}


#pragma mark - Public

- (void)renderBannerForPack: (DMPack*)pack
{
    if ( pack == self.pack ) {
        return;
    }
    
    __bannerPack = pack;
    [self renderBanner];
}

@end
