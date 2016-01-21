//
//  ZDWeakProxy.m
//  ZDProxy
//
//  Created by 符现超 on 16/1/6.
//  Copyright © 2016年 Fate.D.Bourne. All rights reserved.
//

#import "ZDWeakProxy.h"

@implementation ZDWeakProxy

- (instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target
{
    return [[ZDWeakProxy alloc] initWithTarget:target];
}

#pragma mark - Forward Message

- (id)forwardingTargetForSelector:(SEL)selector
{
    return _target;
}

///注册方法签名
///注册为NSObject的init方法
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

///转发消息
- (void)forwardInvocation:(NSInvocation *)invocation
{
    void *null = NULL;
    [invocation setReturnValue:&null];
}

#pragma mark - NSObject Protocol

- (BOOL)isEqual:(id)object
{
    return [_target isEqual:object];
}

- (NSUInteger)hash
{
    return [_target hash];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [_target respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [_target conformsToProtocol:aProtocol];
}

- (Class)superclass
{
    return [_target superclass];
}

- (Class)class
{
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass
{
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    return [_target isMemberOfClass:aClass];
}

- (BOOL)isProxy
{
    return YES;
}

- (NSString *)description
{
    return [_target description];
}

- (NSString *)debugDescription
{
    return [_target debugDescription];
}

@end
















