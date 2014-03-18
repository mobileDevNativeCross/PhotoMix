//
//  JTLabel.h
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 4/12/11.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JTLabel : UIView
{
	UIFont		*m_font;
	UIColor		*m_textColor;
	NSString	*m_text;
	UIColor		*m_shadowColor;
	CGSize		m_shadowOffset;
	
	NSInteger	m_kerning;
}

@property ( nonatomic, retain ) UIFont	*font;
@property ( nonatomic, retain ) UIColor	*textColor;
@property ( nonatomic, copy   ) NSString	*text;
@property ( nonatomic, retain ) UIColor	*shadowColor;
@property ( nonatomic, assign ) CGSize	shadowOffset;
@property ( nonatomic, assign ) NSInteger	kerning;

- ( void ) drawRect: ( CGRect ) rect inContext: ( CGContextRef ) context;

@end
