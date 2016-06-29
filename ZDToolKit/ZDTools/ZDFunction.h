//
//  ZDFunction.h
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


//===============================================================

#pragma mark - Gif Image
#pragma mark -
/**
 Loads an animated GIF from file, compatible with UIImageView
 */
UIKIT_EXTERN UIImage *ZDAnimatedGIFFromFile(NSString *path);

/**
 Loads an animated GIF from data, compatible with UIImageView
 */
UIKIT_EXTERN UIImage *ZDAnimatedGIFFromData(NSData *data);


//===============================================================

#pragma mark - Image
#pragma mark -

UIKIT_EXTERN UIImage *TintedImageWithColor(UIColor *tintColor, UIImage *image);

///  制作缩略图
///  @param url       图片本地地址
///  @param imageSize 图片的宽或高
///  @return 生成的缩略图
UIKIT_EXTERN UIImage *ThumbnailImageFromURl(NSURL *url, int imageSize);

///  获取图片格式
///  @param data 图片数据
///  @return 格式字符串
FOUNDATION_EXPORT NSString *TypeForImageData(NSData *data);
FOUNDATION_EXPORT NSString *TypeForData(NSData *data);

///  高斯模糊图片
///  @param image 原始图片
///  @param blur  高斯比例（0->1）
///  @return 高斯图片
UIKIT_EXTERN UIImage *ZDBlurImageWithBlurNumber(UIImage *image, CGFloat blur);

//===============================================================

#pragma mark - UIView
#pragma mark - 
/**
 * lineFrame:     虚线的 frame
 * length:        虚线中短线的宽度
 * spacing:       虚线中短线之间的间距
 * color:         虚线中短线的颜色
 */
UIView *ZDCreateDashedLineWithFrame(CGRect lineFrame, int lineLength, int lineSpacing, UIColor *lineColor);

#pragma mark - String
#pragma mark -
/**
 *  @name 设置文字行间距
 */
FOUNDATION_EXPORT NSMutableAttributedString *SetAttributeString(NSString *string, CGFloat lineSpace, CGFloat fontSize);

/**
 *  @name 指定文字为某种颜色
 */
FOUNDATION_EXPORT NSMutableAttributedString *SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor);
FOUNDATION_EXPORT NSString *URLEncodedString(NSString *sourceText);
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
FOUNDATION_EXPORT BOOL IsEmptyString(NSString *string);
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
BOOL isRetina();
CGFloat Scale();
CGSize ScreenSize();
CGFloat ScreenWidth();
CGFloat ScreenHeight();
BOOL iPhone4s();
BOOL iPhone5s();
BOOL iPhone6();
BOOL iPhone6p();

/// 数组两个值，第一个是本地地址，127.0.0.1也就是localhost，
/// 第二个是路由器DNS分配的公网地址。
FOUNDATION_EXPORT NSArray *IPAddresses();
/// 获取当前的内存使用情况
FOUNDATION_EXPORT double ZD_MemoryUsage(void);

#pragma mark - Function
#pragma mark -
/// 处理精度问题
FOUNDATION_EXPORT double ZD_Round(CGFloat num, NSInteger num_digits);

#pragma mark - Runtime
#pragma mark -
void ZD_PrintObjectMethods();
void ZD_SwizzleClassSelector(Class aClass, SEL originalSelector, SEL newSelector);
void ZD_SwizzleInstanceSelector(Class aClass, SEL originalSelector, SEL newSelector);
IMP  ZD_SwizzleMethodIMP(Class aClass, SEL originalSel, IMP replacementIMP);
BOOL ZD_SwizzleMethodAndStoreIMP(Class aClass, SEL originalSel, IMP replacementIMP, IMP *orignalStoreIMP);





















