//
//  UINavigationController+ZDPop.m
//  UINavigationControllerStudy
//
//  Created by 符现超 on 15/10/25.
//  Copyright © 2015年 Fate.D.Bourne. All rights reserved.
//

#import "UINavigationController+ZDPop.h"
#import <objc/runtime.h>

static NSString *const originDelegate = @"originDelegate";

@implementation UINavigationController (ZDPop)

+ (void)load
{
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		Class class = [self class];

		SEL originalSelector = @selector(navigationBar:shouldPopItem:);
		SEL swizzledSelector = @selector(zd_navigationBar:shouldPopItem:);

		Method originalMethod = class_getInstanceMethod(class, originalSelector);
		Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

		if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
			class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
		}
		else {
			method_exchangeImplementations(originalMethod, swizzledMethod);
		}
	});
}

- (BOOL)zd_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
	UIViewController *vc = self.topViewController;

	if (item != vc.navigationItem) {
		return YES;
	}

	if ([vc conformsToProtocol:@protocol(UINavigationBarDelegate)]) {
		if ([(id < UINavigationControllerShouldPop >)vc navigationControllerShouldPop:self]) {
			return [self zd_navigationBar:navigationBar shouldPopItem:item];
		}
		else {
			return NO;
		}
	}
	else {
		return [self zd_navigationBar:navigationBar shouldPopItem:item];
	}
}

@end
