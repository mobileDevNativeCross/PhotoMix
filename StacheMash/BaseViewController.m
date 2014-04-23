//
//  BaseViewController.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 2/12/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "BaseViewController.h"
#import "HighlightedButton.h"


@implementation BaseViewController

@synthesize toolbar = _toolbar;
@synthesize navBar = _navBar;
@synthesize navBarTitleLabel = _navBarTitleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    error(@"ACHTUNG! DID Receive Memory WARNING");
//	[DebugHelper logMemoryUsage];

    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // BG image
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame: self.view.bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
      //  bgImageView.image = [UIImage imageNamed: @"bg-@2x.png"];
    }else{
   // bgImageView.image = [UIImage imageNamed: @"bg-.png"];
    }
    bgImageView.userInteractionEnabled = YES;
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview: bgImageView];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    debug(@"BASE VIEW: did unload");
    
    self.toolbar = nil;
    self.navBar = nil;
    self.navBarTitleLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (BOOL)canSendMail
{
    BOOL canSendMail = YES;
    if ( ![MFMailComposeViewController canSendMail] ) {
        [Flurry logEvent: @"CannotSendMail"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                        message: NSLocalizedString(@"Looks like there's no email account setup. Please, check your email settings", @"")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString( @"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        canSendMail = NO;
    }
    
    return canSendMail;
}



#pragma mark Views

- (UIButton*)plainButtonWithImageNamed: (NSString*)imageName
                      pressedImageName: (NSString*)pressedImageName
                                target: (id)target
                                action: (SEL)action
{
    if ( nil == imageName ) {
        error(@"nil image supplied");
        return nil;
    }
    
    UIImage *buttonImage = [UIImage imageNamed: imageName];
    UIImage *buttonPressedImage = [UIImage imageNamed: pressedImageName];
	
	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    //button.layer.borderWidth = 4;
   // button.layer.borderColor = [UIColor redColor].CGColor;
    [button setImage: buttonImage forState: UIControlStateNormal];
    [button setImage: buttonPressedImage forState: UIControlStateHighlighted];
   // NSLog(@"imageName==%@",imageName);
    if(![imageName isEqualToString:@"recycle"])
	button.frame = CGRectMake(0, 0, buttonImage.size.width/2, buttonImage.size.height/2);
    else
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
	[button addTarget: target action: action forControlEvents: UIControlEventTouchUpInside];
    
    return button;
}


- (UIView*)buttonWithImageNamed: (NSString*)imageName
               pressedImageName: (NSString*)pressedImageName
                         target: (id)target
                         action: (SEL)action
{
    UIButton *button = [self plainButtonWithImageNamed: imageName
                                      pressedImageName: pressedImageName
                                                target: target
                                                action: action];
    
    return [HighlightedButton bottomBarButtonWithButton: button];
}


- (UIView*)buttonWithImageNamed: (NSString*)imageName target: (id)target action: (SEL)action
{
    return [self buttonWithImageNamed: imageName
                     pressedImageName: [NSString stringWithFormat: @"%@-pressed", imageName]
                               target: target
                               action: action];
}

- (void)createBottomToolbar1: (NSArray*)buttonsArray
{
    UIImage *barImage;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        barImage = [UIImage imageNamed: @"bar-down-ipad.png"];
    }else{
        barImage = [UIImage imageNamed: @"header_black.png"];
    }
    self.toolbar = [[UIImageView alloc] initWithFrame:
                    CGRectMake(0,0
                               /*self.view.frame.size.height - barImage.size.height*/,
                               self.view.frame.size.width,
                               barImage.size.height-20)];
    self.toolbar.userInteractionEnabled = YES;
    self.toolbar.image = barImage;
    //self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview: self.toolbar];
   // self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    //[self.view addSubview: self.toolbar];
    NSLog(@"self.toolbar==%@",self.toolbar);
    if ( 0 == [buttonsArray count] ) {
        error(@"empty array supplied");
        return;
        
    }
    
    // CALC positions
    CGFloat occupiedSpace = 0;
    for ( UIView *btn in buttonsArray ) {
        occupiedSpace += btn.bounds.size.width;
    }
    
    CGFloat freeSpace = self.view.frame.size.width - occupiedSpace;
    CGFloat freeInterval = round(freeSpace / ([buttonsArray count] + 1));
    
    for ( int i = 0; i < [buttonsArray count]; i++ ) {
        UIView *btn = [buttonsArray objectAtIndex: i];
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        CGRect btnFrame = btn.frame;
        btnFrame.origin = CGPointMake(freeInterval * (i + 1) +  i * btnFrame.size.width,
                                      0.5 * (barImage.size.height - btnFrame.size.height));
        btn.frame = btnFrame;
        [self.toolbar addSubview: btn];
    }
}

- (void)createBottomToolbarWithButtons: (NSArray*)buttonsArray
{
    if ( nil != self.toolbar ) {
        error(@"toolbar is alread created");
        return;
    }
    
    // CREATE toolbar
    //Sun-iPad support
    UIImage *barImage;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        barImage = [UIImage imageNamed: @"bar-down-ipad.png"];
    }else{
         barImage = [UIImage imageNamed: @"bar-down.png"];
    }
    self.toolbar = [[UIImageView alloc] initWithFrame:
                    CGRectMake(0,0
                               /*self.view.frame.size.height - barImage.size.height*/,
                               self.view.frame.size.width,
                               barImage.size.height)];
    self.toolbar.userInteractionEnabled = YES;
    self.toolbar.image = barImage;
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview: self.toolbar];

    if ( 0 == [buttonsArray count] ) {
        error(@"empty array supplied");
        return;
        
    }
    
    // CALC positions
    CGFloat occupiedSpace = 0;
    for ( UIView *btn in buttonsArray ) {
        occupiedSpace += btn.bounds.size.width;
    }
    
    CGFloat freeSpace = self.view.frame.size.width - occupiedSpace;
    CGFloat freeInterval = round(freeSpace / ([buttonsArray count] + 1));
    
    for ( int i = 0; i < [buttonsArray count]; i++ ) {
        UIView *btn = [buttonsArray objectAtIndex: i];
        btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        CGRect btnFrame = btn.frame;
        if(i==0){
            btnFrame.origin = CGPointMake(0,
                                          0.5 * (barImage.size.height - btnFrame.size.height));
        }
        else{
        btnFrame.origin = CGPointMake(/*freeInterval * (i + 1) +  i * btnFrame.size.width*/320-btnFrame.size.width,
                                      0.5 * (barImage.size.height - btnFrame.size.height));
        }
        btn.frame = btnFrame;
        //btn.layer.borderWidth = 1;
      //  btn.layer.borderColor = [UIColor greenColor].CGColor;
        
        [self.toolbar addSubview: btn];
    }
}
-(void)createBottomToolbarPurchase: (NSArray*)buttonsArray{
    if ( nil != self.toolbar ) {
        error(@"toolbar is alread created");
        //   return;
    }
    
    // CREATE toolbar
    //Sun-iPad support
    UIImage *barImage;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        barImage = [UIImage imageNamed: @"bar-down-ipad.png"];
    }else{
        barImage = [UIImage imageNamed: @"header_black.png"];
    }
     UIImageView *toolbar = [[UIImageView alloc] initWithFrame:
                    CGRectMake(0,0
                               /*self.view.frame.size.height - barImage.size.height*/,
                               self.view.frame.size.width,
                               barImage.size.height-40)];
    toolbar.userInteractionEnabled = YES;
    toolbar.image = barImage;
    //self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview: toolbar];
    
    if ( 0 == [buttonsArray count] ) {
        error(@"empty array supplied");
        return;
        
    }
    
    // CALC positions
    CGFloat occupiedSpace = 0;
    for ( UIView *btn in buttonsArray ) {
        occupiedSpace += btn.bounds.size.width;
    }
    
    CGFloat freeSpace = self.view.frame.size.width - occupiedSpace;
    CGFloat freeInterval = round(freeSpace / ([buttonsArray count] + 1));
    
    for ( int i = 0; i < [buttonsArray count]; i++ ) {
        UIView *btn = [buttonsArray objectAtIndex: i];
        //btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        CGRect btnFrame = btn.frame;
        
        if(i==0){
            NSLog(@"IIIII==%d",i);
            btnFrame.origin = CGPointMake(0,
                                          /*0.5 * (barImage.size.height - btnFrame.size.height)*/5);
            btn.frame = CGRectMake((320-btnFrame.size.width), 5, 120, 120);
            [toolbar addSubview: btn];
            btn.frame = btnFrame;
        }
        else if(i==1) {
            NSLog(@"IIIII2==%d",i);
            btnFrame.origin = CGPointMake(/*freeInterval * (i + 1) +  i * btnFrame.size.width*/145,
                                          /*0.5 * (barImage.size.height - btnFrame.size.height)*/5);
            btn.frame = CGRectMake((160+btnFrame.size.width), 5, barImage.size.width, barImage.size.height);
            //  btn.layer.borderWidth  = 3;
            // btn.layer.borderColor = [UIColor redColor].CGColor;
            [toolbar addSubview: btn];
            btn.frame = btnFrame;
            
        }
        else if(i==2) {
            NSLog(@"IIIII2==%d",i);
            btnFrame.origin = CGPointMake(/*freeInterval * (i + 1) +  i * btnFrame.size.width*/320-btnFrame.size.width,
                                          /*0.5 * (barImage.size.height - btnFrame.size.height)*/5);
            btn.frame = CGRectMake((320-btnFrame.size.width), 5, 120, 120);
            [toolbar addSubview: btn];
            btn.frame = btnFrame;
        }
        
        //btn.layer.borderWidth = 1;
        //btn.layer.borderColor = [UIColor greenColor].CGColor;
        
        
        [self.view bringSubviewToFront: toolbar];
        //      self.toolbar.layer.borderWidth = 3;
        //        self.toolbar.layer.borderColor = [UIColor greenColor].CGColor;
        
    }
}

-(void)createBottomToolbar: (NSArray*)buttonsArray{
    if ( nil != self.toolbar ) {
        error(@"toolbar is alread created");
        return;
    }
    
    // CREATE toolbar
    //Sun-iPad support
    UIImage *barImage;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        barImage = [UIImage imageNamed: @"bar-down-ipad.png"];
    }else{
        barImage = [UIImage imageNamed: @"header_black.png"];
    }
    self.toolbar = [[UIImageView alloc] initWithFrame:
                    CGRectMake(0,0
                               /*self.view.frame.size.height - barImage.size.height*/,
                               self.view.frame.size.width,
                               barImage.size.height-40)];
    self.toolbar.userInteractionEnabled = YES;
    self.toolbar.image = barImage;
    //self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview: self.toolbar];
    
    if ( 0 == [buttonsArray count] ) {
        error(@"empty array supplied");
        return;
        
    }
    
    // CALC positions
    CGFloat occupiedSpace = 0;
    for ( UIView *btn in buttonsArray ) {
        occupiedSpace += btn.bounds.size.width;
    }
    
    CGFloat freeSpace = self.view.frame.size.width - occupiedSpace;
    CGFloat freeInterval = round(freeSpace / ([buttonsArray count] + 1));
    
    for ( int i = 0; i < [buttonsArray count]; i++ ) {
        UIView *btn = [buttonsArray objectAtIndex: i];
        //btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        CGRect btnFrame = btn.frame;
       
        if(i==0){
           
            btnFrame.origin = CGPointMake(0,
                                          /*0.5 * (barImage.size.height - btnFrame.size.height)*/5);
             btn.frame = CGRectMake((320-btnFrame.size.width), 5, 120, 120);
             [self.toolbar addSubview: btn];
             btn.frame = btnFrame;
        }
        else if(i==1) {
              NSLog(@"IIIII==%f",barImage.size.width);            btnFrame.origin = CGPointMake(/*freeInterval * (i + 1) +  i * btnFrame.size.width*/145,
                                         /*0.5 * (barImage.size.height - btnFrame.size.height)*/5);
            btn.frame = CGRectMake((160+btnFrame.size.width), 5, barImage.size.width, barImage.size.height);
          //  btn.layer.borderWidth  = 3;
           // btn.layer.borderColor = [UIColor redColor].CGColor;
[self.toolbar addSubview: btn];
             btn.frame = btnFrame;
           
        }
        else if(i==2) {
            NSLog(@"IIIII2==%d",i);
            btnFrame.origin = CGPointMake(/*freeInterval * (i + 1) +  i * btnFrame.size.width*/320-btnFrame.size.width,
                                          /*0.5 * (barImage.size.height - btnFrame.size.height)*/5);
            btn.frame = CGRectMake((320-btnFrame.size.width), 5, 120, 120);
            [self.toolbar addSubview: btn];
             btn.frame = btnFrame;
        }
       
        //btn.layer.borderWidth = 1;
        //btn.layer.borderColor = [UIColor greenColor].CGColor;
        
       
        [self.view bringSubviewToFront: self.toolbar];
  //      self.toolbar.layer.borderWidth = 3;
//        self.toolbar.layer.borderColor = [UIColor greenColor].CGColor;
        
    }
}

- (void)updateBottomToolbarToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation
{
    if ( UIInterfaceOrientationIsPortrait(interfaceOrientation) ) {
        //Sun - iPad support
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.toolbar.image = [UIImage imageNamed: @"bar-down-ipad.png"];
        }else{
        self.toolbar.image = [UIImage imageNamed: @"bar-down.png"];
        }
    }
    else { //Landscape
        //Sun - iPad support
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            self.toolbar.image = [UIImage imageNamed: @"bar-down-hor-ipad.png"];
        }else{
            self.toolbar.image = [UIImage imageNamed: @"bar-down-hor.png"];
        }
        
    }
}


- (void)createNavBar
{
    // CREATE nav bar
    //iPad support
    UIImage *barImage;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        barImage = [UIImage imageNamed: @"header_black.png"];
    }else{
        
        barImage = [UIImage imageNamed: @"header_black.png"];
    }
    
    self.navBar = [[UIImageView alloc] initWithFrame:
                   CGRectMake(0, 0, self.view.frame.size.width,
                              barImage.size.height-40)];
   
    
    
    self.navBar.userInteractionEnabled = YES;
    self.navBar.image = barImage;
    [self.view addSubview: self.navBar];
}


- (void)createLeftNavBarButtonWithTitle: (NSString*)title target: (id)target action: (SEL)action
{
    UIImage *buttonImage, *buttonPressedImage;
    //Sun-ipad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        buttonImage = [UIImage imageNamed: @""];
        buttonPressedImage = [UIImage imageNamed: @"btn-Right-ipad-pressed.png"];
    }else{
        
    buttonImage = [UIImage imageNamed: @""];
        buttonPressedImage = [UIImage imageNamed: @"btn-Right-pressed.png"];
    }

	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [button setBackgroundImage: buttonImage forState: UIControlStateNormal];
    [button setBackgroundImage: buttonPressedImage forState: UIControlStateHighlighted];
    
	button.frame= CGRectMake(6, 0.5 * (self.navBar.bounds.size.height - 60),
                             60, 60);
	
    [button setTitle: @"back" forState: UIControlStateNormal];
    button.titleLabel.textColor = [UIColor colorWithRed: 0.88 green: 0.80 blue: 0.58 alpha: 1.0];
    //Sun - ipad
    int sizeFont = 21;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        sizeFont = 26;
    }
    button.titleLabel.font = [UIFont systemFontOfSize: sizeFont];
    
    
    [button addTarget: target action: action forControlEvents: UIControlEventTouchUpInside];
    
    [self.navBar addSubview: button];
}


- (void)createRightNavBarButtonWithTitle: (NSString*)title target: (id)target action: (SEL)action
{
    UIImage *buttonImage, *buttonPressedImage;
    //Sun-ipad support
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        buttonImage = [UIImage imageNamed: @""];
        buttonPressedImage = [UIImage imageNamed: @"btn-Right-ipad-pressed.png"];
    }else{
                
        buttonImage = [UIImage imageNamed: @""];
        buttonPressedImage = [UIImage imageNamed: @"btn-Right-pressed.png"];
    }

	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [button setBackgroundImage: buttonImage forState: UIControlStateNormal];
    [button setBackgroundImage: buttonPressedImage forState: UIControlStateHighlighted];
    
	button.frame= CGRectMake(self.navBar.bounds.size.width - 60 - 6,
                             0.5 * (self.navBar.bounds.size.height - 60),
                             60, 60);
	 
    [button setTitle: title forState: UIControlStateNormal];
    button.titleLabel.textColor = [UIColor /*colorWithRed: 0.88 green: 0.80 blue: 0.58 alpha: 1.0*/whiteColor];
    //Sun - ipad
    int sizeFont = 21;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        sizeFont = 26;
    }

    button.titleLabel.font = [UIFont systemFontOfSize: sizeFont];
    
    [button addTarget: target action: action forControlEvents: UIControlEventTouchUpInside];
    
    [self.navBar addSubview: button];
}


- (void)createNavBarTitleWithText: (NSString*)text
{
    //ipad
    int sizeFont = 20;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        sizeFont = 40;
    }
    
    [self createNavBarTitleWithText: text fontSize: sizeFont];
}


- (void)createNavBarTitleWithText: (NSString*)text fontSize: (CGFloat)fontSize
{
    CGFloat labelWidth = 200.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        labelWidth = 400.0;
        self.navBarTitleLabel = [[UILabel alloc] initWithFrame:
                                 CGRectMake(70 + 130, 0,
                                            labelWidth, self.navBar.frame.size.height)];
        
    }else
    {
        self.navBarTitleLabel = [[UILabel alloc] initWithFrame:
                                 CGRectMake(70, 0,
                                            labelWidth, self.navBar.frame.size.height)];
    }
  
  
    self.navBarTitleLabel.font = [UIFont boldSystemFontOfSize: fontSize];
    self.navBarTitleLabel.textColor = [UIColor colorWithRed: 0.17 green: 0.1 blue: 0.04 alpha: 1.0];
    self.navBarTitleLabel.backgroundColor = [UIColor clearColor];
    self.navBarTitleLabel.shadowOffset = CGSizeMake(0, -0.5);
    self.navBarTitleLabel.shadowColor = [UIColor colorWithRed: 0.94 green: 0.90 blue: 0.75 alpha: 1.0];
    self.navBarTitleLabel.text = text;
    [self.navBar addSubview: self.navBarTitleLabel];
}

@end
