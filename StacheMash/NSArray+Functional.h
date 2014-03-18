//
//  NSArray+Functional.h
//  MustacheBash
//
//  Created by Kostiantyn Sokolinskyi on 3/24/13.
//  Copyright (c) 2013 Bright Newt. All rights reserved.
//
// based on http://www.mikeash.com/pyblog/friday-qa-2009-08-14-practical-blocks.html

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (NSArray *)map: (id (^)(id obj))block;
- (NSArray *)select: (BOOL (^)(id obj))block;
- (id)selectFirst: (BOOL (^)(id obj))block;

- (void)run: (void (^)(id obj))block;

@end
