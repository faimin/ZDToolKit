//
//  NSObject+Runtime.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import "NSObject+ZDRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (ZDRuntime)

static char ZDRuntimeDeallocBlocks;

#pragma mark - Blocks

- (void)addDeallocBlock:(void(^)())block
{
    // don't accept NULL block
    NSParameterAssert(block);
    
    NSMutableArray *deallocBlocks = objc_getAssociatedObject(self, &ZDRuntimeDeallocBlocks);
    
    // add array of dealloc blocks if not existing yet
    if (!deallocBlocks)
    {
        deallocBlocks = [[NSMutableArray alloc] init];
        
        objc_setAssociatedObject(self, &ZDRuntimeDeallocBlocks, deallocBlocks, OBJC_ASSOCIATION_RETAIN);
    }
    
    ZDObjectBlockExecutor *executor = [ZDObjectBlockExecutor blockExecutorWithDeallocBlock:block];
    
    [deallocBlocks addObject:executor];
}

+ (BOOL)addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void(^)(id))block
{
    // don't accept nil name
    NSParameterAssert(selectorName);
    
    // don't accept NULL block
    NSParameterAssert(block);
    
    // See http://stackoverflow.com/questions/6357663/casting-a-block-to-a-void-for-dynamic-class-method-resolution
    
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_7
    void *impBlockForIMP = (void *)objc_unretainedPointer(block);
#else
    id impBlockForIMP = (__bridge id)objc_unretainedPointer(block);
#endif
    
    IMP myIMP = imp_implementationWithBlock(impBlockForIMP);
    
    SEL selector = NSSelectorFromString(selectorName);
    return class_addMethod(self, selector, myIMP, "v@:");
}

#pragma mark - Method Swizzling

+ (void)swizzleInstanceMethod:(SEL)selector withMethod:(SEL)otherSelector
{
    // my own class is being targetted
    Class myClass = [self class];
    
    // get the methods from the selectors
    Method originalMethod = class_getInstanceMethod(myClass, selector);
    Method otherMethod = class_getInstanceMethod(myClass, otherSelector);
    
    if (class_addMethod(myClass, selector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod)))
    {
        class_replaceMethod(myClass, otherSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, otherMethod);
    }
}

+ (void)swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector
{
    Class myClass = [self class];
    Method originalMethod = class_getClassMethod(myClass, selector);
    Method otherMethod = class_getClassMethod(myClass, otherSelector);
    
    method_exchangeImplementations(originalMethod, otherMethod);
}

@end


///======================================================

@implementation ZDObjectBlockExecutor

+ (instancetype)blockExecutorWithDeallocBlock:(void(^)())block
{
    ZDObjectBlockExecutor *executor = [[ZDObjectBlockExecutor alloc] init];
    executor.deallocBlock = block; // copy
    return executor;
}

- (void)dealloc
{
    if (_deallocBlock)
    {
        _deallocBlock();
        _deallocBlock = nil;
    }
}

@end
