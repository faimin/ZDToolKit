//
//  NSObject+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (ZDUtility)

+ (nullable id)zd_cast:(id)objc;

- (nullable id)deepCopy;

@end
NS_ASSUME_NONNULL_END