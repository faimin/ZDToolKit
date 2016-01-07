//
//  UIView+Utility.h
//  ZDUtility
//
//  Created by 符现超 on 15/8/4.
//  Copyright (c) 2015年 Fate.D.Bourne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZDUtility)

//MARK: Controller
@property (nonatomic, strong, readonly) UIViewController *viewController;
@property (nonatomic, strong, readonly) UIViewController *topMostController;

//MARK:Method

- (void)eachSubview:(void (^)(UIView *subview))block;

@end

#pragma mark -
///========================================================================

@interface UIView (Frame)

//MARK: Frame
// Frame
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

// Frame Origin
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

// Frame Size
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

// Frame Borders
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;

// Center Point
#if !IS_IOS_DEVICE
@property (nonatomic) CGPoint center;
#endif
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

// Middle Point
@property (nonatomic, readonly) CGPoint middlePoint;
@property (nonatomic, readonly) CGFloat middleX;
@property (nonatomic, readonly) CGFloat middleY;

// Layer
@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end









