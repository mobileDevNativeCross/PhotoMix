//
//  MustacheHighlightedButton.m
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/27/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "MustacheHighlightedButton.h"
#import "DMPack.h"
#import "DMStache.h"

@implementation MustacheHighlightedButton

@synthesize stache = __stache;
@synthesize pack = __pack;

- (id)initWitStache: (DMStache*)stache fromPack: (DMPack*)pack
{
    if ( nil == stache ) {
        error(@"nil stache supplied");
        return nil;
    }
    
    UIImage *buttonImage = [pack imageForThumb: stache];
    UIImage *buttonPressedImage = [pack imageForThumb: stache];
	
	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    
    
	button.frame= CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height+5);
    //button.layer.borderWidth = 1;
    [button setImage: buttonImage forState: UIControlStateNormal];
    
  //  button.imageEdgeInsets = UIEdgeInsetsMake(0, buttonImage.size.width, 0, buttonImage.size.width);
    
    [button setImage: buttonPressedImage forState: UIControlStateHighlighted];
    //Sun -ipad support
    NSString *pressName = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        pressName = @"press-ipad.png";
    }
    
    self = [super initWithButton: button highlightImageName: pressName];
    if ( self ) {
        self.stache = stache;
        self.pack = pack;
     //   self.layer.borderWidth = 1;
        /*UILabel *stacheTitleLabel = [[UILabel alloc] initWithFrame:
                                     CGRectMake(0, 6,
                                                button.bounds.size.width,
                                                0.3 * button.bounds.size.height)];
         */
        UILabel *stacheTitleLabel = [[UILabel alloc] initWithFrame:
                                     CGRectMake(0, button.bounds.size.height-27,
                                                button.bounds.size.width-5,
                                                button.bounds.size.height)];
        
        stacheTitleLabel.textAlignment = UITextAlignmentCenter;
        //Sun - iPad support
        CGFloat fontSize = 12;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            fontSize += 10;
        }
//stacheTitleLabel.font = [UIFont fontWithName: @"Anderson Thunderbirds Are GO!" size: fontSize];
        stacheTitleLabel.font = [UIFont fontWithName: @"Helvetica-Light" size: fontSize];
        stacheTitleLabel.textColor = [UIColor colorWithRed: 255 green: 242 blue: 0.0 alpha: 1.0];
        stacheTitleLabel.backgroundColor = [UIColor clearColor];
        stacheTitleLabel.text = stache.title;
        stacheTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        stacheTitleLabel.numberOfLines = 4;
       
        [self addSubview: stacheTitleLabel];
    }
    
    return self;
}

@end
