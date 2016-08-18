//
//  NSObject+Runtime.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (ZDRuntime)

static const char ZDRuntimeDeallocBlocks;

#pragma mark - Dealloc Blocks

- (void)addDeallocBlock:(void(^)())block
{
    // don't accept NULL block
    NSParameterAssert(block);
    
    NSMutableArray *deallocBlocks = objc_getAssociatedObject(self, &ZDRuntimeDeallocBlocks);
    
    // add array of dealloc blocks if not existing yet
    if (!deallocBlocks) {
        deallocBlocks = [[NSMutableArray alloc] init];
        
        objc_setAssociatedObject(self, &ZDRuntimeDeallocBlocks, deallocBlocks, OBJC_ASSOCIATION_RETAIN);
    }
    
    ZDObjectBlockExecutor *executor = [ZDObjectBlockExecutor blockExecutorWithDeallocBlock:block];
    
    [deallocBlocks addObject:executor];
}

- (void)zd_deallocBlcok:(void(^)())deallocBlock
{
    if (deallocBlock) {
        ZDWeakSelf *blockExecutor = [[ZDWeakSelf alloc] initWithBlock:deallocBlock];
        ///原理: 当self释放时,它所绑定的属性也自动会释放,所以在这个属性对象的dealloc里执行回调,操作remove观察者等操作
        objc_setAssociatedObject(self, (__bridge const void *)deallocBlock, blockExecutor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


+ (BOOL)zd_addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void(^)(id))block
{
    // don't accept nil name
    NSParameterAssert(selectorName);
    
    // don't accept NULL block
    NSParameterAssert(block);
    
    // See http://stackoverflow.com/questions/6357663/casting-a-block-to-a-void-for-dynamic-class-method-resolution
    
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_7
    void *impBlockForIMP = (void *)objc_unretainedPointer(block);
#else
    id impBlockForIMP = (__bridge id)(__bridge void *)(block);
#endif
    
    IMP myIMP = imp_implementationWithBlock(impBlockForIMP);
    
    SEL selector = NSSelectorFromString(selectorName);
    return class_addMethod(self, selector, myIMP, "v@:");
}

#pragma mark - Method Swizzling

+ (void)zd_swizzleInstanceMethod:(SEL)selector withMethod:(SEL)otherSelector
{
    // my own class is being targetted
    Class myClass = [self class];
    
    // get the methods from the selectors
    Method originalMethod = class_getInstanceMethod(myClass, selector);
    Method otherMethod = class_getInstanceMethod(myClass, otherSelector);
    
    if (class_addMethod(myClass, selector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod))) {
        class_replaceMethod(myClass, otherSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, otherMethod);
    }
}

+ (void)zd_swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector
{
    /// http://nshipster.com/method-swizzling/
    /// 文中指出swizzle一个类方法用 Class class = object_getClass((id)self);
    Class myClass = object_getClass(self);
    Method originalMethod = class_getClassMethod(myClass, selector);
    Method otherMethod = class_getClassMethod(myClass, otherSelector);
    
    method_exchangeImplementations(originalMethod, otherMethod);
}

#pragma mark - Associate

- (void)zd_setStrongAssociateValue:(id)value forKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (id)zd_getStrongAssociatedValueForKey:(void *)key
{
    return objc_getAssociatedObject(self, key);
}

- (void)zd_setCopyAssociateValue:(id)value forKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

- (id)zd_getCopyAssociatedValueForKey:(void *)key
{
    return objc_getAssociatedObject(self, key);
}

// 此处是利用block捕获外部变量的原理实现的.
// 其实把value作为一个对象的weak属性,然后绑定这个对象也可以实现,当get时拿到这个对象,并获取它那个weak属性即可.
- (void)zd_setWeakAssociateValue:(id)value forKey:(void *)key
{
    __weak id weakValue = value;
    objc_setAssociatedObject(self, key, ^{
        return weakValue;
    }, OBJC_ASSOCIATION_COPY);
}

- (id)zd_getWeakAssociateValueForKey:(void *)key
{
    id(^tempBlock)() = objc_getAssociatedObject(self, key);
    if (tempBlock) {
        return tempBlock();
    }
    return nil;
}

- (void)zd_removeAssociatedValues
{
	objc_removeAssociatedObjects(self);
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


//========================================================
#pragma mark - ZDWeakSelf
//========================================================

@implementation ZDWeakSelf

- (instancetype)initWithBlock:(void(^)())deallocBlock
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






