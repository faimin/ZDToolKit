//
//  ZDSafe.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/29.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//  https://github.com/wuwen1030/XTSafeCollection

#import "ZDSafe.h"
#import <objc/runtime.h>

#if __has_feature(objc_arc)
#error "ZDSafe.m must be compiled with the (-fno-objc-arc) flag"
#endif

#if (ZD_LOG)
  #define ZDLOG(...) ZDLog(__VA_ARGS__)
#else
  #define ZDLOG(...)
#endif

void ZDLog(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);
void ZDLog(NSString *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	NSString *content = [[NSString alloc] initWithFormat:fmt arguments:ap];
	NSLog(@"%@", content);
	va_end(ap);

	NSLog(@" ============= call stack ========== \n%@", [NSThread callStackSymbols]);
}

#pragma mark - Swizzle Function

BOOL zdSwizzleInstanceMethod(Class aClass, SEL originalSel, SEL replacementSel)
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

BOOL zd_swizzleClassMethod(Class aClass, SEL originalSel, SEL replacementSel)
{
	return zdSwizzleInstanceMethod(object_getClass((id)aClass), originalSel, replacementSel);
}

///==================================================================
#pragma mark - NSArray
///==================================================================
@interface NSArray (ZDSafe)

@end

@implementation NSArray (ZDSafe)

- (id)zd_objectAtIndex:(NSUInteger)index
{
	if (index >= self.count) {
		ZDLog(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
			NSStringFromClass([self class]),
			NSStringFromSelector(_cmd),
			(unsigned long)index,
			MAX((unsigned long)self.count - 1, 0));
		return nil;
	}

	return [self zd_objectAtIndex:index];
}

+ (id)zd_arrayWithObjects:(const id _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt
{
	id validObjects[cnt];

    NSUInteger count = 0;
	for (NSUInteger i = 0; i < cnt; i++) {
		if (objects[i]) {
			validObjects[count] = objects[i];
			count++;
		}
		else {
			ZDLOG(@"[%@ %@] NIL object at index {%lu}",
				NSStringFromClass([self class]),
				NSStringFromSelector(_cmd),
				(unsigned long)i);
		}
	}

	return [self zd_arrayWithObjects:objects count:cnt];
}

@end

///==================================================================
#pragma mark - NSMutableArray
///==================================================================
@interface NSMutableArray (ZDSafe)

@end

@implementation NSMutableArray (ZDSafe)

- (id)zd_objectAtIndex:(NSUInteger)index
{
	if (index >= self.count) {
		ZDLog(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
			NSStringFromClass([self class]),
			NSStringFromSelector(_cmd),
			(unsigned long)index,
			MAX((unsigned long)self.count - 1, 0));
		return nil;
	}

	return [self zd_objectAtIndex:index];
}

- (void)zd_addObject:(id)anObject
{
	if (!anObject) {
		ZDLOG(@"[%@ %@], NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}
	[self zd_addObject:anObject];
}

- (void)zd_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	if (index >= self.count) {
		ZDLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
			NSStringFromClass([self class]),
			NSStringFromSelector(_cmd),
			(unsigned long)index,
			MAX((unsigned long)self.count - 1, 0));
		return;
	}

	if (!anObject) {
		ZDLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}

	[self zd_replaceObjectAtIndex:index withObject:anObject];
}

- (void)zd_insertObject:(id)anObject atIndex:(NSUInteger)index
{
	if (index > self.count) {
		ZDLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
			NSStringFromClass([self class]),
			NSStringFromSelector(_cmd),
			(unsigned long)index,
			MAX((unsigned long)self.count - 1, 0));
		return;
	}

	if (!anObject) {
		ZDLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}

	[self zd_insertObject:anObject atIndex:index];
}

@end

///==================================================================
#pragma mark - NSDictionary
///==================================================================
@interface NSDictionary (ZDSafe)

@end

@implementation NSDictionary (ZDSafe)

+ (instancetype)zd_dictionaryWithObjects:(const id[])objects forKeys:(const id <NSCopying>[])keys count:(NSUInteger)cnt
{
	id validObjects[cnt];
	id <NSCopying> validKeys[cnt];

    NSUInteger count = 0;
	for (NSUInteger i = 0; i < cnt; i++) {
		if (objects[i] && keys[i]) {
			validObjects[count] = objects[i];
			validKeys[count] = keys[i];
			count++;
		}
		else {
			ZDLOG(@"[%@ %@] NIL object or key at index{%lu}.",
				NSStringFromClass(self),
				NSStringFromSelector(_cmd),
				(unsigned long)i);
		}
	}

	return [self zd_dictionaryWithObjects:validObjects forKeys:validKeys count:count];
}

@end

///==================================================================
#pragma mark - NSMutableDictionary
///==================================================================
@interface NSMutableDictionary (ZDSafe)

@end

@implementation NSMutableDictionary (ZDSafe)

- (void)zd_setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
	if (!aKey) {
		ZDLOG(@"[%@ %@] NIL key.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}

	if (!anObject) {
		ZDLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}

	[self zd_setObject:anObject forKey:aKey];
}

@end


///==================================================================
#pragma mark - ZDSafe
#pragma mark -
///==================================================================

@implementation ZDSafe

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //NSArray
        zdSwizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:), @selector(zd_objectAtIndex:));
        zd_swizzleClassMethod([NSArray class], @selector(arrayWithObjects:count:), @selector(zd_arrayWithObjects:count:));
        
        //NAMutableArray
        zdSwizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:), @selector(zd_objectAtIndex:));
        zdSwizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(replaceObjectAtIndex:withObject:), @selector(zd_replaceObjectAtIndex:withObject:));
        zdSwizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:), @selector(zd_addObject:));
        zdSwizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(insertObject:atIndex:), @selector(zd_insertObject:atIndex:));
        
        //NSDictionary
        zd_swizzleClassMethod([NSDictionary class], @selector(dictionaryWithObjects:forKeys:count:), @selector(zd_dictionaryWithObjects:forKeys:count:));
        
        //NSMutableDictionary
        zdSwizzleInstanceMethod(NSClassFromString(@"__NSDictionaryM"), @selector(setObject:forKey:), @selector(zd_setObject:forKey:));
    });
}

@end
