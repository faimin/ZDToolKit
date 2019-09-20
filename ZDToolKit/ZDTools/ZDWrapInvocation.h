//
//  ZDWrapInvocation.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDWrapInvocation<__covariant R> : NSObject

+ (R)zd_target:(id)target invokeSelectorWithArgs:(SEL)selector, ...;

+ (id)zd_target:(id)target invokeSelector:(SEL)selector args:(va_list)args;

@end

NS_ASSUME_NONNULL_END
