//
//  UIControl+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//
/*
 http://www.tuicool.com/articles/fMRv6jz
 http://blog.csdn.net/uxyheaven/article/details/48009197
 */

#import "UIControl+ZDUtility.h"
#import <objc/runtime.h>

static void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static NSTimeInterval const defaultIntervalTime = 2.5f;
static BOOL _isIgnoreEvent = NO;

@implementation UIControl (ZDUtility)

+ (void)load
{
    Swizzle(self, @selector(sendAction:to:forEvent:), @selector(zd_sendAction:to:forEvent:));
}

- (void)zd_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    self.clickIntervalTime = (self.clickIntervalTime > 0) ? self.clickIntervalTime : defaultIntervalTime;
    if (_isIgnoreEvent) {
        return;
    }
    else if (self.clickIntervalTime > 0) {
        _isIgnoreEvent = YES;
        //超过时间间隔后恢复
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.clickIntervalTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isIgnoreEvent = NO;
        });
        [self zd_sendAction:action to:target forEvent:event];
    }
    else {
        [self zd_sendAction:action to:target forEvent:event];
    }
}

- (void)setClickIntervalTime:(NSTimeInterval)clickIntervalTime
{
    objc_setAssociatedObject(self, @selector(clickIntervalTime), @(clickIntervalTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)clickIntervalTime
{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

@end
