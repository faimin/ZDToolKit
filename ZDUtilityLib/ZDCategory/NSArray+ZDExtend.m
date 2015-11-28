//
//  NSArray+ZDExtend.m
//  ZDUtility
//
//  Created by 符现超 on 15/11/28.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import "NSArray+ZDExtend.h"

@implementation NSArray (ZDExtend)

- (NSArray *)reverse
{
    if (!self) {
        return @[].mutableCopy;
    }
    NSArray *array = [self reverseObjectEnumerator].allObjects;
    return array;
}

@end


@implementation NSMutableArray (ZDExtend)

- (void)reverse
{
    NSUInteger count = self.count;
    int mid = floor(count / 2.0);
    for (NSUInteger i = 0; i < mid; i++) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(count - (i + 1))];
    }
}


@end
