//
//  UIApplication+ZDUtility.m
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/1/14.
//

#import "UIApplication+ZDUtility.h"

typedef void(^__ZDResponderCallBack)(UIResponder *);

@interface UIResponder (__ZDPrivate)
- (void)_zd_reportAsFirst:(__ZDResponderCallBack)sender;
@end

@implementation UIApplication (ZDUtility)

// https://www.appcoda.com.tw/first-responder
- (__kindof UIResponder *)zd_firstResponder {
    __block __kindof UIResponder *firstResponder = nil;
    __ZDResponderCallBack sender = ^void(UIResponder *responder){
        firstResponder = responder;
    };
    // 原理：to(target)为nil时会自动传递给第一响应者
    [self sendAction:@selector(_zd_reportAsFirst:) to:nil from:sender forEvent:nil];
    return firstResponder;
}

- (__kindof UIWindow *_Nullable)zd_window {
    UIWindow *mainWindow = self.delegate.window;
    if (mainWindow) {
        return mainWindow;
    }
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in self.connectedScenes) {
            if ([scene isKindOfClass:UIWindowScene.class] && [scene.delegate respondsToSelector:@selector(window)]) {
                id<UIWindowSceneDelegate> delegate = (id<UIWindowSceneDelegate>)scene.delegate;
                mainWindow = delegate.window;
                break;
            }
        }
        if (!mainWindow) {
            mainWindow = self.windows.firstObject;
        }
    }
    else {
        mainWindow = self.keyWindow;
    }
    return mainWindow;
}

// https://github.com/facebook/react-native/commit/0c53420a7af306d629350e1244e8e2ccae08a312
- (UIWindow *)_uiWindowFromScene {
    if (@available(iOS 13.0, *)) {
        for (__kindof UIScene *scene in self.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && UIWindowScene.class) {
                return [[UIWindow alloc] initWithWindowScene:scene];
            }
        }
    }
    return nil;
}

@end

@implementation UIResponder (__ZDPrivate)

- (void)_zd_reportAsFirst:(__ZDResponderCallBack)sender {
    if (sender) sender(self);
}

@end
