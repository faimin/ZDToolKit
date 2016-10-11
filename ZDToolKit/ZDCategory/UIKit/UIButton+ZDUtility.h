//
//  UIButton+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/1/29.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//  https://github.com/Phelthas/Demo_ButtonImageTitleEdgeInsets
//  http://www.tuicool.com/articles/byaMbaa

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZDImagePosition) {
    ZDImagePosition_Left = 0,
    ZDImagePosition_Right,
    ZDImagePosition_Top,
    ZDImagePosition_Bottom
};

@interface UIButton (ZDUtility)

/// @brief 垂直排列image和title
/// @param spacing 图片和文字的间隔
- (void)zd_verticalImageAndTitle:(CGFloat)spacing;

- (void)zd_imagePosition:(ZDImagePosition)postion spacing:(CGFloat)spacing;

- (void)zd_setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end
