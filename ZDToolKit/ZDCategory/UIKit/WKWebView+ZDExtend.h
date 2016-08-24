//
//  WKWebView+ZDExtend.h
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 16/8/24.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (ZDExtend)

- (void)getImageUrls:(void(^)(id imageUrls))block;

@end
