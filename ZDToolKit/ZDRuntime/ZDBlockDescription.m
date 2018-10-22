//
//  ZDBlock.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2017/11/14.
//

#import "ZDBlockDescription.h"
#import <objc/message.h>
#import <objc/runtime.h>
#if __has_include(<ffi.h>)
#import <ffi.h>
#elif __has_include("ffi.h")
#import "ffi.h"
#endif

@interface ZDBlockDescription ()

@end

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

void ZD_ReduceBlockSignatureTypes(NSString *signatureCodingType, NSArray<NSString *> **argTypesResult, NSString **returnTypeResult) {
    if (signatureCodingType.length == 0) return;
    
    NSString *types = signatureCodingType.copy;
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

NSString *ZD_ReduceBlockSignatureCodingType(const char *signatureCodingType) {
    NSString *charType = [NSString stringWithUTF8String:signatureCodingType];
    if (charType.length == 0) return nil;
    
    NSString *codingType = charType.copy;
    
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
    
    const char *originArgType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    
    NSString *argTypeString = ZD_ReduceBlockSignatureCodingType(originArgType);
    const char *argType = argTypeString.UTF8String;
    
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
                // 当前类自身没有实现这个method，所以下面获取到的其实是父类的方法
                Method method = class_getInstanceMethod(newBlockClass, selector);
                // 因为当前类自己没有实现这个method，所以执行class_replaceMethod就等价于class_addMethod，so在这里使用此方法没毛病
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

#pragma mark - ------------------------------- Libffi ----------------------------------
#pragma mark -

#if USE_LIBFFI
ffi_type *ZD_ffiTypeWithTypeEncoding(const char *type) {
    if (strcmp(type, "@?") == 0) { // block
        return &ffi_type_pointer;
    }
    const char *c = type;
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
    
    NSCAssert(NO, @"can't match a ffi_type of %s", type);
    return NULL;
}

//*****************************************
//static const void *ZD_SignatureBind_Key = &ZD_SignatureBind_Key;
@interface ZDFfiBlockHook () {
    @package
    ffi_cif _cif;
    //ffi_cif _blockCif;
    ffi_type **_args;
    //ffi_type **_blockArgs;
    ffi_closure *_closure;
    
    void *_originalIMP;
    void *_newIMP;
}
@end

@interface NSMethodSignature (ZDBKWeakBinding)
@property (nonatomic, weak) id zdbk_weakBindValue;
@end

@implementation NSMethodSignature (ZDBKWeakBinding)

- (void)setZdbk_weakBindValue:(id)zdbk_weakBindValue {
    __weak id weakValue = zdbk_weakBindValue;
    objc_setAssociatedObject(self, @selector(zdbk_weakBindValue), ^id{
        return weakValue;
    }, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id)zdbk_weakBindValue {
    id (^block)(void) = objc_getAssociatedObject(self, _cmd);
    return block ? block() : nil;
}

@end
//****************************************

static void ZD_ffi_clousure_func(ffi_cif *cif, void *ret, void **args, void *userdata) {
    ZDFfiBlockHook *self = (__bridge ZDFfiBlockHook *)userdata;
    //NSUInteger argCount = self.signature.numberOfArguments;

#if DEBUG
    int i = *((int *)args[2]);
    NSString *str = (__bridge NSString *)(*((void **)args[1]));
    NSLog(@"%d, %@", i, str);
#endif
    
    //根据cif函数原型，函数指针，返回值内存指针，函数参数数据调用这个函数
    ffi_call(&(self->_cif), self->_originalIMP, ret, args);
}

static void ZD_ffi_prep_cif(NSMethodSignature *signature) {
    ZDFfiBlockHook *self = (ZDFfiBlockHook *)(signature.zdbk_weakBindValue);
    
    ffi_type *returnType = ZD_ffiTypeWithTypeEncoding(signature.methodReturnType);
    NSCAssert(returnType, @"can't find a ffi_type of %s", signature.methodReturnType);
    
    NSUInteger argCount = signature.numberOfArguments; // 第一个参数是block自己，第二个参数才是我们看到的参数
    ffi_type **args = alloca(sizeof(ffi_type *) * argCount); // 栈上开辟内存
    self->_args = args;
    
    int tempInt = 0;
    for (int i = tempInt; i < argCount; ++i) {
        const char *argType = [signature getArgumentTypeAtIndex:i];
        ffi_type *arg_ffi_type = ZD_ffiTypeWithTypeEncoding(argType);
        NSCAssert(arg_ffi_type, @"can't find a ffi_type of %s", argType);
        args[i-tempInt] = arg_ffi_type;
    }
    
    //生成 ffi_cfi 对象，保存函数参数个数、类型等信息，相当于一个函数原型
    ffi_status status = ffi_prep_cif(&(self->_cif), FFI_DEFAULT_ABI, (unsigned int)argCount, returnType, args);
    if (status != FFI_OK) {
        NSCAssert1(NO, @"Got result %u from ffi_prep_cif", status);
    }
}

static void ZD_ffi_prep_closure(NSMethodSignature *signature) {
    ZDFfiBlockHook *self = (ZDFfiBlockHook *)(signature.zdbk_weakBindValue);
    
    // https://blog.cnbang.net/tech/3332/
    ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void **)&(self->_newIMP));
    self->_closure = closure;
    
    ffi_status status = ffi_prep_closure_loc(closure, &(self->_cif), ZD_ffi_clousure_func, (__bridge void *)self, self->_newIMP);
    if (status != FFI_OK) {
        NSCAssert(NO, @"genarate closure failed");
    }
    
    self->_originalIMP = ((__bridge ZDBlock *)self.block)->invoke;
    ((__bridge ZDBlock *)self.block)->invoke = self->_newIMP;
    
    /*
    NSUInteger argCount = signature.numberOfArguments;
    ffi_type **blockArgs = alloca(sizeof(ffi_type *) * argCount); // 开辟栈内存
    
    ffi_type *current_ffi_type_0 = ZD_ffiTypeWithTypeEncoding("@?");
    blockArgs[0] = current_ffi_type_0;
    ffi_type *current_ffi_type_1 = ZD_ffiTypeWithTypeEncoding("@");
    blockArgs[1] = current_ffi_type_1;
    
    for (int i = 2; i < argCount; i++) {
        ffi_type *arg_ffi_type = ZD_ffiTypeWithTypeEncoding([signature getArgumentTypeAtIndex:i]);
        blockArgs[i] = arg_ffi_type;
    }
    
    ffi_cif blockCif;
    if (ffi_prep_cif(&blockCif, FFI_DEFAULT_ABI, (unsigned int)argCount, returnType, blockArgs) != FFI_OK) {
        NSCAssert1(NO, @"Got result %u from ffi_prep_cif", status);
    }
    */
}

static void ZD_HookBlockWithSignature(NSMethodSignature *signature) {
    ZD_ffi_prep_cif(signature);
    ZD_ffi_prep_closure(signature);
}

static void ZD_HookBlockWithLibffi(id block) {
    const char *blockTypeEncoding = ZD_BlockSignatureTypes(block);
    NSString *blockTypeEncodingString = ZD_ReduceBlockSignatureCodingType(blockTypeEncoding);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:blockTypeEncodingString.UTF8String];
    
    ZD_HookBlockWithSignature(signature);
}

#pragma mark -

@implementation ZDFfiBlockHook

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    ffi_closure_free(_closure);
    //free(_args);
}

+ (instancetype)hookBlock:(id)block {
    ZDFfiBlockHook *blockHook = [[ZDFfiBlockHook alloc] init];
    blockHook.block = block;
    const char *typeEncoding = ZD_ReduceBlockSignatureCodingType(ZD_BlockSignatureTypes(block)).UTF8String;
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:typeEncoding];
    signature.zdbk_weakBindValue = self;
    blockHook.signature = signature;
    blockHook.typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    
    ZD_HookBlockWithLibffi(block);

    return blockHook;
}

@end
#endif

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

