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
    if (self.count <= 1) {
        return self;
    }
    NSArray *array = [self reverseObjectEnumerator].allObjects;
    return array;
}

- (NSArray *)shuffle
{
    if (self.count > 0) {
        NSMutableArray *mutArr = [self mutableCopy];
        [mutArr shuffle];
        return [mutArr copy];
    } else {
        return self;
    }
}

@end


@implementation NSMutableArray (ZDExtend)

- (void)reverse
{
    NSUInteger count = self.count;
    int mid = floor(count / 2.0);
    for (NSUInteger i = 0; i < mid; i++) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:(count - (i + 1))];
    }
}

- (void)shuffle
{
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:(i - 1)
                  withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
}

@end
