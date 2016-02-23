//
//  ViewController.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/1/23.
//  Copyright © 2016年 Zero.D.Bourne. All rights reserved.
//

#import "ViewController.h"
#import "ZDDefine.h"
#import "NSString+ZDUtility.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self functionTest];
    [self numberTest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)functionTest
{
    UIView *view = ({
        UIView *view = [UIView new];
        zd_defer{
            /// 所谓作用域结束，包括大括号结束、return、goto、break、exception等各种情况
            NSLog(@"当前作用域结束,马上要出作用域了");
        };
        view.backgroundColor = [UIColor redColor];
        view.frame = CGRectMake(20, 100, 50, 50);
        view;
    });
    [self.view addSubview:view];
    
    NSLog(@"执行完毕");
}

- (void)numberTest
{
    NSString *str = @"2345";
    BOOL isAllNum = [str isAllNumber];
    NSLog(@"%@", isAllNum ? @"YES" : @"NO");
}





@end
