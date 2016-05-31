//
//  NSObject+Runtime.h
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//
//  PS: most of methods from DTFoundation: https://github.com/Cocoanetics/DTFoundation


#import <Foundation/Foundation.h>

@interface NSObject (ZDRuntime)

#pragma mark - Dealloc Block
/**
 Adds a block to be executed as soon as the receiver's memory is deallocated
 @param block The block to execute when the receiver is being deallocated
 */
- (void)addDeallocBlock:(void(^)())block;

/// 对象释放时执行block
- (void)zd_deallocBlcok:(void(^)())deallocBlock;

#pragma mark - Swizzeling

/**
 Adds a new instance method to a class. All instances of this class will have this method.
 
 The block captures `self` in the calling context. To allow access to the instance from within the block it is passed as parameter to the block.
 @param selectorName The name of the method.
 @param block The block to execute for the instance method, a pointer to the instance is passed as the only parameter.
 @returns `YES` if the operation was successful
 */
+ (BOOL)zd_addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void(^)(id))block;

/**
 Exchanges two method implementations. After the call methods to the first selector will now go to the second one and vice versa.
 @param selector The first method
 @param otherSelector The second method
 */
+ (void)zd_swizzleInstanceMethod:(SEL)selector withMethod:(SEL)otherSelector;


/**
 Exchanges two class method implementations. After the call methods to the first selector will now go to the second one and vice versa.
 @param selector The first method
 @param otherSelector The second method
 */
+ (void)zd_swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector;


#pragma mark - Associate

- (void)zd_setAssociateValue:(id)value forKey:(void *)key;

- (void)zd_setAssociateWeakValue:(id)value forKey:(void *)key;

- (id)zd_getAssociatedValueForKey:(void *)key;

- (void)zd_removeAssociatedValues;

@end

//==========================================================

/**
 This class is used by [NSObject addDeallocBlock:] to execute blocks on dealloc
 */

@interface ZDObjectBlockExecutor : NSObject

/**
 Convenience method to create a block executor with a deallocation block
 @param block The block to execute when the created receiver is being deallocated
 */
+ (instancetype)blockExecutorWithDeallocBlock:(void(^)())block;

/**
 Block to execute when dealloc of the receiver is called
 */
@property (nonatomic, copy) void (^deallocBlock)();

@end

//========================================================
#pragma mark ZDWeakSelf
//========================================================
@interface ZDWeakSelf : NSObject

@property (nonatomic, copy, readonly) void(^deallocBlock)();

- (instancetype)initWithBlock:(void(^)())deallocBlock;

@end