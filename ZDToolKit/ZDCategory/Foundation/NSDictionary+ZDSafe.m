//
//  NSDictionary+ZDSafe.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2023/4/17.
//

#import "NSDictionary+ZDSafe.h"

@implementation NSDictionary (ZDSafe)

+ (nullable id)dictionary:(NSDictionary *)dict objectForKey:(NSString *)aKey defaultValue:(nullable id)value
{
    if (!dict) {
        return value;
    }
    return [dict objectForKey:aKey defaultValue:value];
}

+ (nullable NSString *)dictionary:(NSDictionary *)dict stringForKey:(NSString *)aKey defaultValue:(nullable NSString *)value
{
    if (!dict) {
        return value;
    }
    return [dict stringForKey:aKey defaultValue:value];
}

+ (nullable NSArray *)dictionary:(NSDictionary *)dict arrayForKey:(NSString *)aKey defaultValue:(nullable NSArray *)value
{
    if (!dict) {
        return value;
    }
    return [dict arrayForKey:aKey defaultValue:value];
}

+ (nullable NSDictionary *)dictionary:(NSDictionary *)dict dictionaryForKey:(NSString *)aKey defaultValue:(nullable NSDictionary *)value
{
    if (!dict) {
        return value;
    }
    return [dict dictionaryForKey:aKey defaultValue:value];
}

+ (nullable NSData *)dictionary:(NSDictionary *)dict dataForKey:(NSString *)aKey defaultValue:(nullable NSData *)value
{
    if (!dict) {
        return value;
    }
    return [dict dataForKey:aKey defaultValue:value];
}

+ (nullable NSDate *)dictionary:(NSDictionary *)dict dateForKey:(NSString *)aKey defaultValue:(nullable NSDate *)value
{
    if (!dict) {
        return value;
    }
    return [dict dateForKey:aKey defaultValue:value];
}

+ (nullable NSNumber *)dictionary:(NSDictionary *)dict numberForKey:(NSString *)aKey defaultValue:(nullable NSNumber *)value
{
    if (!dict) {
        return value;
    }
    return [dict numberForKey:aKey defaultValue:value];
}

+ (NSUInteger)dictionary:(NSDictionary *)dict unsignedIntegerForKey:(NSString *)aKey defaultValue:(NSUInteger)value
{
    if (!dict) {
        return value;
    }
    return [dict unsignedIntegerForKey:aKey defaultValue:value];
}

+ (NSInteger)dictionary:(NSDictionary *)dict integerForKey:(NSString *)aKey defaultValue:(NSInteger)value
{
    if (!dict) {
        return value;
    }
    return [dict integerForKey:aKey defaultValue:value];
}

+ (float)dictionary:(NSDictionary *)dict floatForKey:(NSString *)aKey defaultValue:(float)value
{
    if (!dict) {
        return value;
    }
    return [dict floatForKey:aKey defaultValue:value];
}

+ (double)dictionary:(NSDictionary *)dict doubleForKey:(NSString *)aKey defaultValue:(double)value
{
    if (!dict) {
        return value;
    }
    return [dict doubleForKey:aKey defaultValue:value];
}

+ (long long)dictionary:(NSDictionary *)dict longLongValueForKey:(NSString *)aKey defaultValue:(long long)value
{
    if (!dict) {
        return value;
    }
    return [dict longLongValueForKey:aKey defaultValue:value];
}

+ (BOOL)dictionary:(NSDictionary *)dict boolForKey:(NSString *)aKey defaultValue:(BOOL)value
{
    if (!dict) {
        return value;
    }
    return [dict boolForKey:aKey defaultValue:value];
}

+ (int)dictionary:(NSDictionary *)dict intForKey:(NSString *)aKey defaultValue:(int)value
{
    if (!dict) {
        return value;
    }
    return [dict intForKey:aKey defaultValue:value];
}


@end
