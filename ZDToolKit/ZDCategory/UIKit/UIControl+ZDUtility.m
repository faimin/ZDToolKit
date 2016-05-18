//
//  UIControl+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UIControl+ZDUtility.h"
#import <objc/runtime.h>

void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}
/*
 http://www.tuicool.com/articles/fMRv6jz
 http://blog.csdn.net/uxyheaven/article/details/48009197
 */
@implementation UIControl (ZDUtility)

+ (void)load
{
    Swizzle(self, @selector(sendAction:to:forEvent:), @selector(zd_sendAction:to:forEvent:));
}

- (void)zd_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    
}

@end
