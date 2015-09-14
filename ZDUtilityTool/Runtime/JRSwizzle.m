// JRSwizzle.m semver:1.0
//   Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/jrswizzle

#import "JRSwizzle.h"

#if TARGET_OS_IPHONE
	#import <objc/runtime.h>
	#import <objc/message.h>
#else
	#import <objc/objc-class.h>
#endif

#define SetNSErrorFor(FUNC, errorVAR, FORMAT,...)	\
	if (errorVAR) {	\
		NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
		*errorVAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
										 code:-1	\
									 userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
	}
#define SetNSError(errorVAR, FORMAT,...) SetNSErrorFor(__func__, errorVAR, FORMAT, ##__VA_ARGS__)

#if OBJC_API_VERSION >= 2
#define GetClass(obj)	object_getClass(obj)
#else
#define GetClass(obj)	(obj ? obj->isa : Nil)
#endif

@implementation NSObject (JRSwizzle)

+ (BOOL)jr_swizzleMethod:(SEL)origSel withMethod:(SEL)altSel error:(NSError**)error {
#if OBJC_API_VERSION >= 2
	Method origMethod = class_getInstanceMethod(self, origSel);
	if (!origMethod) {
#if TARGET_OS_IPHONE
		SetNSError(error, @"original method %@ not found for class %@", NSStringFromSelector(origSel), [self class]);
#else
		SetNSError(error, @"original method %@ not found for class %@", NSStringFromSelector(origSel), [self className]);
#endif
		return NO;
	}
	
	Method altMethod = class_getInstanceMethod(self, altSel);
	if (!altMethod) {
#if TARGET_OS_IPHONE
		SetNSError(error, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel), [self class]);
#else
		SetNSError(error, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel), [self className]);
#endif
		return NO;
	}
	
	class_addMethod(self,
					origSel,
					class_getMethodImplementation(self, origSel),
					method_getTypeEncoding(origMethod));
	class_addMethod(self,
					altSel,
					class_getMethodImplementation(self, altSel),
					method_getTypeEncoding(altMethod));
	
	method_exchangeImplementations(class_getInstanceMethod(self, origSel), class_getInstanceMethod(self, altSel));
	return YES;
#else
	//	Scan for non-inherited methods.
	Method directOriginalMethod = NULL, directAlternateMethod = NULL;
	
	void *iterator = NULL;
	struct objc_method_list *mlist = class_nextMethodList(self, &iterator);
	while (mlist) {
		int method_index = 0;
		for (; method_index < mlist->method_count; method_index++) {
			if (mlist->method_list[method_index].method_name == origSel) {
				assert(!directOriginalMethod);
				directOriginalMethod = &mlist->method_list[method_index];
			}
			if (mlist->method_list[method_index].method_name == altSel) {
				assert(!directAlternateMethod);
				directAlternateMethod = &mlist->method_list[method_index];
			}
		}
		mlist = class_nextMethodList(self, &iterator);
	}
	
	//	If either method is inherited, copy it up to the target class to make it non-inherited.
	if (!directOriginalMethod || !directAlternateMethod) {
		Method inheritedOriginalMethod = NULL, inheritedAlternateMethod = NULL;
		if (!directOriginalMethod) {
			inheritedOriginalMethod = class_getInstanceMethod(self, origSel);
			if (!inheritedOriginalMethod) {
				SetNSError(error, @"original method %@ not found for class %@", NSStringFromSelector(origSel), [self className]);
				return NO;
			}
		}
		if (!directAlternateMethod) {
			inheritedAlternateMethod = class_getInstanceMethod(self, altSel);
			if (!inheritedAlternateMethod) {
				SetNSError(error, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel), [self className]);
				return NO;
			}
		}
		
		int hoisted_method_count = !directOriginalMethod && !directAlternateMethod ? 2 : 1;
		struct objc_method_list *hoisted_method_list = malloc(sizeof(struct objc_method_list) + (sizeof(struct objc_method)*(hoisted_method_count-1)));
        hoisted_method_list->obsolete = NULL;	// soothe valgrind - apparently ObjC runtime accesses this value and it shows as uninitialized in valgrind
		hoisted_method_list->method_count = hoisted_method_count;
		Method hoisted_method = hoisted_method_list->method_list;
		
		if (!directOriginalMethod) {
			bcopy(inheritedOriginalMethod, hoisted_method, sizeof(struct objc_method));
			directOriginalMethod = hoisted_method++;
		}
		if (!directAlternateMethod) {
			bcopy(inheritedAlternateMethod, hoisted_method, sizeof(struct objc_method));
			directAlternateMethod = hoisted_method;
		}
		class_addMethods(self, hoisted_method_list);
	}
	
	//	Swizzle.
	IMP temp = directOriginalMethod->method_imp;
	directOriginalMethod->method_imp = directAlternateMethod->method_imp;
	directAlternateMethod->method_imp = temp;
	
	return YES;
#endif
}

+ (BOOL)jr_swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel error:(NSError**)error {
	return [GetClass((id)self) jr_swizzleMethod:origSel withMethod:altSel error:error];
}

@end
