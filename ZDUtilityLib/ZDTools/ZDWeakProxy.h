//
//  ZDWeakProxy.h
//  ZDProxy
//
//  Created by 符现超 on 16/1/6.
//  Copyright © 2016年 Fate.D.Bourne. All rights reserved.
//  https://github.com/mikeash/MAZeroingWeakRef
//  https://github.com/ibireme/YYKit/blob/master/YYKit%2FUtility%2FYYWeakProxy.h

#import <Foundation/Foundation.h>

@interface ZDWeakProxy : NSProxy

@property (nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;

@end
