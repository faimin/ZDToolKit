//
//  ZDQueuePool.m
//  DDReaderPlus
//
//  Created by 符现超 on 2017/4/5.
//  Copyright © 2017年 dangdang. All rights reserved.
//

#import "ZDQueuePool.h"
#import <libkern/OSAtomic.h>

static const int maxQueueCount = 16;
static char * const name = "com.zero.d.saber";

@implementation ZDQueuePool

+ (dispatch_queue_t)downloadImageQueue {
    static int queueCount;
    static dispatch_queue_t queues[maxQueueCount];
    static volatile int32_t counter = 0;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : (queueCount > maxQueueCount ? maxQueueCount : queueCount);
        
        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
            for (uint i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
                queues[i] = dispatch_queue_create(name, attr);
            }
        }
        else {
            for (uint i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create(name, DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
            }
        }
    });
    
    int32_t executeCounter = OSAtomicIncrement32(&counter);
    if (executeCounter < 0) {
        executeCounter = -executeCounter;
    }
    
    return queues[(executeCounter) % queueCount];
}

@end




































