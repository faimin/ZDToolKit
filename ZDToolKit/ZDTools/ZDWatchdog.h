//
//  ZDWatchdog.h
//  Pods
//
//  Created by Zero on 2016/12/8.
//
//

#import <Foundation/Foundation.h>

@interface ZDWatchdog : NSObject

@property long long timeInterval;

+ (instancetype)alloc __attribute__((unavailable("alloc方法不可用，请用shareInstance")));

+ (instancetype)shareInstance;

- (void)start;

- (void)stop;

@end
