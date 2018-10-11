//
//  ZDBaseModel.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/9/30.
//  Copyright © 2018 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseModel.h"
@import ObjectiveC;

@implementation ZDBaseModel

@end


@implementation ZDBaseModel (Extend)

- (void)setUrl:(NSURL *)url {
    objc_setAssociatedObject(self, @selector(url), url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)url {
    return objc_getAssociatedObject(self, _cmd);
}

@end
