//
//  ZDFunction.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import "ZDFunction.h"
#import <ImageIO/ImageIO.h>

//MARK:gif图片
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

//MARK:字符串
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


NSString *UrlEncodedString(NSString *sourceText)
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)sourceText ,NULL ,CFSTR("!*'();:@&=+$,/?%#[]") ,kCFStringEncodingUTF8));
    return result;
}


//MARK: Runtime
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





























