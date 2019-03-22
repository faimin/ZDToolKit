//
//  NSNull+ZDUtility.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/3/22.
//

#import "NSNull+ZDUtility.h"
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSNull_ZDUtility)

@implementation NSNull (ZDUtility)

- (char)charValue {
    return 0;
}

- (unsigned char)unsignedCharValue {
    return 0;
}

- (short)shortValue {
    return 0;
}

- (unsigned short)unsignedShortValue {
    return 0;
}

- (int)intValue {
    return 0;
}

- (unsigned int)unsignedIntValue {
    return 0;
}

- (long)longValue {
    return 0;
}

- (unsigned long)unsignedLongValue {
    return 0;
}

- (long long)longLongValue {
    return 0;
}

- (unsigned long long)unsignedLongLongValue {
    return 0;
}

- (float)floatValue {
    return 0.f;
}

- (double)doubleValue {
    return 0.0;
}

- (BOOL)boolValue {
    return NO;
}

- (NSInteger)integerValue {
    return 0;
}

- (NSUInteger)unsignedIntegerValue {
    return 0;
}

#pragma mark - Forward Message

// 其他未识别方法进入消息转发，把消息转发给 nil
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        signature = [NSObject instanceMethodSignatureForSelector:@selector(init)];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
}

@end
