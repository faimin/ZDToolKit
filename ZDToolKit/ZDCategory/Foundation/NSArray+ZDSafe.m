//
//  NSArray+ZDSafe.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2023/4/17.
//

#import <objc/runtime.h>
#import "NSArray+ZDSafe.h"

@implementation NSArray (ZDSafe)

#pragma mark - safe hook

+ (void)load {
#if 0
    [self swizzleInstanceSelector:@selector(objectAtIndex:) withNewSelector:@selector(zd_safeObjectAtIndex:)];
    [self swizzleClassSelector:@selector(arrayWithObjects:count:) withNewSelector:@selector(zd_safeArrayWithObjects:count:)];
#endif
}

- (id)zd_safeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return nil;
    }

    return [self zd_safeObjectAtIndex:index];
}

static const NSUInteger loopLimit = 10;
+ (instancetype)zd_safeArrayWithObjects:(const id [])objects count:(NSUInteger)cnt {
    NSUInteger loopTimes = (cnt > loopLimit ? loopLimit : cnt);

    for (int i = 0; i < loopTimes; i++) {
        if (!objects[i]) {
            return nil;
        }
    }

    return [self zd_safeArrayWithObjects:objects count:cnt];
}

#pragma mark - other -

- (id)objectAtIndex:(NSUInteger)index kindOfClass:(Class)aClass {
    if (index < [self count]) {
        id obj = [self objectAtIndex:index];
        return [obj isKindOfClass:aClass] ? obj : nil;
    }

    return nil;
}

- (id)objectAtIndex:(NSUInteger)index memberOfClass:(Class)aClass {
    if (index < [self count]) {
        id obj = [self objectAtIndex:index];
        return [obj isMemberOfClass:aClass] ? obj : nil;
    }

    return nil;
}

- (id)objectAtIndex:(NSUInteger)index defaultValue:(id)value {
    id obj = nil;

    if (index < [self count]) {
        obj = [self objectAtIndex:index];

        if (obj == [NSNull null]) {
            return value;
        }
    }

    return nil == obj ? value : obj;
}

- (NSString *)stringAtIndex:(NSUInteger)index defaultValue:(NSString *)value {
    NSString *str = [self objectAtIndex:index kindOfClass:[NSString class]];

    return nil == str ? value : str;
}

- (NSNumber *)numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)value {
    NSNumber *number = [self objectAtIndex:index kindOfClass:[NSNumber class]];

    return nil == number ? value : number;
}

- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)value {
    NSDictionary *dict = [self objectAtIndex:index kindOfClass:[NSDictionary class]];

    return nil == dict ? value : dict;
}

- (NSArray *)arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)value {
    NSArray *array = [self objectAtIndex:index kindOfClass:[NSArray class]];

    return nil == array ? value : array;
}

- (NSData *)dataAtIndex:(NSUInteger)index defaultValue:(NSData *)value {
    NSData *data = [self objectAtIndex:index kindOfClass:[NSData class]];

    return nil == data ? value : data;
}

- (NSDate *)dateAtIndex:(NSUInteger)index defaultValue:(NSDate *)value {
    NSDate *date = [self objectAtIndex:index kindOfClass:[NSDate class]];

    return nil == date ? value : date;
}

- (float)floatAtIndex:(NSUInteger)index defaultValue:(float)value {
    float f = value;

    if (index < [self count]) {
        id obj = [self objectAtIndex:index];
        f = [obj respondsToSelector:@selector(floatValue)] ? [obj floatValue] : value;
    }

    return f;
}

- (double)doubleAtIndex:(NSUInteger)index defaultValue:(double)value {
    double d = value;

    if (index < [self count]) {
        id obj = [self objectAtIndex:index];
        d = [obj respondsToSelector:@selector(doubleValue)] ? [obj doubleValue] : value;
    }

    return d;
}

- (NSInteger)integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)value {
    NSInteger i = value;

    if (index < [self count]) {
        id obj = [self objectAtIndex:index];
        i = [obj respondsToSelector:@selector(integerValue)] ? [obj integerValue] : value;
    }

    return i;
}

- (NSUInteger)unintegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)value {
    NSUInteger u = value;

    if (index < [self count]) {
        id obj = [self objectAtIndex:index];
        u = [obj respondsToSelector:@selector(unsignedIntegerValue)] ? [obj unsignedIntegerValue] : value;
    }

    return u;
}

- (BOOL)boolAtIndex:(NSUInteger)index defaultValue:(BOOL)value {
    BOOL b = value;

    if (index < [self count]) {
        id obj = [self objectAtIndex:index];
        b = [obj respondsToSelector:@selector(boolValue)] ? [obj boolValue] : value;
    }

    return b;
}

#pragma mark -

+ (id)array:(NSArray *)array objectAtIndex:(NSUInteger)index defaultValue:(id)value {
    if (!array) {
        return value;
    }

    return [array objectAtIndex:index defaultValue:value];
}

+ (NSString *)array:(NSArray *)array stringAtIndex:(NSUInteger)index defaultValue:(NSString *)value {
    if (!array) {
        return value;
    }

    return [array stringAtIndex:index defaultValue:value];
}

+ (NSNumber *)array:(NSArray *)array numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)value {
    if (!array) {
        return value;
    }

    return [array numberAtIndex:index defaultValue:value];
}

+ (NSDictionary *)array:(NSArray *)array dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)value {
    if (!array) {
        return value;
    }

    return [array dictionaryAtIndex:index defaultValue:value];
}

+ (NSArray *)array:(NSArray *)array arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)value {
    if (!array) {
        return value;
    }

    return [array arrayAtIndex:index defaultValue:value];
}

+ (NSData *)array:(NSArray *)array dataAtIndex:(NSUInteger)index defaultValue:(NSData *)value {
    if (!array) {
        return value;
    }

    return [array dataAtIndex:index defaultValue:value];
}

+ (NSDate *)array:(NSArray *)array dateAtIndex:(NSUInteger)index defaultValue:(NSDate *)value {
    if (!array) {
        return value;
    }

    return [array dateAtIndex:index defaultValue:value];
}

+ (float)array:(NSArray *)array floatAtIndex:(NSUInteger)index defaultValue:(float)value {
    if (!array) {
        return value;
    }

    return [array floatAtIndex:index defaultValue:value];
}

+ (double)array:(NSArray *)array doubleAtIndex:(NSUInteger)index defaultValue:(double)value {
    if (!array) {
        return value;
    }

    return [array doubleAtIndex:index defaultValue:value];
}

+ (NSInteger)array:(NSArray *)array integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)value {
    if (!array) {
        return value;
    }

    return [array integerAtIndex:index defaultValue:value];
}

+ (NSUInteger)array:(NSArray *)array unintegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)value {
    if (!array) {
        return value;
    }

    return [array unintegerAtIndex:index defaultValue:value];
}

+ (BOOL)array:(NSArray *)array boolAtIndex:(NSUInteger)index defaultValue:(BOOL)value {
    if (!array) {
        return value;
    }

    return [array boolAtIndex:index defaultValue:value];
}

@end

@implementation NSMutableArray (Safe)

#pragma mark - safe hook -

+ (void)load {
#ifdef DISTRIBUTION
    [objc_getClass("__NSArrayM") swizzleInstanceSelector:@selector(addObject:) withNewSelector:@selector(zd_safeAddObject:)];

    if (@available(iOS 15.0, *)) {
        //在iOS 15 下 会引起内存持续增长，具体原因不明
    } else {
        [objc_getClass("__NSArrayM") swizzleInstanceSelector:@selector(objectAtIndex:) withNewSelector:@selector(zd_safeObjectAtIndex:)];
    }

    [objc_getClass("__NSArrayM") swizzleInstanceSelector:@selector(insertObject:atIndex:) withNewSelector:@selector(zd_safeInsertObject:atIndex:)];
    [objc_getClass("__NSArrayM") swizzleInstanceSelector:@selector(removeObjectAtIndex:) withNewSelector:@selector(zd_safeRemoveObjectAtIndex:)];
#endif
}

- (id)zd_safeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return nil;
    }

    return [self zd_safeObjectAtIndex:index];
}

- (void)zd_safeAddObject:(id)anObject {
    if (!anObject) {
        return;
    }

    [self zd_safeAddObject:anObject];
}

- (void)zd_safeInsertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {
        return;
    }

    [self zd_safeInsertObject:anObject atIndex:index];
}

- (void)zd_safeRemoveObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        return;
    }

    [self zd_safeRemoveObjectAtIndex:index];
}

#pragma mark - other

- (void)removeObjectAtIndexInBoundary:(NSUInteger)index {
    if (index < [self count]) {
        [self removeObjectAtIndex:index];
    }
}

- (void)insertObject:(id)anObject atIndexInBoundary:(NSUInteger)index
{
    if (index <= [self count] && nil != anObject) {
        [self insertObject:anObject atIndex:index];
    }
}

- (void)replaceObjectAtInBoundaryIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index < [self count] && nil != anObject) {
        [self replaceObjectAtIndex:index withObject:anObject];
    }
}

- (void)addObjectSafe:(id)anObject
{
    if (anObject && anObject != [NSNull class]) {
        [self addObject:anObject];
    }
}

@end
