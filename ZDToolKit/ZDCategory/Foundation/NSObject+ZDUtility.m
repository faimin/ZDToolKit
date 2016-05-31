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
/// AutoCoding: https://github.com/nicklockwood/AutoCoding/blob/master/AutoCoding/AutoCoding.m
- (id)zd_deepCopy
{
    Class selfClass = [self class];
    
    unsigned int propertyListCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(selfClass, &propertyListCount);
    
    id newInstance = [[self class] new];
    
    for (int i = 0; i < propertyListCount; i++) {
        objc_property_t property = propertyList[i];
        
        const char *property_Name = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:property_Name encoding:NSUTF8StringEncoding];
        
        // 检查此属性是否是可读写和动态的
        char *dynamic = property_copyAttributeValue(property, "D");
        char *readonly = property_copyAttributeValue(property, "R");
        if (propertyName && !readonly) {
            id propertyValue = [self valueForKey:propertyName];
            // 检查属性是否是对象
            BOOL flag = [[self class] isObjectClass:[propertyValue class]];
            if (flag) {
                if ([propertyValue conformsToProtocol:@protocol(NSCopying)]) {
                    id copyValue = [propertyValue copy];
                    [newInstance setValue:copyValue forKey:propertyName];
                }
                else {
                    id copyValue = [[[propertyValue class] alloc] init];
                    [copyValue zd_deepCopy];
                    [newInstance setValue:copyValue forKey:propertyName];
                }
            }
            else {
                [newInstance setValue:propertyValue forKey:propertyName];
            }
        }
        free(dynamic);
        free(readonly);
    }
    free(propertyList);
    return newInstance;
}

+ (BOOL)isObjectClass:(Class)clazz
{
    BOOL flag = class_conformsToProtocol(clazz, @protocol(NSObject));
    if (flag) {
        return flag;
    }
    else {
        Class superClass = class_getSuperclass(clazz);
        if (!superClass) {
            return NO;
        }
        else {
            return [NSObject isObjectClass:superClass];
        }
    }
}

@end
