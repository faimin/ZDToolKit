//
//  ZDLabel.h
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZDLabel : UILabel

///  设置文字在label中的边距（上、左、下、右）;
///  @discussion 设置此属性后需要设置[self.label sizeToFit]，
@property (nonatomic, assign) UIEdgeInsets zd_edgeInsets;

- (void)setTarget:(id)target action:(SEL)selector forRange:(NSRange)range;

@end
