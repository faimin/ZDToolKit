//
//  NSMutableArray+Safe.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import "NSMutableArray+Safe.h"

@implementation NSMutableArray (Safe)

- (void)zd_addObject:(id)obj
{
    if (obj)
    {
        [self addObject:obj];
    }
    else
    {
        NSLog(@"obj为空");
    }
}

@end
