//
//  NSObject+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDUtility.h"

@implementation NSObject (ZDUtility)

- (id)cast:(id)objc
{
    if ([objc isKindOfClass:[self class]]) {
        return objc;
    }
    return nil;
}

@end
