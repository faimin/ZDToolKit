//
//  UIColor+ZDUtility.h
//  ZDUtility
//
//  Created by 符现超 on 16/1/5.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ZDUtility)

/// 获取UIColor对象的CMYK字符串值。
@property (nonatomic, copy, readonly) NSString *CMYKStringValue;

+ (UIColor *)randomColor;

@end
