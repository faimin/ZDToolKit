//
//  UIViewController+ZDBackButtonHandler.h
//  UINavigationControllerStudy
//
//  Created by 符现超 on 15/10/30.
//  Copyright © 2015年 Fate.D.Bourne. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZDBackButtonHandler <NSObject>

@optional
/// 自定义push到下一界面的返回按钮的标题 (The length of the text is limited, otherwise it will be set to "Back")
- (NSString *)navigationItemBackBarButtonTitle;

/// 自定义返回事件 (Override this method in UIViewController derived class to handle 'Back' button click)
- (BOOL)navigationControllerShouldPop:(UINavigationController *)navigationController;

@end

@interface UIViewController (ZDBackButtonHandler) <ZDBackButtonHandler>

@end
