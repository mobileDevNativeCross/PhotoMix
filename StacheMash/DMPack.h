//
//  DMPack.h
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/26/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMObject.h"

@class DMStache;

@interface DMPack : DMObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *IAP_id;
@property (strong, nonatomic) NSNumber *bought;
@property (strong, nonatomic) NSNumber *visible;

@property (strong, nonatomic) NSArray *staches;
@property (strong, nonatomic) NSArray *banners;

- (NSString*)pathForThumb: (DMStache*)stache;
- (UIImage*)imageForThumb: (DMStache*)stache;
- (NSArray*)imagesForStaches: (DMStache*)stache;
- (NSArray*)imagesForBanners;

@end
