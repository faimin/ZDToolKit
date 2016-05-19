//
//  UIView+Utility.m
//  ZDUtility
//
//  Created by 符现超 on 15/8/4.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import "UIView+ZDUtility.h"
#import <objc/runtime.h>

static const void* CornerRadiusKey = &CornerRadiusKey;
static const void* TouchExtendInsetKey = &TouchExtendInsetKey;

static void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

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

- (void)removeAllSubviews
{
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}

- (UIImage *)snapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates
{
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (NSData *)snapshotPDF
{
    CGRect bounds = self.bounds;
    NSMutableData* data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

- (void)shake:(CGFloat)range
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.5;
    animation.values = @[@(-range), @(range), @(-range/2), @(range/2), @(-range/5), @(range/5), @(0)];
    animation.repeatCount = CGFLOAT_MAX;
    [self.layer addAnimation:animation forKey:@"shake"];
}

#pragma mark - TouchExtendInset
+ (void)load
{
    Swizzle(self, @selector(pointInside:withEvent:), @selector(myPointInside:withEvent:));
}

- (BOOL)myPointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.touchExtendInset, UIEdgeInsetsZero) || self.hidden ||
        ([self isKindOfClass:UIControl.class] && !((UIControl *)self).enabled)) {
        return [self myPointInside:point withEvent:event]; // original implementation
    }
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.touchExtendInset);
    hitFrame.size.width = MAX(hitFrame.size.width, 0); // don't allow negative sizes
    hitFrame.size.height = MAX(hitFrame.size.height, 0);
    return CGRectContainsPoint(hitFrame, point);
}

- (void)setTouchExtendInset:(UIEdgeInsets)touchExtendInset
{
    UIEdgeInsets zdTouchExtendInset = UIEdgeInsetsMake(-touchExtendInset.top, -touchExtendInset.left, -touchExtendInset.bottom, -touchExtendInset.right);
    objc_setAssociatedObject(self, TouchExtendInsetKey, [NSValue valueWithUIEdgeInsets:zdTouchExtendInset], OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)touchExtendInset
{
    return [objc_getAssociatedObject(self, TouchExtendInsetKey) UIEdgeInsetsValue];
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

#pragma mark EdgeInset
+ (void)load
{
    Swizzle(self, @selector(pointInside:withEvent:), @selector(myPointInside:withEvent:));
}

- (BOOL)myPointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.touchExtendInset, UIEdgeInsetsZero) || self.hidden ||
        ([self isKindOfClass:[UIControl class]] && !((UIControl *)self).enabled)) {
        return [self myPointInside:point withEvent:event];
    }
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.touchExtendInset);
    hitFrame.size.width = MAX(hitFrame.size.width, 0); // don't allow negative sizes
    hitFrame.size.height = MAX(hitFrame.size.height, 0);
    return CGRectContainsPoint(hitFrame, point);
}

- (void)setTouchExtendInset:(UIEdgeInsets)touchExtendInset
{
    objc_setAssociatedObject(self, TouchExtendInsetKey, [NSValue valueWithUIEdgeInsets:touchExtendInset], OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)touchExtendInset
{
    return [objc_getAssociatedObject(self, TouchExtendInsetKey) UIEdgeInsetsValue];
}

#pragma mark Layer
- (void)setCornerRadius:(CGFloat)cornerRadius
{
    objc_setAssociatedObject(self, CornerRadiusKey, @(cornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //下面的方法只有获取到真实的bounds才有效
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        cornerRadius:cornerRadius];
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


@implementation UIImage (CornerRadius)

- (UIImage *)imageWithCornerRadius:(CGFloat)radius
{
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //clip image
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.0f, radius);
    CGContextAddLineToPoint(context, 0.0f, self.size.height - radius);
    CGContextAddArc(context, radius, self.size.height - radius, radius, M_PI, M_PI / 2.0f, 1);
    CGContextAddLineToPoint(context, self.size.width - radius, self.size.height);
    CGContextAddArc(context, self.size.width - radius, self.size.height - radius, radius, M_PI / 2.0f, 0.0f, 1);
    CGContextAddLineToPoint(context, self.size.width, radius);
    CGContextAddArc(context, self.size.width - radius, radius, radius, 0.0f, -M_PI / 2.0f, 1);
    CGContextAddLineToPoint(context, radius, 0.0f);
    CGContextAddArc(context, radius, radius, radius, -M_PI / 2.0f, M_PI, 1);
    CGContextClip(context);
    
    //draw image
    [self drawAtPoint:CGPointZero];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

@end

/**
 
 - (UIImage *)drawImageWithBorderWidth:(CGFloat)borderWidth
 radius:(CGFloat)radius
 borderColor:(UIColor *)borderColor
 backgroundColor:(UIColor *)backgroundColor
 {
 CGFloat halfBorderWidth = borderWidth / 2.0;
 
 UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 CGContextSetLineWidth(context, borderWidth);
 CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
 CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
 
 CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
 CGContextMoveToPoint(context, width - halfBorderWidth, radius + halfBorderWidth);  // 开始坐标右边开始
 CGContextAddArcToPoint(context, width - halfBorderWidth, height - halfBorderWidth, width - radius - halfBorderWidth, height - halfBorderWidth, radius);  // 右下角角度
 CGContextAddArcToPoint(context, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - radius - halfBorderWidth, radius); // 左下角角度
 CGContextAddArcToPoint(context, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius); // 左上角
 CGContextAddArcToPoint(context, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, radius + halfBorderWidth, radius); // 右上角
 
 CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
 UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return output;
 }

 */
