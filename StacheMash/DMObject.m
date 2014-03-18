//
//  DMObject.m
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 11/14/10.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//


#import "DMObject.h"
#import "NSObject+FTUtils.h"


@interface DMObject ()

- (BOOL) _hasPropertyNamed: (NSString*)propertyName;

@end


@implementation DMObject

- (BOOL)_hasPropertyNamed: (NSString*)propertyName
{
	return ( nil != [m_propertyDict objectForKey: propertyName] );
}


- (id)init
{
	self = [self initWithDictionary: nil];
	
	return self;
}


- (id) initWithDictionary: (NSDictionary*)dict
{	
	if ( self = [super init] ) {
		m_propertyDict = [self propertyDictionary];
		
		if ( nil != dict ) {
			NSArray *keys = [dict allKeys];
			
			for ( NSString *key in keys ) {
				if ( [self _hasPropertyNamed: key] ) {
					[self setValue: [dict objectForKey: key] forKey: key];
				}
			}
		}
	}
	return self;
}


- (NSString*)description
{	
	NSString *str = [NSString stringWithFormat: @"%@: ", NSStringFromClass([self class])];
	NSArray *propList = [self propertyList];
	
	for ( NSString *propName in propList) {
		str = [str stringByAppendingFormat: @"%@ -> '%@'; ",
			   propName,
			   [self valueForKey: propName]];
	}
	
	return str;
}


- (NSDictionary*)dictionary
{	
	NSArray *propList = [self propertyList];
	NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
	
	for (NSString *propName in propList) {
		[d setObject: [NSString stringWithFormat:@"%@", [self valueForKey: propName]] 
			  forKey: propName];
	}
	
	return d;
}


@end
