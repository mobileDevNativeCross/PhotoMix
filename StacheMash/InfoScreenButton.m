//
//  InfoScreenButton.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 2/14/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "InfoScreenButton.h"
#import "GUIHelper.h"

static const CGFloat kLabelHeight = 30.0;

@interface InfoScreenButton ()

@property (strong, nonatomic) UIImageView *highlightImageView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIColor *textColor;

- (void)touchDown: (id)sender;
- (void)touchUp: (id)sender;

@end


@implementation InfoScreenButton

@synthesize highlightImageView = _highlightImageView;
@synthesize label = _label;
@synthesize textColor = _textColor;
@synthesize button = __button;

- (id)initWithFrame: (CGRect)frame
{
    self = [super initWithFrame: frame];
    if ( self ) {
    }
    return self;
}

- (id)initWithButton: (UIButton*)btn
                text: (NSString*)text
 labelWidthExtension: (CGFloat)widthExtension
{
    
    self = [self initWithFrame: btn.bounds];

    if ( self ) {
        self.textColor = [UIColor colorWithRed: 0.18 green: 0.11 blue: 0.04 alpha: 1.0];
        
        // HIGHLIGHTING
        // Sun -ipad
        NSString *highlightName = @"info-button-highlight.png";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            highlightName = @"info-button-highlight-ipad.png";
        }
        
        self.highlightImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: highlightName]];
        self.highlightImageView.center = CGPointMake(round( 0.5 * self.bounds.size.width),
                                                     round( 0.5 * self.bounds.size.height) + 14.0);
        
        
        self.highlightImageView.userInteractionEnabled = YES;
        self.highlightImageView.alpha = 0.0;
        
        [self addSubview: self.highlightImageView];
        
        // BUTTON
        __button = btn;
        
        btn.frame = btn.bounds;
         
        [btn addTarget: self action: @selector(touchDown:) forControlEvents: UIControlEventTouchDown];
        [btn addTarget: self action: @selector(touchDown:) forControlEvents: UIControlEventTouchDragEnter];
        
        [btn addTarget: self action: @selector(touchUp:) forControlEvents: UIControlEventTouchUpInside];
        [btn addTarget: self action: @selector(touchUp:) forControlEvents: UIControlEventTouchUpOutside];
        [btn addTarget: self action: @selector(touchUp:) forControlEvents: UIControlEventTouchCancel];
        [btn addTarget: self action: @selector(touchUp:) forControlEvents: UIControlEventTouchDragExit];
        
        [self addSubview: btn];
        
        // LABEL
        CGFloat fontSize = 12;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            fontSize = 22;
            self.label = [[UILabel alloc] initWithFrame:
                          CGRectMake( - 0.5 * widthExtension,
                                     [GUIHelper getBottomYForView: btn] - 10,
                                     self.frame.size.width + widthExtension,
                                     kLabelHeight + 45)];
            
        }else{
            self.label = [[UILabel alloc] initWithFrame:
                                                CGRectMake( - 0.5 * widthExtension,
                                                           [GUIHelper getBottomYForView: btn],
                                                           self.frame.size.width + widthExtension,
                                                           kLabelHeight)];
        }
        self.label.font = [UIFont boldSystemFontOfSize: fontSize];      
        self.label.textAlignment = UITextAlignmentCenter;
        self.label.textColor = [UIColor colorWithRed: 0.18 green: 0.11 blue: 0.04 alpha: 1.0];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.numberOfLines = 2;
        self.label.text = text;
        
        [self addSubview: self.label];
    }
    
    return self;
}

- (void)touchDown: (id)sender
{
    self.highlightImageView.alpha = 1.0;
    self.label.textColor = [UIColor whiteColor];
}


- (void)touchUp: (id)sender
{
    self.highlightImageView.alpha = 0.0;
    self.label.textColor = self.textColor;
}



@end
