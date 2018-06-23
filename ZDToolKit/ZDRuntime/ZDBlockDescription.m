//
//  ZDBlock.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/14.
//

#import "ZDBlockDescription.h"

@implementation ZDBlockDescription

@end

#pragma mark - Block Helpers

// https://github.com/rabovik/RSSwizzle
#if !defined(NS_BLOCK_ASSERTIONS)

// See http://clang.llvm.org/docs/Block-ABI-Apple.html#high-level
struct ZDBlockLiteral {
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

typedef NS_OPTIONS(NSUInteger, ZDBlockDescriptionFlags) {
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_HAS_STRET =         (1 << 29), // compiler: IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30), // compiler
};

/// 不能直接通过blockRef->descriptor->signature获取签名，因为不同场景下的block结构有差别:
/// 比如当block内部引用了外面的局部变量，并且这个局部变量是OC对象，
/// 或者是`__block`关键词包装的变量，block的结构里面有copy和dispose函数，因为这两种变量都是属于内存管理的范畴的；
/// 其他场景下的block就未必有copy和dispose函数。
/// 所以这里是通过flag判断是否有签名，以及是否有copy和dispose函数，然后通过地址偏移找到signature的。
const char *ZD_BlockSignatureTypes(id block) {
    if (!block) return NULL;
    
    struct ZDBlockLiteral *blockRef = (__bridge struct ZDBlockLiteral *)block;
    
    // unsigned long int size = blockRef->descriptor->size;
    ZDBlockDescriptionFlags flags = blockRef->flags;
    
    if ( !(flags & BLOCK_HAS_SIGNATURE) ) return NULL;
    
    void *signatureLocation = blockRef->descriptor;
    signatureLocation += sizeof(unsigned long int);
    signatureLocation += sizeof(unsigned long int);
    
    if (flags & BLOCK_HAS_COPY_DISPOSE) {
        signatureLocation += sizeof(void(*)(void *dst, void *src));
        signatureLocation += sizeof(void(*)(void *src));
    }
    
    const char *signature = (*(const char **)signatureLocation);
    return signature;
}

void *ZD_BlockInvokeIMP(id block) {
    if (!block) return NULL;
    
    struct ZDBlockLiteral *blockRef = (__bridge struct ZDBlockLiteral *)block;
    return blockRef->invoke;
}

BOOL ZD_BlockIsCompatibleWithMethodType(id block, const char *methodType) {
    // 1. blockSignature
    const char *blockType = ZD_BlockSignatureTypes(block);
    
    NSMethodSignature *blockSignature;
    
    if (strncmp(blockType, (const char *)"@\"", 2) == 0) {
        // Block return type includes class name for id types
        // while methodType does not include.
        // Stripping out return class name.
        char *quotePtr = strchr(blockType + 2, '"');
        if (NULL != quotePtr) {
            ++quotePtr;
            char filteredType[strlen(quotePtr) + 2];
            memset(filteredType, 0, sizeof(filteredType));
            *filteredType = '@';
            strncpy(filteredType + 1, quotePtr, sizeof(filteredType) - 2);
            
            blockSignature = [NSMethodSignature signatureWithObjCTypes:filteredType];
        } else {
            return NO;
        }
    } else {
        blockSignature = [NSMethodSignature signatureWithObjCTypes:blockType];
    }
    
    // 2. methodSignature
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:methodType];
    
    if (!blockSignature || !methodSignature) {
        return NO;
    }
    
    if (blockSignature.numberOfArguments != methodSignature.numberOfArguments) {
        return NO;
    }
    
    if (strcmp(blockSignature.methodReturnType, methodSignature.methodReturnType) != 0) {
        return NO;
    }
    
    // 3. compare
    for (int i = 0; i < methodSignature.numberOfArguments; ++i) {
        if (i == 0) {
            // self in method, block in block
            if (strcmp([methodSignature getArgumentTypeAtIndex:i], "@") != 0) {
                return NO;
            }
            if (strcmp([blockSignature getArgumentTypeAtIndex:i], "@?") != 0) {
                return NO;
            }
        } else if (i == 1) {
            // SEL in method, self in block
            if (strcmp([methodSignature getArgumentTypeAtIndex:i], ":") != 0) {
                return NO;
            }
            if (strncmp([blockSignature getArgumentTypeAtIndex:i], "@", 1) != 0) {
                return NO;
            }
        } else {
            const char *blockSignatureArg = [blockSignature getArgumentTypeAtIndex:i];
            
            if (strncmp(blockSignatureArg, "@?", 2) == 0) {
                // Handle function pointer / block arguments
                blockSignatureArg = "@?";
            }
            else if (strncmp(blockSignatureArg, "@", 1) == 0) {
                blockSignatureArg = "@";
            }
            
            if (strcmp(blockSignatureArg, [methodSignature getArgumentTypeAtIndex:i]) != 0) {
                return NO;
            }
        }
    }
    
    return YES;
}

#endif // NS_BLOCK_ASSERTIONS

