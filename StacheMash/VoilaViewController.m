//
//  VoilaViewController.m
//  StacheMash
//
//  Created by Konstantin Sokolinskyi on 1/21/12.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "AppDelegate.h"
#import "VoilaViewController.h"
//#import "iRate.h"
#import "Flurry.h"
#import "DETweetComposeViewController.h"
#import "UIDevice+DETweetComposeViewController.h"
#import "Chartboost.h"
#import "DataModel.h"
#import "RevMobAds.h"
#import "YRDropdownView.h"
#import "vunglepub.h"
#import "vkLoginViewController.h"
#import "JSONKit.h"
#import "VKSdk.h"
// Sun - add
#import "GUIHelper.h"

static const NSInteger kFBInvitedUsersCountToGetPack = 5;

static NSArray  * SCOPE = nil;

@interface VoilaViewController ()
{
    EFacebookAPICall _currentAPICall;
    BOOL _isYRDrodownShown;
    BOOL _isFirstApperance;
    UIImageView *view;
    UIButton *button;
}

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIAlertView *errorAlertView;
@property (strong, nonatomic) UIAlertView *successAlertView;
@property (strong, nonatomic) UIAlertView *optionAlertView;
@property (strong, nonatomic) MFMailComposeViewController *sendByEmailController;
@property (strong, nonatomic) MFMailComposeViewController *shareToBNEmailController;
@property (strong, nonatomic) UIButton *printButton;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) NavController *facebookShareViewNavController;
@property (strong, nonatomic) UIAlertView *inviteFBFriends;
//Instagram
@property(nonatomic, retain)     UIDocumentInteractionController* docController;
- (void)shareIG:(id)sender;

- (void)showNagScreen: (NSString*)nagScreenName;

- (void)goBack: (id)sender;
- (void)startOver: (id)sender;

- (void)saveToLibrary: (id)sender;
- (void)imageSavedToPhotosAlbum: (UIImage*)image
       didFinishSavingWithError: (NSError*)error
                    contextInfo: (void*)contextInfo;

- (void)shareByEmail: (id)sender;
- (void)shareToFacebook: (id)sender;

- (void)shareToTwitter: (id)sender;
- (void)addTweetContent: (id)tcvc;
- (void)closeModalViews: (NSNotification*)info;


@end



@implementation VoilaViewController



//@synthesize api = _api;
//@synthesize newRequest = _newRequest;
@synthesize sourceImage = __sourceImage;
@synthesize imageView = _imageView;
@synthesize errorAlertView = _errorAlertView;
@synthesize successAlertView = _successAlertView;
@synthesize optionAlertView = _optionAlertView;
@synthesize sendByEmailController = _sendByEmailController;
@synthesize shareToBNEmailController = _shareToBNEmailController;
@synthesize printButton = _printButton;
@synthesize friendPickerController = _friendPickerController;
@synthesize facebookShareViewNavController = _facebookShareViewNavController;
//Sun
@synthesize oriImage = _oriImage;
@synthesize descriptiontext = _descriptiontext;
@synthesize firstHeightVoila = _firstHeightVoila;
@synthesize firstWidhtVoila = _firstWidhtVoila;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isYRDrodownShown = NO;
        _isFirstApperance = YES;
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
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSLog(@"firstHeightVoila==%.3f",_firstHeightVoila);
    NSLog(@"firstWidthVoila==%.3f",_firstWidhtVoila);
}

-(void)startWorking
{
    
     [VKSdk authorize:SCOPE];
    [VKSdk authorize:SCOPE revokeAccess:YES];
   /* VKRequest * getWall = [VKRequest requestWithMethod:@"wall.get" andParameters:@{VK_API_OWNER_ID : @"-1"} andHttpMethod:@"GET"];
    
    VKRequest *request = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"back"] parameters:[VKImageParameters pngImage] userId:0 groupId:0];
    VKRequest * audioReq = [[VKApi users] get];
   // VKRequest * audioReq = [[VKApi wall]];
    [audioReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"Json result: %@", response.json);
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        } 
    }];*/
      vkLoginViewController *vk = [[vkLoginViewController alloc] init];
    self.appID = @"4279535";
    vk.appID = @"4279535";
    vk.delegate = self;
    [self presentModalViewController:vk animated:YES];
    
    NSLog(@"doAuth");
    
    
    
}
- (void) authComplete {
   
    isAuth = YES;
    NSLog(@"isAuth: %@", isAuth ? @"YES":@"NO");
    if(!isAuth) return;
    /*
     
     Отправка изображения на стену пользователя происходит в несколько этапов:
     1. Запрос сервера ВКонтакте для загрузки нашего изображения (photos.getWallUploadServer)
     2. По полученной ссылке в ответе сервера отправляем изображение методом POST
     3. Получив в ответе hash, photo, server отправлем команду на сохранение фото на стене (photos.saveWallPhoto)
     4. Получив в ответе photo id делаем запрос на размещение на стене картинки с помощью wall.post, где в качестве attachment указываем photo id
     
     */
    
    UIImage *image = self.sourceImage;//[UIImage imageNamed:@"test.jpg"];
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessUserId"];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"VKAccessToken"];
    
    // Этап 1
    NSString *getWallUploadServer = [NSString stringWithFormat:@"https://api.vk.com/method/photos.getWallUploadServer?owner_id=%@&access_token=%@", user_id, accessToken];
    
    NSDictionary *uploadServer = [self sendRequest:getWallUploadServer withCaptcha:NO];
    
    // Получаем ссылку для загрузки изображения
    NSString *upload_url = [[uploadServer objectForKey:@"response"] objectForKey:@"upload_url"];
    
    // Этап 2
    // Преобразуем изображение в NSData
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSDictionary *postDictionary = [self sendPOSTRequest:upload_url withImageData:imageData];
    
    // Из полученного ответа берем hash, photo, server
    NSString *hash = [postDictionary objectForKey:@"hash"];
    NSString *photo = [postDictionary objectForKey:@"photo"];
    NSString *server = [postDictionary objectForKey:@"server"];
    
    // Этап 3
    // Создаем запрос на сохранение фото на сервере вконтакте, в ответ получим id фото
    NSString *saveWallPhoto = [NSString stringWithFormat:@"https://api.vk.com/method/photos.saveWallPhoto?owner_id=%@&access_token=%@&server=%@&photo=%@&hash=%@", user_id, accessToken,server,photo,hash];
    
    saveWallPhoto = [saveWallPhoto stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    //вот эту строчку копируйте в свой код
    
    NSDictionary *saveWallPhotoDict = [self sendRequest:saveWallPhoto withCaptcha:NO];
    
    NSDictionary *photoDict = [[saveWallPhotoDict objectForKey:@"response"] lastObject];
    NSString *photoId = [photoDict objectForKey:@"id"];
    
    // Этап 4
    // Постим изображение на стену пользователя
    NSString *postToWallLink = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@&attachment=%@", user_id, accessToken, [self URLEncodedString:@"Created with PhotoMix"], photoId];
    
    NSDictionary *postToWallDict = [self sendRequest:postToWallLink withCaptcha:NO];
    NSString *errorMsg = [[postToWallDict  objectForKey:@"error"] objectForKey:@"error_msg"];
    if(errorMsg) {
        NSLog(@"ERRRRRRRRRRRRRR");
    } else {
        NSLog(@"++++++++++++++++++++++");

    }
}
- (NSString *)URLEncodedString:(NSString *)str
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)str,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8));
   
	return result;
}
- (NSDictionary *) sendRequest:(NSString *)reqURl withCaptcha:(BOOL)captcha {
    // Если это запрос после ввода капчи, то добавляем в запрос параметры captcha_sid и captcha_key
    
    NSLog(@"Sending request0: %@", reqURl);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    
    // Для простоты используется обычный запрос NSURLConnection, ответ сервера сохраняем в NSData
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // Если ответ получен успешно, можем его посмотреть и заодно с помощью JSONKit получить NSDictionary
    if(responseData){
        NSLog(@"responseData==%@",responseData);
        NSDictionary *dict = [[JSONDecoder decoder] parseJSONData:responseData];
        
        // Если есть описание ошибки в ответе
        NSString *errorMsg = [[dict objectForKey:@"error"] objectForKey:@"error_msg"];
        
        NSLog(@"Server response: %@ \nError: %@", dict, errorMsg);
        
        // Если требуется ввод капчи
        
        
        return dict;
    }
    return nil;
}
- (NSDictionary *) sendPOSTRequest:(NSString *)reqURl withImageData:(NSData *)imageData {
    NSLog(@"Sending request1: %@", reqURl);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:reqURl]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
    // Устанавливаем метод POST
    [request setHTTPMethod:@"POST"];
    
    // Кодировка UTF-8
    [request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuid)) ;
    CFRelease(uuid);
    NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;  boundary=%@", stringBoundary];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"%@",endItemBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Добавляем body к NSMutableRequest
    [request setHTTPBody:body];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *dict;
    if(responseData){
        dict = [[JSONDecoder decoder] parseJSONData:responseData];
        
        // Если есть описание ошибки в ответе
        NSString *errorMsg = [[dict objectForKey:@"error"] objectForKey:@"error_msg"];
        
        NSLog(@"Server response: %@ \nError: %@", dict, errorMsg);
        
        return dict;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"DESCR-======%@",self.descriptiontext);
   // self.api = [[Odnoklassniki alloc] initWithAppId:appID andAppSecret:appSecret1 andAppKey:appKey1 andDelegate:self];
	//if session is still valid
	//if(self.api.isSessionValid)
	//	[self okDidLogin];
//
      SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_MESSAGES];
    [VKSdk initializeWithDelegate:(id)self andAppId:@"4279535"];
    //if ([VKSdk wakeUpSession])
    //{
       // [self startWorking];
       
        
    //}
    
    // create BOTTOM TOOLBAR
    NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
    //Sun - iPad support
    NSString *arrLName = @"back"/*, *fbookName = @"fbook", *twitterName = @"twitter", *emailName = @"email"*/;
    NSString *saveName = @"save", *instagramName = @"instagram", *homeName = @"", *next = @"next";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        arrLName = @"arrow-L-ipad";
        /*fbookName = @"fbook-ipad";
        twitterName = @"twitter-ipad";
        emailName = @"email-ipad";
        saveName = @"save-ipad";
        instagramName = @"instagram-ipad";
        homeName = @"home-ipad"*/;
    }

    [buttonsArray addObject: [self buttonWithImageNamed: arrLName target: self action: @selector(goBack:)]];
    
   /* [buttonsArray addObject: [self buttonWithImageNamed: fbookName target: self action: @selector(shareToFacebook:)]];
    [buttonsArray addObject: [self buttonWithImageNamed: twitterName target: self action: @selector(shareToTwitter:)]];
    [buttonsArray addObject: [self buttonWithImageNamed: emailName target: self action: @selector(shareByEmail:)]];
    [buttonsArray addObject: [self buttonWithImageNamed: saveName target: self action: @selector(saveToLibrary:)]];
    
     //Instagram
    [buttonsArray addObject: [self buttonWithImageNamed: instagramName target: self action: @selector(shareIG:)]];
    */
    [buttonsArray addObject: [self buttonWithImageNamed: homeName target: self action: @selector(startOver:)]];
    
    [buttonsArray addObject: [self buttonWithImageNamed: next target: self action: @selector(showSharing:)]];
    [self createBottomToolbar: buttonsArray];
    
   // [[iRate sharedInstance] logEvent: NO];
    
    // IMAGE view
    if ( nil == self.imageView ) {
        self.imageView = [[UIImageView alloc] initWithFrame:
                          CGRectMake( 0, self.toolbar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.toolbar.frame.size.height)];//dima
       // self.imageView.layer.borderWidth = 1;
      //  self.imageView.layer.borderColor = [UIColor greenColor].CGColor;
       self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.image = self.sourceImage;
        
        
        
         [self.view addSubview: self.imageView];
        //self.imageView.frame =
          //                CGRectMake( 0, self.toolbar.frame.size.height, self.view.frame.size.width, self.imageView.frame.size.height-self.toolbar.frame.size.height);
       
    }

    // PRINT ME button
    //Sun - ipad support
    NSString *printName = @"PrintMe-button-send.png";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        printName = @"PrintMe-button-send-ipad.png";
    }
    UIImage *printMeImg = [UIImage imageNamed: printName];
    self.printButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    self.printButton.frame = CGRectMake(0, 0, printMeImg.size.width, printMeImg.size.height);

    [self.printButton setImage: printMeImg forState: UIControlStateNormal];
    
    // Sun - ipad support

    self.printButton.center = CGPointMake(self.view.frame.size.width - printMeImg.size.width / 2.0 - 6,
                                     printMeImg.size.height / 2.0 + 10);

    [self.printButton addTarget: self action: @selector(sendPostcard:) forControlEvents: UIControlEventTouchUpInside];
   // [self.view addSubview: self.printButton];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(closeModalViews:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];

}

-(void)showSharing:(id)sender{
    view  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [view setBackgroundColor:[UIColor blackColor]];//
    UIImageView *bottom  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_bar_black.png"]];
    bottom.frame = CGRectMake(0, 0, 320, 60);
    
    UIImageView *backBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back.png"]];
    backBtn.frame = CGRectMake(0, 5, 60, 35);
   
   
    
   
    
    UIImageView *doneBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next.png"]];
   // backBtn.frame = CGRectMake(0, 5, 60, 35);
   // [bottom addSubview:backBtn];
    
  //  UIImage *buttonImage = [UIImage imageNamed: imageName];
   // UIImage *buttonPressedImage = [UIImage imageNamed: pressedImageName];
	
	button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake(0, 90, 320, 50);
    [button setTitle:@"facebook" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:24];
    [button.titleLabel setTextAlignment: NSTextAlignmentRight];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 200, 0, 0);
    
//////////////////////////////////////////////////////////////////////////////////////////
   UIButton* instBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    instBtn.frame = CGRectMake(0, 150, 320, 50);
    [instBtn setTitle:@"instagram" forState:UIControlStateNormal];
    instBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [instBtn.titleLabel setTextAlignment: NSTextAlignmentRight];
    instBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 200, 0, 0);
//////////////////////////////////////////////////////////////////////////////////////////
    UIButton* twitBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    twitBtn.frame = CGRectMake(0, 210, 320, 50);
    [twitBtn setTitle:@"twitter" forState:UIControlStateNormal];
    twitBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [twitBtn.titleLabel setTextAlignment: NSTextAlignmentRight];
    twitBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 240, 0, 0);
/////////////////////////////////////////////////////////////////////////////////////////
    UIButton* saveBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 270, 320, 50);
    [saveBtn setTitle:@"save to photos" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [saveBtn.titleLabel setTextAlignment: NSTextAlignmentRight];
    saveBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 150, 0, 0);
/////////////////////////////////////////////////////////////////////////////////////////
    UIButton* vkBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    vkBtn.frame = CGRectMake(0, 330, 320, 50);
    [vkBtn setTitle:@"vkontakte" forState:UIControlStateNormal];
    vkBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [vkBtn.titleLabel setTextAlignment: NSTextAlignmentRight];
    vkBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 200, 0, 0);
////////////////////////////////////////////////////////////////////////////////////////
    UIButton* odnBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    odnBtn.frame = CGRectMake(0, 390, 320, 50);
    [odnBtn setTitle:@"odnoklassniki" forState:UIControlStateNormal];
    odnBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [odnBtn.titleLabel setTextAlignment: NSTextAlignmentRight];
    odnBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 150, 0, 0);
////////////////////////////////////////////////////////////////////////////////////////
    /*
     [buttonsArray addObject: [self buttonWithImageNamed: fbookName target: self action: @selector(shareToFacebook:)]];
     [buttonsArray addObject: [self buttonWithImageNamed: twitterName target: self action: @selector(shareToTwitter:)]];
    // [buttonsArray addObject: [self buttonWithImageNamed: emailName target: self action: //@selector(shareByEmail:)]];
     [buttonsArray addObject: [self buttonWithImageNamed: saveName target: self action: @selector(saveToLibrary:)]];
     
     
     */
  //  UITapGestureRecognizer *tapOdn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareToOdn:)];
//    [odnBtn addGestureRecognizer:tapOdn];
   // [view addSubview:odnBtn];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareToFacebook:)];
    [button addGestureRecognizer:tap];
    [view addSubview:bottom];
    
    UITapGestureRecognizer *tapInst = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareIG:)];
    [instBtn addGestureRecognizer:tapInst];
    [view addSubview:instBtn];
    
    UITapGestureRecognizer *tapTwit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareToTwitter:)];
    [twitBtn addGestureRecognizer:tapTwit];
    [view addSubview:twitBtn];

    
    UITapGestureRecognizer *tapSave = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveToLibrary:)];
    [saveBtn addGestureRecognizer:tapSave];
    [view addSubview:saveBtn];
    
    UITapGestureRecognizer *closeView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeViewMy:)];
    [backBtn addGestureRecognizer:closeView];
   // [view addSubview:saveBtn];
    UITapGestureRecognizer *vkShare = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startWorking)];
    [vkBtn addGestureRecognizer:vkShare];
    [view addSubview:vkBtn];
    
    [view addSubview:button];
    [view addSubview: backBtn];
   // [backBtn bringSubviewToFront:bottom];
    [view setUserInteractionEnabled:YES];
     [backBtn setUserInteractionEnabled:YES];

    
    [self.view addSubview:view];
  //  [view becomeFirstResponder];
}
-(void)shareToOdn:(id) sender{
  //  [self.api authorize:[NSArray arrayWithObjects:@"VALUABLE ACCESS", @"SET STATUS", nil]];
//    [self.newRequest ]
    
    NSString *saveWallPhoto = [NSString stringWithFormat:@"http://api.odnoklassniki.ru/api/photosV2/getUploadUrl?application_key=[Application Key]&sig=[Signature]&session_key=[Session Key]&aid=d7fd39747hd94gd4&count=3%d",2];
    
    saveWallPhoto = [saveWallPhoto stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *saveWallPhotoDict = [self sendRequest:saveWallPhoto withCaptcha:NO];
   // NSLog(@"newRequest===%@",newRequest);
}
-(void)closeViewMy:(id)sender{
    [view removeFromSuperview];
}
- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    debug(@"VOILA: did unload");
    
    self.imageView = nil;
    self.successAlertView = nil;
    self.errorAlertView = nil;
    self.optionAlertView = nil;
}


- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    self.printButton.center = [self centerForPrintButtonWithOrientation: self.interfaceOrientation];
}


- (void)viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];
    
    if ( _isFirstApperance && [[FacebookManager sharedInstance] isFacebookReachable] && ![[DataModel sharedInstance] userHasFreePack]) {
       // [self performSelector:@selector(showFBNotification) withObject:nil afterDelay:0.4];
        _isFirstApperance = NO;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || UIInterfaceOrientationIsLandscape(interfaceOrientation));
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateBottomToolbarToInterfaceOrientation: interfaceOrientation];
    
    self.printButton.center = [self centerForPrintButtonWithOrientation: interfaceOrientation];

}



#pragma mark - Custom View

- (CGPoint)centerForPrintButtonWithOrientation: (UIInterfaceOrientation)orientation
{
    // Sun - iPad support
    CGFloat verticalShift =  ( _isYRDrodownShown ? 60 : 0);;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        verticalShift = ( _isYRDrodownShown ? 135 : 0);
    }
    
    return CGPointMake(-100,
                       0);
    ;//CGPointMake(self.view.frame.size.width - self.printButton.frame.size.width / 2.0 - 6,
             //          self.printButton.frame.size.height / 2.0 + 10 + verticalShift);
}


- (void)showFBNotification
{
    YRDropdownView *view =
    [YRDropdownView showDropdownInView:self.view
                                 title:@""
                                detail:@""
                                 image:nil
                              animated:YES
                             hideAfter:6.0];
    
    _isYRDrodownShown = YES;
    //ipad
    NSString *fbBanner = @"banner.png";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        fbBanner = @"banner@2x.png";
    }
    view.backgroundImage = [UIImage imageNamed:fbBanner];
   // self.printButton.center = [self centerForPrintButtonWithOrientation: self.interfaceOrientation];
    
    [view setTapBlock: ^{
        [self shareToFacebook: nil];
    }];
    
    [view setHideBlock: ^{
        _isYRDrodownShown = NO;
       // self.printButton.center = [self centerForPrintButtonWithOrientation: self.interfaceOrientation];
    }];
}


- (void)showNagScreen: (NSString*)nagScreenName;
{
    
#if NAG_SCREENS_ON
    
//    RevMobFullscreen *revMobFullScreen = [[RevMobAds session] fullscreen];
//    revMobFullScreen.delegate = (AppDelegate*)[UIApplication sharedApplication];
//    [revMobFullScreen showAd];
//    
//    if ( 0 == [nagScreenName length] ) {
//        error(@"empty nag screen name supplied");
//        return;
//    }
//    
//    Chartboost *cb = [Chartboost sharedChartboost];
//    [cb showInterstitial: nagScreenName];
    
    debug(@"ad available: %d", [VGVunglePub adIsAvailable]);
    if ( [VGVunglePub adIsAvailable] ) {
        [VGVunglePub playModalAd: self animated: YES];
    }
    
    [Flurry logEvent: @"ShowNagScreenAfterShareEvent"
               withParameters: [NSDictionary dictionaryWithObjectsAndKeys: nagScreenName, @"NagScreenName", nil]];
#endif
    
}


#pragma mark - Actions

- (void)closeModalViews: (NSNotification*)info
{
    if (self.modalViewController != self.facebookShareViewNavController)
        [self.modalViewController dismissModalViewControllerAnimated: NO];
}


- (void)goBack: (id)sender
{
    [Flurry logEvent: @"BackToEditStache"];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated: YES];
    
    
}


- (void)startOver: (id)sender
{
    [Flurry logEvent: @"StartOver"];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated: NO];
    
#if NAG_SCREENS_ON
    
//    [[Chartboost sharedChartboost] showInterstitial: @"NAG_ON_START_UP"];
    
    RevMobFullscreen *revMobFullScreen = [[RevMobAds session] fullscreenWithPlacementId:REVMOB_FULLSCREEN_PLACEMENT_ID]; // @"515eedc64979bf0d00000001"];
    revMobFullScreen.delegate = (AppDelegate*)[UIApplication sharedApplication];
    [revMobFullScreen showAd];
    
    [[PHPublisherContentRequest requestForApp: [DataModel sharedInstance].playHavenToken secret: [DataModel sharedInstance].playHavenSecret placement: PLAYHAVEN_PLACEMENT2 delegate: (AppDelegate*)[UIApplication sharedApplication].delegate] send];
#endif
    
}


- (void)saveToLibrary: (id)sender
{
    [Flurry logEvent: @"PicSaveToLib"];
    CGFloat imageWidth,imageHeight;
    imageWidth = self.sourceImage.size.width;
    imageHeight = self.sourceImage.size.height;
    
     NSLog(@"imageWidth0==%f imageHeight0=%f",imageWidth,imageHeight);
    
    // Fixing export to camera roll
  /*  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if([GUIHelper isIPadretina]){
            
            (imageWidth <= 1536 ? imageWidth = 1536 : imageWidth);
            (imageHeight <= 2008 ? imageHeight = 2008 : imageWidth);
        }else{
            (imageWidth <= 768 ? imageWidth = 768 : imageWidth);
            (imageHeight <= 1004 ? imageHeight = 1004 : imageWidth);
        }
    }
    else{
        if([GUIHelper isPhone5]){
            (imageWidth <= 640 ? imageWidth = 640 : imageWidth);
            (imageHeight <= 1136 ? imageHeight = 1136 : imageWidth);
            NSLog(@"imageWidth==%f imageHeight=%f",imageWidth,imageHeight);
        }else{
            (imageWidth <= 320 ? imageWidth = 320 : imageWidth);
            (imageHeight <= 480 ? imageHeight = 480 : imageWidth);

        }
    }
    */
    if([GUIHelper isPhone5]){
        (imageWidth <= 640 ? imageWidth = 640 : imageWidth);
        (imageHeight <= 1136 ? imageHeight = 1136 : imageWidth);
        NSLog(@"imageWidth==%f imageHeight=%f",imageWidth,imageHeight);
    }else{
        (imageWidth <= 320 ? imageWidth = 320 : imageWidth);
        (imageHeight <= 480 ? imageHeight = 480 : imageWidth);
        
    }
   
    UIImage *scaledImage = [GUIHelper imageByScalingMY: self.imageView.image toSize: CGSizeMake(imageWidth, imageHeight)];
    
    
    
    //return scaledImage;
    
   /* UIImageWriteToSavedPhotosAlbum(self.imageView.image,
                                   self,
                                   @selector(imageSavedToPhotosAlbum:                                             didFinishSavingWithError:
                                             contextInfo:),
                                  nil);
     */
    
    
     NSParameterAssert(scaledImage);
    UIImageWriteToSavedPhotosAlbum(scaledImage,
                                   self,
                                   @selector(imageSavedToPhotosAlbum:
                                             didFinishSavingWithError:
                                             contextInfo:),
                                   nil);
    

   
  /*  UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, @selector(imageSavedToPhotosAlbum:
                                                               didFinishSavingWithError:
                                                               contextInfo:), nil);
    
*/
}


- (void)imageSavedToPhotosAlbum: (UIImage*)image
       didFinishSavingWithError: (NSError*)error
                    contextInfo: (void*)contextInfo
{
    if ( error ) {
        self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                        message: [error localizedDescription]
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [self.errorAlertView show];
    }
    else {
        self.successAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"PhotoMix!", @"Successful Save to photo album - alert title")
                                                        message: NSLocalizedString(@"Your picture was saved successfully.", @"Successful Save to photo album - alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        self.successAlertView.delegate = self;
        [self.successAlertView show];
    }
} 


- (void)shareByEmail: (id)sender
{
    [Flurry logEvent: @"PicSendByEmail"];
    
    if ( [self canSendMail] ) {
        self.sendByEmailController = [[MFMailComposeViewController alloc] init];
        [self.sendByEmailController setSubject: NSLocalizedString(@"Stachebashed!", @"Share picture by email - subject")];
        
        NSString *message = [NSString stringWithFormat: NSLocalizedString(@"Share by email with glob.ly link %@", @"Share picture by email - body"), [DataModel sharedInstance].globlyLink];
        
        [self.sendByEmailController setMessageBody: message isHTML: NO];
        [self.sendByEmailController setMailComposeDelegate: self];
        
        
        [self.sendByEmailController addAttachmentData: UIImageJPEGRepresentation(self.imageView.image, 0.8)
                             mimeType: @"image/jpeg"
                             fileName: @"Staches.jpg"];
        
        [self presentModalViewController: self.sendByEmailController animated: YES];
    }
}


- (void)shareToFacebook: (id)sender
{
    [Flurry logEvent: @"PicShareToFb"];
    
    if ( ![[FacebookManager sharedInstance] isFacebookReachable] ) {
        error(@"no route to Facebook - cannot post picture");
        self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
                                                         message: NSLocalizedString(@"You need to be connected to Internet to share on Facebook.", @"")
                                                        delegate: nil
                                               cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                               otherButtonTitles: nil];
        [self.errorAlertView show];
        return;
    }
    
    debug(@"sharing to facebook");
    if ( [[FacebookManager sharedInstance] isLoggedIn] ) {
        FacebookShareViewController *vc = [[FacebookShareViewController alloc] initWithNibName: nil bundle: nil];
        vc.sourceImage = self.imageView.image;
        vc.delegate = self;
        [FacebookManager sharedInstance].shareDelegate = vc;
        
        self.facebookShareViewNavController = [[NavController alloc] initWithRootViewController: vc];
        self.facebookShareViewNavController.navigationBarHidden = YES;
        
        [self presentModalViewController: self.facebookShareViewNavController animated: YES];
    }
    else {
        debug(@"initiating login");
        [FacebookManager sharedInstance].loginDelegate = self;
        [[FacebookManager sharedInstance] logIn];
    }

    
// POSTPONED until we get how to link FBSheet share to MB Community page
//    if ( nil != NSClassFromString(@"SLComposeViewController") ) {   // iOS6 FaceBook
//        
//        if([SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook]) {
//            
//            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//            
//            SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
//                if (result == SLComposeViewControllerResultCancelled) {
//                    debug(@"Cancelled");
//                }
//                else {
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Stachebashed!", @"Facebook alert title")
//                                                                    message: NSLocalizedString(@"Your picture was posted successfully.", @"Facebook alert notification text")
//                                                                   delegate: self
//                                                          cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
//                                                          otherButtonTitles: nil];
//                    [alert show];
//                }
//                
//                [controller dismissViewControllerAnimated:YES completion:Nil];
//            };
//            controller.completionHandler =myBlock;
//            
//            [controller setInitialText: NSLocalizedString(@"Stachebashed!", @"Facebook alert title")];
//            [controller addURL: [NSURL URLWithString: @"http://glob.ly/2nr"]];
//            [controller addImage: self.imageView.image];
//            
//            [self presentViewController:controller animated:YES completion:Nil];
//        }
//        else {
//            error(@"no FB accoutn setup");
//        }
//    }
//    else {
//        if ( ![[FacebookManager sharedInstance] isFacebookReachable] ) {
//            error(@"no route to Facebook - cannot post picture");
//            self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
//                                                             message: NSLocalizedString(@"You need to be connected to Internet to share on Facebook.", @"")
//                                                            delegate: nil
//                                                   cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
//                                                   otherButtonTitles: nil];
//            [self.errorAlertView show];
//            return;
//        }
//        
//        debug(@"sharing to facebook");
//        if ( [[FacebookManager sharedInstance] isLoggedIn] ) {
//            FacebookShareViewController *vc = [[FacebookShareViewController alloc] initWithNibName: nil bundle: nil];
//            vc.sourceImage = self.imageView.image;
//            vc.delegate = self;
//            
//            NavController *navController = [[NavController alloc] initWithRootViewController: vc];
//            navController.navigationBarHidden = YES;
//            
//            [FacebookManager sharedInstance].shareDelegate = vc;
//            [self presentModalViewController: navController animated: YES];
//        }
//        else {
//            debug(@"initiating login");
//            [FacebookManager sharedInstance].loginDelegate = self;
//            [[FacebookManager sharedInstance] logIn];
//        }
//    }
}


- (void)shareToTwitter: (id)sender
{
    [Flurry logEvent: @"PicShareToTw"];
    
    Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
    
    if ( nil != tweeterClass ) {  // iOS5.0 Twitter
        if ( [TWTweetComposeViewController canSendTweet] ) {
            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            [self addTweetContent: tweetViewController];
            
            tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                switch (result) {
                    case TWTweetComposeViewControllerResultCancelled:
                        debug(@"Twitter Result: Cancelled");
                        break;
                    case TWTweetComposeViewControllerResultDone:
                    {
                        debug(@"Twitter Result: Sent");
                        [self showNagScreen: @"NAG_AFTER_SHARE_TO_TW"];
                        break;
                    }
                }
                
                [self dismissViewControllerAnimated: YES completion: nil];
            };
            
            [self presentViewController: tweetViewController animated: YES completion: nil];
        }
        else {
            error(@"CANNOT send twitter - setup account");
            self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"") 
                                                            message: NSLocalizedString(@"You need to setup at least 1 twitter account or allow the app to send tweets on your behalf. Please check Twitter in Settings application", @"No twiter account alert text")
                                                           delegate: nil 
                                                  cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                                  otherButtonTitles: nil];
            [self.errorAlertView show];
        }
    }
    else { // DETweeter
        DETweetComposeViewControllerCompletionHandler completionHandler = ^(DETweetComposeViewControllerResult result) {
            switch (result) {
                case DETweetComposeViewControllerResultCancelled:
                    debug(@"Twitter Result: Cancelled");
                    break;
                case DETweetComposeViewControllerResultDone:
                {
                    debug(@"Twitter Result: Sent");
                    [self showNagScreen: @"NAG_AFTER_SHARE_TO_TW"];
                    break;
                }
            }
            [self dismissModalViewControllerAnimated: YES];
        };
        
        DETweetComposeViewController *tcvc = [[DETweetComposeViewController alloc] init];
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self addTweetContent: tcvc];
        tcvc.completionHandler = completionHandler;
        [self presentModalViewController: tcvc animated: YES];
    }
}


- (void)addTweetContent: (id)tcvc
{
    if ( nil == tcvc ) {
        error(@"nil twitter controller supplied");
        return;
    }
    
    [tcvc setInitialText: NSLocalizedString(@"Check out my mustache! via @mustachebashapp", 
                                            @"Default twitter text for mustached picture sharing")];
    [tcvc addImage: self.imageView.image];
}


//- (void)shareWithBN: (id)sender
//{
//    [Flurry logEvent: @"ShareWithBrightNewtPressed"];
//    
//    self.optionAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Send to BrightNewt" , @"Send to BrightNewt - alert title") 
//                                                    message: NSLocalizedString(@"You can send your picture to BrightNewt and find it on Mustache Bash Facebook Page" , @"Send to BrightNewt - alert text") 
//                                                   delegate: nil 
//                                          cancelButtonTitle: NSLocalizedString(@"Not this time", @"Send to BrightNewt - alert no button")
//                                          otherButtonTitles: NSLocalizedString(@"Send it", @"Send to BrightNewt - alert yes button"), nil];
//    self.optionAlertView.delegate = self;
//    [self.optionAlertView show];
//}


- (void)sendPostcard: (id)sender
{
    debug(@"sourceIamge size: %@", NSStringFromCGSize(self.sourceImage.size));
    
    NSString *appKey;
    
#if MB_LUXURY
    appKey = @"D68H3W6BIPH5Z02C9WDVGGDZG8XTZDUFSDCQB137";
#else
//    @"48I7JB96B7992KN7KE574RI2XCL8M0UKB9SLEK6S"// - MINE
    appKey = SINCELERY_ID;//@"IM7VVSK8F4CAFLMC3QZBGD8IC37SMMS928VYY602"; //@"IM7VVSK8F4CAFLMC3QZBGD8IC37SMMS928VYY602"; // - AUSTIN
#endif
    
      
    SYSincerelyController *controller = [[SYSincerelyController alloc] initWithImages:[NSArray arrayWithObject: self.sourceImage]
                                                product:SYProductTypePostcard
                                                applicationKey:appKey
                                                delegate:self];
    
    
    
    controller.shouldSkipCrop = YES;
    
    
    if (controller) {
        //[self presentModalViewController:controller animated: YES];
        [self  presentViewController:controller animated:YES completion:NULL];
        //[controller release];
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView: (UIAlertView*)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex
{
    if ( alertView == self.optionAlertView ) {
        if ( buttonIndex != alertView.cancelButtonIndex ) {
            debug(@"sending email");
            
            [Flurry logEvent: @"ShareWithBrightNewtEmailOpen"];
            
            if ( [self canSendMail] ) {
                self.shareToBNEmailController = [[MFMailComposeViewController alloc] init];
                [self.shareToBNEmailController setSubject: NSLocalizedString(@"Stachebashed to BrightNewt", @"Send to BrightNewt - email subject")];
                
                [self.shareToBNEmailController setToRecipients: [NSArray arrayWithObject: @"support@mustachebashapp.com"]];
                [self.shareToBNEmailController setMessageBody: NSLocalizedString(@"Hi there,\n\n here's my stachebashed picture for Bright Newt contest", @"Send to BrightNewt - email body")
                                    isHTML: NO];
                [self.shareToBNEmailController setMailComposeDelegate: self];
                
                [self.shareToBNEmailController addAttachmentData: UIImageJPEGRepresentation(self.imageView.image, 0.8)
                                     mimeType: @"image/jpeg"
                                     fileName: @"Staches.jpg"];
                
                [self presentModalViewController: self.shareToBNEmailController animated: YES];
            }
        }
        else {
            debug(@"canceled email sending");
            [Flurry logEvent: @"ShareWithBrightNewtCancelled"];
        }
    }
    else if ( alertView == self.successAlertView ) {
        [self showNagScreen: @"NAG_AFTER_SAVE_TO_ALBUM"];
    }
    else if (alertView == self.inviteFBFriends)
    {
        if ( buttonIndex != alertView.cancelButtonIndex ) {
            [self shareAppWithFriends: nil];
        }
        else {
            [Flurry logEvent: @"InviteFBFriendsRejected"];
        }
    }
}


#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController: (MFMailComposeViewController*)controller
          didFinishWithResult: (MFMailComposeResult)result
                        error: (NSError*)error
{
	[self dismissModalViewControllerAnimated: YES]; 
	
	if ( MFMailComposeResultFailed == result ) {
		self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"") 
														message: [NSString stringWithFormat: NSLocalizedString(@"Error sending email: %@", @"email error alert text"), [error localizedDescription]]
													   delegate: nil 
											  cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles: nil]; 
		[self.errorAlertView show];
	}
	else {
        if ( controller == self.shareToBNEmailController ) {
            [self showNagScreen: @"NAG_AFTER_SHARE_TO_BN"];
        }
        else if ( controller == self.sendByEmailController ) {
            [self showNagScreen: @"NAG_AFTER_SHARE_BY_EMAIL"];
        }
        else {
            error(@"Unknown email controller");
        }
	}
}


#pragma mark - FacebookManagerLoginDelegate

- (void)facebookDidLogIn
{
    debug(@"did LOG IN");
    [self shareToFacebook: self];
}


- (void)facebookDidNotLogin: (BOOL)cancelled;
{
    if ( !cancelled ) {
        self.errorAlertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", @"")
                                                        message: NSLocalizedString(@"Failed to authorize with Facebook", @"Facebook authorization failure - alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [self.errorAlertView show];
    }
}


- (void)facebookDidLogOut
{
    debug(@"did LOG OUT");
}



#pragma mark - FacebookShareViewControllerDelegate

- (void)cancelFacebookShareViewController: (id)controller
{
    [self.modalViewController dismissModalViewControllerAnimated: YES];
    [FacebookManager sharedInstance].shareDelegate = nil;
}

- (void)doneFacebookShareViewController: (id)controller
{
#if NAG_SCREENS_ON
    [self showNagScreen: @"NAG_AFTER_SHARE_TO_FB"];
#endif
    [self.modalViewController dismissModalViewControllerAnimated: YES];
    [FacebookManager sharedInstance].shareDelegate = nil;
}


-(void)shareAppWithFriends: (id)controller
{
    [Flurry logEvent: @"InviteFbFriends"];
    if (controller != nil){
        [self.modalViewController dismissModalViewControllerAnimated: YES];
        [FacebookManager sharedInstance].shareDelegate = nil;
    }
    if ( ![[FacebookManager sharedInstance] isFacebookReachable] ) {
        error(@"no route to Facebook - cannot post picture");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
                                                        message: NSLocalizedString(@"You need to be connected to Internet to interact with Facebook.", @"Info screen - share facebook - no connection error alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    debug(@"invite via facebook");
    //    if ( [[FacebookManager sharedInstance] isLoggedIn] ) {
    _currentAPICall = kDialogRequestsSendToMany;
    
    NSSet *fields = [NSSet setWithObjects:@"installed", nil];
    if (self.friendPickerController == nil) {
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        //Sun - Fix warnings
        
        self.friendPickerController.delegate = self;
    }
    
    self.friendPickerController.fieldsForRequest = fields;
    [self.friendPickerController loadData];
    [FacebookManager sharedInstance].dialogDelegate = self;
    
    [[FacebookManager sharedInstance] performSelector: @selector(apiDialogRequestsSendToMany:)
                                           withObject: self.friendPickerController.selection
                                           afterDelay: 0.05];
    
    //    }
    //    else {
    //        debug(@"intite friends - initiating login");
    //        _currentAPICall = kDialogRequestsSendToMany;
    //        debug(@"initiating login with _currentAPICall: %d", _currentAPICall);
    //
    //        //    [FacebookManager sharedInstance].loginDelegate = self;
    //        [[FacebookManager sharedInstance] logIn];
    //    }
}


- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    if ( _currentAPICall == kDialogRequestsSendToMany){
        BOOL notInstalled = [user objectForKey:@"installed"] == nil;
        return notInstalled;
    }
    return YES;
}



- (void)facebookDidSendToFriends: (NSArray *) friends
{
    
    [Flurry logEvent: @"InviteFBFriendsDone" withParameters: @{@"count" : [NSString stringWithFormat: @"%d", [friends count]]}];
    
    NSInteger friendsToInviteLeft = kFBInvitedUsersCountToGetPack - [[DataModel sharedInstance] saveInvitedFriends: [friends count]];
    if (friendsToInviteLeft <= 0)
    {
        [[DataModel sharedInstance] presentFreePack];
        [Flurry logEvent: @"UserGotFreePack"];
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Congrats!", @"User got a free pack alert title")
                                                               message: NSLocalizedString(@"Enjoy your Secret pack!", @"Alert description : user got free pack")
                                                              delegate: self
                                                     cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                                     otherButtonTitles: nil];
        
        
        [successAlert show];
        
    }
    else
    {
        self.inviteFBFriends = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Oops!", @"Need more users to invite alert title")
                                                          message: [NSString stringWithFormat: NSLocalizedString(@"You need to invite %d more friends to get a Secret pack", @"You need to invite %d more friends to get a Secret pack"), friendsToInviteLeft]
                                                         delegate: self
                                                cancelButtonTitle:@"Later"
                                                otherButtonTitles:@"Invite more!", nil];
        
        [self.inviteFBFriends show];
    }
}


- (void)facebookDidFailWithError: (NSError*)error
{
    
}


#pragma mark - SYSincerelyControllerDelegate

- (void)sincerelyControllerDidFinish:(SYSincerelyController *)controller
{
    debug(@"postcard sent");
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sincerelyControllerDidCancel:(SYSincerelyController *)controller
{
    debug(@"postcard cancelled");
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sincerelyControllerDidFailInitiationWithError:(NSError *)error
{
    debug(@"postcard failed init: %@", error);
}  

//Instaram
- (void)shareIG:(id)sender
{
    [Flurry logEvent: @"PicShareToIg"];
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        
      
        
        
        NSString* imagePath1 = [NSString stringWithFormat:@"%@/instagramShare.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath1 error:nil];
        
        
        
        
       
       
        
        UIImage *scaledImage = [GUIHelper ScalingForIG: self.imageView.image toSize: CGSizeMake(612, 612)];
        
        UIImage *backgroundImage = [UIImage imageNamed:@"placeForPict.png"];
        
        UIImage * test =    [VoilaViewController mergeImage:backgroundImage withImage:scaledImage];
        
        
        
        UIImage *instagramImage = scaledImage;//[UIImage imageNamed:@"scroll.png"];
        [UIImagePNGRepresentation(instagramImage) writeToFile:imagePath1 atomically:YES];
        NSLog(@"Image Size >>> %@", NSStringFromCGSize(instagramImage.size));
        //[self.view addSubview:];
       // self.imageView.image = instagramImage;
        self.docController=[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath1]];
        self.docController.delegate = self;
        self.docController.UTI = @"com.instagram.exclusivegram";
     
        [self.docController presentOpenInMenuFromRect: self.view.frame inView:self.view animated:YES ];
        
        /*
        
        
        
        
        UIImage* instaImage = self.imageView.image;
        NSString* imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
        NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
        
        //fixed
        self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
        _docController.delegate=self;
        _docController.UTI = @"com.instagram.exclusivegram";
        //Add caption
        self.docController.annotation = [NSDictionary dictionaryWithObject:INSTAGRAM_CAPTION forKey:@"InstagramCaption"];
       
        //iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [_docController presentOpenInMenuFromRect:[sender frame] inView:self.view animated:YES];
        }
        else{
            [_docController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
        }

        */
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error" , @"")
                                                        message: NSLocalizedString(@"Instagram unavailable. You need to install Instagram in your device in order to share this image.", @"Info screen - share Instagram - no instagram error alert text")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"Dismiss", @"")
                                              otherButtonTitles: nil];
        [alert show];
        return;
        
        
    }
}
/*+ (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
{
    // get size of the first image
    CGImageRef firstImageRef = first.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef)+77;
    
    // get size of the second image
    CGImageRef secondImageRef = second.CGImage;
    CGFloat secondWidth = CGImageGetWidth(secondImageRef)/2;
    CGFloat secondHeight = CGImageGetHeight(secondImageRef)/2;
    
    // build merged size
    CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight+secondHeight*4.2, secondHeight));
    
    // capture image context ref
    UIGraphicsBeginImageContext(mergedSize);
    
    //Draw images onto the context
    [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [second drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
   // firstHeightVoila = firstHeight;
    //firstWidthVoila  = firstWidth;
    // assign context to new UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}
 */

+ (UIImage*)mergeImage:(UIImage*)first withImage:(UIImage*)second
 {
 // get size of the first image
 CGImageRef firstImageRef = first.CGImage;
 CGFloat firstWidth = CGImageGetWidth(firstImageRef);
 CGFloat firstHeight = CGImageGetHeight(firstImageRef);
 
 // get size of the second image
 CGImageRef secondImageRef = second.CGImage;
 CGFloat secondWidth = CGImageGetWidth(secondImageRef);
 CGFloat secondHeight = CGImageGetHeight(secondImageRef);
 
 // build merged size
 CGSize mergedSize = CGSizeMake(MAX(firstWidth, secondWidth), MAX(firstHeight, secondHeight));
 
 // capture image context ref
 UIGraphicsBeginImageContext(mergedSize);
 
 //Draw images onto the context
 [first drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
 [second drawInRect:CGRectMake(0, 0, secondWidth, secondHeight)];
 
 // assign context to new UIImage
 UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
 
 // end context
 UIGraphicsEndImageContext();
 
 return newImage;
 }

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}



@end
