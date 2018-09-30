//
//  ZDBaseModel.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/9/30.
//  Copyright © 2018 Zero.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDBaseModel : NSObject

@property (nonatomic, strong) id value;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, assign) NSUInteger age;

@end

NS_ASSUME_NONNULL_END
