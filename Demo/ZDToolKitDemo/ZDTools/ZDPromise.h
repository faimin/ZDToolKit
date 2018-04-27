//
//  ZDPromise.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/1/20.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZDPromise;
typedef NS_ENUM(NSUInteger, ZDPromiseState) {
    ZDPromiseState_Pending = 0,
    ZDPromiseState_Fulfilled,
    ZDPromiseState_Rejected,
};

typedef void(^ZDFulfillBlock)(id value);
typedef void(^ZDRejectBlock)(NSError *error);
typedef id _Nullable (^ZDThenBlock)(id value);
typedef void(^ZDPromiseObserver)(ZDPromiseState state, id resolve);

//***************************************************************

@interface ZDPromise : NSObject

@property (nonatomic, class, readonly) dispatch_group_t zd_dispatchGroup;
@property (atomic, class) dispatch_queue_t defaultDispatchQueue;

+ (instancetype)async:(void(^)(ZDFulfillBlock fulfill, ZDRejectBlock reject))block;
- (instancetype)then:(ZDThenBlock)thenBlock;
- (instancetype)catch:(ZDRejectBlock)catchBlock;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

