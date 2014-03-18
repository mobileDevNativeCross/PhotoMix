//
//  GUIHelper.m
//  SamoletikiPrototype
//
//  Created by Konstantin Sokolinskyi on 12/5/10.
//  Copyright 2010 Bright Newt. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GUIHelper.h"


@implementation GUIHelper

#pragma mark GUI measurements

+ ( CGFloat ) getBottomYForRect: ( const CGRect* ) viewRect;
{
	if ( NULL == viewRect )
		return 0.0;
	
	return viewRect->origin.y + viewRect->size.height;
}


+ ( CGFloat ) getBottomYForView: ( const UIView * ) view
{
	if ( nil == view )
		return 0.0;
	
	CGRect rect = view.frame;
	return [GUIHelper getBottomYForRect: &rect];
}


+ ( CGFloat ) getRightXForRect: ( const CGRect* ) viewRect
{
	if ( NULL == viewRect )
		return 0.0;
	
	return viewRect->origin.x + viewRect->size.width;
}


+ ( CGFloat ) getRightXForView: ( const UIView * ) view
{
	if ( nil == view )
		return 0.0;
	
	CGRect rect = view.frame;
	return [ GUIHelper getRightXForRect: &rect ];
}


#pragma mark Default values

+ ( UIColor* ) defaultShadowColor
{
	return [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.66];
}


+ ( CGSize ) defaultShadowOffset
{
	return CGSizeMake( 0, -1 );
}


+ ( UIColor* ) colorWithRGBComponent: ( int ) component
{
	return [ UIColor colorWithRed: ( float ) component / 256
							green: ( float ) component / 256
							 blue: ( float ) component / 256
							alpha: 1 ];
}


#pragma mark Overlaying bg

+ ( UIImage* ) imageByCropping: ( UIImage* ) imageToCrop toRect: ( CGRect ) rect
{
    if ( nil == imageToCrop ) {
        error(@"nil image supplied");
        return nil;
    }

	//create a context to do our clipping in
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake( 0, 0, rect.size.width, rect.size.height );
	CGContextClipToRect( currentContext, clippedRect );
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
	CGRect drawRect = CGRectMake( rect.origin.x * -1.0,
								 rect.origin.y * 1.0,
								 imageToCrop.size.width,
								 imageToCrop.size.height );
	
	CGContextTranslateCTM( currentContext, 0.0, imageToCrop.size.height );
	CGContextScaleCTM( currentContext, 1.0, -1.0 );
	
	//draw the image to our clipped context using our offset rect
	CGContextDrawImage( currentContext, drawRect, imageToCrop.CGImage );
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}


+ ( UIImage* ) imageByScaling: ( UIImage* ) imageToScale toSize: ( CGSize ) targetSize;
{
    if ( nil == imageToScale ) {
        error(@"nil image supplied");
        return nil;
    }
    
    UIImage *sourceImage = imageToScale;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) 
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }       
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 1);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) {
        error(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


+ ( UIView* ) overlayBgViewWithFrame: ( CGRect ) frame alpha: ( float ) alpha
{
	UIImageView *overlayingBgImgView = [[UIImageView alloc] initWithFrame: frame];
	overlayingBgImgView.alpha		= alpha;
	overlayingBgImgView.contentMode	= UIViewContentModeScaleToFill;	
	overlayingBgImgView.image		= [self imageByCropping: [UIImage imageNamed: @"UI-table_BG.png"]
														toRect: frame];
	return overlayingBgImgView;
}


+ ( UIImage* ) imageFromView: ( UIView* ) view
{
    if ( nil == view ) {
        error(@"nil view supplied");
        return nil;
    }

    // get image with layerd staches
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



+ (NSData*)scaledItemNSDataImageWith: (NSData*)sourceData
{
//    return UIImageJPEGRepresentation([UIImage imageWithData: sourceData], 0.1);
    return UIImagePNGRepresentation([GUIHelper imageByScaling: [UIImage imageWithData: sourceData]
                                                       toSize: CGSizeMake(140, 140)]);
}

+ (NSData*)scaledItemNSDataUserImageWith: (UIImage*)image
{
    return UIImagePNGRepresentation([GUIHelper imageByScaling: image
                                                       toSize: CGSizeMake(140, 140)]);
}


+ (BOOL)isPhone5
{
    return (480 < [UIScreen mainScreen].bounds.size.height);
}

//Sun iPad support
+ (BOOL)isIPadretina
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0) {
        return YES;
    }
    return NO;
}



@end
