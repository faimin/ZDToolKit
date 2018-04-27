//
//  ZDPromise.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/1/20.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZDPromise;
typedef ZDPromise* (^PromiseBlock)(id param);

@interface ZDPromise : NSObject

@property (nonatomic, class, readonly) dispatch_group_t zd_dispatchGroup;

@end
