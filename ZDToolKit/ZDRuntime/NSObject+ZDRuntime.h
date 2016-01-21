//
//  NSObject+Runtime.h
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//
//  PS: All of methods from DTFoundation: https://github.com/Cocoanetics/DTFoundation


#import <Foundation/Foundation.h>

@interface NSObject (ZDRuntime)

/**
 Adds a block to be executed as soon as the receiver's memory is deallocated
 @param block The block to execute when the receiver is being deallocated
 */
- (void)addDeallocBlock:(void(^)())block;

/**
 Adds a new instance method to a class. All instances of this class will have this method.
 
 The block captures `self` in the calling context. To allow access to the instance from within the block it is passed as parameter to the block.
 @param selectorName The name of the method.
 @param block The block to execute for the instance method, a pointer to the instance is passed as the only parameter.
 @returns `YES` if the operation was successful
 */
+ (BOOL)addInstanceMethodWithSelectorName:(NSString *)selectorName block:(void(^)(id))block;

/**
 Exchanges two method implementations. After the call methods to the first selector will now go to the second one and vice versa.
 @param selector The first method
 @param otherSelector The second method
 */
+ (void)swizzleInstanceMethod:(SEL)selector withMethod:(SEL)otherSelector;


/**
 Exchanges two class method implementations. After the call methods to the first selector will now go to the second one and vice versa.
 @param selector The first method
 @param otherSelector The second method
 */
+ (void)swizzleClassMethod:(SEL)selector withMethod:(SEL)otherSelector;


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
