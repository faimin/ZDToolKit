//
//  AppDelegate.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/1/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "AppDelegate.h"
#import <ZDToolKit/ZDWatchdog.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[ZDWatchdog shareInstance] start];
    
    [self debug];
    
    return YES;
}

/**
 1、Call [UIDebuggingInformationOverlay prepareDebuggingOverlay] - I’m not sure exactly what this method does, but the overlay will be empty if you don’t call it.
 2、Call [[UIDebuggingInformationOverlay overlay] toggleVisibility] - This shows the overlay window (assuming it’s not already visible).
 */

- (void)debug {
#if DEBUG
    Class aClass = objc_getClass("UIDebuggingInformationOverlay");
    // 运行程序后，执行下面方法后，两根手指点击状态栏即可调起这个调试的悬浮层
    ((void (*) (id, SEL))(void *)objc_msgSend) ((id)aClass, sel_registerName("prepareDebuggingOverlay"));
    // 下面方法是可选的，可以不调用
    __unused id returnInstance = ((id (*) (id, SEL))(void *)objc_msgSend) ((id)aClass, sel_registerName("overlay"));
    // ((void* (*) (id, SEL))(void *)objc_msgSend) ((id)returnInstance, sel_registerName("toggleVisibility"));
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
