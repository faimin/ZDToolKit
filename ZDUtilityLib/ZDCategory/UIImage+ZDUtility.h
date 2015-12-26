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
- (UIImage *)imageAddAlphaChannle;
- (UIImage *)resizeToSize:(CGSize)size;

@end
