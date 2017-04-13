//
//  NSTimer+ZDUtility.m
//  Pods
//
//  Created by 符现超 on 2017/4/13.
//
//

#import "NSTimer+ZDUtility.h"

@implementation NSTimer (ZDUtility)

+ (NSTimer *)zd_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(executeTimerBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)zd_timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(executeTimerBlock:) userInfo:[block copy] repeats:repeats];
}

+ (void)executeTimerBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void(^timerBlock)(NSTimer *) = (void(^)(NSTimer *))[timer userInfo];
        timerBlock(timer);
    }
}

@end
