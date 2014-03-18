//
//  PictureViewController.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/18/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <stdlib.h>

#import "AppDelegate.h"
#import "PictureViewController.h"
#import "VoilaViewController.h"
#import "Flurry.h"
#import "GUIHelper.h"
#import "MustacheHighlightedButton.h"
#import "DMPack.h"
#import "DMStache.h"
#import "MAKVONotificationCenter.h"
#import "FlurryAds.h"


#define FLURRY_AD_SPACE @"MB Free Banner" 

static NSString *kTsaiclipBaseName = @"tie-clip";

@interface PictureViewController ()

// Sun add
@property (strong, nonatomic) UIImage *originalImage;


@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSMutableArray *stachesArray;
@property (assign, nonatomic) StacheView *currentStacheView;
@property (strong, nonatomic) UIImageView *stacheColorsImageView;

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

@property (strong, nonatomic) MustacheCurtainView *mustacheCurtainView;
@property (strong, nonatomic) MustacheCurtainView *paidPacksCurtainView;
@property (strong, nonatomic) MustacheCurtainView *packCurtainView;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) UIRotationGestureRecognizer *rotationGesture;

@property (strong, nonatomic) HighlightedButton *recycleButton;
@property (strong, nonatomic) HighlightedButton *changeMustacheButton;
@property (strong, nonatomic) HighlightedButton *addMustacheButton;

@property (assign, nonatomic) HighlightedButton *callerMustacheButton;

@property (strong, nonatomic) HighlightedButton *highHelpButton;
@property (strong, nonatomic) UIImageView *helpOverlayView;
@property (assign, nonatomic) BOOL isHelpOverlayShown;

@property (assign, nonatomic) CGRect sourceImageScaledRect;
@property (strong, nonatomic) UIView *scaledPicView;
@property (assign, nonatomic) CGFloat originalScaleFactor;
@property (assign, nonatomic) CGSize sourceImageSize;
@property (assign, nonatomic) BOOL isCurtainShown;
@property (assign, nonatomic) UIInterfaceOrientation effectiveInterfaceOrientation;
@property (assign, nonatomic) BOOL isFirstLoad;
@property (assign, nonatomic) BOOL shouldLayoutInterface;

@property (nonatomic, strong) HighlightedButton *highDollarButton;
@property (nonatomic, strong) UIAlertView *tsaiclipAlert;

@property (nonatomic, assign) CGPoint highHelpButtonCenterNoBanner;
@property (nonatomic, assign) CGPoint highHelpButtonCenterWithBanner;
@property (nonatomic, assign) CGPoint stacheColorsImageViewCenterNoBanner;
@property (nonatomic, assign) CGPoint stacheColorsImageViewCenterWithBanner;
@property (nonatomic, assign) CGPoint highDollarButtonCenterNoBanner;
@property (nonatomic, assign) CGPoint highDollarButtonCenterWithBanner;

#pragma mark - Banners

@property (nonatomic, strong) UIButton *removeBannerAdButton;

@property (nonatomic, strong) MobclixAdView* mobclixAdView;
@property (nonatomic, assign) BOOL isMobClixBannerShown;
@property (nonatomic, assign) BOOL isMobClixBannerLoaded;
@property (nonatomic, assign) BOOL isSubscrubiedToMobclixKVO;

@property (nonatomic, strong) RevMobBannerView *revMobBannerView;
@property (nonatomic, assign) BOOL isRevMobBannerShown;
@property (nonatomic, assign) BOOL isRevMobBannerLoaded;
@property (nonatomic, assign) BOOL isSubscrubiedToRevMobKVO;

@property (nonatomic, assign) BOOL isFlurryBannerShown;
@property (nonatomic, assign) BOOL isFlurryBannerLoaded;
@property (nonatomic, assign) BOOL isSubscrubiedToFlurryKVO;


#pragma mark - Face Detection

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) NSUInteger mustachesToDropCount;


- (UIImage*)scaleToProductionImage: (UIImage*)image;

- (void)setMustacheBarButtonsEnabled: (BOOL)enabled;
- (void)closeModalViews: (NSNotification*)info;
- (void)layoutImageAndMustahcesToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation;
- (void)layoutCurtainViews;

- (void)subscribeToMobclixBannerKVO;
- (void)unsubscribeFromMobclixBannerKVO;
- (void)removeMobclixAd;
- (void)addMobclixAd;

- (void)makeTopMostView: (UIView*) view;

- (void)goBack: (id)sender;
- (void)goVoila: (id)sender;

- (void)addStache: (id)sender;
- (void)closeMustacheCurtain: (id)sender;
- (void)changeCurrentStacheWithImageArray: (NSArray*)imagesArray stache: (DMStache*)stache;
- (StacheView*)addNewStacheToViewWithImageArray: (NSArray*)imagesArray stache: (DMStache*)stache;
- (void)removeStache: (id)sender;

- (void)addColorIndicator;
- (void)removeColorIndicator;
- (void)updateDollarButton;
- (void)updateColorIndicator;

- (void)buyStache: (id)sender;
- (void)closePaidPacksCurtain: (id)sender;

- (void)closeCurtain: (MustacheCurtainView*)curtainView withCompletion: (void(^)(BOOL finished))block;

- (void)showCurtainForPack: (DMPack*)pack;
- (void)closePackCurtain: (id)sender;

- (void)removeBanner: (id)sender;

- (void)showHelpOverlay: (id)sender;
- (void)hideHelpOverlay: (id)sender;
- (UIImage*)helpOverlayImage;

- (void)showDollarButton;
- (void)hideDollarButton;
- (void)showTsaiclipAlert: (id)sender;

- (UIImage*)exportStachedImage;
- (UIImage*)imageFromStacheView: (StacheView*)stache;
- (CGImageRef)newCGImageRotated:(CGImageRef)imgRef byRadians: (CGFloat)angleInRadians;

- (void)addImageViewGestures;
- (void)removeImageViewGestures;

- (void)tapColorIndicator: (UITapGestureRecognizer*)gestureRecognizer;
- (void)panStache: (UIPanGestureRecognizer*)gestureRecognizer;
- (void)scaleStache: (UIPinchGestureRecognizer*)gestureRecognizer;
- (void)rotateStache: (UIRotationGestureRecognizer*)gestureRecognizer;
- (void)tapImage: (UITapGestureRecognizer*)gestureRecognizer;
- (void)tapHelpOverlay: (UITapGestureRecognizer*)gestureRecognizer;

- (void)disableActiveMustache;

@end 


@implementation PictureViewController
{
    CIDetector *_faceDetector;
    NSArray *_faceFeaturesArray;
    BOOL _faceDetectionCompleted;
    BOOL _isSubscribedToDroppingKVO;
    
    id<MAKVOObservation> _mustachesCountObservation;
    UIView *_flurryAdContainerView;
}

@synthesize sourceImage = __sourceImage;
@synthesize imageView = _imageView;
@synthesize stachesArray = _stachesArray;
@synthesize currentStacheView = _currentStacheView;
@synthesize stacheColorsImageView = _stacheColorsImageView;
@synthesize pinchGesture = _pinchGesture;
@synthesize rotationGesture = _rotationGesture;
@synthesize panGesture = _panGesture;
@synthesize tapGesture = _tapGesture;
@synthesize sourceImageScaledRect = _sourceImageScaledRect;
@synthesize mustacheCurtainView = _mustacheCurtainView;
@synthesize paidPacksCurtainView = _paidPacksCurtainView;
@synthesize packCurtainView = _packCurtainView;
@synthesize recycleButton = _recycleButton;
@synthesize changeMustacheButton = _changeMustacheButton;
@synthesize addMustacheButton = _addMustacheButton;
@synthesize callerMustacheButton = _callerMustacheButton;
@synthesize scaledPicView = _scaledPicView;
@synthesize originalScaleFactor = _originalScaleFactor;
@synthesize sourceImageSize = _sourceImageSize;
@synthesize isCurtainShown = _isCurtainShown;
@synthesize effectiveInterfaceOrientation = _effectiveInterfaceOrientation;
@synthesize helpOverlayView = _helpOverlayView;
@synthesize isHelpOverlayShown = _isHelpOverlayShown;
@synthesize isFirstLoad = _isFirstLoad;
@synthesize shouldLayoutInterface = _shouldLayoutInterface;
@synthesize highDollarButton = _highDollarButton;
@synthesize tsaiclipAlert = _tsaiclipAlert;
@synthesize mobclixAdView = _mobclixAdView;
@synthesize isMobClixBannerShown = _isMobClixBannerShown;
@synthesize isMobClixBannerLoaded = _isMobClixBannerLoaded;
@synthesize isSubscrubiedToMobclixKVO = _isSubscrubiedToMobclixKVO;

@synthesize highHelpButton = _highHelpButton;

@synthesize highHelpButtonCenterNoBanner = _highHelpButtonCenterNoBanner;
@synthesize highHelpButtonCenterWithBanner = _highHelpButtonCenterWithBanner;
@synthesize stacheColorsImageViewCenterNoBanner = _stacheColorsImageViewCenterNoBanner;
@synthesize stacheColorsImageViewCenterWithBanner = _stacheColorsImageViewCenterWithBanner;
@synthesize highDollarButtonCenterNoBanner = _highDollarButtonCenterNoBanner;
@synthesize highDollarButtonCenterWithBanner = _highDollarButtonCenterWithBanner;
@synthesize removeBannerAdButton = _removeBannerAdButton;

@synthesize revMobBannerView = _revMobBannerView;
@synthesize isRevMobBannerShown = _isRevMobBannerShown;
@synthesize isRevMobBannerLoaded = _isRevMobBannerLoaded;
@synthesize isSubscrubiedToRevMobKVO = _isSubscrubiedToRevMobKVO;

@synthesize isFlurryBannerShown;
@synthesize isFlurryBannerLoaded;
@synthesize isSubscrubiedToFlurryKVO;


@synthesize mustachesToDropCount = _mustachesToDropCount;
@synthesize hud = _hud;



#pragma mark - @property (strong, nonatomic) UIImage *sourceImage;

- (UIImage*)scaleToProductionImage: (UIImage*)image
{
    if ( nil == image ) {
        error(@"nil image supplied");
        return nil;
    }
    
    CGFloat maxImageWidth = self.view.frame.size.width * [[UIScreen mainScreen] scale];
    if ( image.size.width < maxImageWidth ) {
        return image;
    }
    else {
        CGFloat scaledPhotoHeight = round((maxImageWidth * image.size.height) / image.size.width);
        UIImage *scaledImage = [GUIHelper imageByScaling: image toSize: CGSizeMake(maxImageWidth, scaledPhotoHeight)];
        return scaledImage;
    }
}


- (void)setSourceImage: (UIImage*)image
{    
    if ( image != __sourceImage ) {
        self.originalImage = image;
        __sourceImage = [self scaleToProductionImage: image];
        
        if ( nil != self.imageView ) {
            self.imageView.image = __sourceImage;
        }
        
        // calculate scaled rect for source image for stached image cropping
        self.sourceImageSize = __sourceImage.size;
        CGFloat xScaleFactor = self.view.frame.size.width / self.sourceImageSize.width;
        CGFloat yScaleFactor = self.toolbar.frame.origin.y / self.sourceImageSize.height;
        self.originalScaleFactor = MIN(xScaleFactor, yScaleFactor);
        
        CGRect scaledRect = CGRectZero;
        scaledRect.size = CGSizeMake(floor(self.sourceImageSize.width * self.originalScaleFactor),
                                     floor(self.sourceImageSize.height * self.originalScaleFactor));
        scaledRect.origin = CGPointMake(self.imageView.center.x - 0.5 * scaledRect.size.width, self.imageView.center.y - 0.5 * scaledRect.size.height);
        
        self.sourceImageScaledRect = scaledRect;
        if ( nil == self.scaledPicView ) {
            self.scaledPicView = [[UIView alloc] initWithFrame: self.sourceImageScaledRect];
            self.scaledPicView.backgroundColor = [UIColor clearColor];//[[UIColor redColor] colorWithAlphaComponent: 0.3];
            [self.imageView addSubview: self.scaledPicView];
        }
    }
}


#pragma mark - Initialization

- (id)initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    if ( self ) {
        self.wantsFullScreenLayout = YES;
        self.stachesArray = [[NSMutableArray alloc] init];
        self.isCurtainShown = NO;
        self.isHelpOverlayShown = NO;
        self.isFirstLoad = YES;
        self.shouldLayoutInterface = NO;
        
        self.isMobClixBannerShown = NO;
        self.isMobClixBannerLoaded = NO;
        self.isSubscrubiedToMobclixKVO = NO;
        
        
        self.isRevMobBannerLoaded = NO;
        self.isRevMobBannerShown = NO;
        self.isSubscrubiedToRevMobKVO = NO;
        
        self.isFlurryBannerLoaded = NO;
        self.isFlurryBannerShown = NO;
        self.isSubscrubiedToFlurryKVO = NO;
        
        _faceDetectionCompleted = NO;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc
{
    [self unsubscribeFromMobclixBannerKVO];
    [self unsubscribeFromRevMobBannerKVO];
    [self unsubscribeFromFlurryBannerKVO];
}


#pragma mark - Face Detections

- (UIView*)dotViewWithCenter: (CGPoint)point color: (UIColor*)color
{
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 10, 10)];
    view.backgroundColor = color;//[color colorWithAlphaComponent: 0.2];
    view.center = point;
    
    return view;
}


- (CGPoint)scaledFeaturePoint: (CGPoint)point
{
    CGFloat scaleFactor = 1 / [[UIScreen mainScreen] scale];
    return CGPointMake(point.x * scaleFactor, self.imageView.frame.size.height - point.y * scaleFactor);
}


- (CGRect)scaledFeatureRect: (CGRect)rect
{
    CGFloat scaleFactor = 1 / [[UIScreen mainScreen] scale];
    return CGRectMake(rect.origin.x * scaleFactor,
                      self.imageView.frame.size.height - (rect.origin.y + rect.size.height) * scaleFactor,
                      rect.size.width * scaleFactor,
                      rect.size.height * scaleFactor);
}


- (void)detectFaceFeaturesWithImage: (UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage: image];
    NSNumber *orientation = @(UIImageOrientationUp);
    
    _faceFeaturesArray = [_faceDetector featuresInImage:ciImage options: @{ CIDetectorImageOrientation : orientation }];
    debug(@"features count: %d", [_faceFeaturesArray count]);
    
    _faceDetectionCompleted = YES;
    [MBProgressHUD hideHUDForView: self.view animated: YES];
    
    if ( 0 < [_faceFeaturesArray count] ) {
        [Flurry logEvent: @"FaceDetected" withParameters: @{ @"count" : [NSString stringWithFormat: @"%d", [_faceFeaturesArray count]] }];
        [self dropMustaches];
    }
    
    debug(@"done analysing features");
}


- (void)addStacheForFeature: (CIFaceFeature*)ff withIndex: (NSUInteger)idx trigger: (int)trigger
{
    if ( trigger ) {
        [self addFreeBeardForFeature: ff withIndex: idx];
    }
    else {
        [self addFreeMustachesForFeature: ff withIndex: idx];
    }
}


- (void)dropMustaches
{
    NSUInteger idx = 0;
    self.mustachesToDropCount = [_faceFeaturesArray count];
    for ( CIFaceFeature *ff in _faceFeaturesArray ) {
        
        int rndTrigger = arc4random() % 2;
        if ( idx % 2 ) {
            [self addStacheForFeature: ff withIndex: idx trigger: rndTrigger];
        }
        else {
            [self addStacheForFeature: ff withIndex: idx trigger: !rndTrigger];
        }
        
        [self addGlassesForFeature: ff withIndex: idx];
        idx++;
        
#if DEBUG_FACES
        UIView *faceView = [[UIView alloc] initWithFrame: [self scaledFeatureRect: [ff bounds]]];
        faceView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent: 0.2];
        [self.scaledPicView addSubview: faceView];
#endif
        
#if DEBUG_FACES
        
        if ( ff.hasLeftEyePosition ) {
            debug(@"leftEyePosition: %@", NSStringFromCGPoint([self scaledFeaturePoint: ff.leftEyePosition]));
            [self.imageView addSubview: [self dotViewWithCenter: [self scaledFeaturePoint: ff.leftEyePosition] color: [UIColor greenColor]]];
        }
        
        if ( ff.hasRightEyePosition ) {
            debug(@"rightEyePosition: %@", NSStringFromCGPoint([self scaledFeaturePoint: ff.rightEyePosition]));
            [self.imageView addSubview: [self dotViewWithCenter: [self scaledFeaturePoint: ff.rightEyePosition] color: [UIColor blueColor]]];
        }
#endif
        
#if DEBUG_FACES
        if ( ff.hasMouthPosition ) {
            debug(@"mouthPosition: %@", NSStringFromCGPoint([self scaledFeaturePoint: ff.mouthPosition]));
            [self.imageView addSubview: [self dotViewWithCenter: [self scaledFeaturePoint: ff.mouthPosition] color: [UIColor blackColor]]];
        }
#endif
	}
}


- (CGFloat)rotationAngleForFaceFeature: (CIFaceFeature*)ff
{
    CGFloat angle = 0.0;
    
    if ( ff.hasLeftEyePosition && ff.hasRightEyePosition ) {
        CGPoint leftPoint = [self scaledFeaturePoint: ff.leftEyePosition];
        CGPoint rightPoint = [self scaledFeaturePoint: ff.rightEyePosition];
        
        CGPoint eyeVector = CGPointMake(rightPoint.x - leftPoint.x, rightPoint.y - leftPoint.y);
        CGFloat cosAngle = eyeVector.x / sqrt(pow(eyeVector.x, 2) + pow(eyeVector.y, 2));
        angle = (rightPoint.y <= leftPoint.y ? -acos(cosAngle) : acos(cosAngle));
    }
    
    return angle;
}


- (StacheView*)addFreeMustacheWithIndex: (NSUInteger)idx
{
    DMPack *freePack = [[DataModel sharedInstance].packsArray objectAtIndex: 0];
    if ( [freePack.staches count] - 1 < idx ) {
        error(@"idx is out of bounds [0 .. %d]", [freePack.staches count]);
        return nil;
    }
    
    DMStache *stache = [freePack.staches objectAtIndex: idx];
    NSArray *imagesArray = [freePack imagesForStaches: stache];
    
    StacheView *stacheView = [self addNewStacheToViewWithImageArray: imagesArray stache: stache];
    [stacheView setColorWithIndex: (arc4random() % [stacheView colorCount])];
    
    return stacheView;
}


- (void)addFreeMustachesForFeature: (CIFaceFeature*)ff withIndex: (NSUInteger)idx
{
    if ( ff.hasMouthPosition ) {
        CGRect scaledFaceRect = [self scaledFeatureRect: [ff bounds]];
        CGPoint scaledMouthPoint = [self scaledFeaturePoint: ff.mouthPosition];
        
        StacheView *stacheView = [self addFreeMustacheWithIndex: 1];
        
        CGFloat mustacheScale = scaledFaceRect.size.width * 1.0 / stacheView.bounds.size.width;
        [stacheView scaleTo: mustacheScale];
        
        CGPoint adjustedMouthPoint = scaledMouthPoint;
        adjustedMouthPoint.y += 0.05 * scaledFaceRect.size.height;
        
        [self animateRoratingDropDown: stacheView toPoint: adjustedMouthPoint withRotationAngle: [self rotationAngleForFaceFeature: ff] delayIndex: idx];
    }
}


- (void)addFreeBeardForFeature: (CIFaceFeature*)ff withIndex: (NSUInteger)idx
{
    if ( ff.hasMouthPosition ) {
        CGRect scaledFaceRect = [self scaledFeatureRect: [ff bounds]];
        CGPoint scaledMouthPoint = [self scaledFeaturePoint: ff.mouthPosition];
        
        StacheView *stacheView = [self addFreeMustacheWithIndex: 12];
        
        CGFloat mustacheScale = scaledFaceRect.size.width * 0.9 / stacheView.bounds.size.width;
        [stacheView scaleTo: mustacheScale];
        
        CGPoint adjustedMouthPoint = scaledMouthPoint;
        adjustedMouthPoint.y += 0.41 * scaledFaceRect.size.height;
        
        [self animateRoratingDropDown: stacheView toPoint: adjustedMouthPoint withRotationAngle: [self rotationAngleForFaceFeature: ff] delayIndex: idx];
    }
}


- (void)animateRoratingDropDown: (StacheView*)stacheView toPoint: (CGPoint)point withRotationAngle: (CGFloat)angle delayIndex: (NSUInteger)idx
{
    // STARTING point of animation
    stacheView.center = CGPointMake(point.x, -stacheView.frame.size.height / 2.0);
    [stacheView rotateTo: angle];
    
    [UIView animateWithDuration: 0.2
                          delay: idx * 0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         stacheView.center = point;
                     }
                     completion: ^(BOOL finished) {
                         [UIView animateWithDuration: 0.07
                                               delay: 0.0
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations: ^{
                                              [stacheView rotateTo: 0.1];
                                          }
                                          completion: ^(BOOL finished){
                                              [UIView animateWithDuration: 0.07
                                                                    delay: 0.0
                                                                  options: UIViewAnimationOptionCurveEaseIn
                                                               animations: ^{
                                                                   [stacheView rotateTo: -0.2];
                                                               }
                                                               completion: ^(BOOL finished) {
                                                                   [UIView animateWithDuration: 0.07
                                                                                         delay: 0.0
                                                                                       options: UIViewAnimationOptionCurveEaseOut
                                                                                    animations: ^{
                                                                                        [stacheView rotateTo: 0.1];
                                                                                    }
                                                                                    completion: nil];
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
}


- (void)addGlassesForFeature: (CIFaceFeature*)ff withIndex: (NSUInteger)idx
{
    if ( ff.hasLeftEyePosition && ff.hasRightEyePosition ) {
        CGRect scaledFaceRect = [self scaledFeatureRect: [ff bounds]];
        CGPoint leftPoint = [self scaledFeaturePoint: ff.leftEyePosition];
        CGPoint rightPoint = [self scaledFeaturePoint: ff.rightEyePosition];
        
        StacheView *stacheView = [self addFreeMustacheWithIndex: 14];
        CGFloat mustacheScale = scaledFaceRect.size.width / stacheView.bounds.size.width;
        [stacheView scaleTo: mustacheScale];
        
        CGFloat centerAdjustment = (rightPoint.y <= leftPoint.y ? 1 : -1);
        CGPoint centerPoint = CGPointMake(leftPoint.x + 0.5 * fabs(rightPoint.x - leftPoint.x), leftPoint.y - centerAdjustment * 0.5 * fabs(rightPoint.y - leftPoint.y));
        
        [self animateTremblingDropDown: stacheView withFinalPoint: centerPoint withRotationAngle: [self rotationAngleForFaceFeature: ff] delayIndex: idx completionBlock: ^{ self.mustachesToDropCount--; }];
    }
}


- (void)animateTremblingDropDown: (StacheView*)stacheView withFinalPoint: (CGPoint)point withRotationAngle: (CGFloat)angle delayIndex: (NSUInteger)idx completionBlock: (void(^)(void))block
{
    // STARTING point of animation
    stacheView.center = CGPointMake(point.x, -stacheView.frame.size.height / 2.0);
    [stacheView rotateTo: angle];
    
    [UIView animateWithDuration: 0.2
                          delay: 0.2 + idx * 0.1
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         stacheView.center = CGPointMake(point.x, point.y + stacheView.frame.size.height * 0.05);
                     }
                     completion: ^(BOOL finished) {
                         [UIView animateWithDuration: 0.2
                                               delay: 0.0
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations: ^{
                                              stacheView.center = CGPointMake(point.x, point.y - stacheView.frame.size.height * 0.02);
                                          }
                                          completion: ^(BOOL finished){
                                              [UIView animateWithDuration: 0.1
                                                                    delay: 0.0
                                                                  options: UIViewAnimationOptionCurveEaseOut
                                                               animations: ^{
                                                                   stacheView.center = point;
                                                               }
                                                               completion: ^(BOOL finished){
                                                                   if ( block ) block();
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
}


#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].applicationFrame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)createToolBar
{
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    //Sun - iPad support
    NSString *arrL = @"arrow-L", *recycleName = @"recycle", *plusName = @"plus", *mustacheName = @"mustache";
    NSString *basketName = @"basket", *shareName = @"share1";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        arrL = @"arrow-L-ipad";
        recycleName = @"recycle-ipad";
        plusName = @"plus-ipad";
        mustacheName = @"mustache-ipad";
        basketName = @"basket-ipad";
        shareName = @"share1-ipad";
    }
    [buttonsArray addObject: [self buttonWithImageNamed: arrL target: self action: @selector(goBack:)]];
    
    self.recycleButton = (HighlightedButton*)[self buttonWithImageNamed: recycleName target: self action: @selector(removeStache:)];
    [buttonsArray addObject: self.recycleButton];
    
    self.addMustacheButton = (HighlightedButton*)[self buttonWithImageNamed: plusName target: self action: @selector(addStache:)];
    [buttonsArray addObject: self.addMustacheButton];
    
    self.changeMustacheButton = (HighlightedButton*)[self buttonWithImageNamed: mustacheName target: self action: @selector(addStache:)];
    [buttonsArray addObject: self.changeMustacheButton];
    
#ifndef MB_LUXURY
    [buttonsArray addObject: [self buttonWithImageNamed: basketName target: self action: @selector(buyStache:)]];
#endif
    
    [buttonsArray addObject: [self buttonWithImageNamed: shareName target: self action: @selector(goVoila:)]];
    
    [self createBottomToolbarWithButtons: buttonsArray];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    debug(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    
    // create BOTTOM TOOLBAR
    [self createToolBar];
    
    // create IMAGE VIEW
    self.imageView = [[UIImageView alloc] initWithFrame:
                      CGRectMake( 0, 0, self.view.frame.size.width, self.toolbar.frame.origin.y)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.sourceImage;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.clipsToBounds = YES;
    [self.view addSubview: self.imageView];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(closeModalViews:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [self setMustacheBarButtonsEnabled: NO];
    
    // create HELP button
    //Sun - ipad support 
    NSString *helpName = @"help";
    NSString *helpPressName = @"help-pressed";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        helpName = @"help-ipad";
        helpPressName = @"help-ipad-pressed";
    }
    
    UIButton *helpButton = [self plainButtonWithImageNamed: helpName
                                          pressedImageName: helpPressName
                                                    target: self
                                                    action: @selector(showHelpOverlay:)];
    self.highHelpButton = [[HighlightedButton alloc] initWithButton: helpButton highlightImageName: nil];
    self.highHelpButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.highHelpButtonCenterNoBanner = CGPointMake(2*17, 2*20);
        self.highHelpButtonCenterWithBanner = CGPointMake(2*17, 100.0);
    }else{
        self.highHelpButtonCenterNoBanner = CGPointMake(17, 20);
        self.highHelpButtonCenterWithBanner = CGPointMake(17, 20 + 45.0);
    }
   
    self.highHelpButton.center = self.highHelpButtonCenterNoBanner;
    
    [self.view addSubview: self.highHelpButton];
    
    // create DOLLAR button
    UIButton *dollarButton = [self plainButtonWithImageNamed: @"dollar"
                                            pressedImageName: @"dollar-pressed"
                                                      target: self
                                                      action: @selector(showTsaiclipAlert:)];
    self.highDollarButton = [[HighlightedButton alloc] initWithButton: dollarButton highlightImageName: nil];
    self.highDollarButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.highDollarButton.hidden = YES;
    self.highDollarButton.button.enabled = NO;
    
    self.highDollarButtonCenterNoBanner = CGPointMake(self.view.frame.size.width - 23, 23);
    self.highDollarButtonCenterWithBanner = CGPointMake(self.view.frame.size.width - 23, 23 + 50.0);
    
    self.highDollarButton.center = self.highDollarButtonCenterNoBanner;
    
    [self.view addSubview: self.highDollarButton];
    
    
    // create REMOVE BANNER Ad button
    
#ifndef MB_LUXURY
    self.removeBannerAdButton = [UIButton buttonWithType: UIButtonTypeCustom];
    NSString *redXname = @"RedXButton.png";
    CGFloat redW = 30, redH = 30;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        redXname = @"RedXButton-ipad.png";
        redW = 60,redH = 60;
    }
    UIImage *closeImage = [UIImage imageNamed: redXname];
    self.removeBannerAdButton.frame = CGRectMake(0, 0, redW, redH);
    [self.removeBannerAdButton setImage: closeImage forState: UIControlStateNormal];
    [self.removeBannerAdButton addTarget: self action: @selector(removeBanner:) forControlEvents: UIControlEventTouchUpInside];
#endif
    
    // ROTATION stuff
    if ( self.isFirstLoad ) {
        self.effectiveInterfaceOrientation = self.interfaceOrientation;
        self.isFirstLoad = NO;
    }
    else // RESTORE after mem-warning
    {
        if ( nil == self.scaledPicView ) {
            self.scaledPicView = [[UIView alloc] initWithFrame: self.sourceImageScaledRect];
            self.scaledPicView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent: 0.3];
            [self.imageView addSubview: self.scaledPicView];
        }
        
        // RENDER staches if available
        for ( StacheView *stacheView in self.stachesArray ) {
            [self.imageView addSubview: stacheView];
        }
        
        self.shouldLayoutInterface = YES;
    }
    
#if NAG_SCREENS_ON
    
//    if ( [DataModel sharedInstance].shouldShowBannerAds ) {
//        self.mobclixAdView = [[MobclixAdViewiPhone_320x50 alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 50.0f)];
//        self.mobclixAdView.delegate = self;
//        [self.view addSubview: self.mobclixAdView];
//        
//        [self subscribeToMobclixBannerKVO];
//    }
    
    if ( [DataModel sharedInstance].shouldShowBannerAds ) {
        debug(@"showing Flurry banners");
        
        [FlurryAds setAdDelegate: self];
        [self subscribeToFlurryBannerKVO];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            _flurryAdContainerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 768, 66)];
            
        }else
        {
            _flurryAdContainerView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 50.0)];
        }

        [self.view addSubview: _flurryAdContainerView];
    }
    
    if ( [DataModel sharedInstance].shouldShowBannerAds ) {
        
        if ( nil == [RevMobAds session] ) {
            debug(@"initializing rev mob");
            [RevMobAds startSessionWithAppID: [DataModel sharedInstance].revMobFullscreenAppId];
        }
        
        //self.revMobBannerView = [[RevMobAds session] bannerView];
        self.revMobBannerView = [[RevMobAds session] bannerViewWithPlacementId: REVMOB_BANNER_ID];
                                 // @"5156fc9b26a2bb1200000051"];
        self.revMobBannerView.delegate = self;
        [self.revMobBannerView loadAd];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
            [self.revMobBannerView setFrame:CGRectMake(0, 0, 768, 66)];
            
        }else
        {
            [self.revMobBannerView setFrame:CGRectMake(0, 0, 320, 50)];
        }
        
        [self.view addSubview: self.revMobBannerView];
        
        [self subscribeToRevMobBannerKVO];
    }
    
#endif
    
    Class CIDetector = NSClassFromString(@"CIDetector");
    if ( nil != CIDetector ) {  // iOS5.0
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    }
}


- (void)setMustacheBarButtonsEnabled: (BOOL)enabled
{
    self.recycleButton.button.enabled = enabled;
    self.changeMustacheButton.button.enabled = enabled;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    debug(@"PICTURE EDIT: did unload");
    
    self.recycleButton = nil;
    self.addMustacheButton = nil;
    self.changeMustacheButton = nil;
    
    self.mustacheCurtainView = nil;
    self.paidPacksCurtainView = nil;
    self.packCurtainView = nil;
    self.helpOverlayView = nil;
    
    self.pinchGesture = nil;
    self.rotationGesture = nil;
    
    self.imageView = nil;
    self.scaledPicView = nil;
    self.tsaiclipAlert = nil;
    
    [self.mobclixAdView cancelAd];
    self.mobclixAdView = nil;
    self.mobclixAdView.delegate = nil;
    
    [DataModel sharedInstance].purchaseDelegate = nil;
    
    [self unsubscribeFromMobclixBannerKVO];
    [self unsubscribeFromRevMobBannerKVO];
    [self unsubscribeFromFlurryBannerKVO];
}


- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    [[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation: UIStatusBarAnimationNone];
    
    if ( self.shouldLayoutInterface ||
        self.effectiveInterfaceOrientation != self.interfaceOrientation ) {
        [self layoutImageAndMustahcesToInterfaceOrientation: self.interfaceOrientation];
        [self layoutCurtainViews];
        self.effectiveInterfaceOrientation = self.interfaceOrientation;
    }
    
    if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
        [self addMobclixAd];
        //[self addRevMobBanner];
        [self addFlurrybBanner];
    }
    
    [DataModel sharedInstance].purchaseDelegate = self;
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear: animated];
    
    [self removeMobclixAd];
    [self removeRevMobBanner];
    [self removeFlurryBanner];
    
    [DataModel sharedInstance].purchaseDelegate = nil;
    
    if ( nil != _mustachesCountObservation ) {
        [_mustachesCountObservation remove];
    }
}


- (void)viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
    //Sun
    [self addRevMobBanner];
    
    if ( nil != _faceDetector ) {
        if ( !_faceDetectionCompleted ) {
            self.hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
            self.hud.delegate = self;
            self.hud.labelText = NSLocalizedString(@"Some magic", @"HUD title");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self detectFaceFeaturesWithImage: [GUIHelper imageFromView: self.imageView]];
            });
            
            if ( ![DataModel sharedInstance].didShowPictureEditInstructions ) {
                [self observeTarget: self keyPath: @"mustachesToDropCount"  options: NSKeyValueObservingOptionNew |
                 NSKeyValueObservingOptionOld block: ^(MAKVONotification *notification) {
                     
                     debug(@"mustachesToDropCount: %d", self.mustachesToDropCount);
                     
                     if ( 0 == self.mustachesToDropCount && ![DataModel sharedInstance].didShowPictureEditInstructions ) {
                         [self showHelpOverlay: self];
                         [DataModel sharedInstance].didShowPictureEditInstructions = YES;
                         
                         [_mustachesCountObservation remove];
                         _mustachesCountObservation = nil;
                     }
                 }];
            }
        }
    }
    else { // CIFaceDetector not available, iOS ver < 5.0
        if ( ![DataModel sharedInstance].didShowPictureEditInstructions ) {
            [self showHelpOverlay: self];
            [DataModel sharedInstance].didShowPictureEditInstructions = YES;
        }
    }
}


- (void)closeModalViews: (NSNotification*)info
{
//    [self.modalViewController dismissModalViewControllerAnimated: NO];
}


#pragma mark - Banners

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"isMobClixBannerShown"]) {
        
        [self supportBannerStatuChange: self.isMobClixBannerShown withBannerView: self.mobclixAdView];
    }
    else if ([keyPath isEqual:@"isRevMobBannerShown"]) {
        
        [self supportBannerStatuChange: self.isRevMobBannerShown withBannerView: self.revMobBannerView];
    }
    else if ([keyPath isEqual:@"isFlurryBannerShown"]) {
        
        [self supportBannerStatuChange: self.isFlurryBannerShown withBannerView: nil];
    }
}


- (void)makeTopMostView: (UIView*) view
{
    int topMostIndex = [self.view.subviews count] - 1;
    UIView *topMostView = [self.view.subviews objectAtIndex: topMostIndex];
    if ( view != topMostView ) {
        debug(@"dragging view overlay to top");
        [self.view exchangeSubviewAtIndex: topMostIndex withSubviewAtIndex: topMostIndex - 1];
    }
}


#pragma mark - Mobclix support methods

- (void)supportBannerStatuChange: (BOOL)bannerShown withBannerView: (UIView*)view
{
    
    if ( bannerShown ) {
        self.highHelpButton.center = self.highHelpButtonCenterWithBanner;
        self.stacheColorsImageView.center = self.stacheColorsImageViewCenterWithBanner;
        self.highDollarButton.center = self.highDollarButtonCenterWithBanner;
        
#ifndef MB_LUXURY
        if ( nil == self.removeBannerAdButton.superview ) {
            
            if ( nil != view ) {
                self.removeBannerAdButton.center =
                CGPointMake(self.view.frame.size.width - self.removeBannerAdButton.frame.size.width,
                            view.frame.size.height * 0.5);
            }
            else {
                self.removeBannerAdButton.center =
                CGPointMake(self.view.frame.size.width - self.removeBannerAdButton.frame.size.width, 25);
            }
            
            
            [self.view addSubview: self.removeBannerAdButton];
            
            if ( self.isCurtainShown || self.isHelpOverlayShown ) {
                int topMostIndex = [self.view.subviews count] - 1;
                [self.view exchangeSubviewAtIndex: topMostIndex withSubviewAtIndex: topMostIndex - 1];
            }
        }
#endif
    }
    else {
        if ( [DataModel sharedInstance].shouldShowBannerAds)
           self.highHelpButton.center = self.highHelpButtonCenterWithBanner;
        else
            self.highHelpButton.center = self.highHelpButtonCenterNoBanner;
        
        self.stacheColorsImageView.center = CGPointMake(self.view.frame.size.width - 40, self.stacheColorsImageViewCenterNoBanner.y);
        self.highDollarButton.center = CGPointMake(self.view.frame.size.width - 23, self.highDollarButtonCenterNoBanner.y);
        
#ifndef MB_LUXURY
        if ( ![DataModel sharedInstance].shouldShowBannerAds)
        [self.removeBannerAdButton removeFromSuperview];
#endif
    }
}


- (void)bringButtonsToFront
{
    [self.view bringSubviewToFront: self.highHelpButton];
    [self.view bringSubviewToFront: self.stacheColorsImageView];
    [self.view bringSubviewToFront: self.highDollarButton];
   
}


- (void)subscribeToMobclixBannerKVO
{
    if ( !self.isSubscrubiedToMobclixKVO ) {
        [self addObserver: self 
               forKeyPath: @"isMobClixBannerShown"
                  options: (NSKeyValueObservingOptionNew |
                            NSKeyValueObservingOptionOld)
                  context: NULL];
        self.isSubscrubiedToMobclixKVO = YES;
    }
}


- (void)unsubscribeFromMobclixBannerKVO
{
    if ( self.isSubscrubiedToMobclixKVO ) {
        [self removeObserver: self
                  forKeyPath: @"isMobClixBannerShown"];
        self.isSubscrubiedToMobclixKVO = NO;
    }
}


- (void)removeMobclixAd
{
    if ( nil != self.mobclixAdView ) {
        [self.mobclixAdView removeFromSuperview];
        [self.mobclixAdView pauseAdAutoRefresh];
        self.isMobClixBannerShown = NO;
    }
}


- (void)addMobclixAd
{
    if ( [DataModel sharedInstance].shouldShowBannerAds ) {
        //[self.view addSubview: self.mobclixAdView];
        //[self bringButtonsToFront];
        
        //[self.mobclixAdView resumeAdAutoRefresh];
        
//        if ( self.isMobClixBannerLoaded ) {
//            self.isMobClixBannerShown = YES;
//        }
    }
}


#pragma mark - RevMob support methods

- (void)subscribeToRevMobBannerKVO
{
    if ( !self.isSubscrubiedToRevMobKVO ) {
        [self addObserver: self
               forKeyPath: @"isRevMobBannerShown"
                  options: (NSKeyValueObservingOptionNew |
                            NSKeyValueObservingOptionOld)
                  context: NULL];
        self.isSubscrubiedToRevMobKVO = YES;
    }
}

- (void)unsubscribeFromRevMobBannerKVO
{
    if ( self.isSubscrubiedToRevMobKVO ) {
        [self removeObserver: self
                  forKeyPath: @"isRevMobBannerShown"];
        self.isSubscrubiedToRevMobKVO = NO;
    }
}

- (void)addRevMobBanner
{
    debug(@"Adding RevMob banner");
    if ( [DataModel sharedInstance].shouldShowBannerAds && nil == self.revMobBannerView.superview ) {
        
        [self.view addSubview: self.revMobBannerView];
        [self bringButtonsToFront];
//        if ( self.isRevMobBannerLoaded ) {
//            self.isRevMobBannerShown = YES;
//        }
        if ( self.isRevMobBannerLoaded ) {
            self.isRevMobBannerShown = YES;
            //[self.view addSubview: self.removeBannerAdButton];
        }
        [self.view addSubview: self.removeBannerAdButton];
        //[self bringButtonsToFront];
        [self.view bringSubviewToFront: self.removeBannerAdButton];
        
    }
}

- (void)removeRevMobBanner
{
    debug(@"removing RevMob banner");
    if ( nil != self.revMobBannerView ) {
//        [self.revMobBannerView removeFromSuperview];
//        self.isRevMobBannerShown = NO;
        [self.revMobBannerView removeFromSuperview];
        self.isRevMobBannerShown = NO;
        [self.removeBannerAdButton removeFromSuperview];
    }
}


#pragma mark - Flurry App Spot support methods

- (void)subscribeToFlurryBannerKVO
{
    if ( !self.isSubscrubiedToFlurryKVO ) {
        [self addObserver: self
               forKeyPath: @"isFlurryBannerShown"
                  options: (NSKeyValueObservingOptionNew |
                            NSKeyValueObservingOptionOld)
                  context: NULL];
        self.isSubscrubiedToFlurryKVO = YES;
    }
}

- (void)unsubscribeFromFlurryBannerKVO
{
    if ( self.isSubscrubiedToFlurryKVO ) {
        [self removeObserver: self
                  forKeyPath: @"isFlurryBannerShown"];
        self.isSubscrubiedToFlurryKVO = NO;
    }
}

- (void)addFlurrybBanner
{
    debug(@"Adding Flurry banner");
    if ( [DataModel sharedInstance].shouldShowBannerAds && !self.isFlurryBannerShown ) {
        
//        [FlurryAds fetchAndDisplayAdForSpace: FLURRY_AD_SPACE view: self.view size: BANNER_TOP];
        [FlurryAds fetchAndDisplayAdForSpace: FLURRY_AD_SPACE view: _flurryAdContainerView size: BANNER_TOP];
        
        if ( self.isFlurryBannerLoaded ) {
            self.isFlurryBannerShown = YES;
        }
    }
}

- (void)removeFlurryBanner
{
    debug(@"removing Flurry banner");
    if ( self.isFlurryBannerShown ) {
        [FlurryAds removeAdFromSpace: FLURRY_AD_SPACE];
        self.isFlurryBannerShown = NO;
        self.isFlurryBannerLoaded = NO;
    }
}


#pragma mark - Rotations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    debug(@"shouldAutorotateToInterfaceOrientation: %d", interfaceOrientation);
    if ( self.isCurtainShown || self.isHelpOverlayShown ) {
        return interfaceOrientation == self.interfaceOrientation;
    }
    else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(interfaceOrientation));
    }
}


- (BOOL)shouldAutorotate
{
    return !(self.isCurtainShown || self.isHelpOverlayShown);
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    debug(@"will animate rotation");
    
    [self layoutImageAndMustahcesToInterfaceOrientation: interfaceOrientation];
    [self layoutCurtainViews];
    [self updateBottomToolbarToInterfaceOrientation: interfaceOrientation];
    self.effectiveInterfaceOrientation = interfaceOrientation;
    
    // adjust Mobclix Ad
    if ( UIInterfaceOrientationIsLandscape(interfaceOrientation) ) {
        [self removeMobclixAd];
        [self removeRevMobBanner];
        [self removeFlurryBanner];
    }
    else if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
        [self addMobclixAd];
        [self addRevMobBanner];
        [self addFlurrybBanner];
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}


- (void)layoutImageAndMustahcesToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
//    debug(@"laying out subviews to interfaceOrientation: %d", interfaceOrientation);
    
    // SAVE mustache centers
    NSMutableArray *oldStacheCenterArray = [[NSMutableArray alloc] init];
    for ( StacheView *stacheView in self.stachesArray ) {
        CGPoint oldStacheCenter = [self.scaledPicView convertPoint: stacheView.center fromView: self.imageView];
        [oldStacheCenterArray addObject: [NSValue valueWithCGPoint: oldStacheCenter]];
    }
    
    // UPDATE imageView frame
    self.imageView.frame = CGRectMake( 0, 0, self.view.frame.size.width, self.toolbar.frame.origin.y);
    
    // CALC changes in height
    CGFloat scaledViewOldHeight;
    CGFloat scaledViewNewHeight;
    
    if ( UIInterfaceOrientationIsLandscape(interfaceOrientation) ) {
        scaledViewOldHeight = self.sourceImageScaledRect.size.height;
        scaledViewNewHeight = self.imageView.frame.size.height;
    }
    else { // Portrait
        scaledViewOldHeight = self.sourceImageScaledRect.size.height;
        scaledViewNewHeight = self.sourceImageSize.height * self.originalScaleFactor;
    }
    
    CGFloat scaledViewScaleRatio = scaledViewNewHeight / scaledViewOldHeight;
    CGRect scaledImageRect = self.sourceImageScaledRect;
    
    if ( UIInterfaceOrientationIsLandscape(interfaceOrientation) ) {
        scaledImageRect.size.width = scaledImageRect.size.width * scaledViewScaleRatio;
        scaledImageRect.size.height = self.imageView.frame.size.height;
        scaledImageRect.origin = CGPointMake(self.imageView.center.x - 0.5 * scaledImageRect.size.width, 0);
    }
    else { // Portrait
        scaledImageRect.size.width = scaledImageRect.size.width * scaledViewScaleRatio;
        scaledImageRect.size.height = scaledImageRect.size.height * scaledViewScaleRatio;
        scaledImageRect.origin = CGPointMake(self.imageView.center.x - 0.5 * scaledImageRect.size.width, self.imageView.center.y - 0.5 * scaledImageRect.size.height);
    }
    
    self.sourceImageScaledRect = scaledImageRect;
    self.scaledPicView.frame = self.sourceImageScaledRect;

    // UPDATE stache positions and size
    [self.stachesArray enumerateObjectsUsingBlock: ^(StacheView *stacheView, NSUInteger idx, BOOL *stop) {
        CGPoint oldStacheCenter = [[oldStacheCenterArray objectAtIndex: idx] CGPointValue];
        CGPoint newStacheCenter = [self.scaledPicView convertPoint:
                                   CGPointMake(oldStacheCenter.x * scaledViewScaleRatio,
                                               oldStacheCenter.y * scaledViewScaleRatio)
                                                            toView: self.imageView];
        
        stacheView.transform = CGAffineTransformScale(stacheView.transform,
                                                      scaledViewScaleRatio,
                                                      scaledViewScaleRatio);
        stacheView.center = newStacheCenter;
    }];
}


- (void)layoutCurtainViews
{
    [self.mustacheCurtainView setNeedsLayout];
    [self.packCurtainView setNeedsLayout];
    [self.paidPacksCurtainView setNeedsLayout];    
}


#pragma mark - Actions

- (void)goBack: (id)sender
{
    [Flurry logEvent: @"BackToStart"];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated: YES];
}


- (void)goVoila: (id)sender
{
    [Flurry logEvent: @"ForwardToVoila"
               withParameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ?
                                 @"portrait" :
                                 @"landscape"), @"orientation", nil]];
    [self disableActiveMustache];
    
    VoilaViewController *voilaViewController = [[VoilaViewController alloc] initWithNibName: nil bundle: nil];
    voilaViewController.sourceImage = [self exportStachedImage];
    //Sun
    voilaViewController.oriImage = self.originalImage;
    
    [self.navigationController pushViewController: voilaViewController animated: YES];
}


- (void)addStache: (id)sender 
{
    if ( nil == self.mustacheCurtainView ) {
        self.mustacheCurtainView = [[MustacheCurtainView alloc] initWithFrame:
                                    CGRectMake(0,
                                               - self.view.bounds.size.height,
                                               self.view.bounds.size.width,
                                               self.view.bounds.size.height)];
        self.mustacheCurtainView.delegate = self;
        [self.mustacheCurtainView setClosingTarget: self action: @selector(closeMustacheCurtain:)];
        [self.mustacheCurtainView renderStaches];
        
        [self.view addSubview: self.mustacheCurtainView];
    }
//    else {
//        [self.mustacheCurtainView redrawStacheBanners];
//    }
    
    if ( [DataModel sharedInstance].redrawMusctaheCurtain ) {
        [self.mustacheCurtainView clearCurtain];
        [self.mustacheCurtainView renderStaches];
        [DataModel sharedInstance].redrawMusctaheCurtain = NO;
    }
    
    [self.view bringSubviewToFront: self.mustacheCurtainView];
    
    if ( sender == self.addMustacheButton.button ) {
        [Flurry logEvent: @"OpenStacheSelectionForAdding"];
        self.callerMustacheButton = self.addMustacheButton;
    }
    else if ( sender == self.changeMustacheButton.button ) {
        [Flurry logEvent: @"OpenStacheSelectionForChanging"];
        self.callerMustacheButton = self.changeMustacheButton;
    }
    else {
        error(@"ACHTUNG! no parent HighlightedButton found for button: %@", sender);
    }
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.mustacheCurtainView.frame = self.view.bounds;
                     }
                     completion: ^(BOOL finished) {
                         self.isCurtainShown = YES;
                         [self makeTopMostView: self.mustacheCurtainView];
                     }
     ];
}


- (void)closeMustacheCurtain: (id)sender
{
    MustacheHighlightedButton *highButton = (MustacheHighlightedButton*)sender;
    
    if ( [highButton isKindOfClass: [MustacheHighlightedButton class]]) {
        [Flurry logEvent: @"MustacheSelected"
                   withParameters: [NSDictionary dictionaryWithObjectsAndKeys:
                                    highButton.stache.title, @"MustacheName",
                                    highButton.pack.name, @"PackName", nil]];
        
        if ( nil != self.callerMustacheButton ) {
            NSArray *imagesArray = [highButton.pack imagesForStaches: highButton.stache];
            if ( self.callerMustacheButton == self.changeMustacheButton ) {
                [self changeCurrentStacheWithImageArray: imagesArray stache: highButton.stache];
            }
            else if ( self.callerMustacheButton == self.addMustacheButton ) {
                [self addNewStacheToViewWithImageArray: imagesArray stache: highButton.stache];
            }
            else {
                error(@"unknown self.callerMustacheButton: %@", self.callerMustacheButton);
            }
            
            self.callerMustacheButton = nil;
        }
        else {
            error(@"self.callerMustacheButton is NIL!");
        }
    }
    else {
        [Flurry logEvent: @"CloseMustacheSelection"];
    }
    
    [self closeCurtain: self.mustacheCurtainView  withCompletion: ^(BOOL finished) {
        self.isCurtainShown = NO;
    }];
}


- (void)changeCurrentStacheWithImageArray: (NSArray*)imagesArray stache: (DMStache*)stache
{
    if ( 0 == [imagesArray count] ) {
        error(@"empty imagesArray. Bailing out");
        return;
    }
    
    self.currentStacheView.stache = stache;
    [self.currentStacheView setNewStacheImageArray: imagesArray];
    [self updateColorIndicator];
//    [self updateDollarButton];
}


- (StacheView*)addNewStacheToViewWithImageArray: (NSArray*)imagesArray stache: (DMStache*)stache
{
    if ( 0 == [imagesArray count] ) {
        error(@"empty imagesArray. Bailing out");
        return nil;
    }
    
    UIImage *image = [imagesArray objectAtIndex: 0];
//    StacheView *newStacheView = [[StacheView alloc] initWithFrame:
//                                 CGRectMake(0, 0,
//                                            0.5 * image.size.width,
//                                            0.5 * image.size.height)
//                                                      imagesArray: imagesArray];
    CGFloat widthImage, heightImage;
    //Sun - iPad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if ([GUIHelper isIPadretina]){//iPad retina
        widthImage = 2*image.size.width;
        heightImage = 2*image.size.height;
        }
        else{
            widthImage = 1.3*image.size.width;
            heightImage = 1.3*image.size.height;
        }
    }
    else if ( [GUIHelper isPhone5] ) {
        widthImage = image.size.width;
        heightImage = image.size.height;
    }
    else {
        widthImage = image.size.width/2;
        heightImage = image.size.height/2;
    }
   // UIImage *scaledImage = [GUIHelper imageByScaling: image toSize: CGSizeMake(widthImage, heightImage)];


    StacheView *newStacheView = [[StacheView alloc] initWithFrame:
                                 CGRectMake(0, 0,
                                            widthImage,
                                            heightImage)
                                                      imagesArray: imagesArray];

    newStacheView.center = self.imageView.center;
    newStacheView.delegate = self;
    [newStacheView setupPinchGestureWithTarget: self action: @selector(scaleStache:) delegate: self];
    [newStacheView setupRotationGestureWithTarget: self action: @selector(rotateStache:) delegate: self];
    newStacheView.stache = stache;

    [self.imageView addSubview: newStacheView];
    [self.stachesArray addObject: newStacheView];
    
    if ( nil != self.currentStacheView ) {
        self.currentStacheView.enabled = NO;
    }
    self.currentStacheView = newStacheView;
    self.currentStacheView.enabled = YES;
    
    [self setMustacheBarButtonsEnabled: YES];
    [self addImageViewGestures];
    [self updateColorIndicator];
//    [self updateDollarButton];
    
    return newStacheView;
}


- (void)removeStache: (id)sender
{
    [Flurry logEvent: @"RemoveStache"];
    
    [self removeImageViewGestures];
    
    [self.currentStacheView removeFromSuperview];
    [self.stachesArray removeObject: self.currentStacheView];
    self.currentStacheView = nil;
    [self setMustacheBarButtonsEnabled: NO];
    [self updateColorIndicator];
//    [self updateDollarButton];
}


- (void)addColorIndicator
{
    if ( nil == self.stacheColorsImageView ) {
        //Sun - iPad support
        NSString *colorName = @"colors.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            colorName = @"colors-ipad.png";
        }
        UIImage *stacheColorsImage = [UIImage imageNamed: colorName];
        self.stacheColorsImageView = [[UIImageView alloc] initWithFrame:
                                      CGRectMake( 0, 0, stacheColorsImage.size.width, stacheColorsImage.size.height)];
        self.stacheColorsImageView.image = stacheColorsImage;
        self.stacheColorsImageView.userInteractionEnabled = YES;
        self.stacheColorsImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        //Sun -iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.stacheColorsImageViewCenterNoBanner = CGPointMake(self.view.frame.size.width - 70 ,  80);
            self.stacheColorsImageViewCenterWithBanner = CGPointMake( self.view.frame.size.width - 70, 140);
        }else{
        self.stacheColorsImageViewCenterNoBanner = CGPointMake(self.view.frame.size.width - 40, 40);
        self.stacheColorsImageViewCenterWithBanner = CGPointMake(self.view.frame.size.width - 35, 40 + 43);
        }
        if ( self.isMobClixBannerShown ) {
            self.stacheColorsImageView.center = self.stacheColorsImageViewCenterWithBanner;
        }
        else {
            if ( self.isRevMobBannerShown ) {
                self.stacheColorsImageView.center = self.stacheColorsImageViewCenterWithBanner;
            }else
            self.stacheColorsImageView.center = self.stacheColorsImageViewCenterNoBanner;
        }
        
        // add TAP gesture recognizer
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(tapColorIndicator:)];
        tapGesture.delegate = self;
        [self.stacheColorsImageView addGestureRecognizer: tapGesture];
    }
    // Sun - iPad
    CGFloat shift = 40;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        shift = 71;
    }

    if ( nil == self.stacheColorsImageView.superview) {
        CGFloat y = 0;
        if ( self.view.frame.size.width - shift != self.stacheColorsImageView.center.x ) { // update position according to orientation
            
            
            if ( self.isMobClixBannerShown ) {
                y = self.stacheColorsImageViewCenterWithBanner.y;
            }
            else {
                if (self.isRevMobBannerShown){
                y = self.stacheColorsImageViewCenterWithBanner.y;
                }else
                    y = self.stacheColorsImageViewCenterNoBanner.y;
            }
            
            self.stacheColorsImageView.center = CGPointMake(self.view.frame.size.width - shift, y);
            
        }else{
            if (self.isRevMobBannerShown ){
                self.stacheColorsImageView.center = self.stacheColorsImageViewCenterWithBanner;
            }
        }
        [self.view addSubview: self.stacheColorsImageView];
        
    }
    
    if ( 0 == self.mustachesToDropCount && [DataModel sharedInstance].shouldShowMustacheColorInstructions ) {
        [DataModel sharedInstance].didShowMustacheColorInstructions = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Tip", @"Alert title")
                                                        message: NSLocalizedString(@"When you see the color wheel icon, you can tap it to change the mustache color.", @"Alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString( @"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }
}


- (void)removeColorIndicator
{
    if ( nil != self.stacheColorsImageView ) {
        [self.stacheColorsImageView removeFromSuperview];
    }
}


- (void)updateColorIndicator
{
    if ( nil == self.currentStacheView ) {
        [self removeColorIndicator];
    }
    else {
        if ( self.currentStacheView.hasMultipleColors ) {
            [self addColorIndicator];
        }
        else {
            [self removeColorIndicator];
        }
    }
}


- (void)updateDollarButton
{
    if ( [self.currentStacheView.stache.baseName isEqualToString: kTsaiclipBaseName] ) {
        [self showDollarButton];
    }
    else {
        [self hideDollarButton];
    }
}


- (void)buyStache: (id)sender
{
    [Flurry logEvent: @"OpenIAPPacksList"];
    
    if ( nil == self.paidPacksCurtainView ) {
        self.paidPacksCurtainView = [[MustacheCurtainView alloc] initWithFrame:
                                    CGRectMake(0,
                                               - self.view.bounds.size.height,
                                               self.view.bounds.size.width,
                                               self.view.bounds.size.height)];
        self.paidPacksCurtainView.delegate = self;
        [self.paidPacksCurtainView setClosingTarget: self action: @selector(closePaidPacksCurtain:)];
        [self.paidPacksCurtainView renderPaidPackBanners];
        
        [self.view addSubview: self.paidPacksCurtainView];
    }
    
    if ( [DataModel sharedInstance].redrawPacksCurtain ) {
        [self.paidPacksCurtainView clearCurtain];
        [self.paidPacksCurtainView renderPaidPackBanners];
        [DataModel sharedInstance].redrawPacksCurtain = NO;
    }
    
    [self.view bringSubviewToFront: self.paidPacksCurtainView];
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.paidPacksCurtainView.frame = self.view.bounds;
                     }
                     completion: ^(BOOL finished) {
                         self.isCurtainShown = YES;
                         [self makeTopMostView: self.paidPacksCurtainView];
                     }
     ];
}


- (void)closePaidPacksCurtain: (id)sender
{
    [Flurry logEvent: @"CloseIAPPacksList"];
    [self closeCurtain: self.paidPacksCurtainView withCompletion: ^(BOOL finished) {
        self.isCurtainShown = NO;
    }];
}


- (void)closeCurtain: (MustacheCurtainView*)curtainView withCompletion: (void(^)(BOOL finished))block
{
    if ( nil != curtainView ) {
        [UIView animateWithDuration: 0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{
                             CGRect newFrame = curtainView.frame;
                             newFrame.origin.y = - self.view.bounds.size.height;
                             curtainView.frame = newFrame;
                         }
                         completion: block
         ];
    }
}


- (void)showCurtainForPack: (DMPack*)pack
{
    if ( nil == self.packCurtainView ) {
        self.packCurtainView = [[MustacheCurtainView alloc] initWithFrame:
                                    CGRectMake(0,
                                               - self.view.bounds.size.height,
                                               self.view.bounds.size.width,
                                               self.view.bounds.size.height)];
        self.packCurtainView.delegate = self;
        [self.packCurtainView setClosingTarget: self action: @selector(closePackCurtain:)];
        [self.view addSubview: self.packCurtainView];
    }
    
    [self.view bringSubviewToFront: self.packCurtainView];
    SKProduct *product = [[DataModel sharedInstance] productForPack: pack];
    
    // format localized price
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale: product.priceLocale];
    NSString *localizedPrice = [numberFormatter stringFromNumber: product.price];
    
    NSString *description = @"";
    if ( 0 < [product.localizedDescription length] ) {
        description = [NSString stringWithFormat: @"%@ - %@", localizedPrice, product.localizedDescription];
    }
    
    [self.packCurtainView renderStachesForPack: pack
                                 withBuyButton: ![pack.bought boolValue]
                                   description: description];
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.packCurtainView.frame = self.view.bounds;
                     }
                     completion: ^(BOOL finished) {
                         self.isCurtainShown = YES;
                         [self makeTopMostView: self.packCurtainView];
                     }
     ];
}


- (void)closePackCurtain: (id)sender
{
    [Flurry logEvent: @"CloseBuyPackCurtain"];
    [self closeCurtain: self.packCurtainView withCompletion: ^(BOOL finished) {
        self.isCurtainShown = NO;
    }];
}


- (void)removeBanner: (id)sender
{
    debug(@"remove banner pressed");
    [[DataModel sharedInstance] removeBannerAd];
}


#pragma mark - Help Overlay

- (void)showHelpOverlay: (id)sender
{
    [Flurry logEvent: @"ShowHelpOverlay"];
    
    self.helpOverlayView = nil;
    if ( nil == self.helpOverlayView ) {
        UIImage *overlayImage = [self helpOverlayImage];
        self.helpOverlayView = [[UIImageView alloc] initWithFrame:
                                CGRectMake(0, -overlayImage.size.height,
                                           overlayImage.size.width, overlayImage.size.height)];
        self.helpOverlayView.image = overlayImage;
        self.helpOverlayView.userInteractionEnabled = YES;
        [self.view addSubview: self.helpOverlayView];
        
        UITapGestureRecognizer *helpOverlayTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapHelpOverlay:)];
        [self.helpOverlayView addGestureRecognizer: helpOverlayTapGesture];
    }
    
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.helpOverlayView.frame = self.view.bounds;
                     }
                     completion: ^(BOOL finished) {
                         self.isHelpOverlayShown = YES;
                     }
     ];
}


- (void)hideHelpOverlay: (id)sender
{
    [Flurry logEvent: @"HideHelpOverlay"];
    
    if ( nil != self.helpOverlayView ) {
        [UIView animateWithDuration: 0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{
                             CGRect newFrame = self.helpOverlayView.frame;
                             newFrame.origin.y = -self.helpOverlayView.frame.size.height;
                             self.helpOverlayView.frame = newFrame;
                         }
                         completion: ^(BOOL finished) {
                             self.isHelpOverlayShown = NO;
                         }
         ];
    }
}


- (UIImage*)helpOverlayImage
{
    //iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return [UIImage imageNamed: @"ov-portrait-version-ipad.png"];
    }else{
    if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
        return [UIImage imageNamed: @"ov-portrait-version.png"];
    }
    else {
        return [UIImage imageNamed: @"ov-landscape-version.png"];
    }
    }
}



#pragma mark - Dollar sign

- (void)showTsaiclipAlert: (id)sender
{
    [Flurry logEvent: @"ShowTsaiClipAlert"];
    
    self.tsaiclipAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Tsaiclip title", @"Tsaiclip alert title")
                                                    message: NSLocalizedString(@"Make a statement with a moustache tie clip from tsaiclip.com!", @"Tsaiclip dollar sign alert text")
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString( @"No Thanks", @"Tsai clip alert - NO")
                                          otherButtonTitles: NSLocalizedString( @"Show Me", @"Tsai clip alert - YES"), nil];
    self.tsaiclipAlert.delegate = self;
    [self.tsaiclipAlert show];
}


- (void)showDollarButton
{
    if ( self.highDollarButton.hidden ) {
        self.highDollarButton.hidden = NO;
        self.highDollarButton.button.enabled = YES;
    }
}


- (void)hideDollarButton
{
    if ( nil != self.highDollarButton.superview ) {
        self.highDollarButton.hidden = YES;
        self.highDollarButton.button.enabled = NO;
    }
}


#pragma mark - Image export

- (UIImage*)exportStachedImage
{
    UIImage *sourceImage = self.imageView.image;
    CGRect imageRect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
    
    if ( 0 == self.originalScaleFactor ) {
        fatal(@"scale factor is 0 !!!");
        return nil;
    }
    
    CGFloat scaleFactor = 1 / self.originalScaleFactor;
    
    if ( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ) {
        scaleFactor *= (self.sourceImageSize.height * self.originalScaleFactor / self.sourceImageScaledRect.size.height);
    }
    
    UIGraphicsBeginImageContextWithOptions(sourceImage.size, NO, 1);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(currentContext, YES);
	CGContextSetInterpolationQuality(currentContext, kCGInterpolationHigh);
    
    // draw Image
    [sourceImage drawInRect: imageRect];
    
    // draw Stache
    for ( StacheView *stache in self.stachesArray ) {
        CGRect drawRect = [self.scaledPicView convertRect: stache.frame fromView: self.imageView];
        
        drawRect.origin.x *= scaleFactor;
        drawRect.origin.y *= scaleFactor;
        drawRect.size.width *= scaleFactor;
        drawRect.size.height *= scaleFactor;
        
        CGImageRef rotatedStacheImg = [self newCGImageRotated: [stache image].CGImage byRadians: [stache rotation]];
        CGContextDrawImage(currentContext, drawRect, rotatedStacheImg);
        CFRelease(rotatedStacheImg);
    }
    
	UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return resultImage;
}


- (UIImage*)imageFromStacheView: (StacheView*)stache
{
    CALayer *layer = stache.layer;
    UIGraphicsBeginImageContextWithOptions([layer frame].size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(currentContext, 0.0, [layer frame].size.height);
    CGContextScaleCTM(currentContext, [stache scale], -[stache scale]);
    CGContextRotateCTM(currentContext, [stache rotation]);
    
    [layer renderInContext: currentContext];
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


- (CGImageRef)newCGImageRotated:(CGImageRef)imgRef byRadians: (CGFloat)angleInRadians
{
//	CGFloat angleInRadians = angle * (M_PI / 180);
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
    
	CGRect imgRect = CGRectMake(0, 0, width, height);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL,
												   rotatedRect.size.width,
												   rotatedRect.size.height,
												   8,
												   0,
												   colorSpace,
												   kCGImageAlphaPremultipliedFirst);
	CGContextSetAllowsAntialiasing(bmContext, YES);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(bmContext,
						  +(rotatedRect.size.width/2),
						  +(rotatedRect.size.height/2));
	CGContextRotateCTM(bmContext, angleInRadians);
    CGContextScaleCTM(bmContext, 1.0, -1.0);
	CGContextDrawImage(bmContext, CGRectMake(-width/2, -height/2, width, height),
					   imgRef);
    
	CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
	CFRelease(bmContext);
    
	return rotatedImage;
}



#pragma mark - Touch handling

- (void)addImageViewGestures
{
    // PINCH
    if ( nil == self.pinchGesture ) {
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                      action: @selector(scaleStache:)];
        self.pinchGesture.delegate = self;
    }
    
    if ( nil == self.pinchGesture.view ) {
        [self.imageView addGestureRecognizer: self.pinchGesture];
    }
    
    // ROTATE
    if ( nil == self.rotationGesture ) {
        self.rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget: self
                                                                            action: @selector(rotateStache:)];
        self.rotationGesture.delegate = self;
    }
    
    if ( nil == self.rotationGesture.view ) {
        [self.imageView addGestureRecognizer: self.rotationGesture];
    }
    
    // PAN
    if ( nil == self.panGesture ) {
        self.panGesture =
        [[UIPanGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(panStache:)];
        self.panGesture.maximumNumberOfTouches = 2;
        self.panGesture.delegate = self;
    }
    
    if ( nil == self.panGesture.view ) {
        [self.imageView addGestureRecognizer: self.panGesture];
    }

    
    // TAP
    if ( nil == self.tapGesture ){
        self.tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(tapImage:)];
        self.tapGesture.delegate = self;
    }
    
    if ( nil == self.tapGesture.view ) {
        [self.imageView addGestureRecognizer: self.tapGesture];
    }
}


- (void)removeImageViewGestures
{
    [self.imageView removeGestureRecognizer: self.pinchGesture];
    [self.imageView removeGestureRecognizer: self.rotationGesture];
    [self.imageView removeGestureRecognizer: self.panGesture];
    [self.imageView removeGestureRecognizer: self.tapGesture];
}


- (void)tapColorIndicator: (UITapGestureRecognizer*)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateEnded ) {
        
        [Flurry logEvent: @"ChangeMustacheColor"];
        [self.currentStacheView nextStacheColor];
    }
}


- (void)panStache: (UIPanGestureRecognizer*)gestureRecognizer
{
    UIView *parentView = gestureRecognizer.view;
    
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan
        || gestureRecognizer.state == UIGestureRecognizerStateChanged )  {
        
        CGPoint translation = [gestureRecognizer translationInView: parentView];

        CGPoint newCenter = CGPointMake(self.currentStacheView.center.x + translation.x,
                                        self.currentStacheView.center.y + translation.y);
        
        if ( 0 < newCenter.x && newCenter.x < parentView.bounds.size.width
            && 0 < newCenter.y && newCenter.y < parentView.bounds.size.height) {
            
            self.currentStacheView.center = newCenter;
        }
        
        [gestureRecognizer setTranslation: CGPointZero inView: parentView];
    }
}


- (void)scaleStache: (UIPinchGestureRecognizer*)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan
        || gestureRecognizer.state == UIGestureRecognizerStateChanged )  {
        
        if ( gestureRecognizer.scale < 1.0
            && self.currentStacheView.frame.size.width <= 40.0) {
            
            gestureRecognizer.scale = 1;
            return;
        }
        else if ( 1.0 < gestureRecognizer.scale
                 && ( self.view.frame.size.width <= self.currentStacheView.frame.size.width
                     || self.view.frame.size.width <= self.currentStacheView.frame.size.height ) ) {
            
            gestureRecognizer.scale = 1;
            return;
        }
        else {
            [self.currentStacheView scaleTo: gestureRecognizer.scale];
            gestureRecognizer.scale = 1;
        }
    }
}


- (void)rotateStache: (UIRotationGestureRecognizer*)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan
        || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        [self.currentStacheView rotateTo: gestureRecognizer.rotation];
        gestureRecognizer.rotation = 0.0;
    }
}


- (void)tapImage: (UITapGestureRecognizer*)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateEnded ) {
        [self disableActiveMustache];
    }
}


- (void)tapHelpOverlay: (UITapGestureRecognizer*)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateEnded ) {
        [self hideHelpOverlay: self];
    }    
}


- (void)disableActiveMustache
{
    self.currentStacheView.enabled = NO;
    self.currentStacheView = nil;
    
    [self removeImageViewGestures];
    [self setMustacheBarButtonsEnabled: NO];
    [self updateColorIndicator];
//    [self updateDollarButton];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer: (UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer: (UIGestureRecognizer *)otherGestureRecognizer
{
    if ( [gestureRecognizer class] == [otherGestureRecognizer class] ) {
        return NO;
    }
    else if ( [gestureRecognizer isKindOfClass: [UITapGestureRecognizer class]]
             && [otherGestureRecognizer isKindOfClass: [UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    return YES;
}


#pragma mark - MustacheCurtainViewDelegate

- (void)bannerPressedForPack: (DMPack*)pack curtainView: (MustacheCurtainView*)curtainView
{
    NSString *sourceCurtain;
    if ( curtainView == self.mustacheCurtainView ) {
        sourceCurtain = @"MustacheSelection";
    }
    else if ( curtainView == self.paidPacksCurtainView ) {
        sourceCurtain = @"IAPPacks";
    }
    
    [Flurry logEvent: @"OpenBannerForPack"
               withParameters: [NSDictionary dictionaryWithObjectsAndKeys: pack.name, @"PackName",
                                sourceCurtain, @"BannerSource",
                                nil]
                        timed: NO];
    
    [self closeCurtain: curtainView withCompletion: ^(BOOL finished){
        [self showCurtainForPack: pack];
    }];
}


- (void)buyNowPressedForPack: (DMPack*)pack curtainView: (id)curtainView
{
    [Flurry logEvent: @"BuyNowPack"
               withParameters: [NSDictionary dictionaryWithObjectsAndKeys: pack.name, @"PackName", nil]
                        timed: NO];
    
    [[DataModel sharedInstance] purchasePack: pack];
}


- (void)restorePurchasesFromCurtainView: (id)curtainView
{
    [Flurry logEvent: @"RestorePurchases"];
    [[DataModel sharedInstance] restorePurchases];
}


- (void)unlockAllPressedFromCurtainView: (id)curtainView
{
    [[DataModel sharedInstance] purchaseUnlockAllMustaches];
}


#pragma mark - StacheViewDelegate

- (void)stacheViewTapped: (StacheView*)stacheView
{
    if ( stacheView == self.currentStacheView ) {
        debug(@"current stache view is active");
        return;
    }
    
    self.currentStacheView.enabled = NO;
    
    self.currentStacheView = stacheView;
    self.currentStacheView.enabled = YES;
    [self.imageView bringSubviewToFront: self.currentStacheView];
    
    [self addImageViewGestures];
    [self updateColorIndicator];
//    [self updateDollarButton];
    [self setMustacheBarButtonsEnabled: YES];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( alertView == self.tsaiclipAlert ) {
        if ( buttonIndex != alertView.cancelButtonIndex ) {
            [Flurry logEvent: @"OpenTsaiClip"
                       withParameters: [NSDictionary dictionaryWithObjectsAndKeys: @"PictureEdit", @"screen", nil]];
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://zfer.us/fl2Rl?d=http://www.tsaiclip.com/products/moustache-tie-clip"]];
        }
        else {
            [Flurry logEvent: @"DontWantTsaiClip"];
        }
    }
    else {
        error(@"uknown alert view: %@", alertView);
    }
}


#pragma mark -
#pragma mark MobclixAdViewDelegate Methods

- (void)adViewDidFinishLoad:(MobclixAdView*)adView
{
//	debug(@"Ad Loaded: %@.", NSStringFromCGSize(adView.frame.size));
    
    if ( nil == self.mobclixAdView.superview ) {
        [self.view addSubview: self.mobclixAdView];
    }
    
    self.isMobClixBannerLoaded = YES;
    self.isMobClixBannerShown = YES;
}

- (void)adView:(MobclixAdView*)adView didFailLoadWithError:(NSError*)error
{
	debug(@"Ad Failed: %@.", NSStringFromCGSize(adView.frame.size));
    
    if ( nil != self.mobclixAdView.superview ) {
        [self.mobclixAdView removeFromSuperview];
    }
    
    self.isMobClixBannerLoaded = NO;
    self.isMobClixBannerShown = NO;
}

- (void)adViewWillTouchThrough:(MobclixAdView*)adView
{
	debug(@"Ad Will Touch Through: %@.", NSStringFromCGSize(adView.frame.size));
}

- (void)adViewDidFinishTouchThrough:(MobclixAdView*)adView
{
	debug(@"Ad Did Finish Touch Through: %@.", NSStringFromCGSize(adView.frame.size));
}

/*******************************************************************************
 MobclixAdViewDelegate Optional Targeting Parameters
 - (NSString*)mcKeywords { }
 - (NSString*)query { }
 
 ******************************************************************************/

#pragma mark - RevMobAdsDelegate

- (void)revmobAdDidReceive
{
    NSLog(@"[RevMob Delegate] Ad loaded.");
    
    if ( nil == self.revMobBannerView.superview ) {
        [self.view addSubview: self.revMobBannerView];
    }
    
    self.isRevMobBannerLoaded = YES;
    self.isRevMobBannerShown = YES;
}

- (void)revmobAdDidFailWithError:(NSError *)error
{
    NSLog(@"[RevMob Delegate] Ad failed: %@", error);
    
    self.isRevMobBannerLoaded = NO;
    self.isRevMobBannerShown = NO;
}

- (void)revmobAdDisplayed
{
    NSLog(@"[RevMob Delegate] Ad displayed.");
}

- (void)revmobUserClosedTheAd
{
    NSLog(@"[RevMob Delegate] User clicked in the close button.");
}

- (void)revmobUserClickedInTheAd
{
    NSLog(@"[RevMob Delegate] User clicked in the Ad.");
}


#pragma mark - DataModelPurchaseDelegate

- (void)updateMustacheCurtain
{
    if ( self.isCurtainShown ) {
        if ( self.mustacheCurtainView.visible ) {
            [self closeCurtain: self.mustacheCurtainView withCompletion: ^(BOOL finished) {
                debug(@"opening mustacheCurtainView again");
                [self addStache: self];
            }];
        }
        else if ( self.paidPacksCurtainView.visible ) {
            [self closeCurtain: self.paidPacksCurtainView withCompletion: ^(BOOL finished) {
                [self buyStache: self];
            }];
        }
        else if ( self.packCurtainView.visible ) {
            [self closeCurtain: self.packCurtainView withCompletion: ^(BOOL finished) {
                [self addStache: self];
            }];
        }
    }
}


- (void)removeAdBanner
{
    [self removeMobclixAd];
    [self removeRevMobBanner];
    [self removeFlurryBanner];
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
	self.hud = nil;
}


#pragma FlurryAdDelegate

- (void) spaceDidReceiveAd:(NSString*)adSpace
{
    debug(@"did receieve add in space: %@", adSpace);
    
    self.isFlurryBannerLoaded = YES;
    self.isFlurryBannerShown = YES;
}

- (void) spaceDidFailToReceiveAd:(NSString*)adSpace error:(NSError *)error
{
    error(@"failed receiving add for space: '%@' with error: %@", adSpace, error);
    
    self.isFlurryBannerLoaded = NO;
    self.isFlurryBannerShown = NO;
}


@end
