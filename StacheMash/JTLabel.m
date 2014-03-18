//
//  JTLabel.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 4/12/11.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "JTLabel.h"


@implementation JTLabel

@synthesize font = m_font;
@synthesize textColor = m_textColor;
@synthesize text = m_text;
@synthesize kerning = m_kerning;
@synthesize shadowColor = m_shadowColor;
@synthesize shadowOffset = m_shadowOffset;


- ( id ) initWithFrame: ( CGRect ) frame
{
    self = [super initWithFrame: frame];
    if ( self ) {
		self.backgroundColor = [UIColor clearColor];
		
		self.font = [UIFont systemFontOfSize: 14];
		self.textColor = [UIColor redColor];
		self.text = @"Sample Text";
		self.kerning = 0;
		self.shadowColor = [UIColor clearColor];
		self.shadowOffset = CGSizeZero;
    }
    return self;
}


- ( void ) drawRect: ( CGRect ) rect {	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[self drawRect: rect inContext: context];
}


- ( void ) drawRect: ( CGRect ) rect inContext: ( CGContextRef ) context
{
	if ( nil == context ) {
		error( @"nil CG context provided" );
		return;
	}
	
	// setting text font properties
    CGContextSelectFont( context, [self.font.fontName cStringUsingEncoding: NSUTF8StringEncoding], self.font.pointSize, kCGEncodingMacRoman );
	
	// seting kerning - letter spacing. Why we need all this plays with
    CGContextSetCharacterSpacing( context, self.kerning );
	
	// setting text shadow
	CGContextSetShadowWithColor( context, self.shadowOffset, 0, self.shadowColor.CGColor );    
	
	// setting text drawing (filling) color
	[self.textColor setFill];
	CGContextSetTextDrawingMode( context, kCGTextFill );
	
	// transofoming coordinate system to draw text in UIKit coordinates
    CGAffineTransform xform = CGAffineTransformMake( 1.0, 0.0, 0.0, -1.0, 0.0, 0.0 );
    CGContextSetTextMatrix( context, xform );
	
    char *text = malloc( [self.text length] + 1 );
    sprintf( text, "%s", [self.text cStringUsingEncoding: NSUTF8StringEncoding] );
	
	CGContextShowTextAtPoint( context,
							 rect.origin.x,
							 rect.origin.y + self.font.pointSize,
							 text,
							 [self.text length] );
	free( text );
}


#pragma mark @property ( nonatomic, retain ) NSString	*text;

- ( void ) setText: ( NSString* ) aText
{
	if ( aText != m_text ) {
		m_text = [aText copy];
	}
	
	[self setNeedsDisplay];
}


@end
