//
//  UIImage+Utility.m
//  ZDUtility
//
//  Created by 符现超 on 15/12/15.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)

- (BOOL)hasAlphaChannel
{
	if (self.CGImage == NULL) {
		return NO;
	}
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(self.CGImage) & kCGBitmapAlphaInfoMask;
	return (alpha == kCGImageAlphaFirst ||
		   alpha == kCGImageAlphaLast ||
		   alpha == kCGImageAlphaPremultipliedFirst ||
		   alpha == kCGImageAlphaPremultipliedLast);
}

/**
 *  如果没有Alpha通道，添加之
 */
- (UIImage *)imageAddAlphaChannle
{
    if ([self hasAlphaChannel]) {
        return self;
    }
    
    CGImageRef imageRef = self.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // The bitsPerComponent and bitmapInfo values are hard-coded to prevent an "unsupported parameter combination" error
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL,
                                                          width,
                                                          height,
                                                          8,
                                                          0,
                                                          CGImageGetColorSpace(imageRef),
                                                          kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    
    // Draw the image into the context and retrieve the new image, which will now have an alpha layer
    CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
    UIImage *imageWithAlpha = [UIImage imageWithCGImage:imageRefWithAlpha];
    
    // Clean up
    CGContextRelease(offscreenContext);
    CGImageRelease(imageRefWithAlpha);
    
    return imageWithAlpha;
}

- (UIImage *)resizeToSize:(CGSize)size
{
    if (size.width <= 0 || size.height <= 0) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
