//
//  UINavigationController+ZDPop.h
//  UINavigationControllerStudy
//
//  Created by 符现超 on 15/10/25.
//  Copyright © 2015年 Fate.D.Bourne. All rights reserved.
//  refer： http://www.jianshu.com/p/6376149a2c4c

#import <UIKit/UIKit.h>

@protocol UINavigationControllerShouldPop <NSObject>

- (BOOL)navigationControllerShouldPop:(UINavigationController *)navigatonController;
@optional
- (BOOL)navigationControllerShouldStarInteractivePopGestureRecognizer:(UINavigationController *)navigatonController;

@end

@interface UINavigationController (ZDPop)

@end
