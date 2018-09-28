//
//  ZDBlock.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/14.
//

#import <Foundation/Foundation.h>
#if __has_include(<ffi.h>)
#import <ffi.h>
#endif

@interface ZDBlockDescription : NSObject

@end

//---------------------------------------

typedef void * ZDBlockIMP;

/// 获取block的typeCoding
FOUNDATION_EXPORT const char *ZD_BlockSignatureTypes(id block);
/// 获取block的函数指针(这种方式获取的函数指针,当调用执行时,第一参数为block自己,后面才是block的参数类型)
FOUNDATION_EXPORT ZDBlockIMP ZD_BlockInvokeIMP(id block);
/// 获取msg_forward函数指针
FOUNDATION_EXPORT IMP ZD_MsgForwardIMP(const char *methodTypes);
/// 判断当前函数指针是否指向的msg_froward
FOUNDATION_EXPORT BOOL ZD_IsMsgForward(IMP imp);
/// 判断block是否与给定的typeCoding相同
//FOUNDATION_EXPORT BOOL ZD_BlockIsCompatibleWithMethodType(id block, const char *methodType);
/// 简化block方法签名
FOUNDATION_EXPORT NSString *ZD_ReduceBlockSignatureCodingType(NSString *signatureCodingType);
FOUNDATION_EXPORT void ZD_ReduceBlockSignatureTypes(NSString *signature, NSArray<NSString *> **argTypesResult, NSString **returnTypeResult);
/// 打印block 参数
/// @return 返回一个新的block
/// @note IMP的第一个参数是block自己，剩余的参数是参数列表中的参数，不存在selector
FOUNDATION_EXPORT id ZD_HookBlock(id block);
