//
//  UIImage+ZDUtility.h
//  ZDUtility
//
//  Created by Zero on 15/12/26.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZDUtility)

- (BOOL)zd_hasAlphaChannel;
- (UIImage *)zd_addAlphaChannle;
/// 获取图片上某一点的颜色
- (UIColor *)getPixelColorAtLocation:(CGPoint)point;

///限制最大边的长度为多少,然后进行等比缩放
- (UIImage *)scaleWithLimitLength:(CGFloat)length;
/// Same as 'scale to fill' in IB.
- (UIImage *)scaleToFillSize:(CGSize)newSize;
/// Preserves aspect ratio. Same as 'aspect fit' in IB.
- (UIImage *)scaleToFitSize:(CGSize)newSize;
- (UIImage *)resizeToSize:(CGSize)newSize;
- (UIImage *)thumbnailWithSize:(int)imageWidthOrHeight;

- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets
                    withColor:(UIColor *)color;

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor;
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                              corners:(UIRectCorner)corners
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor
                       borderLineJoin:(CGLineJoin)borderLineJoin;

/// 方向旋转
- (UIImage *)fixOrientation;
- (UIImage *)imageByRotate:(CGFloat)radians
                   fitSize:(BOOL)fitSize;

/// 根据bundle中的文件名读取图片,返回无缓存的图片
+ (UIImage *)imageWithFileName:(NSString *)name;
+ (UIImage *)imageWithColor:(UIColor *)color;

/// 在图片上绘制文字
- (UIImage *)imageWithTitle:(NSString *)title
                   fontSize:(CGFloat)fontSize;

@end
