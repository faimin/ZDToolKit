//
//  UITextView+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (ZDUtility)

///限制最大输入字数为maxLength
- (NSUInteger)letterCountWithMaxLength:(NSUInteger)maxLength;

/// 利用KVC替换textView隐藏的label属性
@property (nonatomic, strong) UILabel *zd_placeHolderLabel;

@end
