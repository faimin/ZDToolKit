//
//  NSObject+ZDSwizzle.h
//  ZDUtility
//
//  Created by 符现超 on 15/9/29.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//  https://github.com/12207480/TYSwizzleDemo

#import <Foundation/Foundation.h>

@interface NSObject (ZDSwizzle)

// exchange instance method
+ (BOOL)zd_swizzleMethodWithOrignalSel:(SEL)orignalSel replacementSel:(SEL)replacementSel;

// exchange class method
+ (BOOL)zd_swizzleClassMethodWithOrignalSel:(SEL)orignalSel replacementSel:(SEL)replacementSel;

// exchange method with IMP, and store orignal IMP
+ (BOOL)zd_swizzleMethodWithOrignalSel:(SEL)orignalSel replacementIMP:(IMP)replacementIMP orignalStoreIMP:(IMP *)orignalStoreIMP;

+ (IMP) zd_swizzleMethodWithOrignalSel:(SEL)orignalSel replacementIMP:(IMP)replacementIMP;

@end
