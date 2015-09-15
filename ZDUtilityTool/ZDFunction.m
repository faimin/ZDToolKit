//
//  ZDFunction.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import "ZDFunction.h"
#import <ImageIO/ImageIO.h>

#pragma mark - Gif 图片
#pragma mark -
// returns the frame duration for a given image in 1/100th seconds
// source: http://stackoverflow.com/questions/16964366/delaytime-or-unclampeddelaytime-for-gifs
static NSUInteger ZDAnimatedGIFFrameDurationForImageAtIndex(CGImageSourceRef source, NSUInteger index)
{
    NSUInteger frameDuration = 10;
    
    NSDictionary *frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,index,nil));
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if(delayTimeUnclampedProp)
    {
        frameDuration = [delayTimeUnclampedProp floatValue]*100;
    }
    else
    {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if(delayTimeProp)
        {
            frameDuration = [delayTimeProp floatValue]*100;
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 1)
    {
        frameDuration = 10;
    }
    
    return frameDuration;
}

// returns the great common factor of two numbers
static NSUInteger ZDAnimatedGIFGreatestCommonFactor(NSUInteger num1, NSUInteger num2)
{
    NSUInteger t, remainder;
    
    if (num1 < num2)
    {
        t = num1;
        num1 = num2;
        num2 = t;
    }
    
    remainder = num1 % num2;
    
    if (!remainder)
    {
        return num2;
    }
    else
    {
        return ZDAnimatedGIFGreatestCommonFactor(num2, remainder);
    }
}

static UIImage *ZDAnimatedGIFFromImageSource(CGImageSourceRef source)
{
    size_t const numImages = CGImageSourceGetCount(source);
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numImages];
    
    // determine gretest common factor of all image durations
    NSUInteger greatestCommonFactor = ZDAnimatedGIFFrameDurationForImageAtIndex(source, 0);
    
    for (NSUInteger i=1; i<numImages; i++)
    {
        NSUInteger centiSecs = ZDAnimatedGIFFrameDurationForImageAtIndex(source, i);
        greatestCommonFactor = ZDAnimatedGIFGreatestCommonFactor(greatestCommonFactor, centiSecs);
    }
    
    // build array of images, duplicating as necessary
    for (NSUInteger i=0; i<numImages; i++)
    {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        UIImage *frame = [UIImage imageWithCGImage:cgImage];
        
        NSUInteger centiSecs = ZDAnimatedGIFFrameDurationForImageAtIndex(source, i);
        NSUInteger repeat = centiSecs/greatestCommonFactor;
        
        for (NSUInteger j=0; j<repeat; j++)
        {
            [frames addObject:frame];
        }
        
        CGImageRelease(cgImage);
    }
    
    // create animated image from the array
    NSTimeInterval totalDuration = [frames count] * greatestCommonFactor / 100.0;
    return [UIImage animatedImageWithImages:frames duration:totalDuration];
}

UIImage *ZDAnimatedGIFFromFile(NSString *path)
{
    NSURL *URL = [NSURL fileURLWithPath:path];
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)(URL), NULL);
    UIImage *image = ZDAnimatedGIFFromImageSource(source);
    CFRelease(source);
    
    return image;
}

UIImage *ZDAnimatedGIFFromData(NSData *data)
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    UIImage *image = ZDAnimatedGIFFromImageSource(source);
    CFRelease(source);
    
    return image;
}

#pragma mark - 字符串
#pragma mark -
///设置文字行间距
NSMutableAttributedString* SetAttributeString(NSString *string, CGFloat lineSpace, CGFloat fontSize)
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    NSMutableAttributedString *mutStr       = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle}];
    return mutStr;
}

///筛选设置文字color
NSMutableAttributedString* SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor)
{
    NSRange                    range           = [orignString rangeOfString:filterString];
    NSMutableAttributedString *mutAttributeStr = [[NSMutableAttributedString alloc] initWithString:orignString];
    [mutAttributeStr addAttribute:NSForegroundColorAttributeName value:filterColor range:range];
    return mutAttributeStr;
}


NSString *URLEncodedString(NSString *sourceText)
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)sourceText ,NULL ,CFSTR("!*'();:@&=+$,/?%#[]") ,kCFStringEncodingUTF8));
    return result;
}

/// 计算文字高度
CGFloat HeightOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth)
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([sourceString respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [sourceString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    }
    else
    {
        textSize = [sourceString sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [sourceString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.height);
}

/// 计算文字宽度
CGFloat WidthOfString(NSString *sourceString, UIFont *font, CGFloat maxHeight)
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([sourceString respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [sourceString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    }
    else
    {
        textSize = [sourceString sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [sourceString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.width);
}

CGSize SizeOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth, CGFloat maxHeight)
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([sourceString respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        CGSize needSize = maxWidth ? CGSizeMake(maxWidth, CGFLOAT_MAX) : CGSizeMake(CGFLOAT_MAX, maxHeight);
        textSize = [sourceString boundingRectWithSize:needSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        CGSize needSize = maxWidth ? CGSizeMake(maxWidth, CGFLOAT_MAX) : CGSizeMake(CGFLOAT_MAX, maxHeight);
        textSize = [sourceString sizeWithFont:textFont
                    constrainedToSize:needSize
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [sourceString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}


NSString *ReverseString(NSString *sourceString)
{
    NSMutableString* reverseString = [[NSMutableString alloc] init];
    NSInteger charIndex = [sourceString length];
    while (charIndex > 0)
    {
        charIndex --;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reverseString appendString:[sourceString substringWithRange:subStrRange]];
    }
    return reverseString;
}


#pragma mark - Device
#pragma mark -
BOOL iPhone4s(void)
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.height == 480)
    {
        return YES;
    }
    return NO;
}

BOOL iPhone5s(void)
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.height == 568)
    {
        return YES;
    }
    return NO;
}

BOOL iPhone6(void)
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.width == 375)
    {
        return YES;
    }
    return NO;
}

BOOL iPhone6p(void)
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.width == 414)
    {
        return YES;
    }
    return NO;
}


#pragma mark - Runtime
#pragma mark -
void PrintObjectMethods() {
    unsigned int count = 0;
    Method *methods = class_copyMethodList([NSObject class],
                                           &count);
    for (unsigned int i = 0; i < count; ++i) {
        SEL sel = method_getName(methods[i]);
        const char *name = sel_getName(sel);
        printf("%s\n", name);
    }
    free(methods);
}


void class_swizzleSelector(Class class, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    if(class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}


























