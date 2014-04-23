//
//  NSObject+FTUtils.h
//  MustacheBash
//
//  Created by Konstantin Sokolinskyi on 10/6/10.
//  Copyright (c) 2012 Bright Newt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject ( FTUtils )

- ( NSArray* ) propertyList;
- ( NSArray* ) nonNilValuedPropertyList;

- ( NSDictionary* ) propertyDictionary;

@end
