//
//  ZDFunction.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import "ZDFunction.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import <stdlib.h>

#pragma mark - Gif Image
#pragma mark -
// returns the frame duration for a given image in 1/100th seconds
// source: http://stackoverflow.com/questions/16964366/delaytime-or-unclampeddelaytime-for-gifs
static NSUInteger ZDAnimatedGIFFrameDurationForImageAtIndex(CGImageSourceRef source, NSUInteger index)
{
	NSUInteger frameDuration = 10;

	NSDictionary *frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, index, nil));
	NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];

	NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];

	if (delayTimeUnclampedProp) {
		frameDuration = [delayTimeUnclampedProp floatValue] * 100;
	}
	else {
		NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];

		if (delayTimeProp) {
			frameDuration = [delayTimeProp floatValue] * 100;
		}
	}

	// Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
	// We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
	// a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
	// for more information.

	if (frameDuration < 1) {
		frameDuration = 10;
	}

	return frameDuration;
}

// returns the great common factor of two numbers
static NSUInteger ZDAnimatedGIFGreatestCommonFactor(NSUInteger num1, NSUInteger num2)
{
	NSUInteger t, remainder;

	if (num1 < num2) {
		t = num1;
		num1 = num2;
		num2 = t;
	}

	remainder = num1 % num2;

	if (!remainder) {
		return num2;
	}
	else {
		return ZDAnimatedGIFGreatestCommonFactor(num2, remainder);
	}
}

static UIImage *ZDAnimatedGIFFromImageSource(CGImageSourceRef source)
{
	size_t const numImages = CGImageSourceGetCount(source);

	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numImages];

	// determine gretest common factor of all image durations
	NSUInteger greatestCommonFactor = ZDAnimatedGIFFrameDurationForImageAtIndex(source, 0);

	for (NSUInteger i = 1; i < numImages; i++) {
		NSUInteger centiSecs = ZDAnimatedGIFFrameDurationForImageAtIndex(source, i);
		greatestCommonFactor = ZDAnimatedGIFGreatestCommonFactor(greatestCommonFactor, centiSecs);
	}

	// build array of images, duplicating as necessary
	for (NSUInteger i = 0; i < numImages; i++) {
		CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
		UIImage *frame = [UIImage imageWithCGImage:cgImage];

		NSUInteger centiSecs = ZDAnimatedGIFFrameDurationForImageAtIndex(source, i);
		NSUInteger repeat = centiSecs / greatestCommonFactor;

		for (NSUInteger j = 0; j < repeat; j++) {
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

UIImage *tintedImageWithColor(UIColor *tintColor, UIImage *image) {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // draw tint color, preserving alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}

UIImage *thumbnailImageFromURl (NSURL *url, int imageSize)
{
     CGImageRef myThumbnailImage = NULL;
     CGImageSourceRef myImageSource;
     CFDictionaryRef myOptions = NULL;
     CFStringRef myKeys[3];
     CFTypeRef myValues[3];
     CFNumberRef thumbnailSize;
    
     // Create an image source from NSData; no options.
     myImageSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
     // Make sure the image source exists before continuing.
     if (myImageSource == NULL){
         fprintf(stderr, "Image source is NULL.");
         return NULL;
    }
    
     // Package the integer as a CFNumber object. Using CFTypes allows you
     // to more easily create the options dictionary later.
    imageSize *= [UIScreen mainScreen].scale;
     thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
     // Set up the thumbnail options.
     myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
     myValues[0] = (CFTypeRef)kCFBooleanTrue;
     myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
     myValues[1] = (CFTypeRef)kCFBooleanTrue;
     myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
     myValues[2] = (CFTypeRef)thumbnailSize;
    
     myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                        (const void **) myValues, 3,
                                        &kCFTypeDictionaryKeyCallBacks,
                                        &kCFTypeDictionaryValueCallBacks);
    
     // Create the thumbnail image using the specified options.
     myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
                                                                0,
                                                                myOptions);
     // Release the options dictionary and the image source
     // when you no longer need them.
     CFRelease(thumbnailSize);
     CFRelease(myOptions);
     CFRelease(myImageSource);
    
     // Make sure the thumbnail image exists before continuing.
     if (myThumbnailImage == NULL) {
         fprintf(stderr, "Thumbnail image not created from image source.");
         return NULL;
    }
    
     UIImage *thumbnail = [UIImage imageWithCGImage:myThumbnailImage];
     CFRelease(myThumbnailImage);
    
     return thumbnail;
}

NSString *typeForImageData(NSData *data)
{
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return @"未知格式";
}

NSString *typeForData(NSData *data)
{
    if (data.length < 2) {
        return @"NOT FILE";
    }

    int char1 = 0, char2 = 0 ; //必须这样初始化
    [data getBytes:&char1 range:NSMakeRange(0, 1)];
    [data getBytes:&char2 range:NSMakeRange(1, 1)];
    NSString *numStr = [NSString stringWithFormat:@"%i%i", char1, char2];
    NSInteger dataFormatNumber = [numStr integerValue];
    NSString *dataFormatString = @"";
    switch (dataFormatNumber) {
        case 255216:
            dataFormatString = @"jpg";
            break;
        case 13780:
            dataFormatString = @"png";
            break;
        case 7173:
            dataFormatString = @"gif";
            break;
        case 6677:
            dataFormatString = @"bmp";
            break;
        case 6787:
            dataFormatString = @"swf";
            break;
        case 7790:
            dataFormatString = @"exe/dll";
            break;
        case 8297:
            dataFormatString = @"rar";
            break;
        case 8075:
            dataFormatString = @"zip";
            break;
        case 55122:
            dataFormatString = @"7z";
            break;
        case 6063:
            dataFormatString = @"xml";
            break;
        case 6033:
            dataFormatString = @"html";
            break;
        case 239187:
            dataFormatString = @"aspx";
            break;
        case 117115:
            dataFormatString = @"cs";
            break;
        case 119105:
            dataFormatString = @"js";
            break;
        case 102100:
            dataFormatString = @"txt";
            break;
        case 255254:
            dataFormatString = @"sql";
            break;
        default:
            dataFormatString = @"未知格式";
            break;
    }
    return dataFormatString;
}

#pragma mark - String
#pragma mark -
///设置文字行间距
NSMutableAttributedString *SetAttributeString(NSString *string, CGFloat lineSpace, CGFloat fontSize)
{
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];

	paragraphStyle.lineSpacing = lineSpace;
	NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName : paragraphStyle}];
	return mutStr;
}

///筛选设置文字color
NSMutableAttributedString *SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor)
{
	NSRange range = [orignString rangeOfString:filterString];
	NSMutableAttributedString *mutAttributeStr = [[NSMutableAttributedString alloc] initWithString:orignString];

	[mutAttributeStr addAttribute:NSForegroundColorAttributeName value:filterColor range:range];
	return mutAttributeStr;
}

NSString *URLEncodedString(NSString *sourceText)
{
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)sourceText, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));

	return result;
}

/// 计算文字高度
CGFloat HeightOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth)
{
    return SizeOfString(sourceString, font, maxWidth, 0).height;
}

/// 计算文字宽度
CGFloat WidthOfString(NSString *sourceString, UIFont *font, CGFloat maxHeight)
{
    return SizeOfString(sourceString, font, 0, maxHeight).width;
}

CGSize SizeOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth, CGFloat maxHeight)
{
    UIFont *textFont = font ? : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize needSize = CGSizeZero;
    if (maxWidth > 0) {
        needSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    } else if (maxHeight > 0) {
        needSize = CGSizeMake(CGFLOAT_MAX, maxHeight);
    }
    CGSize textSize;
    
    if ([sourceString respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [sourceString boundingRectWithSize:needSize
                                              options:(NSStringDrawingUsesLineFragmentOrigin |
                                                       NSStringDrawingTruncatesLastVisibleLine)
                                           attributes:attributes
                                              context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [sourceString sizeWithFont:textFont
                            constrainedToSize:needSize
                                lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

NSString *ReverseString(NSString *sourceString)
{
	NSMutableString *reverseString = [[NSMutableString alloc] init];
	NSInteger charIndex = [sourceString length];

	while (charIndex > 0) {
		charIndex--;
		NSRange subStrRange = NSMakeRange(charIndex, 1);
		[reverseString appendString:[sourceString substringWithRange:subStrRange]];
	}

	return reverseString;
}

BOOL IsEmptyString(NSString *str)
{
    if (!str || str == (id)[NSNull null]) return YES;
    if ([str isKindOfClass:[NSString class]]) {
        return str.length == 0;
    }
    else {
        return YES;
    }
}

#pragma mark - InterfaceOrientation

UIInterfaceOrientation CurrentInterfaceOrientation()
{
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    return orient;
}

BOOL isPortrait()
{
    return UIInterfaceOrientationIsPortrait(CurrentInterfaceOrientation());
}

BOOL isLandscape()
{
    return UIInterfaceOrientationIsLandscape(CurrentInterfaceOrientation());
}

#pragma mark - NSBundle
#pragma mark -

///refer: http://stackoverflow.com/questions/6887464/how-can-i-get-list-of-classes-already-loaded-into-memory-in-specific-bundle-or
NSArray *GetClassNames()
{
    NSMutableArray *classNames = [NSMutableArray array];
    unsigned int count = 0;
    const char** classes = objc_copyClassNamesForImage([[[NSBundle mainBundle] executablePath] UTF8String], &count);
    for (unsigned int i = 0; i<count; i++) {
        NSString* className = [NSString stringWithUTF8String:classes[i]];
        [classNames addObject:className];
    }
    return classNames.copy;
}

#pragma mark - Device
#pragma mark -

CGSize ScreenSize()
{
    return [UIScreen mainScreen].bounds.size;
}

BOOL iPhone4s(void)
{
	if (ScreenSize().height == 480) {
		return YES;
	}
	return NO;
}

BOOL iPhone5s(void)
{
	if (ScreenSize().height == 568) {
		return YES;
	}
	return NO;
}

BOOL iPhone6(void)
{
	if (ScreenSize().width == 375) {
		return YES;
	}
	return NO;
}

BOOL iPhone6p(void)
{
	if (ScreenSize().width == 414) {
		return YES;
	}
	return NO;
}

#pragma mark - Runtime
#pragma mark -
void PrintObjectMethods()
{
	unsigned int count = 0;
	Method *methods = class_copyMethodList([NSObject class], &count);

	for (unsigned int i = 0; i < count; ++i) {
		SEL sel = method_getName(methods[i]);
		const char *name = sel_getName(sel);
		printf("\n方法名:%s\n", name);
	}

	free(methods);
}

void ZD_SwizzleClassSelector(Class aClass, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getClassMethod(aClass, originalSelector);
    Method newMethod = class_getClassMethod(aClass, newSelector);
    method_exchangeImplementations(origMethod, newMethod);
}

void ZD_SwizzleInstanceSelector(Class aClass, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getInstanceMethod(aClass, originalSelector);
    Method newMethod = class_getInstanceMethod(aClass, newSelector);
    
    if (class_addMethod(aClass, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(aClass, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

IMP ZD_SwizzleMethodIMP(Class aClass, SEL originalSel, IMP replacementIMP)
{
    Method origMethod = class_getInstanceMethod(aClass, originalSel);
    
    if (!origMethod) {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), aClass);
        return NULL;
    }
    
    IMP origIMP = method_getImplementation(origMethod);
    
    if(!class_addMethod(aClass, originalSel, replacementIMP,
                        method_getTypeEncoding(origMethod))) {
        method_setImplementation(origMethod, replacementIMP);
    }
    
    return origIMP;
}

// other way implement
BOOL ZD_SwizzleMethodAndStoreIMP(Class aClass, SEL originalSel, IMP replacementIMP, IMP *orignalStoreIMP)
{
    IMP imp = NULL;
    Method method = class_getInstanceMethod(aClass, originalSel);
    
    if (method) {
        const char *type = method_getTypeEncoding(method);
        imp = class_replaceMethod(aClass, originalSel, replacementIMP, type);
        if (!imp) {
            imp = method_getImplementation(method);
        }
    }
    else {
        NSLog(@"original method %@ not found for class %@", NSStringFromSelector(originalSel), aClass);
    }
    
    if (imp && orignalStoreIMP) {
        *orignalStoreIMP = imp;
    }
    
    return (imp != NULL);
}



