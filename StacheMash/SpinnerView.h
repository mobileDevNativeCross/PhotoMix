//
//  SpinnerView.h
//  SamoletikiPrototype
//
//  Created by Konstantin Sokolinskyi on 2/1/11.
//  Copyright 2011 Bright Newt. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SpinnerView;

@protocol SpinnerViewDelegate

- ( void ) cancelButtonPressed: ( SpinnerView* ) spinnerView;

@end


@interface SpinnerView : UIView
{
	UIActivityIndicatorView *m_spinner;
	UIButton *m_cancelButton;
	id< SpinnerViewDelegate > m_delegate;
	UILabel *m_infoLabel;
}

@property ( nonatomic, assign ) id< SpinnerViewDelegate > delegate;
@property ( nonatomic, copy ) NSString *infoText;

- ( id ) initWithFrame: ( CGRect )frame
			   shading: ( BOOL ) shading;
- (void) showCancelButtonAnimated: (BOOL) animation;
- (void) hideCancelButtonAnimated: (BOOL) animation;
- (void) _cancel;

@end
