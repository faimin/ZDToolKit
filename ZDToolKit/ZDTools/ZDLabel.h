//
//  ZDLabel.h
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface ZDLabel : UILabel

///  设置文字在label中的边距（上、左、下、右）;
///  @discussion 设置此属性后需要设置[self.label sizeToFit]，
@property (nonatomic, assign) UIEdgeInsets zd_edgeInsets;

///  响应文字的点击
///  @param target 执行事件的目标对象
///  @param action 选择子(暂时还不支持携带参数)
///  @param params 参数数组(暂不支持block类型的参数)
///  @param ranges 要响应事件的文字的所在的range数组
- (void)addTarget:(id)target
           action:(SEL)action
           params:(nullable NSArray *)params
           ranges:(NSArray<NSValue *> *)ranges;
//- (void)setTarget:(id)target action:(SEL)selector forRange:(NSRange)range;

@end
NS_ASSUME_NONNULL_END
