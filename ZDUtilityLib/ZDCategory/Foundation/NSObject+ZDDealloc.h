//
//  NSObject+ZDDealloc.h
//  ZDProxy
//
//  Created by 符现超 on 15/12/31.
//  Copyright © 2015年 Fate.D.Bourne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZDDealloc)

- (void)zd_releaseAtDealloc:(void(^)())deallocBlock;

@end

