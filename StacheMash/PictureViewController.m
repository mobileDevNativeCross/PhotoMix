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
//admob
#import "GADBannerView.h"
#import "GADRequest.h"
#import "appID.h"
 #import "CaptureView.h"

#define FLURRY_AD_SPACE @"MB Free Banner"

static NSString *kTsaiclipBaseName = @"tie-clip";

@interface PictureViewController (){
    BOOL isDragging;
    CGPoint touchLocationMY;
    BOOL touchesEnded;
    NSUserDefaults * defs;
    NSString * valueForAppPurchase;
    float textFieldYpos;
    NSString *descriptionStr;
    UIImage *resIm;
    CaptureView *cloneView;
    float firstHeightVoila;
    float firstWidthVoila;
    UIImageView *myDescrView;
}

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

- (StacheView*)addNewStacheToViewWithImageArrayPurchase: (NSArray*)imagesArray stache: (DMStache*)stache;

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
    UIView *PlaceHoldView;
    MustacheHighlightedButton* highButton2;
    
    UITextView *addDescr;
   
}


//adMob
@synthesize bannerView = bannerView_;
//
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
        CGFloat yScaleFactor = (self.imageView.frame.size.height / self.sourceImageSize.height);
        self.originalScaleFactor = MIN(xScaleFactor, yScaleFactor);
        NSLog(@"originalScaleFactor==%f",self.originalScaleFactor);
        NSLog(@"xScaleFactor==%f",xScaleFactor);
        
        NSLog(@"originalScaleFactor==%f",self.originalScaleFactor);
        
        CGRect scaledRect = CGRectZero;
        scaledRect.size = CGSizeMake(floor(self.sourceImageSize.width * self.originalScaleFactor),
                                     floor(self.sourceImageSize.height * self.originalScaleFactor));
        scaledRect.origin = CGPointMake(self.imageView.center.x - 0.5 * scaledRect.size.width, (self.imageView.frame.size.height-scaledRect.size.height)/2);
        
        if (![MKStoreManager featureAPurchased]|| ![MKStoreManager featureAPurchased]){
            addDescr = [[UITextView alloc] initWithFrame:CGRectMake(self.imageView.center.x - 0.5 * scaledRect.size.width, /*self.view.frame.size.height-80*/468, floor(self.sourceImageSize.width * self.originalScaleFactor),
                                                                    50)];
            myDescrView = [[UIImageView alloc] initWithFrame:CGRectMake(self.imageView.center.x - 0.5 * scaledRect.size.width, self.view.frame.size.height-80, floor(self.sourceImageSize.width * self.originalScaleFactor),
                                                                                     50)];
           // [myDescrView setBackgroundColor:[UIColor redColor]];
        }
        else
        {
            addDescr = [[UITextView alloc] initWithFrame:CGRectMake(self.imageView.center.x - 0.5 * scaledRect.size.width, self.view.frame.size.height-20, floor(self.sourceImageSize.width * self.originalScaleFactor),
                                                                   40)];
        }
               addDescr.textContainer.maximumNumberOfLines = 3;
        addDescr.tintColor = addDescr.backgroundColor;
          cloneView = [[CaptureView alloc] initWithView:addDescr];
        addDescr.text = @"Добавить текст";
        NSLog(@"addDescr=YY=%f",self.view.frame.size.height-80);
       
        
      
        
        // eventually, to see it...
        _myCapt = nil;
        // _myCapt = [[UIImage alloc]init];
        _myCapt = cloneView.imageCapture;
        
        myDescrView.image = _myCapt;
         [self.view addSubview:addDescr];
        //[self.view addSubview:myDescrView];
        [addDescr setDelegate:self];
        
        self.sourceImageScaledRect = scaledRect;
        if ( nil == self.scaledPicView ) {
            self.scaledPicView = [[UIView alloc] initWithFrame: self.sourceImageScaledRect];
            self.scaledPicView.backgroundColor = [UIColor clearColor];//[[UIColor redColor] colorWithAlphaComponent: 0.3];
           // self.scaledPicView.layer.borderWidth = 1;
            //self.scaledPicView.layer.borderColor  = [UIColor greenColor].CGColor;
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
        //[Flurry logEvent: @"FaceDetected" withParameters: @{ @"count" : [NSString stringWithFormat: @"%d", [_faceFeaturesArray count]] }];
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
            //  [self addStacheForFeature: ff withIndex: idx trigger: rndTrigger];
        }
        else {
            //[self addStacheForFeature: ff withIndex: idx trigger: !rndTrigger];
        }
        
        //        [self addGlassesForFeature: ff withIndex: idx];
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
    DMStache *stache;
    @try {
        stache = [freePack.staches objectAtIndex: idx];
    }
    @catch (NSException *exception) {
        
    }
    
    
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
        
        CGFloat mustacheScale = 2;//scaledFaceRect.size.width * 1.0 / stacheView.bounds.size.width;
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
    NSString *arrL = @"back"/*, *plusName = @"recycle" ,mustacheName = @"mustache"*/;
    NSString *recycleName = @"recycle", *shareName = @"next";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        arrL = @"back";
        
       /* plusName = @"plus";*/
        /* mustacheName = @"mustache-ipad";*/
         recycleName = @"recycle-ipad";
        shareName = @"next";
    }
    
    [buttonsArray addObject: [self buttonWithImageNamed: arrL target: self action: @selector(goBack:)]];
    
    //[buttonsArray addObject: [self buttonWithImageNamed: recycleName target: self action: @selector(removeStache:)]];
    
    self.recycleButton = (HighlightedButton*)[self buttonWithImageNamed: recycleName target: self action: @selector(removeStache:)];
    [buttonsArray addObject: self.recycleButton];
    
  
    
#ifndef MB_LUXURY
    //  [buttonsArray addObject: [self buttonWithImageNamed: basketName target: self action: @selector(buyStache:)]];
#endif
    
    [buttonsArray addObject: [self buttonWithImageNamed: shareName target: self action: @selector(goVoila:)]];
    
    [self createBottomToolbar: buttonsArray];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}
//admob request
-(GADRequest *)createReques{
    GADRequest *request = [GADRequest request];
    // request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID,GAD_SIZE_320x50, nil];
    return request;
}
-(NSString *)tP{
    detectIphoneVersion *te = [detectIphoneVersion new];
    return    [te deviceModelName ];
}
-(void)adViewDidReceiveAd:(GADBannerView *)adView
{
    NSLog(@"AD resived==%hhd",[MKStoreManager featureAPurchased]);
    if (![MKStoreManager featureAPurchased]|| ![MKStoreManager featureAPurchased]){ // если не куплена фича 1
    [UIView animateWithDuration:1.0 animations:^{
       // adView.layer.borderColor  = [UIColor redColor].CGColor;
        //adView.layer.borderWidth  = 1;
        
        if([[self tP] isEqualToString:@"iPhone4"]){
           adView.frame = CGRectMake(0, 415,adView.frame.size.width,adView.frame.size.height);
        }
        else{
           adView.frame = CGRectMake(0, 515,adView.frame.size.width,adView.frame.size.height);
        }
     //   [self.view bringSubviewToFront:adView];
       // [self.toolbar sendSubviewToBack:self.mustacheCurtainView];
    }];
    }
}
-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{
    NSLog(@"AD not resived");
}
-(void)removeBannerView{
    [self.bannerView removeFromSuperview];
}
- (BOOL)useEmbeddedWebView
{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    descriptionStr = [[NSString alloc]init];
    [MKStoreManager sharedManager].delegate = self;
    //admob
    self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, -700, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    //self.bannerView.layer.borderColor = [UIColor redColor].CGColor;
    // self.bannerView.layer.borderWidth = 1;
    
    self.bannerView.adUnitID = MyAdUnitID;
    self.bannerView.delegate = self;
    [self.bannerView setRootViewController:self];
    
    [self.view addSubview:self.bannerView];
    [self.bannerView loadRequest:[self createReques]];
    //
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    debug(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    
    // create BOTTOM TOOLBAR
    [self createToolBar];
    [self.view bringSubviewToFront:self.toolbar];
    [self.toolbar sendSubviewToBack:self.mustacheCurtainView];
    //self.toolbar.layer.borderWidth = 1;
   // self.toolbar.layer.borderColor  = [UIColor redColor].CGColor;

    
    // create IMAGE VIEW
    if (![MKStoreManager featureAPurchased]|| ![MKStoreManager featureAPurchased]){
        if([[self tP] isEqualToString:@"iPhone4"]){
            self.imageView = [[UIImageView alloc] initWithFrame:
                              CGRectMake( 0, self.toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(self.toolbar.frame.size.height-5)*2-40)];
            
        }
        else
            self.imageView = [[UIImageView alloc] initWithFrame:
                              CGRectMake( 0, self.toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(self.toolbar.frame.size.height-5)*2-40)];
    }
    else{
        self.imageView = [[UIImageView alloc] initWithFrame:
                          CGRectMake( 0, self.toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-70)];
        
    }
    
    
    
    
    
    
    // _imageView.backgroundColor = [UIColor redColor];
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
    
    //  [self.view addSubview: self.highHelpButton];
    
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
    
    // [self.view addSubview: self.highDollarButton];
    
    
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
    self.removeBannerAdButton.frame = CGRectMake(0, self.view.frame.size.height-redH, redW, redH);
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
        
     //   [FlurryAds setAdDelegate: self];
      //  [self subscribeToFlurryBannerKVO];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
           // _flurryAdContainerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 768, 66)];
            
        }else
        {
            //_flurryAdContainerView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, 320.0, 50.0)];
        }
        
        //  [self.view addSubview: _flurryAdContainerView];
    }
    
    if ( [DataModel sharedInstance].shouldShowBannerAds ) {
        
        if ( nil == [RevMobAds session] ) {
            debug(@"initializing rev mob");
          //  [RevMobAds startSessionWithAppID: [DataModel sharedInstance].revMobFullscreenAppId];
        }
        
        //self.revMobBannerView = [[RevMobAds session] bannerView];
      //  self.revMobBannerView = [[RevMobAds session] bannerViewWithPlacementId: REVMOB_BANNER_ID];
        // @"5156fc9b26a2bb1200000051"];
        //self.revMobBannerView.delegate = self;
        //[self.revMobBannerView loadAd];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
          //  [self.revMobBannerView setFrame:CGRectMake(0, 0, 768, 66)];
            
        }else
        {
            
           
        //    [self.revMobBannerView setFrame:CGRectMake(0, /*self.view.frame.size.height-self.toolbar.frame.size.height*/500, 320, 70)];//dima
        }
        
       // [self.view addSubview: self.revMobBannerView];
        
    //    [self subscribeToRevMobBannerKVO];
    }
    
#endif
    
    Class CIDetector = NSClassFromString(@"CIDetector");
    if ( nil != CIDetector ) {  // iOS5.0
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    }
   
    
}

-(void)textViewDidBeginEditing:(UITextView *)textField {
    if ([textField.text isEqualToString:@"Добавить текст"]) {
        textField.text = @"";
        textField.textColor = [UIColor blackColor]; //optional
    }
    
   
    NSLog(@"Hello==%f",textField.frame.origin.y);
    textFieldYpos = textField.frame.origin.y;
    [UIView animateWithDuration:0.6
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         textField.frame = CGRectMake(textField.frame.origin.x, textField.frame.origin.y-170, textField.frame.size.width, textField.frame.size.height);
                                              }
                     completion:^(BOOL finished) {
                     }];


    //
   // return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
      NSLog(@"Hello2");
   
    
    if(textView.text.length==0)
    textView.text = @"Добавить текст";
    descriptionStr  = textView.text;
    [UIView animateWithDuration:0.6
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         textView.frame = CGRectMake(textView.frame.origin.x, textFieldYpos-2, textView.frame.size.width, textView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                        
                     }];
    /*CaptureView *cloneView = [[CaptureView alloc] initWithView:textView];
    cloneView.layer.borderColor  = [UIColor greenColor].CGColor;
    cloneView.backgroundColor = [UIColor greenColor];
    cloneView.layer.borderWidth  = 1;
    //  [self.view addSubview:cloneView];// eventually, to see it...
    
    myCapt = cloneView.imageCapture;
    
    UIImage *soIm  = [self exportStachedImage];
    resIm  = [self mergeImage:soIm withImage:myCapt];
     */
    // [textField becomeFirstResponder];
       return YES;
}
- (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef)+77;
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef)/2;
    CGFloat secondHeight = CGImageGetHeight(secondImageRef)/2;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight+secondHeight*4.2, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [second drawInRect:CGRectMake(0, firstHeight-5, firstWidth, addDescr.frame.size.height*2)];
    firstHeightVoila = firstHeight;
    firstWidthVoila  = firstWidth;
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
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
    
    //[self unsubscribeFromMobclixBannerKVO];
    //[self unsubscribeFromRevMobBannerKVO];
   // [self unsubscribeFromFlurryBannerKVO];
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
       // [self addFlurrybBanner];
    }
    
    [DataModel sharedInstance].purchaseDelegate = self;
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear: animated];
    
    //[self removeMobclixAd];
  //  [self removeRevMobBanner];
 //   [self removeFlurryBanner];
    
    [DataModel sharedInstance].purchaseDelegate = nil;
    
    if ( nil != _mustachesCountObservation ) {
        [_mustachesCountObservation remove];
    }
}


- (void)viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
    //Sun
   // [self addRevMobBanner];
    
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
                //  self.removeBannerAdButton.center =
                //CGPointMake(self.view.frame.size.width - self.removeBannerAdButton.frame.size.width,
                //          view.frame.size.height);
            }
            else {
                //self.removeBannerAdButton.center =
                //CGPointMake(self.view.frame.size.width - self.removeBannerAdButton.frame.size.width, 25);
            }
            
            
            //  [self.view addSubview: self.removeBannerAdButton]; close adds
            
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
   // [self.view bringSubviewToFront: self.highHelpButton];
    //[self.view bringSubviewToFront: self.stacheColorsImageView];
    //[self.view bringSubviewToFront: self.highDollarButton];
    
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
        
       // [self.view addSubview: self.revMobBannerView];
        [self bringButtonsToFront];
        //        if ( self.isRevMobBannerLoaded ) {
        //            self.isRevMobBannerShown = YES;
        //        }
        if ( self.isRevMobBannerLoaded ) {
            self.isRevMobBannerShown = YES;
            //[self.view addSubview: self.removeBannerAdButton];
        }
      //  [self.view addSubview: self.removeBannerAdButton];
        //[self bringButtonsToFront];
       // [self.view bringSubviewToFront: self.removeBannerAdButton];
        
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
        //[self removeRevMobBanner];
       // [self removeFlurryBanner];
    }
    else if ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ) {
        [self addMobclixAd];
       // [self addRevMobBanner];
        //[self addFlurrybBanner];
    }
}





- (void)layoutImageAndMustahcesToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
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
   // [Flurry logEvent: @"ForwardToVoila"
     // withParameters: [NSDictionary dictionaryWithObjectsAndKeys:
       //                ( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ?
         //               @"portrait" :
           //             @"landscape"), @"orientation", nil]];
    [self disableActiveMustache];
    
    VoilaViewController *voilaViewController = [[VoilaViewController alloc] initWithNibName: nil bundle: nil];
    NSLog(@"addDescr==%@",addDescr);
   /*
    */
    if(addDescr.text.length!=0 && ![addDescr.text isEqual:@"Добавить текст"]){
        cloneView = [[CaptureView alloc] initWithView:myDescrView];
        
                 // eventually, to see it...
        _myCapt = nil;
       // _myCapt = [[UIImage alloc]init];
    _myCapt = cloneView.imageCapture;
       
    UIImage *soIm  = [self exportStachedImage];
        
        
        UIImage *im =   [self drawText:addDescr.text inImage:_myCapt atPoint:CGPointMake(3, 3)];
      //  _myCapt.image = im;
    resIm  = [self mergeImage:soIm withImage:im];
   
    
    voilaViewController.sourceImage = resIm;//[self exportStachedImage];
    }
    else
        voilaViewController.sourceImage = [self exportStachedImage];
    
    voilaViewController.descriptiontext = descriptionStr;
    //Sun
    voilaViewController.oriImage = self.originalImage;

    voilaViewController.firstHeightVoila = firstHeightVoila;
    voilaViewController.firstWidhtVoila = firstWidthVoila;
    
    
    
    
    [self.navigationController pushViewController: voilaViewController animated: YES];
}


- (UIImage*)drawText:(NSString*)string inImage:(UIImage*)image atPoint:(CGPoint)point {
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor blackColor] set];
    [string drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
- (void)addStache: (id)sender
{
    if ( nil == self.mustacheCurtainView ) {
        
        
        NSLog(@"self.view.bounds.size.height==%f",self.view.bounds.size.height);
        self.mustacheCurtainView = [[MustacheCurtainView alloc] initWithFrame:
                                    CGRectMake(0,
                                               - self.view.bounds.size.height,
                                               self.view.bounds.size.width,
                                               self.view.bounds.size.height)];
        self.mustacheCurtainView.delegate = self;
        [self.mustacheCurtainView setClosingTarget: self action: @selector(closeMustacheCurtain:)];
        [self.mustacheCurtainView renderStaches];//dima
        
        [self.view addSubview: self.mustacheCurtainView];
        [self.view bringSubviewToFront:self.toolbar];
        [self.toolbar sendSubviewToBack:self.mustacheCurtainView];
        // [self.view addSubview: self.mustacheCurtainView];
        /*
         UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(SwipeRecognizer:)];
         recognizer.direction = UISwipeGestureRecognizerDirectionDown;
         recognizer.numberOfTouchesRequired = 1;
         recognizer.delegate = self;
         [self.mustacheCurtainView addGestureRecognizer:recognizer];
         */
    }
    //  else {
    //     [self.mustacheCurtainView redrawStacheBanners];
    //}
    
    if ( [DataModel sharedInstance].redrawMusctaheCurtain ) {
        //  [self.mustacheCurtainView clearCurtain];
        [self.mustacheCurtainView renderStaches];
        [DataModel sharedInstance].redrawMusctaheCurtain = NO;
    }
    
  //  [self.view bringSubviewToFront: self.mustacheCurtainView];
    
    if ( sender == self.addMustacheButton.button ) {
        [Flurry logEvent: @"OpenStacheSelectionForAdding"];
        self.callerMustacheButton = self.addMustacheButton;
    }
    else if ( sender == self.changeMustacheButton.button ) {
        [Flurry logEvent: @"OpenStacheSelectionForChanging"];
        //self.callerMustacheButton = self.changeMustacheButton;
        self.callerMustacheButton = self.addMustacheButton;
    }
    else {
        
        error(@"ACHTUNG! no parent HighlightedButton found for button: %@", sender);
        //self.callerMustacheButton = self.changeMustacheButton;
        [Flurry logEvent: @"OpenStacheSelectionForAdding"];
        self.callerMustacheButton = self.addMustacheButton;
        
    }
    
    [UIView animateWithDuration: 1.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         //   self.mustacheCurtainView.frame = self.view.bounds;
                         self.mustacheCurtainView.frame = CGRectMake(0,
                                                                     -5,
                                                                     self.view.bounds.size.width,
                                                                     250);
                     }
                     completion: ^(BOOL finished) {
                         self.isCurtainShown = YES;
                      //   [self makeTopMostView: self.mustacheCurtainView];
                     }
     ];
   
    [self.view bringSubviewToFront:self.toolbar];
    [self.toolbar sendSubviewToBack:self.mustacheCurtainView];

    
    //self.mustacheCurtainView.layer.borderWidth = 3;
   // self.mustacheCurtainView.layer.backgroundColor = [UIColor redColor].CGColor;
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view bringSubviewToFront:self.toolbar];
    [addDescr resignFirstResponder];

    [self.toolbar sendSubviewToBack:self.mustacheCurtainView];
    touchesEnded  =NO;
    UITouch *touch =  [[event touchesForView:self.mustacheCurtainView] anyObject];
    CGPoint touchLocation = [touch locationInView:self.mustacheCurtainView];
    CGRect redDotRect = CGRectMake(0, 0, 320, 10);
    UIView *red = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 80)];
    red.layer.borderWidth  =3;
     touchLocationMY.y = touchLocation.y;
  
    if (!CGRectContainsPoint(redDotRect, touchLocation)) {
        isDragging = YES;
       
        NSLog(@"Red Dot tapped!01==%f",touchLocation.y);
        //   NSLog(@"redDotRect0==%f",self.mustacheCurtainView.frame.origin.y
        //       );
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [UIView animateWithDuration:0.6
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                               //  self.mustacheCurtainView.frame = CGRectMake(0,-5,
                                 //                                            self.view.bounds.size.width,
                                   //                                          250);
                             }
                             completion:^(BOOL finished) {
                             }];
        });
    } else if(touchLocation.y<237 &&touchLocationMY.y>=200.0 ){
        /* self.mustacheCurtainView.frame = CGRectMake(0,
         14,
         self.view.bounds.size.width,
         250);*/
        return;
    }
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchesEnded =  TRUE;
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    NSLog(@"touchLocationMY0==%f",touchLocationMY.y-(self.mustacheCurtainView.frame.size.height/2));
    NSLog(@"touchLocation0==%f",touchLocation.y);
    NSLog(@"Delta==%f",(touchLocationMY.y-(self.mustacheCurtainView.frame.size.height/4))-(touchLocation.y));
    
    
    if((touchLocationMY.y-(self.mustacheCurtainView.frame.size.height/4))-(touchLocation.y)>=0 || (
        touchLocationMY.y-(self.mustacheCurtainView.frame.size.height/4)-(touchLocation.y)>=-80 && touchLocationMY.y-(self.mustacheCurtainView.frame.size.height/4)-(touchLocation.y)<=-50))
        
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:0
                     animations:^{
                         self.mustacheCurtainView.frame = CGRectMake(0,
                                                                     -175,
                                                                     self.view.bounds.size.width,
                                                                     250);
                     }
                     completion:^(BOOL finished) {
                     }];
    else
    {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             self.mustacheCurtainView.frame = CGRectMake(0,
                                                                         -7,
                                                                         self.view.bounds.size.width,
                                                                         250);
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    CGRect redDotRect = [self.mustacheCurtainView frame];
    if (CGRectContainsPoint(redDotRect, touchLocation)) {
        
        if(abs(touchLocationMY.y-touchLocation.y)>0 && abs(touchLocationMY.y-touchLocation.y)<2)
         //   [self closeCurtain: self.mustacheCurtainView  withCompletion: ^(BOOL finished) {
           //     self.isCurtainShown = NO;
            //}];
        
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                               self.mustacheCurtainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    isDragging = NO;
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
                             
                             curtainView.frame = CGRectMake(0, -170, 320, 250);
                         }
                         completion: block
         ];
    }
    [self.view bringSubviewToFront:self.toolbar];
    [self.toolbar sendSubviewToBack:self.mustacheCurtainView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIView class]])
    {
        return YES;
    }
    return NO;
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
   
    
    if (isDragging) {
        [UIView animateWithDuration:0.0f
                              delay:0.0f
                            options:(UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut)
                         animations:^{
                             
                             //if(self.mustacheCurtainView.center.y<118.0 && touchLocation.y>40) {
                             
                            if(touchLocationMY.y-(touchLocation.y+5)>=0 && self.mustacheCurtainView.center.y>-58.0 && self.mustacheCurtainView.center.y<=120 && touchLocation.y>0)
                            {
                               
                               // NSLog(@"touchesMoved0==%f",self.mustacheCurtainView.center.y);
                                //NSLog(@"touchLocationMY0==%f",touchLocationMY.y);
                                //NSLog(@"touchLocation0==%f",touchLocation.y);
                                 self.mustacheCurtainView.center = CGPointMake(self.view.frame.size.width/2, touchLocation.y-(self.mustacheCurtainView.frame.size.height-5)/2);
                                
                            }
                            else if( self.mustacheCurtainView.center.y>=-60.0 &&self.mustacheCurtainView.center.y<=-58.0 && self.mustacheCurtainView.center.y<=120 && (touchLocationMY.y-touchLocation.y)<=0 &&touchLocation.y>0)
                            {
                                NSLog(@"touchesMoved1==%f",self.mustacheCurtainView.center.y);
                                NSLog(@"touchLocationMY1==%f",touchLocationMY.y);
                                NSLog(@"touchLocation1==%f",touchLocation.y);
                                self.mustacheCurtainView.center = CGPointMake(self.view.frame.size.width/2, touchLocation.y-(self.mustacheCurtainView.frame.size.height)/2);
                                                            }
                           /* else
                             {
                                 NSLog(@"touchesMoved==%f",self.mustacheCurtainView.center.y);
                                 NSLog(@"touchLocationMY==%f",touchLocationMY.y);
                                 NSLog(@"touchLocation==%f",touchLocation.y);
                                 self.mustacheCurtainView.frame = CGRectMake(0,
                                                                             -170,
                                                                             self.view.bounds.size.width,
                                                                             250);
                             }
                             */
                            // NSLog(@"touchLocationMY==%f",touchLocationMY.y);
                             //NSLog(@"touchLocation==%f",touchLocation.y);

                                   //NSLog(@"touchesMoved==%f",self.mustacheCurtainView.center.y);
                                   [self.view bringSubviewToFront:self.toolbar];
                             [self.toolbar sendSubviewToBack:self.mustacheCurtainView];
                         }
                         completion:NULL];
    }
}

-(void)closeView{
     self.toolbar.hidden  = NO;
    [PlaceHoldView removeFromSuperview];
}
- (void)closeMustacheCurtain: (id)sender
{
     defs = [[NSUserDefaults alloc]init];
    [defs synchronize];
    MustacheHighlightedButton *highButton = (MustacheHighlightedButton*)sender;
    NSLog(@"highButtonhighButtonhighButton==%d",highButton.tag);
    if ( [highButton isKindOfClass: [MustacheHighlightedButton class]]) {
        [Flurry logEvent: @"MustacheSelected"
          withParameters: [NSDictionary dictionaryWithObjectsAndKeys:
                           highButton.stache.title, @"MustacheName",
                           highButton.pack.name, @"PackName", nil]];
        
        // if ( nil != self.callerMustacheButton ) {
        NSArray *imagesArray = [highButton.pack imagesForStaches: highButton.stache];
        //NSLog(@"highButton.stache==%@",highButton.stache);
        NSLog(@"imagesArray==%@",highButton.stache.title);

        //   NSLog(@"highButton.pack==%@",highButton.pack);
        // if ( self.callerMustacheButton == self.changeMustacheButton ) {
        //   [self changeCurrentStacheWithImageArray: imagesArray stache: highButton.stache];
        //}
        //else if ( self.callerMustacheButton == self.addMustacheButton ) {
         valueForAppPurchase  = [[NSString alloc]initWithFormat:@"%@",highButton.stache ];
       
        
        if(highButton.tag==1 || highButton.tag==[defs integerForKey:valueForAppPurchase])
        [self addNewStacheToViewWithImageArray: imagesArray stache: highButton.stache];
        
        else if(highButton.tag>1 && highButton.tag!=[defs integerForKey:valueForAppPurchase])
        {
            NSLog(@"APPPPPPP");
            UIButton *byOnePict = [UIButton buttonWithType: UIButtonTypeCustom];
            NSString *nameForButton = [[NSString alloc]initWithFormat:@" Buy %@",highButton.stache.title ];
           // [byOnePict setContentMode:UIViewContentModeScaleAspectFill];
       //     byOnePict.contentHorizontalAlignment= UIControlContentHorizontalAlignmentFill;
            
            [byOnePict setTitle:nameForButton forState:UIControlStateNormal];
            byOnePict.titleLabel.adjustsFontSizeToFitWidth = YES;
           // [byOnePict sizeToFit];
            [byOnePict addTarget:self action:@selector(byOnePict:) forControlEvents:UIControlEventTouchUpInside];
            
         //   [byOnePict performSelector:@selector(byOnePict:) withObject:@"SDSD"];
            byOnePict.frame = CGRectMake(0, 480, 140, 44);
            byOnePict.tag =highButton.tag;
          //  byOnePict.titleLabel.text  = @"SDSD";
            [PlaceHoldView addSubview:byOnePict];
            byOnePict.layer.borderWidth  =1;
            byOnePict.layer.borderColor = [UIColor whiteColor
                                           ].CGColor;
//by all button
            UIButton *byAll = [UIButton buttonWithType: UIButtonTypeCustom];
            
            [byAll setTitle:@"By All" forState:UIControlStateNormal];
            [byAll addTarget:self action:@selector(byAll:) forControlEvents:UIControlEventTouchUpInside];
            byAll.frame = CGRectMake(180, 480
                                     , 140, 44);
            byAll.tag =highButton.tag;
            
            byAll.layer.borderWidth  =1;
            byAll.layer.borderColor = [UIColor whiteColor
                                           ].CGColor;
          
//
            PlaceHoldView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];//
            UIImageView *TopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_bar_black.png"]];
            NSString *string = [[NSString alloc]initWithFormat:@"%@",highButton.stache.title ];
            UILabel *nameOfPurchase = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 30)];
            nameOfPurchase.textAlignment = NSTextAlignmentCenter;
           // nameOfPurchase.layer.borderWidth = 3;
            //nameOfPurchase.layer.borderColor  = [UIColor redColor].CGColor;
            [nameOfPurchase setText:string];
            [nameOfPurchase setTextColor:[UIColor whiteColor]];
            nameOfPurchase.textColor = [UIColor whiteColor];
            [PlaceHoldView addSubview:nameOfPurchase];
            
//Price fo feature 1
            UILabel *pricePict1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 407, 300, 30)];
            UILabel *pricePict1pr = [[UILabel alloc] initWithFrame:CGRectMake(295, 407, 20, 30)];
            [pricePict1pr setText:@"1€"];
             [PlaceHoldView addSubview:pricePict1pr];
             pricePict1pr.textColor = [UIColor whiteColor];
            NSString *priceForSample = [[NSString alloc]initWithFormat:@"Price for %@",highButton.stache.title ];
            [pricePict1 setText:priceForSample];
            [pricePict1 setTextColor:[UIColor whiteColor]];
            pricePict1.textColor = [UIColor whiteColor];
            [PlaceHoldView addSubview:pricePict1];
//Price fo feature All
            UILabel *priceAll = [[UILabel alloc] initWithFrame:CGRectMake(10, 437, 320, 30)];
            [priceAll setText:@"Price for all pictures                            3€"];
            [priceAll setTextColor:[UIColor whiteColor]];
            priceAll.textColor = [UIColor whiteColor];
            [PlaceHoldView addSubview:priceAll];
//Notes
            UILabel *notes = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height-30, 320, 30)];
            
            notes.font = [UIFont fontWithName:@"Arial" size:12];
            
            [notes setText:@"После покупки реклама убирается"];
            [notes setTextColor:[UIColor whiteColor]];
            notes.textColor = [UIColor whiteColor];
            [PlaceHoldView addSubview:notes];
            
            
            [PlaceHoldView addSubview:byOnePict];
              [PlaceHoldView addSubview:byAll];
            TopView.frame = CGRectMake(0, 0, 320, TopView.frame.size.height/2);
            [self.view addSubview:TopView];
            PlaceHoldView.backgroundColor = [UIColor blackColor];
            [self.view addSubview:PlaceHoldView];
            self.toolbar.hidden  = YES;
//            [self.view setUserInteractionEnabled:NO];
            [self createToolBar1];
            [self addNewStacheToViewWithImageArrayPurchase: imagesArray stache: highButton.stache];

        }
        //}
        //else {
        //  error(@"unknown self.callerMustacheButton: %@", self.callerMustacheButton);
        //[self addNewStacheToViewWithImageArray: imagesArray stache: highButton.stache];
        
        //}
        
        self.callerMustacheButton = nil;
        //  }
        //  else {
        //    error(@"self.callerMustacheButton is NIL!");
        //  [self addNewStacheToViewWithImageArray: imagesArray stache: highButton.stache];
        //}
    }
    else {
        [Flurry logEvent: @"CloseMustacheSelection"];
    }
    
    [self closeCurtain: self.mustacheCurtainView  withCompletion: ^(BOOL finished) {
        self.isCurtainShown = NO;
    }];
}
-(void)byOnePict:(id)feature{
     NSLog(@"Feate====%@",valueForAppPurchase);
      MustacheHighlightedButton* highButton = (MustacheHighlightedButton*)feature;
///       MustacheHighlightedButton *highButton = (MustacheHighlightedButton*)feature;
   // NSString * valueForAppPurchase  = [[NSString alloc]initWithFormat:@"%@",highButton.stache ];
   

   [[MKStoreManager sharedManager] buyFeatureB:highButton.tag :valueForAppPurchase];
    // [defs setInteger: highButton.tag forKey:valueForAppPurchase];
}
-(void)byAll:(id)feat{
    [[MKStoreManager sharedManager] buyFeatureA:1:@"AllPict"];
}
- (void)createToolBar1
{
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    //Sun - iPad support
    NSString *arrL = @"back"/*, *plusName = @"recycle" ,mustacheName = @"mustache"*/;
  //  NSString *recycleName = @"recycle", *shareName = @"next";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        arrL = @"back";
        
        /* plusName = @"plus";*/
        /* mustacheName = @"mustache-ipad";*/
     //   recycleName = @"recycle-ipad";
       // shareName = @"next";
    }
    
    [buttonsArray addObject: [self buttonWithImageNamed: arrL target: self action: @selector(closeView)]];
    
    //[buttonsArray addObject: [self buttonWithImageNamed: recycleName target: self action: @selector(removeStache:)]];
    
   // self.recycleButton = (HighlightedButton*)[self buttonWithImageNamed: recycleName target: self action: @selector(removeStache:)];
  //  [buttonsArray addObject: self.recycleButton];
    
    // self.addMustacheButton = (HighlightedButton*)[self buttonWithImageNamed: plusName target: self action: @selector(goBack:)];
    //[buttonsArray addObject: self.addMustacheButton];
    
    // self.changeMustacheButton = (HighlightedButton*)[self buttonWithImageNamed: mustacheName target: self action: @selector(addStache:)];
    //[buttonsArray addObject: self.changeMustacheButton];
    
#ifndef MB_LUXURY
    //  [buttonsArray addObject: [self buttonWithImageNamed: basketName target: self action: @selector(buyStache:)]];
#endif
    
   // [buttonsArray addObject: [self buttonWithImageNamed: shareName target: self action: @selector(goVoila:)]];
    
    [self createBottomToolbarPurchase: buttonsArray];
}

- (void)changeCurrentStacheWithImageArray: (NSArray*)imagesArray stache: (DMStache*)stache
{
    if ( 0 == [imagesArray count] ) {
        error(@"empty imagesArray. Bailing out");
        return;
    }
    
    self.currentStacheView.stache = stache;
    [self.currentStacheView setNewStacheImageArray: imagesArray];
    // [self updateColorIndicator];
    //    [self updateDollarButton];
}

- (StacheView*)addNewStacheToViewWithImageArrayPurchase: (NSArray*)imagesArray stache: (DMStache*)stache
{
    if ( 0 == [imagesArray count] ) {
        error(@"empty imagesArray. Bailing out");
        return nil;
    }
    NSLog(@"imagesArray====%@",[imagesArray objectAtIndex: 0]);
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
                                 CGRectMake(25 , 105,
                                            widthImage*4,
                                            heightImage*4)
                                                      imagesArray: imagesArray];
    NSLog(@"self.imageView.center==%f",self.imageView.center.x);
    //newStacheView.center = self.imageView.center;
    newStacheView.delegate = self;
   // newStacheView.layer.borderWidth  =3;
   // newStacheView.layer.borderColor = [UIColor redColor].CGColor;
    
   // [newStacheView setupPinchGestureWithTarget: self action: @selector(scaleStache:) delegate: self];
   // [newStacheView setupRotationGestureWithTarget: self action: @selector(rotateStache:) delegate: self];
   // newStacheView.stache = stache;
    
    [PlaceHoldView addSubview: newStacheView];//add stache to view
    
    
    
   // [self.stachesArray addObject: newStacheView];
    
    //if ( nil != self.currentStacheView ) {
      //  self.currentStacheView.enabled = NO;
   // }
    //self.currentStacheView = newStacheView;
    //self.currentStacheView.enabled = YES;
    
    //[self setMustacheBarButtonsEnabled: YES];
  //  [self addImageViewGestures];
    //  [self updateColorIndicator];
    //    [self updateDollarButton];
    
    return newStacheView;
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
    //[self updateColorIndicator];
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
        //   [self.view addSubview: self.stacheColorsImageView];
        
    }
    
    if ( 0 == self.mustachesToDropCount && [DataModel sharedInstance].shouldShowMustacheColorInstructions ) {
        [DataModel sharedInstance].didShowMustacheColorInstructions = YES;
        
        /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Tip", @"Alert title")
         message: NSLocalizedString(@"When you see the color wheel icon, you can tap it to change the mustache color.", @"Alert text")
         delegate: nil
         cancelButtonTitle: NSLocalizedString( @"Dismiss", @"")
         otherButtonTitles: nil];
         [alert show];*/
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
    
   // [self.view bringSubviewToFront: self.paidPacksCurtainView];
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.paidPacksCurtainView.frame = self.view.bounds;
                     }
                     completion: ^(BOOL finished) {
                         self.isCurtainShown = YES;
                       //  [self makeTopMostView: self.paidPacksCurtainView];
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
    
    //[self.view bringSubviewToFront: self.packCurtainView];
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
                        // [self makeTopMostView: self.packCurtainView];
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
    debug(@"remove banner pressed0");
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
        //[self.view addSubview: self.helpOverlayView];
        
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
    NSLog(@"scaleFactor==%f",scaleFactor);
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
        //  NSLog(@"newCenter.x==%f",newCenter.x);
       // NSLog(@"parentView.bounds.size.width%f",parentView.bounds.size.width);
        
        
        

        if ( 0 < newCenter.x && newCenter.x < parentView.bounds.size.width
            && 0 < newCenter.y && newCenter.y < parentView.bounds.size.height-self.currentStacheView.frame.size.height/2+5) {
            
            self.currentStacheView.center = newCenter;
            NSLog(@"newCenter.y%f",newCenter.y);
            NSLog(@"parentView.bounds.size.height%f",parentView.bounds.size.height);
        }
        
        [gestureRecognizer setTranslation: CGPointZero inView: parentView];
    }
}


- (void)scaleStache: (UIPinchGestureRecognizer*)gestureRecognizer
{
    NSLog(@"gestureRecognizer.scale ==%f",gestureRecognizer.scale);
    if ( gestureRecognizer.state == UIGestureRecognizerStateBegan
        || gestureRecognizer.state == UIGestureRecognizerStateChanged )  {
        
        if ( gestureRecognizer.scale < 1.0
            && self.currentStacheView.frame.size.width <= 0.0) {
            
            gestureRecognizer.scale = 0.5;
            
            return;
        }
        else if ( 1.0 < gestureRecognizer.scale
                 && ( self.view.frame.size.width <= self.currentStacheView.frame.size.width
                     || self.view.frame.size.width <= self.currentStacheView.frame.size.height ) ) {
                     NSLog(@"1.0 < gestureRecognizer.scale");
                     gestureRecognizer.scale = 1;
                     return;
                 }
        else {
            NSLog(@"else < gestureRecognizer.scale");
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
   // [self.imageView bringSubviewToFront: self.currentStacheView];
    
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
       // [self.view addSubview: self.revMobBannerView];
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
    //[self removeMobclixAd];
    //[self removeRevMobBanner];
  //  [self removeFlurryBanner];
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
	[hud removeFromSuperview];
   	self.hud = nil;
    [self addStache:self];//show curtain
    
}

-(void)curtainViewShow:(id)sender{
    if ( [DataModel sharedInstance].redrawMusctaheCurtain ) {
        [self.mustacheCurtainView clearCurtain];
        [self.mustacheCurtainView renderStaches];
        [DataModel sharedInstance].redrawMusctaheCurtain = NO;
    }
    
   // [self.view bringSubviewToFront: self.mustacheCurtainView];
    
    // if ( sender == self.addMustacheButton.button ) {
    //   [Flurry logEvent: @"OpenStacheSelectionForAdding"];
    self.callerMustacheButton = self.addMustacheButton;
    //}
    //else if ( sender == self.changeMustacheButton.button ) {
    //  [Flurry logEvent: @"OpenStacheSelectionForChanging"];
    //self.callerMustacheButton = self.changeMustacheButton;
    // }
    // else {
    //   error(@"ACHTUNG! no parent HighlightedButton found for button: %@", sender);
    //}
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.mustacheCurtainView.frame = self.view.bounds;
                     }
                     completion: ^(BOOL finished) {
                         self.isCurtainShown = YES;
                       //  [self makeTopMostView: self.mustacheCurtainView];
                     }
     ];
    
    
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
