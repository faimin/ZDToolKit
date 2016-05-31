//
//  NSObject+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDUtility.h"
#import <objc/runtime.h>

@implementation NSObject (ZDUtility)

+ (id)zd_cast:(id)objc
{
    if ([objc isKindOfClass:[self class]]) {
        return objc;
    }
    return nil;
}

- (id)zd_deepCopy_archiver
{
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    @catch (NSException *exception) {
        NSLog(@"deepCopy error: %@", exception);
    }
    return obj;
}

/// http://nathanli.cn/2015/12/14/objective-c-%E5%85%83%E7%BC%96%E7%A8%8B%E5%AE%9E%E8%B7%B5-%E5%88%86%E7%B1%BB%E5%8A%A8%E6%80%81%E5%B1%9E%E6%80%A7/
- (id)zd_deepCopy
{
    Class selfClass = [self class];
    
    unsigned int propertyListCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(selfClass, &propertyListCount);
    
    for (int i = 0; i < propertyListCount; i++) {
        objc_property_t property = propertyList[i];
        
        const char *property_Name = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:property_Name encoding:NSUTF8StringEncoding];
        
        // 检查此属性是否是可读写和动态的
        char *dynamic = property_copyAttributeValue(property, "D");
        char *readonly = property_copyAttributeValue(property, "R");
        if (propertyName && !readonly) {
            id propertyValue = [self valueForKey:propertyName];
        }
        
        
    }
    
    return nil;
}

@end
