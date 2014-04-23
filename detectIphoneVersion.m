//
//  detectIphoneVersion.m
//  PhotoMix
//
//  Created by Mac on 02.04.14.
//  Copyright (c) 2014 Bright Newt. All rights reserved.
//

#import "detectIphoneVersion.h"

@implementation detectIphoneVersion{
    NSString *modelName;
}

- (NSString*)deviceModelName {
    
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    modelName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if([modelName isEqualToString:@"i386"]) {
        modelName = @"iPhone Simulator";
    }
    else if([modelName isEqualToString:@"iPhone1,1"]) {
        modelName = @"iPhone";
    }
    else if([modelName isEqualToString:@"iPhone1,2"]) {
        modelName = @"iPhone 3G";
    }
    else if([modelName isEqualToString:@"iPhone2,1"]) {
        modelName = @"iPhone 3GS";
    }
    else if([modelName isEqualToString:@"iPhone3,1"]) {
        modelName = @"iPhone4";
    }
    else if([modelName isEqualToString:@"iPhone4,1"]) {
        modelName = @"iPhone4";//S
    }
    else if([modelName isEqualToString:@"iPod1,1"]) {
        modelName = @"iPod 1st Gen";
    }
    else if([modelName isEqualToString:@"iPod2,1"]) {
        modelName = @"iPod 2nd Gen";
    }
    else if([modelName isEqualToString:@"iPod3,1"]) {
        modelName = @"iPod 3rd Gen";
    }
    else if([modelName isEqualToString:@"iPad1,1"]) {
        modelName = @"iPad";
    }
    else if([modelName isEqualToString:@"iPad2,1"]) {
        modelName = @"iPad";
    }
    else if([modelName isEqualToString:@"iPad2,2"]) {
        modelName = @"iPad";
    }
    else if([modelName isEqualToString:@"iPad2,3"]) {
        modelName = @"iPad";
    }
    else if([modelName isEqualToString:@"iPad2,5"]) {
        modelName = @"iPad";
    }
    NSLog(@"modelName1==%@",modelName);
    return modelName;
}

@end
