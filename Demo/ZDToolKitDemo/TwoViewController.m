//
//  TwoViewController.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "TwoViewController.h"
#import "UIView+ZDUtility.h"
#import "ZDFunction.h"
#import "ZDLabel.h"

@interface TwoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ZDLabel *zdLabel;
@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.zd_touchExtendInsets = UIEdgeInsetsMake(50, 50, 50, 50);
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.imageView addGestureRecognizer:tap];
    
    NSString *text = @"链接地址: www.baidu.com";
    self.zdLabel.text = text;
    NSRange range = [text rangeOfString:@"www.baidu.com"];
    [self.zdLabel addTarget:self action:@selector(textAction) ranges:@[[NSValue valueWithRange:range]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textAction {
    NSLog(@"label响应了");
}

- (void)tapAction {
    NSLog(@"点到了。。。。。。");
}

- (void)autoreleaseTest {
    dispatch_queue_t zdQueue = dispatch_queue_create("zdQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(zdQueue, ^{
        if ([NSThread isMainThread]) {
            NSLog(@"主线程");
        }
        
        for (int i = 0; i < 500000; i++) {
            @autoreleasepool {
                // 说明： 当在一个特别多的循环里创建多个临时变量时，需要加上@autoreleasepool，不加的话会导致内存升高
                NSNumber *num = [NSNumber numberWithInt:i];
                NSString *str = [NSString stringWithFormat:@"%d ", i];
                [NSString stringWithFormat:@"%@%@", num, str];
                
                if (i % 3 == 0) {
                    NSString *str = [NSString stringWithFormat:@"%f", ZD_MemoryUsage()];
                    NSLog(@"   %@", str);
                }
            }
        }
    });
    
    dispatch_sync(zdQueue, ^{
        NSLog(@"Over");
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
