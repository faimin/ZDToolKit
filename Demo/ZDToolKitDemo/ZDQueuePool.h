//
//  ZDQueuePool.h
//  DDReaderPlus
//
//  Created by Zero.D.Saber on 2017/4/5.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZDQueuePool : NSObject

+ (dispatch_queue_t)downloadImageQueue;

@end
