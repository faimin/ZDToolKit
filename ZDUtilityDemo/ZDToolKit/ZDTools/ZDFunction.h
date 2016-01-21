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

#pragma mark - Gif Image
#pragma mark -

/// Loads an animated GIF from file, compatible with UIImageView
FOUNDATION_EXPORT UIImage *ZDAnimatedGIFFromFile(NSString *path);
/// Loads an animated GIF from data, compatible with UIImageView
FOUNDATION_EXPORT UIImage *ZDAnimatedGIFFromData(NSData *data);

//===============================================================

#pragma mark - Image
#pragma mark -

FOUNDATION_EXPORT UIImage *TintedImageWithColor(UIColor *tintColor, UIImage *image);

///生成缩略图
FOUNDATION_EXPORT UIImage *ThumbnailImageFromURl (NSURL *url, int imageSize);
///判断图片格式
FOUNDATION_EXPORT NSString *TypeForImageData(NSData *data);
FOUNDATION_EXPORT NSString *TypeForData(NSData *data);

//===============================================================

#pragma mark - String
#pragma mark -

///设置文字行间距
FOUNDATION_EXPORT NSMutableAttributedString *SetAttributeString(NSString *string, CGFloat lineSpace, CGFloat fontSize);

///指定文字为某种颜色
FOUNDATION_EXPORT NSMutableAttributedString *SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor);
FOUNDATION_EXPORT NSString *URLEncodedString(NSString *sourceText);
FOUNDATION_EXPORT CGFloat HeightOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth);
FOUNDATION_EXPORT CGFloat WidthOfString(NSString *sourceString, UIFont *font, CGFloat maxHeight);
///  计算文字的大小
///  @param sourceString 原始文字
///  @param font         字体(默认为系统字体)
///  @param maxWidth     约束的最大宽度
///  @param maxHeight    约束的最大高度
///  @return 文字尺寸
FOUNDATION_EXPORT CGSize SizeOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth, CGFloat maxHeight);

/// 反转字符串
UIKIT_EXTERN NSString *ReverseString(NSString *sourceString);
UIKIT_EXTERN BOOL IsEmptyString(NSString *str);

//===============================================================

#pragma mark - InterfaceOrientation
#pragma mark -
///屏幕是横屏还是竖屏
UIKIT_EXTERN BOOL isPortrait();     ///< 横屏
UIKIT_EXTERN BOOL isLandscape();    ///< 竖屏

#pragma mark - NSBundle
#pragma mark -
///get list of classes already loaded into memory in specific bundle (or binary)
FOUNDATION_EXPORT NSArray *GetClassNames();

//===============================================================

#pragma mark - Device
#pragma mark -
extern CGSize ScreenSize();
extern BOOL iPhone4s(void);
extern BOOL iPhone5s(void);
extern BOOL iPhone6(void);
extern BOOL iPhone6p(void);

#pragma mark - Runtime
#pragma mark -
extern void PrintObjectMethods(void);
extern void ZD_SwizzleClassSelector(Class aClass, SEL originalSelector, SEL newSelector);
extern void ZD_SwizzleInstanceSelector(Class aClass, SEL originalSelector, SEL newSelector);
extern IMP  ZD_SwizzleMethodIMP(Class aClass, SEL originalSel, IMP replacementIMP);
extern BOOL ZD_SwizzleMethodAndStoreIMP(Class aClass, SEL originalSel, IMP replacementIMP, IMP *orignalStoreIMP);





















