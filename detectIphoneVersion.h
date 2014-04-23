//
//  detectIphoneVersion.h
//  PhotoMix
//
//  Created by Mac on 02.04.14.
//  Copyright (c) 2014 Bright Newt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#include <stdio.h>
#include <dlfcn.h>
@interface detectIphoneVersion : NSObject{
}
- (NSString*)deviceModelName;
@end
