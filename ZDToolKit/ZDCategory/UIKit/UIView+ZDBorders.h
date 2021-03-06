//
//  UIView+RZBorders.h
//  Raizlabs
//
//  Created by Nick Donaldson on 10/30/13.

// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZDViewBorderMask)
{
    ZDViewBorderNone    = 0,
    ZDViewBorderLeft    = (1 << 0),
    ZDViewBorderBottom  = (1 << 1),
    ZDViewBorderRight   = (1 << 2),
    ZDViewBorderTop     = (1 << 3),
    ZDViewBorderAll     = ZDViewBorderLeft | ZDViewBorderBottom | ZDViewBorderRight | ZDViewBorderTop
};

// Adds a generated border image view as the highest z-ordered subview of the target view (above all other views).
@interface UIView (ZDBorders)

- (void)zd_addBordersWithCornerRadius:(CGFloat)radius width:(CGFloat)borderWidth color:(UIColor*)color;
- (void)zd_addBordersWithMask:(ZDViewBorderMask)mask width:(CGFloat)borderWidth color:(UIColor*)color;
- (void)zd_removeBorders;

@end

NS_ASSUME_NONNULL_END
