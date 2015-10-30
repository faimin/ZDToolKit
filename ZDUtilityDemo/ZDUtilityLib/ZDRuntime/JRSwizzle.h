// JRSwizzle.h semver:1.0
//   Copyright (c) 2007-2011 Jonathan 'Wolf' Rentzsch: http://rentzsch.com
//   Some rights reserved: http://opensource.org/licenses/MIT
//   https://github.com/rentzsch/jrswizzle

#import <Foundation/Foundation.h>

@interface NSObject (JRSwizzle)

+ (BOOL)jr_swizzleMethod:(SEL)origSel withMethod:(SEL)altSel error:(NSError**)error;

+ (BOOL)jr_swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel error:(NSError**)error;

@end
