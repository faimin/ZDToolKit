//
//  ViewController.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/1/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import "ZDDefine.h"
#import "NSString+ZDUtility.h"
#import "UIView+ZDUtility.h"
#import "UIView+RZBorders.h"
#import "UIImageView+ZDUtility.h"
#import "UIImageView+WebCache.h"
#import "HJCornerRadius.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *testView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self functionTest];
    [self numberTest];
    
    NSString *urlStr = @"http://pic14.nipic.com/20110522/7411759_164157418126_2.jpg";
#if 0
    self.testView.cornerRadius = 30;
    //[self.testView rz_addBordersWithCornerRadius:30 width:1 color:[UIColor blueColor]];
    [self.testImageView zd_setImageWithURL:urlStr placeholderImage:nil cornerRadius:30];
#else
    self.testImageView.aliCornerRadius = 35;
    [self.testImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
#endif

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
