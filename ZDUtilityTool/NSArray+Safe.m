//
//  NSArray+Safe.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import "NSArray+Safe.h"
#import <objc/runtime.h>

@implementation NSArray (Safe)

- (id)zd_objectAtIndex:(NSUInteger)index
{
    if (self.count <= index)
    {
        return nil;
    }
    id obj = self[index];
    return obj;
}


@end
