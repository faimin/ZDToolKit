//
//  ZDBlock.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/14.
//

#import "ZDBlockDescription.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation ZDBlockDescription

@end

#pragma mark - Block Define
#pragma mark -

// https://github.com/rabovik/RSSwizzle
#if !defined(NS_BLOCK_ASSERTIONS)

// http://clang.llvm.org/docs/Block-ABI-Apple.html#high-level
// https://opensource.apple.com/source/libclosure/libclosure-67/Block_private.h.auto.html
struct ZDBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    volatile int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct ZDBlock_descriptor_1 {
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

typedef struct ZDBlockLiteral ZDBlock;

#pragma mark - Function
#pragma mark -

/// 不能直接通过blockRef->descriptor->signature获取签名，因为不同场景下的block结构有差别:
/// 比如当block内部引用了外面的局部变量，并且这个局部变量是OC对象，
/// 或者是`__block`关键词包装的变量，block的结构里面有copy和dispose函数，因为这两种变量都是属于内存管理的范畴的；
/// 其他场景下的block就未必有copy和dispose函数。
/// 所以这里是通过flag判断是否有签名，以及是否有copy和dispose函数，然后通过地址偏移找到signature的。
const char *ZD_BlockSignatureTypes(id block) {
    if (!block) return NULL;
    
    ZDBlock *blockRef = (__bridge ZDBlock *)block;
    
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
    
    ZDBlock *blockRef = (__bridge ZDBlock *)block;
    return blockRef->invoke;
}

// https://github.com/bang590/JSPatch/blob/master/JSPatch/JPEngine.m
IMP ZD_MsgForwardIMP(const char *methodTypes) {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    if (methodTypes[0] == '{') {
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:methodTypes];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    return msgForwardIMP;
}

BOOL ZD_IsMsgForward(IMP imp) {
    return (imp == _objc_msgForward
#if !defined(__arm64__)
            || imp == _objc_msgForward_stret
#endif
            );
}

void ZD_ReduceBlockSignatureTypes(NSString *types, NSArray<NSString *> **argTypesResult, NSString **returnTypeResult) {
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
    
    if (argTypesResult) *argTypesResult = argumentTypes;
    if (returnTypeResult) *returnTypeResult = returnType;
}

NSString *ZD_ReduceBlockSignatureCodingType(NSString *codingType) {
    NSError *error = nil;
    NSString *regexString = @"\\\"[A-Za-z]+\\\"|[0-9]+";// <==> \\"[A-Za-z]+\\"|\d+  <==>  \\"\w+\\"|\d+
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    
    NSTextCheckingResult *mathResult = nil;
    do {
        mathResult = [regex firstMatchInString:codingType options:NSMatchingReportProgress range:NSMakeRange(0, codingType.length)];
        if (mathResult.range.location != NSNotFound && mathResult.range.length != 0) {
            codingType = [codingType stringByReplacingCharactersInRange:mathResult.range withString:@""];
        }
    } while (mathResult.range.length != 0);
    
    return codingType;
}

#pragma mark -

static id ZD_ArgumentOfInvocationAtIndex(NSInvocation *invocation, NSUInteger index) {
#define WRAP_AND_RETURN(type) \
do { \
type val = 0; \
[invocation getArgument:&val atIndex:(NSInteger)index]; \
return @(val); \
} while (0)
    
    const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    
    NSString *argTypeString = [NSString stringWithUTF8String:argType];
    NSError *error;
    NSString *regexString = @"\\\"[A-Za-z]+\\\""; // real regex is----  \\"[A-Za-z]+\\"
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:0 error:&error];
    
    __block NSString *newString;
    [regex enumerateMatchesInString:argTypeString options:NSMatchingReportProgress range:NSMakeRange(0, argTypeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result.range.location != NSNotFound) {
            newString = [argTypeString stringByReplacingCharactersInRange:result.range withString:@""];
        }
    }];
    //NSArray<NSTextCheckingResult *> *array = [regex matchesInString:argTypeString options:NSMatchingReportProgress range:NSMakeRange(0, argTypeString.length)];
    if (newString) {
        argType = newString.UTF8String;
    }
    
    // Skip const type qualifier.
    if (argType[0] == 'r') {
        argType++;
    }
    
    if (strcmp(argType, @encode(id)) == 0 || strcmp(argType, @encode(Class)) == 0) {
        __autoreleasing id returnObj;
        [invocation getArgument:&returnObj atIndex:(NSInteger)index];
        return returnObj;
    } else if (strcmp(argType, @encode(char)) == 0) {
        WRAP_AND_RETURN(char);
    } else if (strcmp(argType, @encode(int)) == 0) {
        WRAP_AND_RETURN(int);
    } else if (strcmp(argType, @encode(short)) == 0) {
        WRAP_AND_RETURN(short);
    } else if (strcmp(argType, @encode(long)) == 0) {
        WRAP_AND_RETURN(long);
    } else if (strcmp(argType, @encode(long long)) == 0) {
        WRAP_AND_RETURN(long long);
    } else if (strcmp(argType, @encode(unsigned char)) == 0) {
        WRAP_AND_RETURN(unsigned char);
    } else if (strcmp(argType, @encode(unsigned int)) == 0) {
        WRAP_AND_RETURN(unsigned int);
    } else if (strcmp(argType, @encode(unsigned short)) == 0) {
        WRAP_AND_RETURN(unsigned short);
    } else if (strcmp(argType, @encode(unsigned long)) == 0) {
        WRAP_AND_RETURN(unsigned long);
    } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
        WRAP_AND_RETURN(unsigned long long);
    } else if (strcmp(argType, @encode(float)) == 0) {
        WRAP_AND_RETURN(float);
    } else if (strcmp(argType, @encode(double)) == 0) {
        WRAP_AND_RETURN(double);
    } else if (strcmp(argType, @encode(BOOL)) == 0) {
        WRAP_AND_RETURN(BOOL);
    } else if (strcmp(argType, @encode(char *)) == 0) {
        WRAP_AND_RETURN(const char *);
    } else if (strcmp(argType, @encode(void (^)(void))) == 0) {
        __unsafe_unretained id block = nil;
        [invocation getArgument:&block atIndex:(NSInteger)index];
        return [block copy];
    } else {
        NSUInteger valueSize = 0;
        NSGetSizeAndAlignment(argType, &valueSize, NULL);
        
        unsigned char valueBytes[valueSize];
        [invocation getArgument:valueBytes atIndex:(NSInteger)index];
        
        return [NSValue valueWithBytes:valueBytes objCType:argType];
    }
    
    return nil;
#undef WRAP_AND_RETURN
}

#pragma mark -

@interface NSInvocation (PrivateAPI)
- (void)invokeUsingIMP:(IMP)imp;
@end

#pragma mark - Hook Block

static const void *ZD_Origin_Block_Key = &ZD_Origin_Block_Key;

//---------------------------------------------------------------------------------
static NSMethodSignature *ZD_NewSignatureForSelector(id self, SEL _cmd, SEL aSelector) {
    const char *blockSignature = ZD_BlockSignatureTypes(self);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:blockSignature];
    return signature;
}

static void ZD_NewForwardInvocation(id self, SEL _cmd, NSInvocation *anInvocation) {
    __unused ZDBlock *layout = (__bridge void *)anInvocation.target;
    __unused SEL selector = anInvocation.selector;
    
    for (NSInteger i = 1; i < anInvocation.methodSignature.numberOfArguments; ++i) {
        id argValue = ZD_ArgumentOfInvocationAtIndex(anInvocation, i);
        NSLog(@"block arg %ld : %@", i, argValue);
    }
    
    id originBlock = objc_getAssociatedObject(self, ZD_Origin_Block_Key);
    [anInvocation setTarget:originBlock];
    //[anInvocation invokeUsingIMP:(IMP)((__bridge ZDBlock *)originBlock)->invoke];
    [anInvocation invoke];
}
//---------------------------------------------------------------------------------
static NSString *const ZD_Prefix = @"ZD_";

id ZD_HookBlock(id block) {
    if (![block isKindOfClass:objc_lookUpClass("NSBlock")]) return NULL;
    
    const char *blockClassName = object_getClassName(block);
    Class newBlockClass = object_getClass(block);
    if (![[NSString stringWithUTF8String:blockClassName] hasPrefix:ZD_Prefix]) {
        const char *prefix = "ZD_";
        char *newBlockClassName = calloc(1, strlen(prefix) + strlen(blockClassName) + 1);//+1 for the zero-terminator
        strcpy(newBlockClassName, prefix);
        strcat(newBlockClassName, blockClassName);
        
        newBlockClass = objc_lookUpClass(newBlockClassName);
        if (!newBlockClass) {
            Class aClass = object_getClass(block);
            newBlockClass = objc_allocateClassPair(aClass, newBlockClassName, 0);
            {
                SEL selector = @selector(methodSignatureForSelector:);
                Method method = class_getInstanceMethod(newBlockClass, selector);
                __unused IMP originIMP = class_replaceMethod(newBlockClass, selector, (IMP)ZD_NewSignatureForSelector, method_getTypeEncoding(method));
            }
            
            {
                SEL selector = @selector(forwardInvocation:);
                Method method = class_getInstanceMethod(newBlockClass, selector);
                __unused IMP originIMP = class_replaceMethod(newBlockClass, selector, (IMP)ZD_NewForwardInvocation, method_getTypeEncoding(method));
            }
            objc_registerClassPair(newBlockClass);
        }

        free(newBlockClassName);
    }
    
    ZDBlock *blockRef = (__bridge ZDBlock *)block;
    if (!blockRef) return NULL;
    
    // create a new block
    ZDBlock *fakeBlock = calloc(1, sizeof(ZDBlock));
    fakeBlock->isa = (__bridge void *)newBlockClass;
    fakeBlock->reserved = blockRef->reserved;
    fakeBlock->flags = blockRef->flags;
    fakeBlock->descriptor = blockRef->descriptor;
    if (blockRef->flags & BLOCK_HAS_STRET) {
        fakeBlock->invoke = (void *)(IMP)_objc_msgForward_stret;
    }
    else {
        fakeBlock->invoke = (void *)(IMP)_objc_msgForward;
    }
    objc_setAssociatedObject((__bridge id _Nonnull)(fakeBlock), ZD_Origin_Block_Key, (__bridge id _Nullable)(blockRef), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return (__bridge_transfer id)fakeBlock;
}


ffi_type *ffiTypeWithType(NSString *type) {
    if ([type isEqualToString:@"@?"]) { // block
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

/*
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

