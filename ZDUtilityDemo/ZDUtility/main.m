//
//  main.m
//  ZDUtility
//
//  Created by 符现超 on 15/7/11.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        int retValue = 0;
        @try {
            retValue = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"exception reason: %@",exception.reason);
            NSLog(@"exception debugDescription: %@",exception.debugDescription);
            NSLog(@"exception callStackSymbols: %@",exception.callStackSymbols);
        }
        @finally {
            // do nothing
        }
        return retValue;
    }
}
