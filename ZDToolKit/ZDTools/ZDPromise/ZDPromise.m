//
//  ZDPromise.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/1/20.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import "ZDPromise.h"

@interface ZDPromise ()
@property (nonatomic, assign) ZDPromiseState state;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSMutableArray *observers; ///< 监听当前promise的状态
@end

static dispatch_queue_t zdPromiseDefaultDispatchQueue;

@implementation ZDPromise

+ (void)initialize {
    if (self == [ZDPromise class]) {
        zdPromiseDefaultDispatchQueue = dispatch_get_main_queue();
    }
}

- (void)dealloc {
    if (_state == ZDPromiseState_Pending) {
        dispatch_group_leave(ZDPromise.zd_dispatchGroup);
    }
}

#pragma mark -

+ (dispatch_group_t)zd_dispatchGroup {
    static dispatch_group_t _zd_dispatchGroup;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zd_dispatchGroup = dispatch_group_create();
    });
    return _zd_dispatchGroup;
}

+ (dispatch_queue_t)defaultDispatchQueue {
    return zdPromiseDefaultDispatchQueue;
}

+ (void)setDefaultDispatchQueue:(dispatch_queue_t)queue {
    NSParameterAssert(queue);
    zdPromiseDefaultDispatchQueue = queue;
}

#pragma mark -

+ (instancetype)pendingPromise {
    return [[self alloc] initPending];
}

- (instancetype)initPending {
    if (self = [super init]) {
        //_queue = dispatch_queue_create("com.zero.promise", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, 0));
        dispatch_group_notify(ZDPromise.zd_dispatchGroup, ZDPromise.defaultDispatchQueue, ^{
            NSLog(@"****** promise结束 ********");
        });
        dispatch_group_enter(ZDPromise.zd_dispatchGroup);
    }
    return self;
}

#pragma mark - Async

+ (instancetype)async:(void(^)(ZDFulfillBlock, ZDRejectBlock))block {
    return [self async:block onQueue:ZDPromise.defaultDispatchQueue];
}

+ (instancetype)async:(void(^)(ZDFulfillBlock fulfill, ZDRejectBlock reject))block onQueue:(dispatch_queue_t)queue {
    ZDPromise *promise = [[self alloc] initPending];
    
    dispatch_group_async(ZDPromise.zd_dispatchGroup, queue, ^{
        block(
              ^(id value){
                  [promise fulfill:value];
              },
              
              ^(NSError *error){
                  [promise reject:error];
              }
        );
    });
    
    return promise;
}

#pragma mark - Then

- (instancetype)then:(ZDThenBlock)thenBlock {
    return [self then:thenBlock onQueue:ZDPromise.defaultDispatchQueue];
}

- (instancetype)then:(ZDThenBlock)thenBlock onQueue:(dispatch_queue_t)queue {
    ZDPromise *newPromise = [self chainOnQueue:queue fulfill:thenBlock reject:nil];
    return newPromise;
}

#pragma mark - Catch

- (instancetype)catch:(ZDRejectBlock)catchBlock {
    return [self catch:catchBlock onQueue:ZDPromise.defaultDispatchQueue];
}

- (instancetype)catch:(ZDRejectBlock)catchBlock onQueue:(dispatch_queue_t)queue {
    ZDPromise *newPromise = [self chainOnQueue:queue fulfill:nil reject:^id(NSError *error) {
        catchBlock(error);
        return error;
    }];
    return newPromise;
}

#pragma mark - Observe

- (instancetype)chainOnQueue:(dispatch_queue_t)queue
                     fulfill:(id(^)(id value))chainedFulfill
                      reject:(id(^)(NSError *error))chainedReject {
    // 创建一个新的promise
    ZDPromise *newPromise = [[ZDPromise alloc] initPending];
    
    void(^finishedBlock)(id) = ^(id value){
        [newPromise fulfill:value];
    };
    
    [self observeOnQueue:queue fulfill:^(id  _Nonnull value) {
        value = chainedFulfill ? chainedFulfill(value) : value;
        finishedBlock(value);
    } reject:^(NSError * _Nonnull error) {
        id value = chainedReject ? chainedReject(error) : error;
        finishedBlock(value);
    }];
    
    return newPromise;
}

- (void)observeOnQueue:(dispatch_queue_t)queue
               fulfill:(ZDFulfillBlock)onFulfill
                reject:(ZDRejectBlock)onReject {
    
    switch (_state) {
        case ZDPromiseState_Pending: {
            if (!_observers) {
                _observers = [[NSMutableArray alloc] init];
            }
            
            // 创建并保存observer
            ZDPromiseObserver observer = ^(ZDPromiseState state, id resolvedValue){
                switch (state) {
                    case ZDPromiseState_Pending:
                        break;
                    case ZDPromiseState_Fulfilled: {
                        onFulfill(resolvedValue);
                    }
                        break;
                    case ZDPromiseState_Rejected: {
                        onReject(resolvedValue);
                    }
                        break;
                    default:
                        break;
                }
            };
            [_observers addObject:observer];
        }
            break;
        case ZDPromiseState_Fulfilled: {
            dispatch_group_async(ZDPromise.zd_dispatchGroup, queue, ^{
                onFulfill(self.value);
            });
        }
            break;
        case ZDPromiseState_Rejected: {
            dispatch_group_async(ZDPromise.zd_dispatchGroup, queue, ^{
                onReject(self.error);
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark - Handle Result

- (void)fulfill:(id)value {
    if ([value isKindOfClass:[NSError class]]) {
        [self reject:(NSError *)value];
    }
    else {
        if (_state == ZDPromiseState_Pending) {
            _state = ZDPromiseState_Fulfilled;
            _value = value;
            for (ZDPromiseObserver observer in _observers) {
                observer(_state, value);
            }
            _observers = nil;
            dispatch_group_leave(ZDPromise.zd_dispatchGroup);
        }
    }
}

- (void)reject:(NSError *)error {
    if (![error isKindOfClass:[NSError class]]) {
        NSCAssert(NO, @"error class type");
    }

    if (_state == ZDPromiseState_Pending) {
        _state = ZDPromiseState_Rejected;
        _error = error;
        for (ZDPromiseObserver observer in _observers) {
            observer(_state, error);
        }
        _observers = nil;
        dispatch_group_leave(ZDPromise.zd_dispatchGroup);
    }
}

@end
