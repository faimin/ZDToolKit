//
//  UIImageView+ZDUtility.h
//  ZDUtility
//
//  Created by 符现超 on 16/1/13.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ZDUtility)

- (void)roundedImageWithCornerRadius:(CGFloat)cornerRadius
                          completion:(void (^)(UIImage *image))completion;

/// radius传CGFLOAT_MIN，就是默认以视图宽度的一半为圆角
- (void)zd_setImageWithURL:(NSString *)urlStr
          placeholderImage:(NSString *)placeHolderStr
              cornerRadius:(CGFloat)radius;

@end
