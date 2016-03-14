//
//  UIImageView+ZDUtility.m
//  ZDUtility
//
//  Created by 符现超 on 16/1/13.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UIImageView+ZDUtility.h"
#import "UIImageView+WebCache.h"

#pragma mark - Functions
void AddRoundedRectToPath(CGContextRef context,
                                 CGRect rect,
                                 float ovalWidth,
                                 float ovalHeight)
{
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGFloat fw, fh;
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    //根据圆角路径绘制
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

UIImage *CreateRoundedRectImage(UIImage *image, CGSize size, NSInteger radius)
{
    CGFloat w = size.width;
    CGFloat h = size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    AddRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), image.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    UIImage *img = [UIImage imageWithCGImage:imageMasked];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    return img;
}



@implementation UIImage (CornerRadius)

- (UIImage *)imageWithCornerRadius:(CGFloat)radius
{
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //clip image
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.0f, radius);
    CGContextAddLineToPoint(context, 0.0f, self.size.height - radius);
    CGContextAddArc(context, radius, self.size.height - radius, radius, M_PI, M_PI / 2.0f, 1);
    CGContextAddLineToPoint(context, self.size.width - radius, self.size.height);
    CGContextAddArc(context, self.size.width - radius, self.size.height - radius, radius, M_PI / 2.0f, 0.0f, 1);
    CGContextAddLineToPoint(context, self.size.width, radius);
    CGContextAddArc(context, self.size.width - radius, radius, radius, 0.0f, -M_PI / 2.0f, 1);
    CGContextAddLineToPoint(context, radius, 0.0f);
    CGContextAddArc(context, radius, radius, radius, -M_PI / 2.0f, M_PI, 1);
    CGContextClip(context);
    
    //draw image
    [self drawAtPoint:CGPointZero];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

@end


#pragma mark -

@implementation UIImageView (ZDUtility)

- (void)roundedImageWithCornerRadius:(CGFloat)cornerRadius
                          completion:(void (^)(UIImage *image))completion
{
    UIImage *image = self.image;
    NSAssert(image, @"此方法执行的前提是image必须提前设置好");
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Begin a new image that will be the new image with the rounded corners
        // (here with the size of an UIImageView)
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        
        // Add a clip before drawing anything, in the shape of an rounded rect
        [[UIBezierPath bezierPathWithRoundedRect:rect
                                    cornerRadius:((cornerRadius > 0) ? cornerRadius : (image.size.width/2))] addClip];
        // Draw your image
        [image drawInRect:rect];
        
        // Get the image, here setting the UIImageView image
        UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // Lets forget about that we were drawing
        UIGraphicsEndImageContext();
        dispatch_async( dispatch_get_main_queue(), ^{
            if (completion) {
                completion(roundedImage);
            }
        });
    });
}

- (void)zd_setImageWithURL:(NSString *)urlStr
          placeholderImage:(NSString *)placeHolderStr
              cornerRadius:(CGFloat)radius
{
    if (placeHolderStr == nil) {
        placeHolderStr = @"占位符图片地址";
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    if (radius != 0.0) {
        //这里传CGFLOAT_MIN，就是默认以图片宽度的一半为圆角
        if (radius == CGFLOAT_MIN) {
            radius = CGRectGetWidth(self.frame) / 2.0;
        }
        
        //头像需要手动缓存处理成圆角的图片
        NSString *cacheurlStr = [urlStr stringByAppendingString:@"radiusCache"];
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheurlStr];
        if (cacheImage) {
            [self makeBackgroundColorToSuperView];
            self.image = cacheImage;
        }
        else {
            [self sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:placeHolderStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (!error) {
                    UIImage *radiusImage = [image imageWithCornerRadius:radius];
                    //imageWithCornerRadius(image, radius);
                    //CreateRoundedRectImage(image, self.frame.size, radius);
                    
                    [self makeBackgroundColorToSuperView];
                    self.image = radiusImage;
                    [[SDImageCache sharedImageCache] storeImage:radiusImage forKey:cacheurlStr];
                    //清除原有非圆角图片缓存
                    [[SDImageCache sharedImageCache] removeImageForKey:urlStr];
                }
                else {
                    NSString *errorStr = error.localizedDescription;
                    NSLog(@"\n----> %@", errorStr);
                }
            }];
        }
    }
    else {
        [self sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:placeHolderStr]];
    }
}

#pragma mark - Private Method

- (void)makeBackgroundColorToSuperView
{
    if (self.superview && ![self.backgroundColor isEqual:self.superview.backgroundColor]) {
        self.backgroundColor = self.superview.backgroundColor;
    }
}

@end



