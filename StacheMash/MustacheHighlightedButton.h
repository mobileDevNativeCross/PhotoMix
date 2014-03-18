//
//  MustacheHighlightedButton.h
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/27/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HighlightedButton.h"

@class DMStache;
@class DMPack;

@interface MustacheHighlightedButton : HighlightedButton

- (id)initWitStache: (DMStache*)stache fromPack: (DMPack*)pack;

@property (strong, nonatomic) DMStache *stache;
@property (strong, nonatomic) DMPack *pack;

@end
