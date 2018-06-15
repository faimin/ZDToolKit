//
//  ZDRootViewController.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2018/6/15.
//  Copyright © 2018年 Zero.D.Saber. All rights reserved.
//

#import "ZDRootViewController.h"
#import <objc/runtime.h>

@interface ZDRootViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *dataSource;
@end

@implementation ZDRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)setup {
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    
}

- (void)setupData {
    self.dataSource = @[
                        @"ViewController", @"TwoViewController", @"ThreeController",
                        @"ZDHookBlockController"
                        ];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *className = self.dataSource[indexPath.row];
    __kindof UIViewController *vc;
    if (indexPath.row < 3) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        vc = [sb instantiateViewControllerWithIdentifier:className];
    } else {
        Class aClass = objc_lookUpClass(className.UTF8String);
        vc = [aClass new];
    }
    [self.navigationController showViewController:vc sender:nil];
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
