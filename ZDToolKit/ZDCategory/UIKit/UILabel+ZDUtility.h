//
//  UILabel+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/3/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (ZDUtility)

- (CGSize)zd_contentSize;

/// get content text in every line
- (__kindof NSArray *)zd_linesArrayOfString;

@end

NS_ASSUME_NONNULL_END
