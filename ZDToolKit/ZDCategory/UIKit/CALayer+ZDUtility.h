//
//  CALayer+ZDUtility.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/5/27.
//
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (ZDUtility)

/// 暂停动画
- (void)zd_pauseAnimation;

/// 重新开始动画
- (void)zd_resumeAnimation;

@end
