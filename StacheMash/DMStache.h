//
//  DMStache.h
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/26/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMObject.h"

@class DMPack;

@interface DMStache : DMObject

@property (strong, nonatomic) NSString *title; 
@property (strong, nonatomic) NSString *baseName;
// Sun - ipad support
@property (strong, nonatomic) NSString *baseNameIpad;

@end
