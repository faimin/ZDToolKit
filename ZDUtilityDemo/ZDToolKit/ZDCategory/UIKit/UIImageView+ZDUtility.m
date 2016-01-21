//
//  UIImageView+ZDUtility.m
//  ZDUtility
//
//  Created by 符现超 on 16/1/13.
//  Copyright © 2016年 Fate.D.Bourne. All rights reserved.
//

#import "UIImageView+ZDUtility.h"

@implementation UIImageView (ZDUtility)

- (void)roundedImageWithCornerRadius:(CGFloat)cornerRadius completion:(void (^)(UIImage *image))completion {
    UIImage *image = self.image;
    if (!image) {
        return;
    }
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Begin a new image that will be the new image with the rounded corners
        // (here with the size of an UIImageView)
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        CGRect rect = CGRectMake(0, 0, image.size.width,image.size.height);
        
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


@end
