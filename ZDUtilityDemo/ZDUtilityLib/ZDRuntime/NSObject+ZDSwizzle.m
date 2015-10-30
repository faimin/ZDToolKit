//
//  NSObject+ZDSwizzle.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/29.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import "NSObject+ZDSwizzle.h"
#import "ZDSwizzle.h"

@implementation NSObject (ZDSwizzle)

+ (BOOL)zd_swizzleMethodWithOrignalSel:(SEL)orignalSel replacementSel:(SEL)replacementSel
{
    return zd_swizzleInstanceMethod(self, orignalSel, replacementSel);
}

+ (BOOL)zd_swizzleClassMethodWithOrignalSel:(SEL)orignalSel replacementSel:(SEL)replacementSel
{
    return zd_swizzleClassMethod(self, orignalSel, replacementSel);
}

+ (IMP) zd_swizzleMethodWithOrignalSel:(SEL)orignalSel replacementIMP:(IMP)replacementIMP
{
    return zd_swizzleMethodIMP(self, orignalSel, replacementIMP);
}

+ (BOOL)zd_swizzleMethodWithOrignalSel:(SEL)orignalSel replacementIMP:(IMP)replacementIMP orignalStoreIMP:(IMP *)orignalStoreIMP
{
    return zd_swizzleMethodAndStoreIMP(self, orignalSel, replacementIMP, orignalStoreIMP);
}


@end
