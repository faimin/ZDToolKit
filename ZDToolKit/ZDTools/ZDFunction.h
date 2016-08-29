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
/// Loads an animated GIF from file, compatible with UIImageView
UIKIT_EXTERN UIImage *ZDAnimatedGIFFromFile(NSString *path);

/// Loads an animated GIF from data, compatible with UIImageView
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
UIKIT_EXTERN UIImage *ZDBlurImageWithBlurPercent(UIImage *image, CGFloat blur);

//===============================================================

#pragma mark - UIView
#pragma mark -
/// @brief 画虚线
/// @param lineFrame:     虚线的 frame
/// @param length:        虚线中短线的宽度
/// @param spacing:       虚线中短线之间的间距
/// @param color:         虚线中短线的颜色
UIKIT_EXTERN UIView *ZDCreateDashedLineWithFrame(CGRect lineFrame, int lineLength, int lineSpacing, UIColor *lineColor);

#pragma mark - String
#pragma mark -
///  设置文字行间距
///  @param string    原始字符串
///  @param lineSpace 行间距
///  @param fontSize  字体大小
///  @return NSMutableAttributedString
FOUNDATION_EXPORT NSMutableAttributedString *SetAttributeString(NSString *string, CGFloat lineSpace, CGFloat fontSize);

///  设置某字符串为特定颜色和大小
///  @param orignString  原始字符串
///  @param filterString 指定的字符串
///  @param filterColor  指定的颜色
///  @param filterFont   指定字体
///  @return NSMutableAttributedString
FOUNDATION_EXPORT NSMutableAttributedString *SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor, __kindof UIFont *filterFont);
///  在文字中添加图片
///  @param image 图片
///  @return NSMutableAttributedString
FOUNDATION_EXPORT NSMutableAttributedString *AddImageToAttributeString(UIImage *image);

FOUNDATION_EXPORT NSString *URLEncodedString(NSString *sourceText);
FOUNDATION_EXPORT CGFloat HeightOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth);
FOUNDATION_EXPORT CGFloat WidthOfString(NSString *sourceString, UIFont *font, CGFloat maxHeight);

///  计算文字的大小
///  @param sourceString 原始字符串
///  @param font         字体(默认为系统字体)
///  @param maxWidth     约束宽高度，约束宽度时高度设为0，约束高度时宽度设为0即可
///  @param maxHeight    约束宽高度，约束宽度时高度设为0，约束高度时宽度设为0即可
///  @return CGSize
FOUNDATION_EXPORT CGSize SizeOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth, CGFloat maxHeight);

/// 反转字符串
FOUNDATION_EXPORT NSString *ReverseString(NSString *sourceString);
FOUNDATION_EXPORT BOOL IsEmptyString(NSString *string);
/// 获取字符串(或汉字)首字母
FOUNDATION_EXPORT NSString *FirstCharacterWithString(NSString *string);
/// 将字符串数组按照元素首字母顺序进行排序分组
FOUNDATION_EXPORT NSDictionary *DictionaryOrderByCharacterWithOriginalArray(NSArray<NSString *> *array);


//===============================================================

#pragma mark - InterfaceOrientation
#pragma mark -
/// 屏幕是横屏还是竖屏
FOUNDATION_EXPORT BOOL isPortrait();     ///< 横屏
FOUNDATION_EXPORT BOOL isLandscape();    ///< 竖屏

#pragma mark - NSBundle
#pragma mark -
/// get list of classes already loaded into memory in specific bundle (or binary)
FOUNDATION_EXPORT NSArray *GetClassNames();

//===============================================================

#pragma mark - Device
#pragma mark -
FOUNDATION_EXPORT BOOL isRetina();
FOUNDATION_EXPORT BOOL isRetina();
FOUNDATION_EXPORT BOOL isPad();
FOUNDATION_EXPORT BOOL isSimulator();
FOUNDATION_EXPORT CGFloat Scale();
FOUNDATION_EXPORT CGFloat SystemVersion();
FOUNDATION_EXPORT CGSize ScreenSize();
FOUNDATION_EXPORT CGFloat ScreenWidth();
FOUNDATION_EXPORT CGFloat ScreenHeight();
FOUNDATION_EXPORT BOOL iPhone4s();
FOUNDATION_EXPORT BOOL iPhone5s();
FOUNDATION_EXPORT BOOL iPhone6();
FOUNDATION_EXPORT BOOL iPhone6p();

/// 数组两个值，第一个是本地地址，127.0.0.1也就是localhost，
/// 第二个是路由器DNS分配的公网地址。
FOUNDATION_EXPORT NSArray *IPAddresses();
/// 获取当前的内存使用情况
FOUNDATION_EXPORT double ZD_MemoryUsage(void);

#pragma mark - Function
#pragma mark -
/// 处理精度问题
FOUNDATION_EXPORT double ZD_Round(CGFloat num, NSInteger num_digits);
/// Int转NSData
FOUNDATION_EXPORT NSData *ZD_ConvertIntToData(int value);

#pragma mark - GCD
#pragma mark -
/// 判断当前是不是主队列
FOUNDATION_EXPORT BOOL ZD_IsMainQueue();

#pragma mark - Runtime
#pragma mark -
void ZD_PrintObjectMethods();
void ZD_SwizzleClassSelector(Class aClass, SEL originalSelector, SEL newSelector);
void ZD_SwizzleInstanceSelector(Class aClass, SEL originalSelector, SEL newSelector);
IMP  ZD_SwizzleMethodIMP(Class aClass, SEL originalSel, IMP replacementIMP);
BOOL ZD_SwizzleMethodAndStoreIMP(Class aClass, SEL originalSel, IMP replacementIMP, IMP *orignalStoreIMP);





















