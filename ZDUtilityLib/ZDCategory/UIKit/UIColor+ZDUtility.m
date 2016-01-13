//
//  UIColor+ZDUtility.m
//  ZDUtility
//
//  Created by 符现超 on 16/1/5.
//  Copyright © 2016年 Fate.D.Saber. All rights reserved.
//

#import "UIColor+ZDUtility.h"

@implementation UIColor (ZDUtility)

/**
 * @name 获取UIColor对象的CMYK字符串值。
 */
- (NSString *)getCMYKStringValue
{
	// Method provided by the Colours class extension
	NSDictionary *cmykDict = [self getCMYKValueByColor:self];

	return [NSString stringWithFormat:@"(%0.2f, %0.2f, %0.2f, %0.2f)",
		   [cmykDict[@"C"] floatValue],
		   [cmykDict[@"M"] floatValue],
		   [cmykDict[@"Y"] floatValue],
		   [cmykDict[@"K"] floatValue]];
}

/**
 *  获取UIColor对象的CMYK值。
 *
 *  @return
 */
- (NSDictionary *)getCMYKValueByColor:(UIColor *)originColor
{
	// Convert RGB to CMY
	NSDictionary *rgb = [self getRGBDictionaryByColor:originColor];
	CGFloat C = 1 - [rgb[@"R"] floatValue];
	CGFloat M = 1 - [rgb[@"G"] floatValue];
	CGFloat Y = 1 - [rgb[@"B"] floatValue];

	// Find K
	CGFloat K = MIN(1, MIN(C, MIN(Y, M)));

	if (K == 1) {
		C = 0;
		M = 0;
		Y = 0;
	}
	else {
		void (^newCMYK)(CGFloat *);
		newCMYK = ^(CGFloat *x) {
			*x = (*x - K) / (1 - K);
		};
		newCMYK(&C);
		newCMYK(&M);
		newCMYK(&Y);
	}

	return @{@"C" : @(C),
			 @"M" : @(M),
			 @"Y" : @(Y),
			 @"K" : @(K)};
}

/**
 *  获取UIColor对象的RGB值。
 *
 *  @return 包含rgb值的字典对象。
 */
- (NSDictionary *)getRGBDictionaryByColor:(UIColor *)originColor
{
	CGFloat r = 0, g = 0, b = 0, a = 0;

	if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
		[originColor getRed:&r green:&g blue:&b alpha:&a];
	}
	else {
		const CGFloat *components = CGColorGetComponents(originColor.CGColor);
		r = components[0];
		g = components[1];
		b = components[2];
		a = components[3];
	}

	return @{@"R" : @(r),
			 @"G" : @(g),
			 @"B" : @(b),
			 @"A" : @(a)
    };
}

@end
