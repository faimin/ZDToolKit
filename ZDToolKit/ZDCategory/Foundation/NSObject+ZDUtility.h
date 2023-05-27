//
//  NSObject+ZDUtility.h
//  ZDToolKitDemo
//
//  Created by Zero on 16/3/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZDUtility)

@property(nonatomic, strong, readonly, nullable) NSString *NSString;
@property (nonatomic, strong, readonly, nullable) NSNumber *NSNumber;
@property (nonatomic, strong, readonly, nullable) NSArray *NSArray;
@property (nonatomic, strong, readonly, nullable) NSMutableArray *NSMutableArray;
@property (nonatomic, strong, readonly, nullable) NSDictionary *NSDictionary;
@property (nonatomic, strong, readonly, nullable) NSMutableDictionary *NSMutableDictionary;

+ (nullable instancetype)zd_cast:(id)objc;

- (NSInteger)zd_integerValue;
- (int)zd_intValue;
- (long long)zd_longLongValue;
- (double)zd_doubleValue;
- (float)zd_floatValue;
- (BOOL)zd_boolValue;

- (nullable instancetype)zd_deepCopy;

- (nullable id)zd_invokeSelectorWithArgs:(SEL)selector, ...;

@end

NS_ASSUME_NONNULL_END
