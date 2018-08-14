//
//  NSObject+Runtime.m
//  ZDUtility
//
//  Created by Zero on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDRuntime.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ZDMacro.h"

ZD_AVOID_ALL_LOAD_FLAG_FOR_CATEGORY(NSObject_ZDRuntime)

@implementation NSObject (ZDRuntime)

#pragma mark - Dealloc Blocks

- (void)addDeallocBlock:(dispatch_block_t)block
{
    // don't accept NULL block
    NSParameterAssert(block);
    
    NSMutableArray *deallocBlocks = objc_getAssociatedObject(self, _cmd);
    // add array of dealloc blocks if not existing yet
    if (!deallocBlocks) {
        deallocBlocks = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, _cmd, deallocBlocks, OBJC_ASSOCIATION_RETAIN);
    }
    ZDObjectBlockExecutor *executor = [ZDObjectBlockExecutor blockExecutorWithDeallocBlock:block];
    [deallocBlocks addObject:executor];
}

- (void)zd_deallocBlcok:(ZD_FreeBlock)deallocBlock
{
    if (deallocBlock) {
        @autoreleasepool {
            ZDWeakSelf *blockExecutor = [[ZDWeakSelf alloc] initWithBlock:deallocBlock realTarget:self];
            ///原理: 当self释放时,会先释放它本身的关联对象,所以在这个属性对象的dealloc里执行回调,操作remove观察者等操作
            objc_setAssociatedObject(self, (__bridge const void *)deallocBlock, blockExecutor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
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
    
    // 把swizzle的实现方法添加给originMethod，如果没有实现origin方法，则添加成功，否则添加失败。
    // 如果直接exchange的话，那么会覆盖掉父类的方法。
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
    /// 原因: class方法默认是调用的object_getClass(self),但是KVO方法中重写了原来对象的class方法,如果还调class方法,还是会返回class类,而不是KVO新创建的那个子类(这个类才是此时真实的类),所以为了防止这种情况出现,直接调用底层的object_getClass()方法来返回真正的类.
    Class myClass = object_getClass(self);
    Method originalMethod = class_getClassMethod(myClass, selector);
    Method otherMethod = class_getClassMethod(myClass, otherSelector);
    
    method_exchangeImplementations(originalMethod, otherMethod);
}

#pragma mark - Associate

- (void)zd_setStrongAssociateValue:(id)value forKey:(const void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (id)zd_getStrongAssociatedValueForKey:(const void *)key
{
    return objc_getAssociatedObject(self, key);
}

- (void)zd_setCopyAssociateValue:(id)value forKey:(const void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

- (id)zd_getCopyAssociatedValueForKey:(const void *)key
{
    return objc_getAssociatedObject(self, key);
}

- (void)zd_setUnsafeUnretainedAssociateValue:(id)value forKey:(const void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)zd_getUnsafeUnretainedAssociatedValueForKey:(const void *)key
{
    return objc_getAssociatedObject(self, key);
}

// 此处是利用block捕获外部变量的原理实现的.
// 其实把value作为一个对象的weak属性,然后绑定这个对象也可以实现,当get时拿到这个对象,并获取它那个weak属性即可.
- (void)zd_setWeakAssociateValue:(id)value forKey:(const void *)key
{
#if 1
    __weak id weakValue = value;
    objc_setAssociatedObject(self, key, ^id{
        return weakValue;
    }, OBJC_ASSOCIATION_COPY);
#else
    NSHashTable *table = [NSHashTable weakObjectsHashTable];
    [table addObject:value];
    objc_setAssociatedObject(self, key, table, OBJC_ASSOCIATION_RETAIN);
#endif
}

- (id)zd_getWeakAssociateValueForKey:(const void *)key
{
#if 1
    id(^tempBlock)(void) = objc_getAssociatedObject(self, key);
    if (tempBlock) {
        return tempBlock();
    }
    return nil;
#else
    NSHashTable *table = objc_getAssociatedObject(self, key);
    id value = [table allObjects].firstObject;
    return value;
#endif
}

- (void)zd_removeAssociatedValues
{
	objc_removeAssociatedObjects(self);
}

@end


///======================================================

@implementation ZDObjectBlockExecutor

+ (instancetype)blockExecutorWithDeallocBlock:(dispatch_block_t)block
{
    ZDObjectBlockExecutor *executor = [[ZDObjectBlockExecutor alloc] init];
    executor.deallocBlock = block; // copy
    return executor;
}

- (void)dealloc
{
    if (self.deallocBlock) {
        self.deallocBlock();
        _deallocBlock = nil;
    }
}

@end


//========================================================
#pragma mark - ZDWeakSelf
//========================================================

@implementation ZDWeakSelf

- (instancetype)initWithBlock:(ZD_FreeBlock)deallocBlock realTarget:(id)realTarget
{
    self = [super init];
    if (self) {
        //属性设为readonly,并用指针指向方式,是参照RACDynamicSignal中的写法
        self->_deallocBlock = [deallocBlock copy];
        self->_realTarget = realTarget;
    }
    return self;
}

- (void)dealloc
{
    @autoreleasepool {
        if (nil != self.deallocBlock) {
            self.deallocBlock(self);
            _deallocBlock = nil;
            NSLog(@"成功移除对象");
        }
    }
}

@end


