//
//  ZDRunloopQueue.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2017/12/16.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//
//  https://github.com/Cascable/runloop-queue/blob/master/RunloopQueue/RunloopQueue.swift

#import "ZDRunloopQueue.h"

@interface ZDRunloopQueueThread : NSThread

@end


@interface ZDRunloopQueue ()
@property (nonatomic, strong) ZDRunloopQueueThread *thread;
@end

@implementation ZDRunloopQueue

- (instancetype)initWithName:(NSString *)name {
    if (self = [super init]) {
        
    }
    return self;
}

@end

//------------------------------------------------------------------

@interface ZDRunloopQueueThread ()
@property (nonatomic, assign) CFRunLoopSourceRef runloopSource;
@property (nonatomic, assign) CFRunLoopRef currentRunloop;
@property (nonatomic, copy) void(^whenReadyCallBack)(CFRunLoopRef);
@end

@implementation ZDRunloopQueueThread

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    CFRunLoopSourceContext sourceContext = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    self.runloopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &sourceContext);
}

- (void)startWhenReady:(void(^)(CFRunLoopRef))callback {
    self.whenReadyCallBack = callback;
    [self start];
}

@end


