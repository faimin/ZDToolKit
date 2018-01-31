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

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create("com.zero.promise", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, 0));
        _group = dispatch_group_create();
        
    }
    return self;
}

- (instancetype)create:(PromiseBlock(^)(id))block {
    
    dispatch_group_notify(self.group, self.queue, ^{
        
    });
    
    return nil;
}

@end
