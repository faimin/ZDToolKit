//
//  UIControl+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (ZDUtility)
///防止用户多次点击
@property (nonatomic, assign) NSTimeInterval zd_clickIntervalTime;///< 点击的时间间隔

@end
