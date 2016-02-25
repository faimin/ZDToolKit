//
//  NSObject+ZDDealloc.m
//  ZDProxy
//
//  Created by 符现超 on 15/12/31.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDDealloc.h"
#import <objc/runtime.h>

//========================================================
#pragma mark - ZDWeakSelf
//========================================================

@interface ZDWeakSelf : NSObject

@property (nonatomic, copy, readonly) void(^deallocBlock)();

- (id)initWithBlock:(void(^)())deallocBlock;

@end

@implementation ZDWeakSelf

- (id)initWithBlock:(void(^)())deallocBlock
{
    self = [super init];
    if (self) {
        //属性设为readonly,并用指针指向方式,是参照RACDynamicSignal中的写法
        self->_deallocBlock = [deallocBlock copy];
    }
    return self;
}

- (void)dealloc
{
    if (nil != self.deallocBlock) {
        self.deallocBlock();
#if DEBUG
        NSLog(@"成功移除对象");
#endif
    }
}

@end

//========================================================
#pragma mark - ZDDealloc
//========================================================

@implementation NSObject (ZDDealloc)

- (void)zd_deallocBlcok:(void(^)())deallocBlock
{
    if (deallocBlock) {
        ZDWeakSelf *blockExecutor = [[ZDWeakSelf alloc] initWithBlock:deallocBlock];
        ///原理: 当self释放时,它所绑定的属性也自动会释放,所以在这个属性对象的dealloc里执行回调,操作remove观察者等操作
        objc_setAssociatedObject(self, (__bridge const void *)deallocBlock, blockExecutor, OBJC_ASSOCIATION_RETAIN);
    }
}

@end









