//
//  NSArray+ZDExtend.h
//  ZDUtility
//
//  Created by 符现超 on 15/11/28.
//  Copyright © 2015年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ZDExtend)

- (NSArray *)reverse;

- (NSArray *)shuffle;

- (NSArray *)moveObjcToFront:(id)objc;

///去重
- (NSArray *)deduplication;

@end

@interface NSMutableArray (ZDExtend)

@end