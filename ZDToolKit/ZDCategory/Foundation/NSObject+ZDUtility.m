//
//  NSObject+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDUtility.h"

@implementation NSObject (ZDUtility)

+ (id)zd_cast:(id)objc
{
    if ([objc isKindOfClass:[self class]]) {
        return objc;
    }
    return nil;
}

- (id)deepCopy
{
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        NSLog(@"deepCopy error: %@", exception);
    }
    return obj;
}

@end
