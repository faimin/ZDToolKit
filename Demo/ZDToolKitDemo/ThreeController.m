//
//  ThreeController.m
//  ZDToolKitDemo
//
//  Created by Zero.D.Saber on 2017/10/7.
//  Copyright © 2017年 Zero.D.Saber. All rights reserved.
//

#import "ThreeController.h"
#import "ZDBannerScrollView.h"
#import <ZDToolKit/UIView+ZDUtility.h>
#import <ZDToolKit/ZDFunction.h>

@interface ThreeController () <ZDBannerScrollViewDelegate>
@property (nonatomic, strong) NSArray<NSString *> *dataSource;
@end

@implementation ThreeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = ZD_RandomColor();
    self.navigationItem.title = NSStringFromClass(self.class);
    
    ZDBannerScrollView *banner = [ZDBannerScrollView scrollViewWithFrame:(CGRect){CGPointZero, self.view.width, self.view.width/4.0*3.0} delegate:self placeholderImage:nil];
    banner.imageURLStrings = self.dataSource;
    [self.view addSubview:banner];
}

#pragma mark -

- (void)scrollView:(ZDBannerScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
}

#pragma mark - Getter

- (NSArray<NSString *> *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507351086234&di=ae9d3cadcfc61324c0ce7c5bd321786d&imgtype=0&src=http%3A%2F%2Fc.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F060828381f30e9245208984d4c086e061d95f71a.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507351086233&di=52989259afeea36d5db867c8ad30041c&imgtype=0&src=http%3A%2F%2Fa.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F4b90f603738da977f14989f6b551f8198718e38d.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507351086233&di=7a4a2377d7bb5ba6351ac2169ba56c8b&imgtype=0&src=http%3A%2F%2Fimg2.niutuku.com%2Fdesk%2Fanime%2F0126%2F0126-6403.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507351086233&di=c1960b0f0e395df9d9a5ed7acf9edbbd&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F8%2F5444c4a24d97f.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507351086232&di=2eac74aedcf9dfdb079f87398b8edfdb&imgtype=0&src=http%3A%2F%2Fwww.pp3.cn%2Fuploads%2F201701%2F2017021708.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507351086232&di=8a6498b6f6e188e1be4cd3f74f255fe3&imgtype=0&src=http%3A%2F%2Fbizhi.zhuoku.com%2Fbizhi2008%2F1226%2FAnime%2FAnime_girl12.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1507351086229&di=71e61cf2e74253c621005cf6638c4f9a&imgtype=0&src=http%3A%2F%2Fpic41.nipic.com%2F20140503%2F18641501_163214498000_2.jpg",
                        ];
    }
    return _dataSource;
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
