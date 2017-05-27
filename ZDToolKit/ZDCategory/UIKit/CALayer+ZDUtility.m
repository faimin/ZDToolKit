//
//  CALayer+ZDUtility.m
//  Pods
//
//  Created by Zero.D.Saber on 2017/5/27.
//
//

#import "CALayer+ZDUtility.h"

@implementation CALayer (ZDUtility)

- (void)zd_pauseAnimation {
    CFTimeInterval pauseTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0;
    self.timeOffset = pauseTime;
}

- (void)zd_resumeAnimation {
    CFTimeInterval pauseTime = self.timeOffset;
    self.speed = 1.0;
    self.timeOffset = 0.0;
    self.beginTime = 0.0;
    CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
    self.beginTime = timeSincePause;
}

@end
