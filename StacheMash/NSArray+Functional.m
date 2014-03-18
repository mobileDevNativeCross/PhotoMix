//
//  NSArray+Functional.m
//  MustacheBash
//
//  Created by Kostiantyn Sokolinskyi on 3/24/13.
//  Copyright (c) 2013 Bright Newt. All rights reserved.
//
// based on http://www.mikeash.com/pyblog/friday-qa-2009-08-14-practical-blocks.html

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)map: (id (^)(id obj))block
{
    NSMutableArray *new = [NSMutableArray array];
    for(id obj in self)
    {
        id newObj = block(obj);
        [new addObject: newObj ? newObj : [NSNull null]];
    }
    return new;
}

- (NSArray *)select: (BOOL (^)(id obj))block
{
    NSMutableArray *new = [NSMutableArray array];
    for(id obj in self)
        if(block(obj))
            [new addObject: obj];
    return new;
}

- (id)selectFirst: (BOOL (^)(id obj))block
{
    for(id obj in self)
        if(block(obj))
            return obj;
    
    return nil;
}


- (void)run: (void (^)(id obj))block
{
    for(id obj in self)
        block(obj);
}

@end
