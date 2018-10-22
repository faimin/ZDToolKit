//
//  ZDModel.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/9/30.
//  Copyright © 2018 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZDModel : ZDBaseModel

@property (nonatomic, strong) id myValue;
@property (nonatomic, copy) NSString *myName;
@property (nonatomic, copy) NSString *mySex;
@property (nonatomic, assign) NSUInteger myAge;

@end

NS_ASSUME_NONNULL_END
