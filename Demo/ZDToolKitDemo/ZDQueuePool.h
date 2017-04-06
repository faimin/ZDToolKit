//
//  ZDQueuePool.h
//  DDReaderPlus
//
//  Created by 符现超 on 2017/4/5.
//  Copyright © 2017年 dangdang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZDQueuePool : NSObject

+ (dispatch_queue_t)downloadImageQueue;

@end
