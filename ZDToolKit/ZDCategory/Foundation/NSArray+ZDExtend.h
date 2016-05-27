//
//  NSArray+ZDExtend.h
//  ZDUtility
//
//  Created by 符现超 on 15/11/28.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSArray (ZDExtend)

- (NSArray *)reverse;

- (NSArray *)shuffle;

- (NSArray *)moveObjcToFront:(id)objc;

///去重
- (NSArray *)deduplication;

/// 求和
- (CGFloat)sum;
/// 平均值
- (CGFloat)avg;
/// 最大值
- (CGFloat)max;
/// 最小值
- (CGFloat)min;

@end

@interface NSMutableArray (ZDExtend)

@end