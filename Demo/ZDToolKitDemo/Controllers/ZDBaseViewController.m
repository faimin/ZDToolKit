//
//  ZDBaseViewController.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/6/15.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import "ZDBaseViewController.h"
#import <ZDToolKit/ZDFunction.h>

@interface ZDBaseViewController ()

@end

@implementation ZDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ZD_RandomColor();
    [self setup];
}

- (void)setup {
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    
}

- (void)setupData {
    
}

#pragma mark -

- (void)didReceiveMemoryWarning {
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

@end
