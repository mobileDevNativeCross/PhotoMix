//
//  StacheView.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/19/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StacheView.h"
#import "GUIHelper.h"

@interface StacheView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (assign, nonatomic) CGFloat actualScale;
@property (assign, nonatomic) CGFloat actualRotation;

@property (strong, nonatomic) NSArray *imagesArray;
@property (assign, nonatomic) NSInteger currentStacheImageIndex;

@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) UIRotationGestureRecognizer *rotationGesture;

@property (strong, nonatomic) UIView *handlesView;


- (void)setActive;
- (void)setInactive;

- (CGRect)handlesFrameForRect: (CGRect)frame;
- (void)handleTap: (UITapGestureRecognizer*)gestureRecognizer;

@end


@implementation StacheView

@synthesize delegate = __delegate;
@synthesize hasMultipleColors = __hasMultipleColors;

@synthesize imageView = _imageView;
@synthesize actualScale = _actualScale;
@synthesize actualRotation = _actualRotation;
@synthesize imagesArray = _imagesArray;
@synthesize currentStacheImageIndex = _currentStacheImageIndex;
@synthesize pinchGesture = _pinchGesture;
@synthesize rotationGesture = _rotationGesture;
@synthesize enabled = _enabled;
@synthesize handlesView = _handlesView;
@synthesize stache = _stache;


#pragma mark - @property (nonatomic, assign) BOOL enabled;

- (void)setEnabled: (BOOL)enabled
{
    if ( enabled == _enabled ) {
        return;
    }
    else {
        _enabled = enabled;
        
        if (self.enabled) {
            [self setActive];
        }
        else {
            [self setInactive];
        }
    }
}


- (void)setActive
{
    [self.pinchGesture setEnabled: YES];
    [self.rotationGesture setEnabled: YES];
    
    [self addSubview: self.handlesView];
    [self sendSubviewToBack: self.handlesView];
}


- (void)setInactive
{
    [self.pinchGesture setEnabled: NO];
    [self.rotationGesture setEnabled: NO];
    
    [self.handlesView removeFromSuperview];
}


- (BOOL)enabled
{
    return _enabled;
}


#pragma mark - View Setup

- (id)initWithFrame: (CGRect)frame imagesArray: (NSArray*)imagesArray;
{
    if ( 0 == [imagesArray count] ) {
        error(@"empty imagesArray supplied");
        return nil;
    }
    
    self = [super initWithFrame: frame];
    if ( self ) {
        self.imagesArray = imagesArray;
        self.actualScale = 1.0;
        self.actualRotation = 0.0;
        self.currentStacheImageIndex = 0;
        __hasMultipleColors = (1 < [self.imagesArray count]);
                
        UIImage *image = [self.imagesArray objectAtIndex: self.currentStacheImageIndex];
        self.imageView = [[UIImageView alloc] initWithFrame: frame];
        self.imageView.center = CGPointMake(0.5 * frame.size.width, 0.5 * frame.size.height);
        self.imageView.image = image;
        [self addSubview: self.imageView];
 
        // add TAP gesture recognizer
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(handleTap:)];
        [self addGestureRecognizer: tapGesture];
        
        self.handlesView = [[UIView alloc] initWithFrame: [self handlesFrameForRect: frame]];
        self.handlesView.center = self.imageView.center;
        self.handlesView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.05];
        //self.handlesView.layer.borderWidth = 1.0;
        self.handlesView.layer.borderColor = [UIColor colorWithWhite: 0.9 alpha: 0.6].CGColor;
//        self.handlesView.layer.cornerRadius = (100 < image.size.width ? 15.0 : 5.0);
        UIView * view = [[UIView alloc] init];
        view.layer.borderWidth  =1;
        CGRect btnFrame = CGRectMake(0, 0, 4, 1);

       view.frame= btnFrame;
        [self.handlesView addSubview:view];
        view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, 1, 4);
        view.layer.borderWidth  =1;
         [self.handlesView addSubview:view];
        
        view = [[UIView alloc] init];
        view.frame = CGRectMake(self.handlesView.frame.size.width, 0, 1, 4);
        view.layer.borderWidth  =1;
        [self.handlesView addSubview:view];

        
        view = [[UIView alloc] init];
        view.frame = CGRectMake(self.handlesView.frame.size.width-3, 0, 3, 1);
        view.layer.borderWidth  =1;
        [self.handlesView addSubview:view];
/////////////down/////////////////
        view = [[UIView alloc] init];
        view.layer.borderWidth  =1;
        view.frame=CGRectMake(0, self.handlesView.frame.size.height, 4, 1);
        [self.handlesView addSubview:view];
        
        view = [[UIView alloc] init];
        view.frame = CGRectMake(0, self.handlesView.frame.size.height-3, 1, 4);
        view.layer.borderWidth  =1;
        [self.handlesView addSubview:view];
        
        view = [[UIView alloc] init];
        view.frame = CGRectMake(self.handlesView.frame.size.width, self.handlesView.frame.size.height-3, 1, 4);
        view.layer.borderWidth  =1;
        [self.handlesView addSubview:view];
        
        
        view = [[UIView alloc] init];
        view.frame = CGRectMake(self.handlesView.frame.size.width-3, self.handlesView.frame.size.height, 4, 1);
        view.layer.borderWidth  =1;
        [self.handlesView addSubview:view];
/////////////////////////
        //dima
        
    }
    
    return self;
}


- (CGRect)handlesFrameForRect: (CGRect)frame
{
    CGFloat handlesScaleFactor = 1.2;
    CGFloat handlesSide = ( frame.size.width >= frame.size.height ? frame.size.width : frame.size.height) * handlesScaleFactor;
    return  CGRectMake(0, 0, handlesSide, handlesSide);
}


- (void)setImage: (UIImage*)newImage
{
    if ( nil == newImage ) {
        error(@"nil image supplied");
        return;
    }
    
    self.imageView.image = newImage;
}


- (void)setNewStacheImageArray: (NSArray*)imagesArray
{
    if ( 0 == [imagesArray count] ) {
        error(@"empty imagesArray provided");
        return;
    }
    
    self.imagesArray = imagesArray;
    self.currentStacheImageIndex = 0;
    
    __hasMultipleColors = (1 < [self.imagesArray count]);
    
    UIImage *image = [imagesArray objectAtIndex: self.currentStacheImageIndex];
    // Sun - ipad support
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

    
//    [self setNewStacheImage: image withFrame: CGRectMake(0, 0,
//                                                         0.5 * image.size.width,
//                                                         0.5 * image.size.height)];
    
    [self setNewStacheImage: image withFrame: CGRectMake(0, 0,
                                                         widthImage,
                                                         heightImage)];

    if (self.enabled) {
        [self setActive];
    }
}


- (void)setNewStacheImage: (UIImage*)newImage withFrame: (CGRect)frame
{
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
//    CGFloat scaleFactor;
//    if ( 0 != self.actualScale ) {
//        scaleFactor = 1.0 / self.actualScale;
//    }
//    else {
//        error(@"self.actualScale == 0!!!");
//        scaleFactor = 1.0;
//    }
    
    CGPoint oldCenter = self.center;
    CGRect realFrame = frame;

    self.frame = realFrame;
    CGRect bounds = CGRectZero;
    bounds.size = realFrame.size;
    self.bounds = bounds;
    
    self.imageView = [[UIImageView alloc] initWithFrame: frame];
    self.imageView.center = CGPointMake(0.5 * self.bounds.size.width,
                                        0.5 * self.bounds.size.height);
    self.imageView.image = newImage;
    [self addSubview: self.imageView];
    
    self.handlesView.frame = [self handlesFrameForRect: frame];
    self.handlesView.center = self.imageView.center;
    
    self.center = oldCenter;
}


- (UIImage*)image
{
    return  self.imageView.image;
}


- (CGFloat)scale
{
    return self.actualScale;
}


- (CGFloat)rotation
{
    return self.actualRotation;
}


#pragma mark - Actions

- (void)scaleTo: (CGFloat)newScale
{
    self.transform = CGAffineTransformScale(self.transform, newScale, newScale);
    self.actualScale *= newScale;
}


- (void)rotateTo: (CGFloat)rotation
{
    self.transform = CGAffineTransformRotate(self.transform, rotation);
    self.actualRotation += rotation;
}


- (void)nextStacheColor
{
    if ( self.currentStacheImageIndex < [self.imagesArray count] - 1) {
        self.currentStacheImageIndex++;
    }
    else {
        self.currentStacheImageIndex = 0;
    }
    
    [self setImage: [self.imagesArray objectAtIndex: self.currentStacheImageIndex]];
}

- (void)setColorWithIndex: (NSUInteger)index
{
    if ( index < [self colorCount] ) {
        [self setImage: [self.imagesArray objectAtIndex: index]];
    }
    else {
        [self setImage: [self.imagesArray objectAtIndex: 0]];
    }
}

- (NSUInteger)colorCount
{
    return [self.imagesArray count];
}

#pragma mark - Gesture recongizers setup

- (void)setupPinchGestureWithTarget: (id)target action: (SEL)action delegate: (id<UIGestureRecognizerDelegate>)delegate
{
    if ( nil == self.pinchGesture ) {
        self.pinchGesture =
        [[UIPinchGestureRecognizer alloc] initWithTarget: target
                                                  action: action];
        self.pinchGesture.delegate = delegate;
        self.pinchGesture.enabled = NO;
        [self addGestureRecognizer: self.pinchGesture];
    }
}


- (void)setupRotationGestureWithTarget: (id)target action: (SEL)action delegate: (id<UIGestureRecognizerDelegate>)delegate
{
    if ( nil == self.rotationGesture ) 
    {
        self.rotationGesture =
        [[UIRotationGestureRecognizer alloc] initWithTarget: target
                                                     action: action];
        self.rotationGesture.delegate = delegate;
        self.rotationGesture.enabled = NO;
        [self addGestureRecognizer: self.rotationGesture];
    }
}


#pragma mark - Private

- (void)handleTap: (UITapGestureRecognizer*)gestureRecognizer
{
    if ( gestureRecognizer.state == UIGestureRecognizerStateEnded ) {
        [self.delegate stacheViewTapped: self];
    }
}



@end
