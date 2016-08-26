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

- (BOOL)isSupport3DTouch;
- (BOOL)isComefromPresent;  ///< 当前控制是不是present来的
- (void)popOrDismiss;
- (void)presentModalBuyItemVCWithId:(NSString *)itemId
                           animated:(BOOL)animated;

- (id<UILayoutSupport>)zd_navigationBarTopLayoutGuide;
- (id<UILayoutSupport>)zd_navigationBarBottomLayoutGuide;

@end
