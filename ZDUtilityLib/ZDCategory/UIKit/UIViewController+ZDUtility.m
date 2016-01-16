//
//  UIViewController+ZDUtility.m
//  ZDUtility
//
//  Created by 符现超 on 16/1/16.
//  Copyright © 2016年 Fate.D.Bourne. All rights reserved.
//

#import "UIViewController+ZDUtility.h"

@implementation UIViewController (ZDUtility)

- (BOOL)isSurport3DTouch
{
    if ([UIDevice currentDevice].systemVersion.integerValue >= 9.0f && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        return YES;
    }
    return NO;
}

@end
