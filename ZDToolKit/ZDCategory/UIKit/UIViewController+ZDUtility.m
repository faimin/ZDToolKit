//
//  UIViewController+ZDUtility.m
//  ZDUtility
//
//  Created by 符现超 on 16/1/16.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UIViewController+ZDUtility.h"


@implementation UIViewController (ZDUtility)

- (BOOL)isSupport3DTouch
{
    if ([UIDevice currentDevice].systemVersion.integerValue >= 9.0f && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        return YES;
    }
    return NO;
}

- (void)presentModalBuyItemVCWithId:(NSString *)itemId animated:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        SKStoreProductViewController *skvc = [[SKStoreProductViewController alloc] init];
        skvc.delegate = self;
        [skvc loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : itemId} completionBlock:^(BOOL result, NSError *error){
            if (!result || error) {
                [skvc dismissViewControllerAnimated:YES completion:nil];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", itemId]]];
            }
        }];
        [self presentViewController:skvc animated:YES completion:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8", itemId]]];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
