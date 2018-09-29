//
//  ZDHookBlockController.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/6/15.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//


//----------------------------------------------------
enum {
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30)  // compiler
};

// revised new layout

#define BLOCK_DESCRIPTOR_1 1
struct Block_descriptor_1 {
    unsigned long int reserved;
    unsigned long int size;
};

#define BLOCK_DESCRIPTOR_2 1
struct Block_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    void (*copy)(void *dst, const void *src);
    void (*dispose)(const void *);
};

#define BLOCK_DESCRIPTOR_3 1
struct Block_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;
};

struct Block_layout {
    void *isa;
    volatile int flags; // contains ref count
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 *descriptor;
    // imported variables
};

//------------------------------------------------------------

#pragma mark -

#import "ZDHookBlockController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <ZDToolKit/ZDBlockDescription.h>

@interface ZDHookBlockController ()

@end

@implementation ZDHookBlockController

- (void)setupData {
    //[self hookBlock];
    //[self hookBlockIMP];
    [self testHookBlock];
}

- (void)testHookBlock {
    __auto_type block = ^NSString *(NSString *name, NSUInteger age, NSNumber *value) {
        NSString *blockResult = [NSString stringWithFormat:@"%@ + %ld + %@", name, age, value];
        NSLog(@"block执行了，结果： %@", blockResult);
        return blockResult;
    };
    
    block = ZD_HookBlock(block);
    
    //__unused ZDFfiBlockHook *hook = [ZDFfiBlockHook hookBlock:block]; // not tyet implement
    
    NSString *result1 = block(@"Zero.D.Saber", 28, @100);
    NSLog(@"执行结果1 = %@", result1);
     
    //NSString *(*originFunc)(id blockSelf, NSString *name, NSUInteger age, NSNumber *) = (__typeof__(originFunc))originIMP;
    //NSString *result2 = originFunc(block, @"Zero.D.Saber", 28, @100);
    //NSLog(@"执行结果2 = %@", result2);
}

#pragma mark -

NSMethodSignature *ZD_NewSignature(NSMethodSignature *original) {
    if (original.numberOfArguments < 1) {
        return nil;
    }
    
    if (original.numberOfArguments >= 2 && strcmp(@encode(SEL), [original getArgumentTypeAtIndex:1]) == 0) {
        return original;
    }
    
    // initial capacity is num. arguments - 1 (@? -> @) + 1 (:) + 1 (ret type)
    // optimistically assuming most signature components are char[1]
    NSMutableString *signature = [[NSMutableString alloc] initWithCapacity:original.numberOfArguments + 1];
    
    const char *retTypeStr = original.methodReturnType;
    [signature appendFormat:@"%s%s%s", retTypeStr, @encode(id), @encode(SEL)];
    
    for (NSUInteger i = 1; i < original.numberOfArguments; i++) {
        const char *typeStr = [original getArgumentTypeAtIndex:i];
        NSString *type = [[NSString alloc] initWithBytesNoCopy:(void *)typeStr length:strlen(typeStr) encoding:NSUTF8StringEncoding freeWhenDone:NO];
        [signature appendString:type];
    }
    
    return [NSMethodSignature signatureWithObjCTypes:signature.UTF8String];
}

//------------------------------------------------------------------
#pragma mark -

NSString *printHookMsg(id self, SEL _cmd) {
    NSLog(@"hookBlock");
    return @"hook successed";
}

- (void)hookBlockIMP {
    __auto_type block = ^NSString *(NSString *name, NSUInteger age) {
        NSLog(@"block");
        return [NSString stringWithFormat:@"%@ + %ld", name, age];
    };
    
    //IMP imp = imp_implementationWithBlock(block);
    
    struct Block_layout *layout = (__bridge void *)block;
    if (!(layout->flags & BLOCK_HAS_SIGNATURE)) return;
    
    // ref orgin IMP
    IMP originIMP = (void *)(layout->invoke);
    NSString *(*originFunc)(id blockSelf, NSString *name, NSUInteger age) = (void *)originIMP;
    
    // replace origin IMP by new IMP
#if 0
    layout->invoke = (void *)printHookMsg;
#else
    layout->invoke = (void *)ZD_MsgForwardIMP(ZD_BlockSignatureTypes(block));
#endif
    
    NSString *result = block(@"Zero.D.Saber", 28);
    NSLog(@"原始block执行结果：---> %@", result);
    
    // 第一个参数是block自己，后面才是block需要的参数，无selector
    NSString *originIMPResult = originFunc(block, @"OriginIMP", 100);
    NSLog(@"原始IMP执行结果：====> %@", originIMPResult);
    
    NSMutableArray<NSString *> *argsArray = @[].mutableCopy;
    const char *codingType = ZD_BlockSignatureTypes(block);
    NSLog(@"********* : %s", codingType);
    
    NSString *returnType = nil;
    ZD_ReduceBlockSignatureTypes([NSString stringWithUTF8String:codingType], &argsArray, &returnType);
    NSLog(@"参数类型：%@, 返回类型：%@", argsArray, returnType);
}

//----------------------------------------------------------------------------

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
