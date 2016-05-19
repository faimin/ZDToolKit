//
//  ZDLabel.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ZDLabel.h"
#import <CoreText/CoreText.h>

@interface ZDLabel ()
{
    CGFloat _iLineSpacing;
    CALayer* _underlindeLayer;
    CGRect _textRect;
    NSMutableDictionary *_targetActions;
    CTFrameRef _ctFrameRef;
}
@end

@implementation ZDLabel

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
            [tartget performSelector:selector withObject:self];
        }
    }
}

@end
