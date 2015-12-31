//
//  NSObject+ZDDealloc.m
//  ZDProxy
//
//  Created by 符现超 on 15/12/31.
//  Copyright © 2015年 Fate.D.Bourne. All rights reserved.
//

#import "NSObject+ZDDealloc.h"
#import <objc/runtime.h>

@implementation NSObject (ZDDealloc)

- (void)zd_releaseAtDealloc:(void(^)())deallocBlock
{
    if (deallocBlock) {
        ZDWeakSelf *blockExecutor = [[ZDWeakSelf alloc] initWithBlock:deallocBlock];
        ///原理: 当self释放时,它所绑定的属性也自动会释放,所以在这个属性对象的dealloc里执行回调,操作remove观察者等操作
        objc_setAssociatedObject(self, (__bridge const void *)deallocBlock, blockExecutor, OBJC_ASSOCIATION_RETAIN);
    }
}

@end

#pragma mark -
@interface ZDWeakSelf ()

@property (nonatomic, copy, readonly) void(^deallocBlock)();

@end

@implementation ZDWeakSelf

- (id)initWithBlock:(void(^)())deallocBlock
{
    self = [super init];
    if (self) {
        self->_deallocBlock = [deallocBlock copy];
    }
    return self;
}

- (void)dealloc
{
    if (nil != self.deallocBlock) {
        self.deallocBlock();
#if DEBUG
        NSLog(@"移除对象");
#endif
    }
}

@end