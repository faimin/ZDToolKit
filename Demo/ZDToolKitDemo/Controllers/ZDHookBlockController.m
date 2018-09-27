//
//  ZDHookBlockController.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/6/15.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

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
    
    NSString *result1 = block(@"Zero.D.Saber", 28, @100);
    NSLog(@"执行结果1 = %@", result1);
    
    //NSString *(*originFunc)(id blockSelf, NSString *name, NSUInteger age, NSNumber *) = (__typeof__(originFunc))originIMP;
    //NSString *result2 = originFunc(block, @"Zero.D.Saber", 28, @100);
    //NSLog(@"执行结果2 = %@", result2);
}

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

struct Block_layout {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;                    // NULL
        unsigned long int size;                        // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(const void *src);       // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

/*
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
 */
#pragma mark -

static NSMethodSignature *ZD_SignatureForBlock(id block) {
    struct Block_layout *layout = (__bridge void *)block;
    if ( !(layout->flags & BLOCK_HAS_SIGNATURE) ) return nil;
    
    void *desc = layout->descriptor;
    desc += sizeof(unsigned long int);
    desc += sizeof(unsigned long int);
    
    if (layout->flags & BLOCK_HAS_COPY_DISPOSE) {
        desc += 2 * sizeof(void *);
    }
    
    const char *signatureTypes = *(const char **)desc;
    
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:signatureTypes];
    return signature;
}

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
//    layout->invoke = (void *)printHookMsg;
    layout->invoke = (void *)ZD_MsgForwardIMP(ZD_BlockSignatureTypes(block));
    
    NSString *result = block(@"Zero.D.Saber", 28);
    NSLog(@"原始block执行结果：---> %@", result);
    
    // 第一个参数是block自己，后面才是block需要的参数
    NSString *originIMPResult = originFunc(block, @"OriginIMP", 100);
    NSLog(@"原始IMP执行结果：====> %@", originIMPResult);
    
    
    NSMutableArray<NSString *> *argsArray = @[].mutableCopy;
    const char *codingType = ZD_BlockSignatureTypes(block);
    NSLog(@"********* : %s", codingType);
    
    /*
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:codingType];
    //NSMethodSignature *newSignature = ZD_NewSignature(signature);
    
    NSString *returnType = [[[NSString stringWithUTF8String:signature.methodReturnType] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    [argsArray addObject:returnType];
    NSUInteger argsCount = signature.numberOfArguments;
    for (NSUInteger i = 0; i < argsCount; i++) {
        const char *arg = [signature getArgumentTypeAtIndex:i];
        //NSLog(@"%s", arg);
        NSString *argString = [NSString stringWithUTF8String:arg];
        argString = [[argString stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        [argsArray addObject:argString];
    }
    NSLog(@"返回值类型和参数类型：%@", argsArray);
     */
    
    NSString *returnType = nil;
    ZD_ReduceBlockSignatureTypes([NSString stringWithUTF8String:codingType], &argsArray, &returnType);
    NSLog(@"参数类型：%@, 返回类型：%@", argsArray, returnType);
}

//----------------------------------------------------------------------------
#pragma mark -

static void addOrReplaceMethod(Class aClass, SEL selector, IMP func) {
    Method method = class_getInstanceMethod([NSObject class], selector);
    BOOL addSuccess = class_addMethod(aClass, selector, func, method_getTypeEncoding(method));
    if (!addSuccess) {
        class_replaceMethod(aClass, selector, func, method_getTypeEncoding(method));
    }
}

//---------------------------------------------------------------------------------
static NSMethodSignature *newSignatureForSelector(id self, SEL _cmd, SEL aSelector) {
    NSMethodSignature *signature = ZD_SignatureForBlock(self);
    return signature;
}

void newForwardInvocation(id self, SEL _cmd, NSInvocation *anInvocation) {
    __unused struct Block_layout *layout = (__bridge void *)anInvocation.target;
    __unused SEL selector = anInvocation.selector;
    //xxx
    id arg1;
    NSInteger arg2;
    __autoreleasing id returnValue;
    [anInvocation getArgument:&arg1 atIndex:1];
    [anInvocation getArgument:&arg2 atIndex:2];
    [anInvocation getReturnValue:&returnValue];
    //[anInvocation invoke];
    NSLog(@"===== 参数： %@, %ld, 返回值： %@", arg1, arg2, returnValue);
}
//---------------------------------------------------------------------------------

static void hookNSBlock() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class blockClass = objc_lookUpClass("NSBlock");
        addOrReplaceMethod(blockClass, @selector(methodSignatureForSelector:), (IMP)newSignatureForSelector);
        addOrReplaceMethod(blockClass, @selector(forwardInvocation:), (IMP)newForwardInvocation);
    });
}

- (void)hookBlock {
    hookNSBlock();
}

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
