//
//  CALayer+ZDUtility.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/5/27.
//
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (ZDUtility)

/// 暂停动画
- (void)zd_pauseAnimation;

/// 恢复动画
- (void)zd_resumeAnimation;

@end

NS_ASSUME_NONNULL_END
