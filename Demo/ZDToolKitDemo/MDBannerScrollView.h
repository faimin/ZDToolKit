//
//  MMScrollView.h
//  MMUIDemo
//
//  Created by Zero.D.Saber on 2017/5/5.
//  Copyright © 2017年 MOMO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MDBannerScrollView;
@protocol MDBannerScrollViewDelegate <NSObject>
@optional
- (void)scrollView:(MDBannerScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;

- (void)scrollView:(MDBannerScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;

@end

@interface MDBannerScrollView : UIView

@property (nonatomic, assign) NSTimeInterval interval;              ///< 定时器的间隔时间,默认2.5s
@property (nonatomic, strong) NSArray<NSString *> *imageURLStrings; ///< 图片地址数组

+ (instancetype)scrollViewWithFrame:(CGRect)frame delegate:(nullable id<MDBannerScrollViewDelegate>)delegate placeholderImage:(nullable NSString *)placeholderImageName;

- (void)pauseTimer;
- (void)resumeTimer;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
