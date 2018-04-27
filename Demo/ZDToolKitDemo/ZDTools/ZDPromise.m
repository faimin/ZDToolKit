//
//  ZDPromise.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/1/20.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import "ZDPromise.h"

@interface ZDPromise ()
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_group_t group;
@end

@implementation ZDPromise

+ (dispatch_group_t)zd_dispatchGroup {
    static dispatch_group_t _zd_dispatchGroup;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zd_dispatchGroup = dispatch_group_create();
    });
    return _zd_dispatchGroup;
}

#pragma mark -

- (instancetype)initPending:(PromiseBlock(^)(id param))block {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.zero.promise", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, 0));
        dispatch_group_enter(ZDPromise.zd_dispatchGroup);
    }
    return self;
}

@end
