//
//  NSObject+ZDParams.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 2017/3/14.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "NSObject+ZDParams.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (ZDParams)

- (void)bindingParams:(NSDictionary *)paramsDict {
    if (!class_conformsToProtocol(self.class, @protocol(Params))) return;
    
    [paramsDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id paramValue = [paramsDict valueForKey:key];
        if (!paramValue) {
            NSLog(@"绑定时缺失key-->：%@", key);
        }
        else {
            __unused Class paramClass = [self classFromClassName:@""];
        }
    }];
}

- (Class)classFromClassName:(NSString *)className {
    static NSDictionary *numberClassTypes;
    static NSDictionary *valueClassTypes;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        numberClassTypes = @{
            @"NSInterger" : [NSNull null],
            @"NSUInterger" : [NSNull null],
            @"CGFloat" : [NSNull null],
            @"NSTimeInterval" : [NSNull null],
            @"BOOL" : [NSNull null],
            @"bool" : [NSNull null],
            @"long" : [NSNull null],
            @"unsigned long" : [NSNull null],
            @"long long" : [NSNull null],
            @"unsigned long long" : [NSNull null],
            @"double" : [NSNull null],
            @"float" : [NSNull null],
            @"int" : [NSNull null],
            @"uint" : [NSNull null],
            @"unsigned int" : [NSNull null],
        };

        valueClassTypes = @{
            @"CGRect" : [NSNull null],
            @"CGPoint" : [NSNull null],
            @"CGSize" : [NSNull null],
            @"UIEdgeInsets" : [NSNull null],
            @"UIOffset" : [NSNull null],
            @"CGAffineTransform" : [NSNull null],
            @"CGVector" : [NSNull null]
        };
    });
    
    if ([numberClassTypes valueForKey:className]) {
        return [NSNumber class];
    }
    else if ([valueClassTypes valueForKey:className]) {
        return [NSValue class];
    }
    else {
        Class aClass = NSClassFromString(className);
        if (!aClass) NSLog(@"%@ class not exist", className);
        NSAssert(aClass, @"class not exist");
        return aClass;
    }
}

@end


@interface Scheme : NSObject

@property (nonatomic, assign, getter=isOptional) BOOL optional;
@property (nonatomic, copy) NSString *paramClass;

@end

@implementation Scheme

//

@end









