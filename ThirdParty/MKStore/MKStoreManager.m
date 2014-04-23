//
//  MKStoreManager.m
//
//  Created by Mugunth Kumar on 17-Oct-09.
//  Copyright 2009 Mugunth Kumar. All rights reserved.
//  mugunthkumar.com
//

#import "MKStoreManager.h"


@implementation MKStoreManager{
     NSUserDefaults * defs;
    int tagB;
    NSString* stacheGlob;

}

@synthesize purchasableObjects;
@synthesize storeObserver;
@synthesize delegate;

// all your features should be managed one and only by StoreManager
static NSString *featureAId = @"vk.com.photomix.allpic";
static NSString *featureBId = @"vk.com.photomix.pic1";
static NSString *featureCId = @"vk.com.photomix.pic2";

BOOL featureAPurchased;
BOOL featureBPurchased;
BOOL featureCPurchased;

static MKStoreManager* _sharedStoreManager; // self

- (void)dealloc {
	
//	[_sharedStoreManager release];
//	[storeObserver release];
//	[super dealloc];
}

+ (BOOL) featureAPurchased {
	
	return featureAPurchased;
}

+ (BOOL) featureBPurchased {
	
	return featureBPurchased;
}

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];			
			[_sharedStoreManager requestProductData];
			
			[MKStoreManager loadPurchases];
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    return _sharedStoreManager;
}


#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

/*- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}
*/

- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects: featureAId, featureBId,featureCId, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[purchasableObjects addObjectsFromArray:response.products];
	// populate your UI Controls here
	for(int i=0;i<[purchasableObjects count];i++)
	{
		
		SKProduct *product = [purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
	//[request autorelease];
}

- (void) buyFeatureA: (int)tags :(NSString*)stache
{
	[self buyFeature: featureAId :tags :stache];
    
}

- (void) restorePreviousTransactionsOnComplete:(void (^)(void)) completionBlock
                                       onError:(void (^)(NSError*)) errorBlock
{
    
    
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions{
   
   //     NSLog(@"SKPaymentQueue==%@",queue);
    defs = [[NSUserDefaults alloc]init];
                        
    for (SKPaymentTransaction* transaction in transactions)
    {
         NSLog(@"transactions==%ld",(long)transaction.transactionState);
        switch ( transaction.transactionState )
        {
            case SKPaymentTransactionStatePurchased:
				debug( @"state = SKPaymentTransactionStatePurchased" );
              //  [self completeTransaction: transaction ];
                if(![stacheGlob isEqualToString:@"buyAll"]){
                    [defs setInteger:tagB forKey:stacheGlob];
                    [defs setValue:@"One" forKey:@"buyOne"];

                }
                else {
                     [defs setValue:stacheGlob forKey:stacheGlob];
                    [defs setValue:@"One" forKey:@"buyOne"];
                    
                }
                    [defs synchronize];
                
                
                break;
            case SKPaymentTransactionStateFailed:
				debug( @"state = SKPaymentTransactionStateFailed" );
                //[self failedTransaction: transaction ];
                break;
            case SKPaymentTransactionStateRestored:
				debug( @"state = SKPaymentTransactionStateRestored" );
                //[self restoreTransaction: transaction ];
			case SKPaymentTransactionStatePurchasing:
				debug( @"state = SKPaymentTransactionStatePurchasing... going on" );
				break;
            default:
				debug( @"state = unknown. WTF?" );
                break;
        }
    }
}
- (void) buyFeature:(NSString*) featureId :(int)tag :(NSString*)stache;
{
    stacheGlob = [[NSString alloc]init];
     defs = [[NSUserDefaults alloc]init];
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:(id)self];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
        if([featureId isEqualToString:featureBId]){
        tagB  = tag;
        stacheGlob = stache;
        }
        else if([featureId isEqualToString:featureAId]){
           
            stacheGlob = @"buyAll";
           
        }
        
        
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PhotoMix" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	//	[alert release];
	}
}

- (void) buyFeatureB:(int)tag :(NSString*)stache;
{
	[self buyFeature :featureBId :tag :stache];
}
-(void)buyFeatureC
{
    [self buyFeature:featureCId :0: @"Restore"];
}
-(void)paymentCanceled
{
	if([delegate respondsToSelector:@selector(failed)])
		[delegate failed];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	if([delegate respondsToSelector:@selector(failed)])
		[delegate failed];
	
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
//	[alert release];
}

-(void) provideContent: (NSString*) productIdentifier
{
	if([productIdentifier isEqualToString:featureAId])
	{
		featureAPurchased = YES;
		if([delegate respondsToSelector:@selector(productAPurchased)])
			[delegate productAPurchased];
	}

	if([productIdentifier isEqualToString:featureBId])
	{
		featureBPurchased = YES;
		if([delegate respondsToSelector:@selector(productBPurchased)])
			[delegate productBPurchased];
	}
	
	[MKStoreManager updatePurchases];
}


+(void) loadPurchases 
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];	
	featureAPurchased = [userDefaults boolForKey:featureAId]; 
	featureBPurchased = [userDefaults boolForKey:featureBId]; 	
}


+(void) updatePurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:featureAPurchased forKey:featureAId];
	[userDefaults setBool:featureBPurchased forKey:featureBId];
}
@end
