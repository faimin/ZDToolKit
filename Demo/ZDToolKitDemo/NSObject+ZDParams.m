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
        [self setValue:obj forKey:obj];
    }];
}

@end
