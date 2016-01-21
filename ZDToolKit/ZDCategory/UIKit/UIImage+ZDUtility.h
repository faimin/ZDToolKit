//
//  UIImage+ZDUtility.h
//  ZDUtility
//
//  Created by 符现超 on 15/12/26.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZDUtility)

- (BOOL)hasAlphaChannel;
- (UIImage *)addAlphaChannle;

/// Same as 'scale to fill' in IB.
- (UIImage *)scaleToFillSize:(CGSize)newSize;
/// Preserves aspect ratio. Same as 'aspect fit' in IB.
- (UIImage *)scaleToFitSize:(CGSize)newSize;
- (UIImage *)resizeToSize:(CGSize)newSize;
- (UIImage *)thumbnailWithSize:(int)imageWidthOrHeight;

- (UIImage *)fixOrientation;

@end
