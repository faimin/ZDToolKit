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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupData {
    [self hookBlock];
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

NSString *printHookMsg(self, _cmd) {
    NSLog(@"hookBlock");
    return @"hook successed";
}

- (void)hookBlock {
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
    layout->invoke = (void *)printHookMsg;
    
    NSString *result = block(@"Zero.D.Saber", 28);
    NSLog(@"原始block执行结果：---> %@", result);
    
    // 第一个参数是block自己，后面才是block需要的参数
    NSString *originIMPResult = originFunc(block, @"OriginIMP", 100);
    NSLog(@"原始IMP执行结果：====> %@", originIMPResult);
    
    
    NSMutableArray<NSString *> *argsArray = @[].mutableCopy;
    const char *codingType = ZD_BlockTypes(block);
    NSLog(@"********* : %s", codingType);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:codingType];
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
