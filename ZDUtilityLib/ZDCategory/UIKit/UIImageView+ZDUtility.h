//
//  UIImageView+ZDUtility.h
//  ZDUtility
//
//  Created by 符现超 on 16/1/13.
//  Copyright © 2016年 Fate.D.Bourne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ZDUtility)

- (void)roundedImage:(void (^)(UIImage *image))completion;

@end
