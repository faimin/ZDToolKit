//
//  UIApplication+ZDUtility.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (ZDUtility)

- (__kindof UIResponder *_Nullable)zd_firstResponder;

/// 获取window
- (__kindof UIWindow *_Nullable)zd_window;

@end

NS_ASSUME_NONNULL_END
