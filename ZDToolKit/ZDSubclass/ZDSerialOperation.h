//
//  ZDSerialOperation.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/5/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZDOnComplteBlock)(BOOL);
typedef void(^ZDOperationBlock)(ZDOnComplteBlock);

@interface ZDSerialOperation : NSOperation

+ (instancetype)operationWithBlock:(ZDOperationBlock)block;

@end

NS_ASSUME_NONNULL_END
