//
//  DMPack.m
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 2/26/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "DMPack.h"
#import "DMStache.h"

@implementation DMPack

@synthesize name = _name;
@synthesize path = _path;
@synthesize IAP_id = _IAP_id;
@synthesize bought = _bought;
@synthesize visible = _visible;

@synthesize staches = _staches;
@synthesize banners = _banners;

- (NSString*)pathForThumb: (DMStache*)stache
{
    // Sun - ipad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return [[NSBundle mainBundle] pathForResource: stache.baseNameIpad
                                               ofType: @"png"
                                          inDirectory: [NSString stringWithFormat: @"staches/%@/thumb", self.path]];
    }
    return [[NSBundle mainBundle] pathForResource: stache.baseName
                                           ofType: @"png"
                                      inDirectory: [NSString stringWithFormat: @"staches/%@/thumb", self.path]];
}


- (UIImage*)imageForThumb: (DMStache*)stache
{
    UIImage *image = [UIImage imageWithContentsOfFile: [self pathForThumb: stache]];
    if ( nil == image ) {
        error(@"FAILED loading image for stache: %@", stache);
        return nil;
    }
    
    return image;
}


- (NSArray*)imagesForStaches: (DMStache*)stache
{
    NSArray *paths;
    paths =  [[[NSBundle mainBundle] pathsForResourcesOfType: @"png"
                                                          inDirectory: [NSString stringWithFormat: @"staches/%@/mustache", self.path]]
                       filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"SELF contains[cd] %@",
                                                     stache.baseName]];
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    for ( NSString *path in paths ) {
//        NSRange atRange = [path rangeOfString: @"@"];
//        if ( 0 == atRange.length ) {
//            //[imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
//            //Sun - iPad
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//            {
//                atRange = [path rangeOfString: @"-ipad"];
//                if ( 0 != atRange.length )
//                    [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
//            }
//            else
//                [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
//        }
                NSRange atRange = [path rangeOfString: @"@2x"];
        
                if ( 0 != atRange.length )
                   [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
                    //Sun - iPad
//                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//                    {
//                        //atRange = [path rangeOfString: @"-ipad"];
//                        if ( 0 != atRange.length )
//                            [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
//                    }
//                    else{
//                        if ( 0 == atRange.length )
//                        [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
//                    }
        

    }
    return imagesArray;
}


- (NSArray*)imagesForBanners
{
    NSArray *paths =  [[NSBundle mainBundle] pathsForResourcesOfType: @"png"
                                                         inDirectory: [NSString stringWithFormat: @"staches/%@/banner", self.path]];
    
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    for ( NSString *path in paths ) {
        NSRange atRange = [path rangeOfString: @"-ipad"];//atRange = [path rangeOfString: @"@"];
//        if ( 0 == atRange.length ) {
//            //Sun - iPad
//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//            {
//                 atRange = [path rangeOfString: @"-ipad"];
//                if ( 0 != atRange.length )
//                    [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
//            }
//            else
//                [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
//        }
        //NSRange atRange = [path rangeOfString: @"-ipad"];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
             //atRange = [path rangeOfString: @"-ipad"];
             if ( 0 != atRange.length )
                    [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
        }else{
            //atRange = [path rangeOfString: @"-ipad"];
            if ( 0 == atRange.length )
                [imagesArray addObject: [UIImage imageWithContentsOfFile: path]];
        }

        
        
    }
    return imagesArray;
}




@end
