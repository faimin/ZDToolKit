//
//  ZDTools.h
//  ZDUtility
//
//  Created by Zero on 15/11/24.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang diagnostic ignored "-Wstrict-prototypes"

NS_ASSUME_NONNULL_BEGIN

@interface ZDTools : NSObject

///  避免方法频繁调用
///  @param timeInterval 时间间隔
///  @param queue        指定的队列
///  @param key          key，用于判断是不是同一个事件
///  @param block        方法回调block
+ (void)zd_throttleWithTimeinterval:(NSTimeInterval)timeInterval
                              queue:(dispatch_queue_t)queue
                                key:(NSString *)key
                              block:(void(^)())block;

@end

#pragma mark - Functions
void zd_dispatch_throttle_on_mainQueue(NSTimeInterval intervalInSeconds, void(^block)());
void zd_dispatch_throttle_on_queue(NSTimeInterval intervalInSeconds, dispatch_queue_t queue, void(^block)());


///================================================
/// @name 使Array和Dictionary打印出汉字
/// 还有一个XCode插件也可以: https://github.com/dhcdht/DXXcodeConsoleUnicodePlugin
///================================================

NS_ASSUME_NONNULL_END
