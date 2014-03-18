//
//  GUIHelper.h
//  SamoletikiPrototype
//
//  Created by Konstantin Sokolinskyi on 12/5/10.
//  Copyright 2010 Bright Newt. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GUIHelper : NSObject
{

}

#pragma mark GUI measurements

+ ( CGFloat ) getBottomYForRect: ( const CGRect * ) viewRect;
+ ( CGFloat ) getBottomYForView: ( const UIView * ) viewRect;

+ ( CGFloat ) getRightXForRect: ( const CGRect * ) viewRect;
+ ( CGFloat ) getRightXForView: ( const UIView * ) view;


#pragma mark Default values

+ ( UIColor* ) defaultShadowColor;
+ ( CGSize   ) defaultShadowOffset;

+ ( UIColor* ) colorWithRGBComponent: ( int ) component;


#pragma mark Overlaying bg
+ ( UIImage* ) imageByCropping: ( UIImage* ) imageToCrop toRect: ( CGRect ) rect;
+ ( UIImage* ) imageByScaling: ( UIImage* ) imageToScale toSize: ( CGSize ) targetSize;
+ ( UIView* ) overlayBgViewWithFrame: ( CGRect ) frame alpha: ( float ) alpha;
+ ( UIImage* ) imageFromView: ( UIView* ) view;
+ (NSData*)scaledItemNSDataImageWith: (NSData*)sourceData;
+ (NSData*)scaledItemNSDataUserImageWith: (UIImage*)image;

#pragma mark  iPhone 5 methods
+ (BOOL) isPhone5;

#pragma mark  iPad methods
+ (BOOL) isIPadretina;




@end
