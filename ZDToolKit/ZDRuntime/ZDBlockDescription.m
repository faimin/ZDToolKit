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

#pragma mark - Function

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

ZDBlockIMP ZD_BlockInvokeIMP(id block) {
    if (!block) return NULL;
    
    struct ZDBlockLiteral *blockRef = (__bridge struct ZDBlockLiteral *)block;
    return blockRef->invoke;
}


#pragma mark - Print Params

void ZD_GenarateTypes(NSString *types, NSArray<NSString *> **argTypesResult, NSString **returnTypeResult) {
    NSMutableArray<NSString *> *argumentTypes = [[NSMutableArray<NSString *> alloc] init];
    NSString *returnType = nil;
    
    NSInteger descNum1 = 0; // num of '\"' in block signature type encoding
    NSInteger descNum2 = 0; // num of '<' or '>' in block signature type encoding
    for (int i = 0; i < types.length; i ++) {
        unichar c = [types characterAtIndex:i];
        
        NSString *arg;
        if (c == '\"') ++descNum1;
        if ((descNum1 % 2) != 0 || c == '\"' || isdigit(c)) {
            continue;
        }
        
        if (c == '<' || c == '>') ++descNum2;
        if ((descNum2 % 2) != 0 || c == '<' || c == '>') {
            continue;
        }
        
        BOOL skipNext = NO;
        if (c == '^') {
            skipNext = YES;
            arg = [types substringWithRange:NSMakeRange(i, 2)];
        }
        else if (c == '?') {
            // @? is block
            arg = [types substringWithRange:NSMakeRange(i - 1, 2)];
            [argumentTypes removeLastObject];
        }
        else if (c == '{') {
            NSUInteger end = [[types substringFromIndex:i] rangeOfString:@"}"].location + i;
            arg = [types substringWithRange:NSMakeRange(i, end - i + 1)];
            if (i == 0) {
                returnType = arg;
            }
            else {
                [argumentTypes addObject:arg];
            }
            i = (int)end;
            continue;
        }
        else {
            arg = [types substringWithRange:NSMakeRange(i, 1)];
        }
        
        if (i == 0) {
            returnType = arg;
        }
        else {
            [argumentTypes addObject:arg];
        }
        
        if (skipNext) i++;
    }
    
    *argTypesResult = argumentTypes;
    *returnTypeResult = returnType;
}

/*
ffi_type *ffiTypeWithType(NSString *type) {
    if ([type isEqualToString:@"@?"]) {
        return &ffi_type_pointer;
    }
    const char *c = [type UTF8String];
    switch (c[0]) {
        case 'v':
            return &ffi_type_void;
        case 'c':
            return &ffi_type_schar;
        case 'C':
            return &ffi_type_uchar;
        case 's':
            return &ffi_type_sshort;
        case 'S':
            return &ffi_type_ushort;
        case 'i':
            return &ffi_type_sint;
        case 'I':
            return &ffi_type_uint;
        case 'l':
            return &ffi_type_slong;
        case 'L':
            return &ffi_type_ulong;
        case 'q':
            return &ffi_type_sint64;
        case 'Q':
            return &ffi_type_uint64;
        case 'f':
            return &ffi_type_float;
        case 'd':
            return &ffi_type_double;
        case 'F':
#if CGFLOAT_IS_DOUBLE
            return &ffi_type_double;
#else
            return &ffi_type_float;
#endif
        case 'B':
            return &ffi_type_uint8;
        case '^':
            return &ffi_type_pointer;
        case '@':
            return &ffi_type_pointer;
        case '#':
            return &ffi_type_pointer;
        case ':':
            return &ffi_type_schar;
    }
    
    NSCAssert(NO, @"can't match a ffi_type of %@", type);
    return NULL;
}

ZDBlockIMP ZD_BlockIMP(NSArray<NSString *> *argumentTypes, NSString *returnType) {
    ffi_type *returnType = ffiTypeWithType(returnType);
    NSAssert(returnType, @"can't find a ffi_type of %@", returnType);
    
    NSUInteger argumentCount = argumentTypes.count;
    ZDBlockIMP blockIMP = NULL;
    ffi_type **_args = malloc(sizeof(ffi_type *) * argumentCount) ;
    
    for (int i = 0; i < argumentCount; i++) {
        ffi_type* current_ffi_type = ffiTypeWithType(argumentTypes[i]);
        NSAssert(current_ffi_type, @"can't find a ffi_type of %@", self.signature.argumentTypes[i]);
        _args[i] = current_ffi_type;
    }
    
    ffi_closure *_closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&blockIMP);
    
    if (ffi_prep_cif(&_cif, FFI_DEFAULT_ABI, (unsigned int)argumentCount, returnType, _args) == FFI_OK) {
        if (ffi_prep_closure_loc(_closure, &_cif, ffi_function, (__bridge void *)(self), stingerIMP) != FFI_OK) {
            NSAssert(NO, @"genarate IMP failed");
        }
    }
    else {
        NSAssert(NO, @"FUCK");
    }
    
    ZD_GenarateBlockCif(argumentTypes, returnType);
    return stingerIMP;
}

void ZD_GenarateBlockCif(NSArray<NSString *> *argumentTypes, NSString *returnType) {
    ffi_type *returnType = ffiTypeWithType(self.signature.returnType);
    
    NSUInteger argumentCount = argumentTypes.count;
    ffi_type **_blockArgs = malloc(sizeof(ffi_type *) * argumentCount);
    
    ffi_type *current_ffi_type_0 = ffiTypeWithType(@"@?");
    _blockArgs[0] = current_ffi_type_0;
    ffi_type *current_ffi_type_1 = ffiTypeWithType(@"@");
    _blockArgs[1] = current_ffi_type_1;
    
    for (int i = 2; i < argumentCount; i++) {
        ffi_type* current_ffi_type = ffiTypeWithType(self.signature.argumentTypes[i]);
        _blockArgs[i] = current_ffi_type;
    }
    
    if (ffi_prep_cif(&_blockCif, FFI_DEFAULT_ABI, (unsigned int)argumentCount, returnType, _blockArgs) != FFI_OK) {
        NSAssert(NO, @"FUCK");
    }
}

static void ffi_function(ffi_cif *cif, void *ret, void **args, void *userdata) {
    StingerInfoPool *self = (__bridge StingerInfoPool *)userdata;
    NSUInteger count = self.signature.argumentTypes.count;
    void **innerArgs = malloc(count * sizeof(*innerArgs));
    
    StingerParams *params = [[StingerParams alloc] init];
    void **slf = args[0];
    params.slf = (__bridge id)(*slf);
    params.sel = self.sel;
    [params addOriginalIMP:self.originalIMP];
    NSInvocation *originalInvocation = [NSInvocation invocationWithMethodSignature:self.ns_signature];
    for (int i = 0; i < count; i ++) {
        [originalInvocation setArgument:args[i] atIndex:i];
    }
    [params addOriginalInvocation:originalInvocation];
    
    innerArgs[1] = &params;
    memcpy(innerArgs + 2, args + 2, (count - 2) * sizeof(*args));
    
#define ffi_call_infos(infos) \
for (id<StingerInfo> info in infos) { \
id block = info.block; \
innerArgs[0] = &block; \
ffi_call(&(self->_blockCif), impForBlock(block), NULL, innerArgs); \
}  \

    // before hooks
    ffi_call_infos(self.beforeInfos);
    // instead hooks
    if (self.insteadInfos.count) {
        id <StingerInfo> info = self.insteadInfos[0];
        id block = info.block;
        innerArgs[0] = &block;
        ffi_call(&(self->_blockCif), impForBlock(block), ret, innerArgs);
    }
    else {
        // original IMP
        ffi_call(cif, (void (*)(void))self.originalIMP, ret, args);
    }
    // after hooks
    ffi_call_infos(self.afterInfos);
    
    free(innerArgs);
}
*/

/*
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
 */

#endif // NS_BLOCK_ASSERTIONS

