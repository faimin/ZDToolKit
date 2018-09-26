//
//  ZDBlock.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/14.
//

#import <Foundation/Foundation.h>
//#import <ffi/ffi.h>

@interface ZDBlockDescription : NSObject

@end

typedef void * ZDBlockIMP;

/// 获取block的typeCoding
FOUNDATION_EXPORT const char *ZD_BlockSignatureTypes(id block);
/// 获取block的函数指针(这种方式获取的函数指针,当调用执行时,第一参数为block自己,后面才是block的参数类型)
FOUNDATION_EXPORT ZDBlockIMP ZD_BlockInvokeIMP(id block);
/// 判断block是否与给定的typeCoding相同
//FOUNDATION_EXPORT BOOL ZD_BlockIsCompatibleWithMethodType(id block, const char *methodType);

FOUNDATION_EXPORT void ZD_GenarateTypes(NSString *types, NSArray<NSString *> **argTypesResult, NSString **returnTypeResult);
