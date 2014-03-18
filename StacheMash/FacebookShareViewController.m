//
//  FacebookShareViewController.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/25/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import "FacebookShareViewController.h"
#import "FacebookManager.h"
#import "GUIHelper.h"
#import "SpinnerView.h"
#import "DataModel.h"
#import <QuartzCore/QuartzCore.h>

static const NSInteger kFBInvitedUsersCount = 5;

@interface FacebookShareViewController ()
{
    EFacebookAPICall _currentAPICall;
}

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIImageView *titleBar;
@property (strong, nonatomic) UITextField *titleField;

@property (strong, nonatomic) UIAlertView *successAlert;
@property (strong, nonatomic) SpinnerView *spinnerView;
@property (assign, nonatomic) BOOL spinnerAnimating;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;
@property (assign, nonatomic) BOOL showingFriendPicker;

@property (strong, nonatomic) UITableView *selectedFriendsTableView;
@property (strong, nonatomic) NSMutableArray *selectedFriendsArray;

- (void)cancel: (id)sender;
- (void)share: (id)sender;

- (void)showActivityIndicator;
- (void)hideActivityIndicator;

- (void)startSpinner;
- (void)stopSpinner;

@end 


@implementation FacebookShareViewController

@synthesize titleBar = _titleBar;
@synthesize sourceImage = __sourceImage;
@synthesize delegate = __delegate;
@synthesize imageView = _imageView;
@synthesize titleField = _titleField;
@synthesize successAlert = _successAlert;
@synthesize spinnerView = _spinnerView;
@synthesize spinnerAnimating = _spinnerAnimating;

@synthesize friendPickerController = _friendPickerController;
@synthesize searchBar = _searchBar;
@synthesize searchText = _searchText;
@synthesize showingFriendPicker = _showingFriendPicker;
@synthesize selectedFriendsTableView = _selectedFriendsTableView;
@synthesize selectedFriendsArray = _selectedFriendsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].applicationFrame];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.showingFriendPicker = NO;
}


- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.showingFriendPicker) {
        [self addSearchBarToFriendPickerView];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createNavBar];
    
    // IMAGE VIEW
    //Sun - iPad support
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        self.imageView = [[UIImageView alloc] initWithFrame:
                          CGRectMake(5, [GUIHelper getBottomYForView: self.navBar] + 2 ,
                                     2*180,
                                     400)];
    }else{
    self.imageView = [[UIImageView alloc] initWithFrame:
                      CGRectMake(5, [GUIHelper getBottomYForView: self.navBar] ,
                                 180,
                                 ([GUIHelper isPhone5] ? 200 : 150))];
    }
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.image = self.sourceImage;
    [self.imageView.layer setBorderColor: [[UIColor colorWithRed:0.0 green:0.48 blue:0.02 alpha:1.0] CGColor]];
    [self.imageView.layer setBorderWidth: 1.0];
    
    [self.view addSubview: self.imageView];
    
    // CREATE title Bar
    //Sun - ipad support
    NSString *barName = @"bar-down-hor.png";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        barName = @"bar-down-hor-ipad.png";
    }
    
    UIImage *barImage = [UIImage imageNamed: barName];
    self.titleBar = [[UIImageView alloc] initWithFrame:
                    CGRectMake(0,
                               self.view.frame.size.height - 216 - barImage.size.height,
                               self.view.frame.size.width,
                               barImage.size.height)];
    self.titleBar.userInteractionEnabled = YES;
    self.titleBar.image = barImage;
    [self.view addSubview: self.titleBar];
    
    
    // TITLE field
    CGFloat titleFieldHeight = 26;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        self.titleField = [[UITextField alloc] initWithFrame: CGRectMake(15,
                                                                         0.5 * (self.titleBar.bounds.size.height - 78),
                                                                         self.view.frame.size.width - 30,
                                                                         30)];
    }else{
    self.titleField = [[UITextField alloc] initWithFrame: CGRectMake(15,
                                                                     0.5 * (self.titleBar.bounds.size.height - titleFieldHeight),
                                                                     self.view.frame.size.width - 30,
                                                                     titleFieldHeight)];
    }
    self.titleField.clearButtonMode = UITextFieldViewModeAlways;
    self.titleField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleField.delegate = self;
    self.titleField.returnKeyType = UIReturnKeyDone;
    self.titleField.placeholder = NSLocalizedString(@"Optional caption", @"");
    
    [self.titleField becomeFirstResponder];
    [self.titleBar addSubview: self.titleField];
    
    // Add friends button
    //Sun - ipad support
    NSString *friendName = @"btn-PostToFriends.png", *friendPressName = @"btn-PostToFriends-press.png";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        friendName = @"btn-PostToFriends-ipad.png";
        friendPressName = @"btn-PostToFriends-ipad-press.png";
    }

    UIImage *buttonImage = [UIImage imageNamed: friendName];
    UIImage *buttonPressedImage = [UIImage imageNamed: friendPressName];
	
	UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    
    [button setBackgroundImage: buttonImage forState: UIControlStateNormal];
    [button setBackgroundImage: buttonPressedImage forState: UIControlStateHighlighted];
    CGFloat yFriendBtn = 60;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        yFriendBtn += 60;
    }
	button.frame= CGRectMake(self.view.frame.size.width - buttonImage.size.width - 8,
                             yFriendBtn,
                             buttonImage.size.width, buttonImage.size.height);
	
    [button addTarget: self action: @selector(pickFriendsButtonClick:) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: button];

    self.selectedFriendsArray = [NSMutableArray array];
    if ([DataModel sharedInstance].currentFBFriend != nil)
    {
        [self.selectedFriendsArray addObject: [DataModel sharedInstance].currentFBFriend];
    }
    [self createTable];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    debug(@"Facebook share: did unload");
    
    self.imageView = nil;
    self.titleBar = nil;
    self.titleField = nil;
    self.successAlert = nil;
    self.spinnerView = nil;
    self.friendPickerController = nil;
    self.searchBar = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Views

- (void)createNavBar
{
    [super createNavBar];
    [self createLeftNavBarButtonWithTitle: NSLocalizedString(@"Cancel", @"Nab bar button") target: self action: @selector(cancel:)];
    [self createRightNavBarButtonWithTitle: NSLocalizedString(@"Share", @"Nab bar button") target: self action: @selector(share:)];
    [self createNavBarTitleWithText: NSLocalizedString(@"Share to facebook", @"Facebook sharing screen Nav bar title")];
}


- (void)addSearchBarToFriendPickerView
{
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}


- (void)createTable
{
    if ( nil == self.selectedFriendsTableView ) {
        CGFloat kTableWidth = 120.0;
        // iPad support
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            kTableWidth = 284.0;
            self.selectedFriendsTableView = [[UITableView alloc] initWithFrame: CGRectMake(self.view.frame.size.width - kTableWidth -10, [GUIHelper getBottomYForView: self.navBar] + 120, kTableWidth, 400) style: UITableViewStylePlain];
        }else{
        self.selectedFriendsTableView = [[UITableView alloc] initWithFrame: CGRectMake(self.view.frame.size.width - kTableWidth -10, [GUIHelper getBottomYForView: self.navBar] + 50, kTableWidth, ([GUIHelper isPhone5] ? 200 : 115)) style: UITableViewStylePlain];
        }
        self.selectedFriendsTableView.delegate = self;
        self.selectedFriendsTableView.dataSource = self;
        self.selectedFriendsTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.selectedFriendsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.selectedFriendsTableView.backgroundColor = [UIColor clearColor];
        self.selectedFriendsTableView.showsVerticalScrollIndicator = YES;
        self.selectedFriendsTableView.showsHorizontalScrollIndicator = NO;
        
    }
    [self.view addSubview:self.selectedFriendsTableView];
    
}




#pragma mark UI handlers


- (void) pickFriendsButtonClick:(id)sender {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];

    [self.friendPickerController clearSelection];
    
    self.showingFriendPicker = YES;
    [self presentViewController:self.friendPickerController
                       animated:YES
                     completion:^(void){
                         [self addSearchBarToFriendPickerView];
                     }
     ];
}


- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}


- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    if ([self.selectedFriendsArray containsObject:user])
        return NO;
    if (self.searchText && ![self.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:self.searchText
                          options:NSCaseInsensitiveSearch];
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
    
}


- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        [self.selectedFriendsArray addObject: user];
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    [self.selectedFriendsTableView reloadData];
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @""];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self fillTextBoxAndDismiss:@""];
    
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
   
    self.showingFriendPicker = NO;
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Actions

- (void)cancel: (id)sender
{
    [self.delegate cancelFacebookShareViewController: self];
}


- (void)share: (id)sender
{
    [self.titleField resignFirstResponder];
    self.titleBar.hidden = YES;
    
    [self showActivityIndicator];
    [FacebookManager sharedInstance].shareDelegate = self;
    if ([self.selectedFriendsArray count] > 0)
    {
        [[FacebookManager sharedInstance] apiGraphUserPhotosPostWithImage: self.imageView.image
                                                                toFriends: self.selectedFriendsArray
                                                                    title: self.titleField.text];
    }
    else{
    
        [[FacebookManager sharedInstance] apiGraphUserPhotosPostWithImage: self.imageView.image
                                                                    title: self.titleField.text];
    }

    _currentAPICall = kAPIGraphUserPhotosPost;
}


#pragma mark - Private

- (void)showActivityIndicator
{
    if (!self.spinnerAnimating) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [self startSpinner];
        self.spinnerAnimating = YES;
    }
}


- (void)hideActivityIndicator
{
    if (self.spinnerAnimating) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [self stopSpinner];
        self.spinnerAnimating = NO;
    }
}


- (void)startSpinner
{
	if ( nil == self.spinnerView )
	{
		CGRect appFrame = [UIScreen mainScreen].applicationFrame;
		
		CGFloat spinnerViewVerticalShift;
		
		if ( UIStatusBarStyleBlackTranslucent == [UIApplication sharedApplication].statusBarStyle )
			spinnerViewVerticalShift = 40.0;
		else
			spinnerViewVerticalShift = 20.0;
        
		appFrame.origin.y -= spinnerViewVerticalShift;
		appFrame.size.height += spinnerViewVerticalShift;
		
		self.spinnerView = [[SpinnerView alloc] initWithFrame: appFrame shading: YES];
		self.spinnerView.alpha = 0.0;
		
		[self.view addSubview: self.spinnerView];
		[self.view bringSubviewToFront: self.spinnerView];
		
		[UIView animateWithDuration: 0.15
							  delay: 0.0
							options: UIViewAnimationOptionCurveLinear
						 animations: ^ {
							 self.spinnerView.alpha = 1.0;
						 }
						 completion: ^( BOOL finished ) {
							 if ( finished ) {
							 }
						 }];	
	}
}


- (void)stopSpinner
{
	if ( nil != self.spinnerView )
	{
		UIApplication* app = [UIApplication sharedApplication];
		app.networkActivityIndicatorVisible = NO;
        
		[UIView animateWithDuration: 0.15
							  delay: 0.0
							options: UIViewAnimationOptionCurveLinear
						 animations: ^ {
							 self.spinnerView.alpha = 0.0;
						 }
						 completion: ^( BOOL finished ) {
							 if ( finished ) {
								 [self.spinnerView removeFromSuperview];
								 self.spinnerView = nil;
							 }
						 }];	
	}
}



#pragma FacebookManagerShareDelegate

- (void)facebookDidShare
{
    
    if (kAPIGraphUserPhotosPost == _currentAPICall){
        [Flurry logEvent: @"DidShareImageToFB"];
        [self hideActivityIndicator];
        if ([[DataModel sharedInstance] userHasFreePack]){
            self.successAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Stachebashed!", @"Facebook alert title")
                                                           message: NSLocalizedString(@"Your picture was posted successfully.", @"Facebook alert notification text")
                                                          delegate: self
                                                 cancelButtonTitle:@"Dismiss"
                                                 otherButtonTitles:nil];
    
        }
        else
        {
            NSInteger invitedFriends = [[DataModel sharedInstance] getInvitedFriends];
            
            if (invitedFriends == 0)
                invitedFriends = kFBInvitedUsersCount;
            self.successAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Stachebashed!", @"Facebook alert title")
                                                       message: [NSString stringWithFormat: NSLocalizedString(@"Your picture was posted successfully. Invite %d friends and get a Secret pack!", @"Your picture was posted successfully. Invite up to 20 friends and get a Secret pack!"), invitedFriends]
                                                      delegate: self
                                             cancelButtonTitle:NSLocalizedString (@"Later", @"Later FB friend alert button")
                                             otherButtonTitles:NSLocalizedString (@"Invite!" , @"Invite FB friend alert button"), nil];

        }
        [self.successAlert show];
    }
    
}


- (void)facebookDidFailWithError: (NSError*)error
{

    if (kAPIGraphUserPhotosPost == _currentAPICall){
        
        [self hideActivityIndicator];
        error(@"pic sharing failed with error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"Alert title")
                                                        message: NSLocalizedString(@"Something went wrong while posting your pic to Facebook! You can try it again", @"FB sharing error message")
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
    }

}


- (void)facebookDidCanceled
{
    
    if (kAPIGraphUserPhotosPost == _currentAPICall){
        
        [self hideActivityIndicator];
        [self.delegate doneFacebookShareViewController: self];
    }
    
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
        [self.delegate doneFacebookShareViewController: self];
    else
        [self.delegate shareAppWithFriends: self];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn: (UITextField*)textField
{
    [self share: textField];
    return YES;
}


- (void)textFieldDidBeginEditing: (UITextField*)textField
{
    [Flurry logEvent: @"BeginEditFBPicCaption"];
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
    [self.friendPickerController updateView];
}


#pragma UITableView Data Source & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (([self.selectedFriendsArray count] > 0)? 1 : 0);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (([self.selectedFriendsArray count] > 0) ? [self.selectedFriendsArray count] + 1: 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier, *ClearCellIdentifier;
    CellIdentifier = @"Cell";
    ClearCellIdentifier = @"ClearFriends";
    
    if ( indexPath.row == [self.selectedFriendsArray count] ) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: ClearCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                          reuseIdentifier: ClearCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        cell.textLabel.text = NSLocalizedString(@"Remove all", @"Remove all");
        cell.textLabel.textColor = [UIColor colorWithRed: 0.71 green: 0.1 blue: 0.1 alpha: 1.0];
        CGFloat fontSize = 14;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            fontSize = 24;
        }
        cell.textLabel.font = [UIFont boldSystemFontOfSize: fontSize];
        cell.contentView.backgroundColor = [UIColor colorWithRed: 0.96 green: 0.95 blue: 0.93 alpha: 1.0];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        return cell;
    }

    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }

    cell.textLabel.textColor = [UIColor colorWithRed: 0.1 green: 0.1 blue: 0.1 alpha: 1.0];
    CGFloat fontNameSize = 12;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        fontNameSize = 22;
    }
    cell.textLabel.font = [UIFont systemFontOfSize: fontNameSize];
    cell.textLabel.text = [self.selectedFriendsArray objectAtIndex:indexPath.row][@"name"];
    cell.contentView.backgroundColor = [UIColor colorWithRed: 0.96 green: 0.95 blue: 0.93 alpha: 1.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: NO];
    if ( indexPath.row == [self.selectedFriendsArray count] ) {
        [self.selectedFriendsArray removeAllObjects];
        [self.selectedFriendsTableView reloadData];
    }
    
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0;
    
}
@end
