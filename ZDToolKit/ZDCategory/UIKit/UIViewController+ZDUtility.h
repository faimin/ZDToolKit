//
//  UIViewController+ZDUtility.h
//  ZDUtility
//
//  Created by 符现超 on 16/1/16.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface UIViewController (ZDUtility)<SKStoreProductViewControllerDelegate>

/// 当前控制器是否支持3D Touch
- (BOOL)isSupport3DTouch;

/// 当前控制是不是present来的
- (BOOL)isComefromPresent;

/// 获取当前控制器的导航控制器的右滑返回手势
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGesture;

/// 让当前界面消失
- (void)popOrDismiss;

/// 弹出AppStore中的某一应用界面
- (void)presentModalBuyItemVCWithId:(NSString *)itemId
                           animated:(BOOL)animated;

- (id<UILayoutSupport>)zd_navigationBarTopLayoutGuide;
- (id<UILayoutSupport>)zd_navigationBarBottomLayoutGuide;

@end
