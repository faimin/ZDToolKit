//
//  NSArray+ZDExtend.m
//  ZDUtility
//
//  Created by 符现超 on 15/11/28.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import "NSArray+ZDExtend.h"

@implementation NSArray (ZDExtend)

- (NSArray *)reverse
{
    if (self.count <= 1) {
        return self;
    }
    return [self reverseObjectEnumerator].allObjects;
}

- (NSArray *)shuffle
{
    if (self.count > 0) {
        NSMutableArray *mutArr = [self mutableCopy];
        [mutArr shuffle];
        return [mutArr copy];
    }
    return self;
}

- (NSArray *)moveObjcToFront:(id)objc
{
    if ([self containsObject:objc]) {
        NSMutableArray *mutArr = [self mutableCopy];
        [mutArr moveObjcToFront:objc];
        return [mutArr copy];
    }
    return self;
}

- (NSArray *)deduplication
{
#if 0
    // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/CollectionOperators.html
    return [self valueForKeyPath:@"@distinctUnionOfObjects.self"];
#else
    return [NSSet setWithArray:self].allObjects;
#endif
}

- (CGFloat)sum
{
    return [[self valueForKeyPath:@"@sum.floatValue"] floatValue];
}

- (CGFloat)avg
{
    return [[self valueForKeyPath:@"@avg.floatValue"] floatValue];
}

- (CGFloat)max
{
    return [[self valueForKeyPath:@"@max.floatValue"] floatValue];
}

- (CGFloat)min
{
    return [[self valueForKeyPath:@"@min.floatValue"] floatValue];
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

- (void)moveObjcToFront:(id)objc
{
    if ([self containsObject:objc]) {
        [self removeObject:objc];
    }
    [self insertObject:objc atIndex:0];
}

@end
