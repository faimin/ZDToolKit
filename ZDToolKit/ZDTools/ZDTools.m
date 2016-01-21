//
//  ZDTools.m
//  ZDUtility
//
//  Created by 符现超 on 15/11/24.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import "ZDTools.h"
#import <objc/runtime.h>

@implementation ZDTools

@end

///==================================================================
#pragma mark - Function
///==================================================================

BOOL zdSwizzleExchageInstanceMethod(Class aClass, SEL originalSel, SEL replacementSel)
{
    Method origMethod = class_getInstanceMethod(aClass, originalSel);
    Method replMethod = class_getInstanceMethod(aClass, replacementSel);
    
    if (!origMethod) {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), aClass);
        return NO;
    }
    
    if (!replMethod) {
        NSLog(@"replace method %@ not found for class %@", NSStringFromSelector(replacementSel), aClass);
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


NSString *StringByReplaceUnicode(NSString *unicodeStr)
{
    if (!unicodeStr) {
        return @"";
    }
    
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
	[convertedString replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, convertedString.length)];
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
        zdSwizzleExchageInstanceMethod([self class], @selector(description), @selector(replaceDescription));
        zdSwizzleExchageInstanceMethod([self class], @selector(descriptionWithLocale:), @selector(replaceDescriptionWithLocale:));
        zdSwizzleExchageInstanceMethod([self class], @selector(descriptionWithLocale:indent:), @selector(replaceDescriptionWithLocale:indent:));
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
        zdSwizzleExchageInstanceMethod([self class], @selector(description), @selector(replaceDescription));
        zdSwizzleExchageInstanceMethod([self class], @selector(descriptionWithLocale:), @selector(replaceDescriptionWithLocale:));
        zdSwizzleExchageInstanceMethod([self class], @selector(descriptionWithLocale:indent:), @selector(replaceDescriptionWithLocale:indent:));
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
