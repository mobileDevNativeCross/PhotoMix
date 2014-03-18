//
//  StacheView.h
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/19/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMStache.h"

@class StacheView;

@protocol StacheViewDelegate <NSObject>

- (void)stacheViewTapped: (StacheView*)stacheView;

@end


@interface StacheView : UIView

@property (nonatomic, assign) id<StacheViewDelegate> delegate;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign, readonly) BOOL hasMultipleColors;
@property (nonatomic, strong) DMStache *stache;

- (id)initWithFrame: (CGRect)frame imagesArray: (NSArray*)imagesArray;

- (void)setImage: (UIImage*)newImage;
- (void)setNewStacheImage: (UIImage*)newImage withFrame: (CGRect)frame;
- (void)setNewStacheImageArray: (NSArray*)imagesArray;

- (void)scaleTo: (CGFloat)newScale;
- (void)rotateTo: (CGFloat)rotation;
- (void)nextStacheColor;

- (void)setColorWithIndex: (NSUInteger)index;
- (NSUInteger)colorCount;

- (void)setupPinchGestureWithTarget: (id)target action: (SEL)action delegate: (id<UIGestureRecognizerDelegate>)delegate;
- (void)setupRotationGestureWithTarget: (id)target action: (SEL)action delegate: (id<UIGestureRecognizerDelegate>)delegate;


- (UIImage*)image;
- (CGFloat)scale;
- (CGFloat)rotation;


@end
