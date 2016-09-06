//
//  NSObject+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDUtility.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, PropertyType) {
    PropertyType_Strong,
    PropertyType_Copy,
    PropertyType_Weak,
    PropertyType_Assign,
    PropertyType_UnKnown
};

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

//- (id)deepCopy
//{
//    unsigned int outCount;
//    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
//    
//    for (int i = 0; i < outCount; i++) {
//        objc_property_t property = properties[i];
//        PropertyType propertyType = [self propertyType:property];
////        switch (propertyType) {
////            case PropertyType_Strong: {
////                <#statement#>
////                break;
////            }
////            case PropertyType_Copy: {
////                <#statement#>
////                break;
////            }
////            case PropertyType_Weak: {
////                <#statement#>
////                break;
////            }
////            case PropertyType_Assign: {
////                <#statement#>
////                break;
////            }
////            case PropertyType_UnKnown: {
////                <#statement#>
////                break;
////            }
////        }
//    }
//    
//    return nil;
//}

- (PropertyType)propertyType:(objc_property_t)property
{
    unsigned int attributeCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attributeCount);
    
    NSMutableDictionary *attributes = @{}.mutableCopy;
    for (int i = 0; i < attributeCount; i++) {
        NSString *name = [NSString stringWithCString:attrs[i].name encoding:NSUTF8StringEncoding];
        NSString *value = [NSString stringWithCString:attrs[i].value encoding:NSUTF8StringEncoding];
        [attributes setObject:value forKey:name];
    }
    free(attrs);
    
    PropertyType type = PropertyType_UnKnown;
    if (attributes[@"&"]) {/// < strong
        type = PropertyType_Strong;
    } else if (attributes[@"C"]) {/// < copy
        type = PropertyType_Copy;
    } else if (attributes[@"W"]) {/// < weak
        type = PropertyType_Weak;
    } else {/// < assign
        type = PropertyType_Assign;
    }
    return type;
}

/// 不支持block、struct、union类型
- (NSString *)decodeType:(const char *)cString
{
    if (!strcmp(cString, @encode(id))) return @"id";
    if (!strcmp(cString, @encode(void))) return @"void";
    if (!strcmp(cString, @encode(void *))) return @"void *";
    if (!strcmp(cString, @encode(float))) return @"float";
    if (!strcmp(cString, @encode(int))) return @"int";
    if (!strcmp(cString, @encode(unsigned int))) return @"unsigned int";
    if (!strcmp(cString, @encode(BOOL))) return @"BOOL";
    if (!strcmp(cString, @encode(bool))) return @"bool";
    if (!strcmp(cString, @encode(char *))) return @"char *";
    if (!strcmp(cString, @encode(char))) return @"char";
    if (!strcmp(cString, @encode(unsigned char))) return @"unsigned char";
    if (!strcmp(cString, @encode(double))) return @"double";
    if (!strcmp(cString, @encode(long double))) return @"long double";
    if (!strcmp(cString, @encode(long))) return @"long";
    if (!strcmp(cString, @encode(long long))) return @"long long";
    if (!strcmp(cString, @encode(unsigned long))) return @"unsigned long";
    if (!strcmp(cString, @encode(unsigned long long))) return @"unsigned long long";
    if (!strcmp(cString, @encode(Class))) return @"class";
    if (!strcmp(cString, @encode(SEL))) return @"SEL";
    
    NSString *classStr = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    if ([[classStr substringToIndex:1] isEqualToString:@"@"] && [classStr rangeOfString:@"?"].location == NSNotFound) {
        classStr = [[classStr substringWithRange:NSMakeRange(2, classStr.length - 3)] stringByAppendingString:@"*"];
    } else if ([[classStr substringToIndex:1] isEqualToString:@"^"]) {
        classStr = [NSString stringWithFormat:@"%@ *", [NSString decodeType:[[classStr substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
    }
    return classStr;
}


@end



