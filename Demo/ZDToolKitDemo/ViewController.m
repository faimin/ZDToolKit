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
#import "UITextView+ZDUtility.h"
#import "NSObject+DLIntrospection.h"
#import "NSObject+ZDUtility.h"
#import "ZDFunction.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *testView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"ZDToolKitDemo";
    //[self functionTest];
    //[self numberTest];
    
    NSString *urlStr = @"http://pic14.nipic.com/20110522/7411759_164157418126_2.jpg";
    //[self.testView rz_addBordersWithCornerRadius:30 width:1 color:[UIColor blueColor]];
#if 1
    [self.testImageView zd_setImageWithURL:urlStr placeholderImage:nil cornerRadius:30];
#else
    self.testImageView.aliCornerRadius = 35;
    [self.testImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
#endif
    
    [self.testImageView zd_addTapGestureWithBlock:^(UITapGestureRecognizer *tapGesture) {
        NSLog(@"\n轻击了, %@", tapGesture);
    }];
    
    self.textView.zd_placeHolderLabel = ({
        UILabel *label = [UILabel new];
        label.text = @"这是一个占位label";
        label.textColor = [UIColor redColor];
        label;
    });
    
    NSArray *propertys = [self.class properties];
    NSLog(@"所有的属性: \n%@", propertys);
    
    //id obj = [self zd_deepCopy];
    //NSLog(@"\n\n%@", obj);
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (ZD_IsMainQueue()) {
            NSLog(@"主队列");
        }
        else {
            NSLog(@"子队列");
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /// 对于autolayout布局的视图，只有在视图显示出来的时候才能获取到真实的frame
    /// viewDidLoad和viewWillAppear方法中都不行，时机过早
    self.testView.zd_cornerRadius = 30;
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
    BOOL isAllNum = [str zd_isAllNumber];
    NSLog(@"%@", isAllNum ? @"YES" : @"NO");
}





@end
