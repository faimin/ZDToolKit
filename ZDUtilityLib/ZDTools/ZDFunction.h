//
//  ZDFunction.h
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


//===============================================================

#pragma mark - Gif 图片
#pragma mark -
/**
 Loads an animated GIF from file, compatible with UIImageView
 */
UIImage *ZDAnimatedGIFFromFile(NSString *path);

/**
 Loads an animated GIF from data, compatible with UIImageView
 */
UIImage *ZDAnimatedGIFFromData(NSData *data);


//===============================================================

#pragma mark - 字符串
#pragma mark -
/// 文字行间距
FOUNDATION_EXPORT NSMutableAttributedString* SetAttributeString(NSString *string, CGFloat lineSpace, CGFloat fontSize);

/// 筛选文字、颜色
FOUNDATION_EXPORT NSMutableAttributedString* SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor);

/// 处理字符串
FOUNDATION_EXPORT NSString *URLEncodedString(NSString *sourceText);

/// 计算文字高度、宽度、size
FOUNDATION_EXPORT CGFloat HeightOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth);
FOUNDATION_EXPORT CGFloat WidthOfString(NSString *sourceString, UIFont *font, CGFloat maxHeight);
/**
 *  @brief 计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param width、height 约束宽高度，约束宽度时高度设为0，约束高度时宽度设为0即可
 */
FOUNDATION_EXPORT CGSize SizeOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth, CGFloat maxHeight);

/// 反转字符串
FOUNDATION_EXPORT NSString *ReverseString(NSString *sourceString);


//===============================================================

#pragma mark - Device
#pragma mark -
BOOL iPhone4s(void);
BOOL iPhone5s(void);
BOOL iPhone6(void);
BOOL iPhone6p(void);

#pragma mark - Runtime
#pragma mark -
void PrintObjectMethods(void);
void class_swizzleSelector(Class class, SEL originalSelector, SEL newSelector);
























