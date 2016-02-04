//
//  NSObject+ZDDealloc.h
//  ZDProxy
//
//  Created by 符现超 on 15/12/31.
//  Copyright © 2015年 Fate.D.Bourne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZDDealloc)

///  对象释放时执行block中的code
- (void)zd_deallocBlcok:(void(^)())deallocBlock;

@end

