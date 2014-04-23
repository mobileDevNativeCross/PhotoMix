//
//  NSObject+FTUtils.m
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 10/6/10.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <objc/runtime.h>

#import "NSObject+FTUtils.h"

static const char *propertyType( objc_property_t property );

@implementation NSObject ( FTUtils )

- ( NSArray* ) propertyList
{	
	unsigned int outCount, i;
	
    objc_property_t *properties = class_copyPropertyList( [self class], &outCount);
	
	if ( 0 == outCount )
	{
		return nil;
	}		
	
	NSMutableArray *array = [NSMutableArray array];
	
    for ( i = 0; i < outCount; i++ )
	{
        objc_property_t property = properties[ i ];
		
        const char *propName = property_getName( property );
		
        if( propName )
		{
			NSString *propertyName = [NSString stringWithCString: propName
														encoding: NSUTF8StringEncoding];
			[array addObject: propertyName];
        }
    }
	
    free( properties );
	
	return array;
}

- ( NSArray* ) nonNilValuedPropertyList
{
	NSArray			*allPropertiesList = [self propertyList];
	
	NSMutableArray	*nonNilValuedPropertyList = [NSMutableArray arrayWithCapacity: [allPropertiesList count]];
	
	for ( NSString *propName in allPropertiesList )
	{
		id object = [self valueForKey: propName];
		
		if ( nil != object )
		{
			[nonNilValuedPropertyList addObject: propName];
		}
	}
	
	return nonNilValuedPropertyList;
}

- ( NSDictionary* ) propertyDictionary
{
	unsigned int outCount, i;
	
    objc_property_t *properties = class_copyPropertyList( [self class], &outCount);
	
	if ( 0 == outCount )
	{
		return nil;
	}		
	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity: outCount];

			//NSLog(@"dictionary++==%@",dictionary);
    
    for ( i = 0; i < outCount; i++ )
	{
        objc_property_t property = properties[ i ];

        
        const char *propName = property_getName( property );
		
        if( propName )
		{
			NSString *propertyName = [NSString stringWithCString: propName
														encoding: NSUTF8StringEncoding];
		
			const char *propType = propertyType( property );
            
			NSString *propertyTypeString = [NSString stringWithCString: propType
															  encoding: NSUTF16StringEncoding];
			
            if ( propertyTypeString ) {
                [dictionary setObject: propertyTypeString forKey: propertyName];
            }
        }
    }
	
   // free( properties );
	//NSLog(@"dictionaryyy===-%@",dictionary);
	return dictionary;
}

static const char *propertyType( objc_property_t property )
{
    const char *attributes = property_getAttributes( property );
	
    char buffer[ 1 + strlen( attributes ) ];
    strcpy( buffer, attributes );
	
    char *state = buffer;
	char *attribute;
	
    while ( ( attribute = strsep( &state, "," ) ) != NULL )
	{
        if ( attribute[ 0 ] == 'T' )
		{
			if ( attribute[ 1 ] == '@' ) // object
			{
				return ( const char * )[[NSData dataWithBytes: ( attribute + 3 ) length: strlen( attribute ) - 4] bytes];
			}
			else
			{
				return ( const char * )[[NSData dataWithBytes: ( attribute + 1 ) length: 1] bytes];
			}
        }
    }
    return "@";
}

@end
