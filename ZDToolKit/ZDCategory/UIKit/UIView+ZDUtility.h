//
//  UIView+Utility.h
//  ZDUtility
//
//  Created by 符现超 on 15/8/4.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ZDUtility)

//MARK: Controller
@property (nonatomic, strong, readonly) UIViewController *viewController;
@property (nonatomic, strong, readonly) UIViewController *topMostController;

//MARK: Method
/// Traverse all subviews
- (void)eachSubview:(void (^)(UIView *subview))block;
- (void)removeAllSubviews;

///  Create a snapshot image of the complete view hierarchy.
- (UIImage *)snapshotImage;

/// Create a snapshot image of the complete view hierarchy.
/// @discussion It's faster than "snapshotImage", but may cause screen updates.
/// See -[UIView drawViewHierarchyInRect:afterScreenUpdates:] for more information.
- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

///  Create a snapshot PDF of the complete view hierarchy.
- (NSData *)snapshotPDF;

///  view shake
///  @param range 角度
- (void)shake:(CGFloat)range;

///  计算添加约束后视图的高度
///  @param maxWidth 最大宽度
///  @return 适应的高度
- (CGFloat)calculateDynamicHeightWithMaxWidth:(CGFloat)maxWidth;

/// load view from xib 
+ (instancetype)zd_loadViewFromXib;

@end

#pragma mark -
///====================================================================

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
@property (nonatomic, assign) CGFloat zd_cornerRadius;

/// Extend clickable area, e.g: self.zd_touchExtendInsets = UIEdgeInsetsMake(10, 20, 40, 10);
@property (nonatomic, assign) UIEdgeInsets zd_touchExtendInsets;

@end









