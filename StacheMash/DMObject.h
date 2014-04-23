//
//  DMObject.h
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 11/14/10.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface DMObject : NSObject
{
	NSDictionary *m_propertyDict;
}

- (id)init;
- (id)initWithDictionary: (NSDictionary*)dict;

- (NSString*)description;
- (NSDictionary*)dictionary;



@end
