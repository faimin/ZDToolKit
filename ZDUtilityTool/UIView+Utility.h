//
//  UIView+Utility.h
//  ZDUtility
//
//  Created by 符现超 on 15/8/4.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Utility)

#pragma mark - Propertys

@property (nonatomic, strong, readonly) UIViewController *viewController;

@property (nonatomic, readonly, strong) UIViewController *topMostController;




#pragma mark - Method

- (void)bk_eachSubview:(void (^)(UIView *subview))block;

@end
