//
//  UITextView+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/6.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UITextView+ZDUtility.h"
#import <objc/runtime.h>

static const void *PlaceHolderLabelKey = &PlaceHolderLabelKey;

@implementation UITextView (ZDUtility)

- (NSUInteger)letterCountWithMaxLength:(NSUInteger)maxLength
{
    NSString *toBeString = self.text;
    NSUInteger txtCount = toBeString.length;
    
    UITextRange *selectedRange = [self markedTextRange];
    //获取高亮部分
    UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position) {
        if (toBeString.length > maxLength) {
            self.text = [toBeString substringToIndex:maxLength];
        }
    }
    // 有高亮选择的字符串，去掉高亮的字数
    else {
        NSInteger startOffset = [self offsetFromPosition:self.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [self offsetFromPosition:self.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        // 去掉高亮的字数
        txtCount -= offsetRange.length;
    }
    
    // 超出部分警告和限制
    if (txtCount > maxLength) {
        self.text = [toBeString substringToIndex:maxLength];
        return maxLength;
    }
    return txtCount;
}

- (void)setPlaceHolderLabel:(UILabel *)placeHolderLabel
{
    if (!placeHolderLabel) {
        return;
    }
    [self addSubview:placeHolderLabel];
    [self setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    objc_setAssociatedObject(self, PlaceHolderLabelKey, placeHolderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILabel *)placeHolderLabel
{
    return objc_getAssociatedObject(self, PlaceHolderLabelKey);
}

@end
