//
//  ZDNavigationController.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/3/8.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDNavigationController.h"

@interface ZDBaseViewController : UIViewController
- (BOOL)zd_gestureRecognizerShouldBegin;
@end

@implementation ZDBaseViewController
- (BOOL)zd_gestureRecognizerShouldBegin
{
    return YES;
}
@end

///---------------------------------------------------

@interface ZDNavigationController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL supportRightGesture;

@end

@implementation ZDNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.supportRightGesture = YES;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([self.topViewController isKindOfClass:[ZDBaseViewController class]]) {
        if ([self.topViewController respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
            ZDBaseViewController *baseVC = (ZDBaseViewController *)self.topViewController;
            self.supportRightGesture = [baseVC zd_gestureRecognizerShouldBegin];
        }
    }
    return self.supportRightGesture;
}

@end










