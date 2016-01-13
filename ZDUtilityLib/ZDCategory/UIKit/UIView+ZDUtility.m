//
//  UIView+Utility.m
//  ZDUtility
//
//  Created by 符现超 on 15/8/4.
//  Copyright (c) 2015年 Fate.D.Bourne. All rights reserved.
//

#import "UIView+ZDUtility.h"
#import <objc/runtime.h>

static const void* CornerRadiusKey = &CornerRadiusKey;

@implementation UIView (ZDUtility)

//MARK: Controller
- (UIViewController *)viewController
{
	UIResponder *nextResponder = self;

	do {
		nextResponder = [nextResponder nextResponder];

		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController *)nextResponder;
		}
	} while (nextResponder != nil);

	return nil;
}

- (UIViewController *)topMostController
{
	NSMutableArray *controllersHierarchy = [[NSMutableArray alloc] init];
	UIViewController *topController = self.window.rootViewController;

	if (topController) {
		[controllersHierarchy addObject:topController];
	}

	while ([topController presentedViewController]) {
		topController = [topController presentedViewController];
		[controllersHierarchy addObject:topController];
	}

	UIResponder *matchController = [self viewController];

	while (matchController != nil && [controllersHierarchy containsObject:matchController] == NO) {
		do {
			matchController = [matchController nextResponder];
		} while (matchController != nil && [matchController isKindOfClass:[UIViewController class]] == NO);
	}

	return (UIViewController *)matchController;
}

//MARK: Method

- (void)eachSubview:(void (^)(UIView *subview))block
{
	NSParameterAssert(block != nil);

	[self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		block(subview);
	}];
}

@end

#pragma mark -
///======================================================================

@implementation UIView (Frame)

#pragma mark Frame

- (CGPoint)origin
{
	return self.frame.origin;
}

- (void)setOrigin:(CGPoint)newOrigin
{
	CGRect newFrame = self.frame;

	newFrame.origin = newOrigin;
	self.frame = newFrame;
}

- (CGSize)size
{
	return self.frame.size;
}

- (void)setSize:(CGSize)newSize
{
	CGRect newFrame = self.frame;

	newFrame.size = newSize;
	self.frame = newFrame;
}

#pragma mark Frame Origin

- (CGFloat)x
{
	return self.frame.origin.x;
}

- (void)setX:(CGFloat)newX
{
	CGRect newFrame = self.frame;

	newFrame.origin.x = newX;
	self.frame = newFrame;
}

- (CGFloat)y
{
	return self.frame.origin.y;
}

- (void)setY:(CGFloat)newY
{
	CGRect newFrame = self.frame;

	newFrame.origin.y = newY;
	self.frame = newFrame;
}

#pragma mark Frame Size

- (CGFloat)height
{
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)newHeight
{
	CGRect newFrame = self.frame;

	newFrame.size.height = newHeight;
	self.frame = newFrame;
}

- (CGFloat)width
{
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)newWidth
{
	CGRect newFrame = self.frame;

	newFrame.size.width = newWidth;
	self.frame = newFrame;
}

#pragma mark Frame Borders

- (CGFloat)left
{
	return self.x;
}

- (void)setLeft:(CGFloat)left
{
	self.x = left;
}

- (CGFloat)right
{
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
	self.x = right - self.width;
}

- (CGFloat)top
{
	return self.y;
}

- (void)setTop:(CGFloat)top
{
	self.y = top;
}

- (CGFloat)bottom
{
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
	self.y = bottom - self.height;
}

#pragma mark Center Point

#if !IS_IOS_DEVICE
- (CGPoint)center
{
	return CGPointMake(self.left + self.middleX, self.top + self.middleY);
}

- (void)setCenter:(CGPoint)newCenter
{
	self.left = newCenter.x - self.middleX;
	self.top = newCenter.y - self.middleY;
}
#endif

- (CGFloat)centerX
{
	return self.center.x;
}

- (void)setCenterX:(CGFloat)newCenterX
{
	self.center = CGPointMake(newCenterX, self.center.y);
}

- (CGFloat)centerY
{
	return self.center.y;
}

- (void)setCenterY:(CGFloat)newCenterY
{
	self.center = CGPointMake(self.center.x, newCenterY);
}

#pragma mark Middle Point

- (CGPoint)middlePoint
{
	return CGPointMake(self.middleX, self.middleY);
}

- (CGFloat)middleX
{
	return self.width / 2;
}

- (CGFloat)middleY
{
	return self.height / 2;
}

#pragma mark Layer
- (void)setCornerRadius:(CGFloat)cornerRadius
{
    objc_setAssociatedObject(self, CornerRadiusKey, @(cornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    [maskPath addClip];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
}

- (CGFloat)cornerRadius
{
    return [objc_getAssociatedObject(self, CornerRadiusKey) integerValue];
}


@end
