//
//  ZDSwizzle.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/29.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import "ZDSwizzle.h"
#import <objc/runtime.h>

BOOL zd_swizzleInstanceMethod(Class aClass, SEL originalSel, SEL replacementSel)
{
    Method origMethod = class_getInstanceMethod(aClass, originalSel);
    Method replMethod = class_getInstanceMethod(aClass, replacementSel);
    
    if (!origMethod)
    {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), aClass);
        return NO;
    }
    
    if (!replMethod)
    {
        NSLog(@"replace method %@ not found for class %@", NSStringFromSelector(replacementSel), aClass);
        return NO;
    }
    
    if (class_addMethod(aClass, originalSel, method_getImplementation(replMethod), method_getTypeEncoding(replMethod)))
    {
        class_replaceMethod(aClass, replacementSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, replMethod);
    }
    return YES;
}

BOOL zdSwizzleClassMethod(Class aClass, SEL originalSel, SEL replacementSel)
{
    return zd_swizzleInstanceMethod(object_getClass((id)aClass), originalSel, replacementSel);
}

IMP  zd_swizzleMethodIMP(Class aClass, SEL originalSel, IMP replacementIMP)
{
    Method origMethod = class_getInstanceMethod(aClass, originalSel);
    
    if (!origMethod) {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), aClass);
        return NULL;
    }
    
    IMP origIMP = method_getImplementation(origMethod);
    
    if(!class_addMethod(aClass, originalSel, replacementIMP,
                        method_getTypeEncoding(origMethod)))
    {
        method_setImplementation(origMethod, replacementIMP);
    }
    return origIMP;
}

// other way implement
BOOL  zd_swizzleMethodAndStoreIMP(Class aClass, SEL originalSel, IMP replacementIMP,IMP *orignalStoreIMP)
{
    IMP imp = NULL;
    Method method = class_getInstanceMethod(aClass, originalSel);
    
    if (method)
    {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(aClass, originalSel, replacementIMP, type);
        if (!imp)
        {
            imp = method_getImplementation(method);
        }
    }
    else
    {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), aClass);
    }
    
    if (imp && orignalStoreIMP)
    {
        *orignalStoreIMP = imp;
    }
    return (imp != NULL);
}
