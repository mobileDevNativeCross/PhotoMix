//
//  SpinnerView.m
//  SamoletikiPrototype
//
//  Created by Konstantin Sokolinskyi on 2/1/11.
//  Copyright 2011 Bright Newt. All rights reserved.
//

#import "SpinnerView.h"
#import "GUIHelper.h"

#define SPINNER_WIDTH 30
#define SPINNER_HEIGHT 30

#define CANCEL_WIDTH 100
#define CANCEL_HEIGHT 40

#define CANCEL_Y_OFFSET 100
#define CANCEL_DISPLAY_TIME 0.2

@implementation SpinnerView

@synthesize delegate = m_delegate;
@dynamic infoText;

- ( id ) initWithFrame: ( CGRect )frame shading: ( BOOL ) shading
{
	if ( self = [super initWithFrame: frame] )
	{
		if ( shading )
			self.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.7];
		else
			self.backgroundColor = [UIColor clearColor];
		
		// CREATE spinner
		CGRect sframe;
		sframe.size.height	= SPINNER_WIDTH;
		sframe.size.width	= SPINNER_HEIGHT;
		sframe.origin.x = frame.size.width / 2 - SPINNER_WIDTH / 2;
		sframe.origin.y = frame.size.height / 2 - SPINNER_HEIGHT / 2;
		
		m_spinner = [[UIActivityIndicatorView alloc] initWithFrame: sframe];
		[m_spinner setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhiteLarge];
		
		[self addSubview: m_spinner];
		
		// CREATE Cancel button
		m_cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
		
		m_cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
		m_cancelButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
		[m_cancelButton setTitle: NSLocalizedString( @"Cancel", @"" ) forState: UIControlStateNormal];
		
		[m_cancelButton setBackgroundImage: [UIImage imageNamed: @"UI-actionsheet_button_black.png"] forState: UIControlStateNormal];
		[m_cancelButton setBackgroundImage: [UIImage imageNamed: @"UI-actionsheet_button_pressed.png"] forState: UIControlStateHighlighted];
		
		[m_cancelButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
		[m_cancelButton setTitleShadowColor: [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.5] forState: UIControlStateNormal];

		m_cancelButton.hidden = YES;
		m_cancelButton.frame = CGRectMake( 21, frame.size.height - 47 - 40, 278, 47 );

		[m_cancelButton addTarget: self
						 action: @selector( _cancel )
			   forControlEvents: UIControlEventTouchUpInside];
		
		[self addSubview: m_cancelButton];
		
		// CREATE title label
		CGFloat sideMargin = 20;
		m_infoLabel = [[[UILabel alloc] initWithFrame:
					   CGRectMake( sideMargin,
								  120,
								  frame.size.width - 2 * sideMargin,
								  50 )] autorelease];
		m_infoLabel.font = [UIFont systemFontOfSize: 15];
		m_infoLabel.textColor = [UIColor colorWithRed: 0.8 green: 0.8 blue: 0.8 alpha: 0.8];
		m_infoLabel.backgroundColor = [UIColor clearColor];
		m_infoLabel.textAlignment = UITextAlignmentCenter;
		m_infoLabel.shadowOffset = [GUIHelper defaultShadowOffset];
		m_infoLabel.shadowColor = [GUIHelper defaultShadowColor];
		
		[self addSubview: m_infoLabel];
		
		[m_spinner startAnimating];
	}
	return self;
}


- ( void ) showCancelButtonAnimated: ( BOOL ) animation
{
	if ( animation )
	{
		m_cancelButton.alpha = 0;
		m_cancelButton.hidden = NO;
		[UIView animateWithDuration: CANCEL_DISPLAY_TIME
							  delay: 0.0
							options: (	UIViewAnimationOptionCurveEaseOut
									  |	UIViewAnimationOptionAllowUserInteraction )
						 animations: ^{
							 m_cancelButton.alpha = 1;
						 }
						 completion: nil
						 ];
		
	}
	else
	{
		m_cancelButton.hidden = NO;
	}
}


- ( void ) hideCancelButtonAnimated: ( BOOL ) animation
{
	if ( animation )
	{
		[UIView animateWithDuration: CANCEL_DISPLAY_TIME
							  delay: 0.0
							options: (	UIViewAnimationOptionCurveEaseOut
									  |	UIViewAnimationOptionAllowUserInteraction )
						 animations: ^{
							 m_cancelButton.alpha = 0;
						 }
						 completion: ^( BOOL finished ){
							 if ( finished ) {
								 m_cancelButton.hidden = YES; 
							 }	
						 }
		 ];
	}
	else
	{
		m_cancelButton.hidden = YES;
	}
}


- ( void ) _cancel
{
	[self.delegate cancelButtonPressed: self];
}


- ( void ) dealloc
{
	[m_spinner stopAnimating];
	[m_spinner release];
	
	[super dealloc];
}


#pragma mark @property ( nonatomic, copy ) NSString *infoText;

- ( NSString* ) infoText
{
	return m_infoLabel.text;
}


- ( void ) setInfoText: ( NSString* ) newText
{
	m_infoLabel.text = [newText copy];
	
	CGSize maxSize = m_infoLabel.frame.size;
	maxSize.height = self.frame.size.height - m_infoLabel.frame.origin.x;
	
	CGSize newSize = [m_infoLabel.text sizeWithFont: m_infoLabel.font
								  constrainedToSize: maxSize
									  lineBreakMode: UILineBreakModeWordWrap];
	
	CGRect newFrame = m_infoLabel.frame;
	newFrame.size.height = newSize.height;
	m_infoLabel.frame = newFrame;
}


@end
