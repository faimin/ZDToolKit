//
//  UIControl+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (ZDUtility)

/// 防止用户多次点击,点击的时间间隔
@property (nonatomic, assign) NSTimeInterval zd_clickIntervalTime;

- (void)zd_addBlockForControlEvents:(UIControlEvents)controlEvents
                              block:(void(^)(id sender))block;

@end
