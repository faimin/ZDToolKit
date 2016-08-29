//
//  ZDWeakProxy.h
//  ZDProxy
//
//  Created by 符现超 on 16/1/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//  https://github.com/mikeash/MAZeroingWeakRef
//  https://github.com/ibireme/YYKit/blob/master/YYKit%2FUtility%2FYYWeakProxy.h

#import <Foundation/Foundation.h>

@interface ZDWeakProxy : NSProxy

@property (nonatomic, weak, readonly) id target;

///  利用消息转发,把可能引起循环引用的target传给weakProxy,比如timer的target
///  @param target: the real target of a object
///  @return instance of ZDWeakProxy that is a proxy for the real target
+ (instancetype)proxyWithTarget:(id)target;

@end
