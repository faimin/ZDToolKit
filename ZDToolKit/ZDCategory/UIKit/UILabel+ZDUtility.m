//
//  UILabel+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/3/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UILabel+ZDUtility.h"
#import <CoreText/CoreText.h>

@implementation UILabel (ZDUtility)

- (CGSize)zd_contentSize {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.alignment = self.textAlignment;
    
    NSDictionary * attributes = @{NSFontAttributeName : self.font, NSParagraphStyleAttributeName : paragraphStyle};
    
    CGSize contentSize = [self.text boundingRectWithSize:self.frame.size
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:attributes
                                                 context:nil].size;
    return contentSize;
}

// http://stackoverflow.com/questions/34867231/issue-get-lines-array-of-string-inn-label
- (__kindof NSArray *)zd_linesArrayOfString {
    NSString *text = self.text;
    UIFont *font = self.font;
    CGRect rect = self.frame;
    
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName
                   value:(__bridge  id)myFont
                   range:NSMakeRange(0, attStr.length)];
    CFRelease(myFont);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc] init];
    for (id line in lines) {
        CTLineRef lineRef = (__bridge CTLineRef)line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0]));
        [linesArray addObject:lineString];
    }
    
    CGPathRelease(path);
    CFRelease(frame);
    CFRelease(frameSetter);
    return linesArray;
}

@end
