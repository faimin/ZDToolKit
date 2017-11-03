//
//  ZDTools.m
//  ZDUtility
//
//  Created by Zero on 15/11/24.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import "ZDTools.h"
#import <objc/runtime.h>

///==================================================================
#pragma mark - Implementation of ZDTools
///==================================================================

@implementation ZDTools

+ (NSMutableDictionary *)scheduleSourceDict
{
    static NSMutableDictionary *_sourceDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sourceDict = [[NSMutableDictionary alloc] init];
    });
    return _sourceDict;
}

// https://github.com/cyanzhong/GCDThrottle/blob/master/GCDThrottle/GCDThrottle.m
+ (void)zd_throttleWithTimeinterval:(NSTimeInterval)intervalInSeconds
                              queue:(dispatch_queue_t)queue
                                key:(NSString *)key
                              block:(void(^)())block
{
    NSCParameterAssert(key);
    if (!key || key.length == 0) return;
    
    NSMutableDictionary *scheduleSourceDict = [self scheduleSourceDict];
    dispatch_source_t timer = scheduleSourceDict[key];
    if (timer) {
        dispatch_source_cancel(timer);
    }
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, intervalInSeconds * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(timer, ^{
        block();
        dispatch_source_cancel(timer);
        scheduleSourceDict[key] = nil;
    });
    dispatch_resume(timer);
    scheduleSourceDict[key] = timer;
}

@end

///==================================================================
#pragma mark - Functions
///==================================================================

static BOOL zd_swizzleExchageInstanceMethod(Class aClass, SEL originalSel, SEL replacementSel)
{
    Method origMethod = class_getInstanceMethod(aClass, originalSel);
    Method replMethod = class_getInstanceMethod(aClass, replacementSel);
    if (!origMethod || !replMethod) {
        !origMethod ? NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), aClass) : nil;
        !replMethod ? NSLog(@"replace method %@ not found for class %@", NSStringFromSelector(replacementSel), aClass) : nil;
        return NO;
    }
    
    if (class_addMethod(aClass, originalSel, method_getImplementation(replMethod), method_getTypeEncoding(replMethod))) {
        class_replaceMethod(aClass, replacementSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, replMethod);
    }
    return YES;
}

void zd_dispatch_throttle_on_mainQueue(NSTimeInterval intervalInSeconds, void(^block)())
{
    [ZDTools zd_throttleWithTimeinterval:intervalInSeconds queue:dispatch_get_main_queue() key:[NSThread callStackSymbols][1] block:block];
}

void zd_dispatch_throttle_on_queue(NSTimeInterval intervalInSeconds, dispatch_queue_t queue, void(^block)())
{
    [ZDTools zd_throttleWithTimeinterval:intervalInSeconds queue:queue key:[NSThread callStackSymbols][1] block:block];
}

NS_INLINE NSString *StringByReplaceUnicode(NSString *unicodeStr)
{
    if (!unicodeStr) return @"";
    
#if 0
	NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
	NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
	NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
	NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
	//NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];

	NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];

	return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
#else
	NSMutableString *convertedString = [unicodeStr mutableCopy];
	[convertedString replaceOccurrencesOfString:@"\\U"
                                     withString:@"\\u"
                                        options:0
                                          range:NSMakeRange(0, convertedString.length)];
	CFStringRef transform = CFSTR("Any-Hex/Java");
	CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
	return convertedString;
#endif
}

///==================================================================
#pragma mark - NSArray
///==================================================================

@interface NSArray (Unicode)

@end

@implementation NSArray (Unicode)

+ (void)load
{
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
        zd_swizzleExchageInstanceMethod([self class], @selector(description), @selector(replaceDescription));
        zd_swizzleExchageInstanceMethod([self class], @selector(descriptionWithLocale:), @selector(replaceDescriptionWithLocale:));
        zd_swizzleExchageInstanceMethod([self class], @selector(descriptionWithLocale:indent:), @selector(replaceDescriptionWithLocale:indent:));
	});
}

- (NSString *)replaceDescription
{
	return StringByReplaceUnicode([self replaceDescription]);
}

- (NSString *)replaceDescriptionWithLocale:(nullable id)locale
{
	return StringByReplaceUnicode([self replaceDescriptionWithLocale:locale]);
}

- (NSString *)replaceDescriptionWithLocale:(nullable id)locale indent:(NSUInteger)level
{
    return StringByReplaceUnicode([self replaceDescriptionWithLocale:locale indent:level]);
}

@end

///==================================================================
#pragma mark - NSDictionary
///==================================================================

@interface NSDictionary (Unicode)

@end

@implementation NSDictionary (Unicode)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zd_swizzleExchageInstanceMethod([self class], @selector(description), @selector(replaceDescription));
        zd_swizzleExchageInstanceMethod([self class], @selector(descriptionWithLocale:), @selector(replaceDescriptionWithLocale:));
        zd_swizzleExchageInstanceMethod([self class], @selector(descriptionWithLocale:indent:), @selector(replaceDescriptionWithLocale:indent:));
    });
}

- (NSString *)replaceDescription
{
    return StringByReplaceUnicode([self replaceDescription]);
}

- (NSString *)replaceDescriptionWithLocale:(nullable id)locale
{
    return StringByReplaceUnicode([self replaceDescriptionWithLocale:locale]);
}

- (NSString *)replaceDescriptionWithLocale:(nullable id)locale indent:(NSUInteger)level
{
    return StringByReplaceUnicode([self replaceDescriptionWithLocale:locale indent:level]);
}

@end

///==================================================================
#pragma mark -
///==================================================================

///==================================================================
#pragma mark -
///==================================================================
