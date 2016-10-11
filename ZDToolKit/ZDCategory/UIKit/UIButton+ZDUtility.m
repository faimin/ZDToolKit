//
//  UIButton+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/1/29.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UIButton+ZDUtility.h"

@implementation UIButton (ZDUtility)

- (void)zd_verticalImageAndTitle:(CGFloat)spacing {
    self.titleLabel.backgroundColor = [UIColor greenColor];
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize textSize = CGSizeZero;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([self respondsToSelector:@selector(sizeWithAttributes:)]) {
        textSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : self.titleLabel.font}];
    } else {
        textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    }
#pragma clang diagnostic pop
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
}

- (void)zd_imagePosition:(ZDImagePosition)postion spacing:(CGFloat)spacing {
    [self setTitle:self.currentTitle forState:UIControlStateNormal];
    [self setImage:self.currentImage forState:UIControlStateNormal];
    
    CGFloat imageWidth = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CGFloat labelWidth = [self.titleLabel.text sizeWithFont:self.titleLabel.font].width;
    CGFloat labelHeight = [self.titleLabel.text sizeWithFont:self.titleLabel.font].height;
#pragma clang diagnostic pop
    
    CGFloat imageOffsetX = (imageWidth + labelWidth) / 2.0f - imageWidth / 2.0f;//image中心移动的x距离
    CGFloat imageOffsetY = imageHeight / 2.0f + spacing / 2.0f;//image中心移动的y距离
    CGFloat labelOffsetX = (imageWidth + labelWidth / 2.0f) - (imageWidth + labelWidth) / 2.0f;//label中心移动的x距离
    CGFloat labelOffsetY = labelHeight / 2.0f + spacing / 2.0f;//label中心移动的y距离
    
    CGFloat tempWidth = MAX(labelWidth, imageWidth);
    CGFloat changedWidth = labelWidth + imageWidth - tempWidth;
    CGFloat tempHeight = MAX(labelHeight, imageHeight);
    CGFloat changedHeight = labelHeight + imageHeight + spacing - tempHeight;
    
    switch (postion) {
        case ZDImagePosition_Left:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing/2.0f, 0, spacing/2.0f);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing/2.0f, 0, -spacing/2.0f);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, spacing/2.0f, 0, spacing/2.0f);
            break;
            
        case ZDImagePosition_Right:
            self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + spacing/2.0f, 0, -(labelWidth + spacing/2.0f));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + spacing/2.0f), 0, imageWidth + spacing/2.0f);
            self.contentEdgeInsets = UIEdgeInsetsMake(0, spacing/2.0f, 0, spacing/2.0f);
            break;
            
        case ZDImagePosition_Top:
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY, labelOffsetX);
            self.contentEdgeInsets = UIEdgeInsetsMake(imageOffsetY, -changedWidth/2.0f, changedHeight-imageOffsetY, -changedWidth/2.0f);
            break;
            
        case ZDImagePosition_Bottom:
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -labelOffsetX, labelOffsetY, labelOffsetX);
            self.contentEdgeInsets = UIEdgeInsetsMake(changedHeight-imageOffsetY, -changedWidth/2.0f, imageOffsetY, -changedWidth/2.0f);
            break;
            
        default:
            break;
    }
}

- (void)zd_setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[self zd_imageWithColor:backgroundColor] forState:state];
}

- (UIImage *)zd_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
