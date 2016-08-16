//
//  ZDLabel.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDLabel.h"
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN
@interface ZDLabel ()
{
//    CGFloat _iLineSpacing;
//    CALayer *_underlindeLayer;
//    CGRect _textRect;
//    NSMutableDictionary *_targetActions;
//    CTFrameRef _ctFrameRef;
}
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSInvocation *invocation;
@property (nonatomic, strong) NSArray *params;
@property (nonatomic, strong) NSArray<NSValue *> *ranges;
@end

@implementation ZDLabel

#pragma mark - TextKit
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textContainer.size = self.bounds.size;
}

- (void)setup {
    self.userInteractionEnabled = YES;
    
    self.textStorage = [[NSTextStorage alloc] init];
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.textContainer = [[NSTextContainer alloc] init];
    
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
}

- (void)setText:(nullable NSString *)text {
    if (text) {
        [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:text]];
        [self setNeedsDisplay];
    }
}

- (void)setAttributedText:(nullable NSAttributedString *)attributedText {
    if (attributedText) {
        [self.textStorage setAttributedString:attributedText];
        [self setNeedsDisplay];
    }
}

- (void)addTarget:(id)target action:(SEL)action params:(nullable NSArray *)params ranges:(NSArray<NSValue *> *)ranges {
    if (!target || NULL == action) return;
    NSUInteger paramsCount = MAX([NSStringFromSelector(action) componentsSeparatedByString:@":"].count - 1, 0);
    NSAssert(paramsCount == params.count, @"参数个数不符");
    self.invocation = ({
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:action]];
        [invocation setTarget:target];
        [invocation setSelector:action];
        [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [invocation setArgument:&obj atIndex:idx + 2];
        }];
        [invocation retainArguments];
        invocation;
    });
    self.ranges = ranges;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    //获取点击字符的索引位置
    NSUInteger index = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer];
    for (NSValue *rangeValue in self.ranges) {
        NSRange range = rangeValue.rangeValue;
        // 索引是否在要响应的range里
        BOOL isInRange = NSLocationInRange(index, range);
        if (isInRange) {
            [self.invocation invoke];
            //( (void (*)(id, SEL))(void *) objc_msgSend)(self.target, self->_selector);
            break;
        }
    }
}

/*
/// CoreText实现图文混排之点击事件：http://www.jianshu.com/p/51c47329203e
- (void)setTarget:(id)target action:(SEL)selector forRange:(NSRange)range
{
    if (nil == target || NULL == selector) {
        return;
    }
    
    NSValue *value = [NSValue valueWithRange:range];
    if (nil == _targetActions) {
        _targetActions = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    NSDictionary *targetActionDict = [_targetActions objectForKey:value];
    if (targetActionDict) {
        [targetActionDict setValue:target forKey:@"target"];
        [targetActionDict setValue:NSStringFromSelector(selector) forKey:@"action"];
    }
    else{
        targetActionDict = @{@"target":target,@"action":NSStringFromSelector(selector)};
        [_targetActions setObject:targetActionDict forKey:value];
    }
}

- (NSInteger)indexOfTouchLocation:(CGPoint)location
{
    if (NULL == _ctFrameRef) {
        NSAttributedString *content = self.attributedText;
        CTFramesetterRef framesetter =  CTFramesetterCreateWithAttributedString((__bridge_retained CFAttributedStringRef)content);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, _textRect);
        //创建CTFrame
        _ctFrameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, content.length), path, NULL);
        CFRelease(framesetter);
        CGPathRelease(path);
    }
    
    CFArrayRef lines = CTFrameGetLines(_ctFrameRef);
    CGPoint origins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(_ctFrameRef, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    CGPathRef path = CTFrameGetPath(_ctFrameRef);
    CGRect rect = CGPathGetBoundingBox(path);
    for (int i= 0; i < CFArrayGetCount(lines); i++){
        CGPoint origin = origins[i];
        CGFloat y = rect.origin.y + rect.size.height - origin.y;
        if ((location.y >= y - _iLineSpacing/2.0f) && (location.y <= y + self.font.lineHeight + _iLineSpacing/2.0f) && (location.x >= origin.x)){
            line = CFArrayGetValueAtIndex(lines, i);
            lineOrigin = origin;
            break;
        }
    }
    
    location.x -= lineOrigin.x;
    CFIndex index = CTLineGetStringIndexForPosition(line, location);
    return index;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    NSInteger index = [self indexOfTouchLocation:location];
    if (index != NSNotFound) {
        NSDictionary *targetAction = nil;
        NSArray *targetActionsKeys = [_targetActions allKeys];
        for (NSValue *value in targetActionsKeys) {
            NSRange range = [value rangeValue];
            if (range.location < index && index < range.location + range.length) {
                targetAction = [_targetActions objectForKey:value];
                break;
            }
        }
        
        if (targetAction) {
            id tartget = [targetAction objectForKey:@"target"];
            SEL selector = NSSelectorFromString([targetAction objectForKey:@"action"]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [tartget performSelector:selector withObject:self];
#pragma clang diagnostic pop
        }
    }
}
*/

#pragma mark - Change text frame
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    // 1.先通过添加edge后计算出此时的rect
    UIEdgeInsets edgeInsets = self.zd_edgeInsets;
    CGRect newRect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, edgeInsets) limitedToNumberOfLines:numberOfLines];
    // 2.然后再去掉edge
    newRect.origin.x -= edgeInsets.left;
    newRect.origin.y -= edgeInsets.top;
    newRect.size.width += (edgeInsets.left + edgeInsets.right);
    newRect.size.height += (edgeInsets.top + edgeInsets.bottom);
    return newRect;
}

// 绘制文本
- (void)drawTextInRect:(CGRect)rect {
    // 3.再用通过textRectForBounds:方法计算出的rect，经过edge处理后获取到实际的rect，然后绘制到这个实际的rect上
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.zd_edgeInsets)];
    
    //===================================================
    // textKit重绘文字
    NSRange range = NSMakeRange(0, self.textStorage.length);
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
}

@end
NS_ASSUME_NONNULL_END
