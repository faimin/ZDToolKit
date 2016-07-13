//
//  NSArray+ZDExtend.m
//  ZDUtility
//
//  Created by 符现超 on 15/11/28.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import "NSArray+ZDExtend.h"

@implementation NSArray (ZDExtend)

- (NSArray *)zd_reverse
{
    if (self.count <= 1) {
        return self;
    }
    return [self reverseObjectEnumerator].allObjects;
}

- (__kindof NSArray *)zd_shuffle
{
    if (self.count > 0) {
        NSMutableArray *mutArr = [self isKindOfClass:[NSMutableArray class]] ? self : [self mutableCopy];
        for (NSUInteger i = self.count; i > 1; i--) {
            [mutArr exchangeObjectAtIndex:(i - 1)
                      withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
        }
        return mutArr;
    }
    return self;
}

- (__kindof NSArray *)zd_moveObjcToFront:(id)objc
{
    if ([self containsObject:objc]) {
        NSMutableArray *mutArr = [self isKindOfClass:[NSMutableArray class]] ? self : [self mutableCopy];
        if ([self containsObject:objc]) {
            [mutArr removeObject:objc];
        }
        [mutArr insertObject:objc atIndex:0];
        return mutArr;
    }
    return self;
}

- (NSArray *)zd_deduplication
{
#if 0
    // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/CollectionOperators.html
    return [self valueForKeyPath:@"@distinctUnionOfObjects.self"];
#else
    return [NSSet setWithArray:self].allObjects;
#endif
}

- (CGFloat)zd_sum
{
    return [[self valueForKeyPath:@"@sum.floatValue"] floatValue];
}

- (CGFloat)zd_avg
{
    return [[self valueForKeyPath:@"@avg.floatValue"] floatValue];
}

- (CGFloat)zd_max
{
    return [[self valueForKeyPath:@"@max.floatValue"] floatValue];
}

- (CGFloat)zd_min
{
    return [[self valueForKeyPath:@"@min.floatValue"] floatValue];
}

@end

