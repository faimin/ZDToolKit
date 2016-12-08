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

+ (instancetype)shareInstance;

- (void)start;

- (void)stop;

@end
