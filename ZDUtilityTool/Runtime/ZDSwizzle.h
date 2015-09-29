//
//  ZDSwizzle.h
//  ZDUtility
//
//  Created by 符现超 on 15/9/29.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

// exchange instance method
BOOL zd_swizzleInstanceMethod(Class aClass, SEL originalSel, SEL replacementSel);

// exchange class method
BOOL zd_swizzleClassMethod(Class aClass, SEL originalSel, SEL replacementSel);

// exchange method with IMP, and store orignal IMP
BOOL zd_swizzleMethodAndStoreIMP(Class aClass, SEL originalSel, IMP replacementIMP,IMP *orignalStoreIMP);

IMP  zd_swizzleMethodIMP(Class aClass, SEL originalSel, IMP replacementIMP);