//
//  ZDWeakProxy.m
//  ZDProxy
//
//  Created by Zero on 16/1/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDProxy.h"

@implementation ZDWeakProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[ZDWeakProxy alloc] initWithTarget:target];
}

#pragma mark - Forward Message

- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

/// 注册方法签名
/// 注册为NSObject的init方法
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

///转发消息
- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

#pragma mark - NSObject Protocol

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

@end


#pragma mark -

@interface ZDMutiDelegatesProxy ()

@property (nonatomic, strong) NSPointerArray *weakTargets;

@end

@implementation ZDMutiDelegatesProxy

//MARK: Public Mehtod
- (instancetype)initWithDelegates:(NSArray *)aDelegates {
    NSParameterAssert(aDelegates);
    self.delegateTargets = aDelegates;
    return self;
}

- (void)addDelegate:(id)aDelegate {
    NSParameterAssert(aDelegate);
    [self.weakTargets addPointer:(void *)aDelegate];
    _delegateTargets = self.weakTargets.allObjects;
}

- (void)removeDelegate:(id)aDelegate {
    NSParameterAssert(aDelegate);
    NSUInteger index = 0;
    for (id target in self.weakTargets) {
        if (target == aDelegate) {
            [self.weakTargets removePointerAtIndex:index];
        }
        index++;
    }
    _delegateTargets = self.weakTargets.allObjects;
}

//MARK: Forward Message
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) return YES;
    
    for (id target in self.weakTargets) {
        return [target respondsToSelector:aSelector];
    }
    
    return NO;
}

/// 方法签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *signature = [super methodSignatureForSelector:sel];
    if (!signature) {
        for (id target in self.weakTargets) {
            signature = [target methodSignatureForSelector:sel];
            if (signature) {
                break;
            }
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    for (id target in self.weakTargets) {
        if ([target respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:target];
        }
    }
}

//MARK: Property
- (void)setDelegateTargets:(NSArray *)delegateTargets {
    self.weakTargets = [NSPointerArray weakObjectsPointerArray];
    for (id target in delegateTargets) {
        [self.weakTargets addPointer:(__bridge void *)(target)];
    }
}

//MARK: Private Method
- (NSString *)debugDescription {
    NSString *allTargetsDebugDescription = @"";
    for (id target in self.weakTargets) {
        allTargetsDebugDescription = [NSString stringWithFormat:@"%@;\n%@", allTargetsDebugDescription, [target debugDescription]];
    }
    return allTargetsDebugDescription;
}

@end












