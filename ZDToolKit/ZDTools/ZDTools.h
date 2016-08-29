//
//  ZDTools.h
//  ZDUtility
//
//  Created by 符现超 on 15/11/24.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

///================================================
/// @name 使Array和Dictionary打印出汉字
/// 还有一个XCode插件也可以:https://github.com/dhcdht/DXXcodeConsoleUnicodePlugin
///================================================
@interface ZDTools : NSObject

void zd_dispatch_throttle_on_mainQueue(NSTimeInterval intervalInSeconds, void(^block)());
void zd_dispatch_throttle_on_queue(NSTimeInterval intervalInSeconds, dispatch_queue_t queue, void(^block)());

+ (void)zd_throttleWithTimeinterval:(NSTimeInterval)timeInterval queue:(dispatch_queue_t)queue key:(NSString *)key block:(void(^)())block;

@end
