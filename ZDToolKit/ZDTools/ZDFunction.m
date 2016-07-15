//
//  ZDFunction.m
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#import "ZDFunction.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import <stdlib.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <arpa/inet.h>
#import <mach/mach.h>
#import <Accelerate/Accelerate.h>

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

UIImage *TintedImageWithColor(UIColor *tintColor, UIImage *image) {
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

UIImage *ThumbnailImageFromURl(NSURL *url, int imageSize)
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

NSString *TypeForImageData(NSData *data)
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

NSString *TypeForData(NSData *data)
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

UIImage *ZDBlurImageWithBlurPercent(UIImage *image, CGFloat blur)
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if (pixelBuffer == NULL) { NSLog(@"No pixelbuffer"); }
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) { NSLog(@"error from convolution %ld", error); }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

//===============================================================

#pragma mark - UIView
#pragma mark -
/// 画虚线
UIView *ZDCreateDashedLineWithFrame(CGRect lineFrame, int lineLength, int lineSpacing, UIColor *lineColor)
{
    UIView *dashedLine = [[UIView alloc] initWithFrame:lineFrame];
    dashedLine.backgroundColor = [UIColor clearColor];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:dashedLine.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(dashedLine.frame) / 2, CGRectGetHeight(dashedLine.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setStrokeColor:lineColor.CGColor];
    [shapeLayer setLineWidth:CGRectGetHeight(dashedLine.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:@[@(lineLength), @(lineSpacing)]];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(dashedLine.frame), 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    [dashedLine.layer addSublayer:shapeLayer];
    return dashedLine;
}

#pragma mark - String
#pragma mark -
/// 设置文字行间距
NSMutableAttributedString *SetAttributeString(NSString *originString, CGFloat lineSpace, CGFloat fontSize)
{
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineSpacing = lineSpace;
	NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] initWithString:originString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName : paragraphStyle}];
	return mutStr;
}

/// 筛选设置文字color && font
NSMutableAttributedString *SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor, __kindof UIFont *filterFont)
{
	NSRange range = [orignString rangeOfString:filterString];
	NSMutableAttributedString *mutAttributeStr = [[NSMutableAttributedString alloc] initWithString:orignString];
    [mutAttributeStr addAttributes:@{NSForegroundColorAttributeName : filterColor, NSFontAttributeName : filterFont} range:range];
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

NSString *FirstCharacterWithString(NSString *string)
{
    NSMutableString *str = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *pingyin = [str capitalizedString];
    return [pingyin substringToIndex:1];
}

NSDictionary *DictionaryOrderByCharacterWithOriginalArray(NSArray<NSString *> *array)
{
    if (array.count == 0) {
        return nil;
    }
    for (id obj in array) {
        if (![obj isKindOfClass:[NSString class]]) {
            return nil;
        }
    }
    UILocalizedIndexedCollation *indexedCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:indexedCollation.sectionTitles.count];
    //创建27个分组数组
    for (int i = 0; i < indexedCollation.sectionTitles.count; i++) {
        NSMutableArray *obj = [NSMutableArray array];
        [objects addObject:obj];
    }
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:objects.count];
    //按字母顺序进行分组
    NSInteger lastIndex = -1;
    for (int i = 0; i < array.count; i++) {
        NSInteger index = [indexedCollation sectionForObject:array[i] collationStringSelector:@selector(uppercaseString)];
        [[objects objectAtIndex:index] addObject:array[i]];
        lastIndex = index;
    }
    //去掉空数组
    for (int i = 0; i < objects.count; i++) {
        NSMutableArray *obj = objects[i];
        if (obj.count == 0) {
            [objects removeObject:obj];
        }
    }
    //获取索引字母
    for (NSMutableArray *obj in objects) {
        NSString *str = obj[0];
        NSString *key = FirstCharacterWithString(str);
        [keys addObject:key];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:objects forKey:keys];
    return dic;
    /**
     以下为苹果自己提供的方法：
     NSArray *resultArr = [array sortedArrayUsingSelector:@selector(localizedCompare:)];
     */
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
/// nativeScale与scale的区别
/// http://stackoverflow.com/questions/25871858/what-is-the-difference-between-nativescale-and-scale-on-uiscreen-in-ios8
BOOL isRetina()
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return [UIScreen mainScreen].nativeScale >= 2;
    }
    else {
        return [UIScreen mainScreen].scale >= 2;
    }
}

CGFloat Scale()
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        return [UIScreen mainScreen].nativeScale;
    }
    else {
        return [UIScreen mainScreen].scale;
    }
}

CGSize ScreenSize()
{
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {    // 横屏
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            CGFloat nativeScale = [UIScreen mainScreen].nativeScale;
            CGFloat width = [UIScreen mainScreen].nativeBounds.size.height / nativeScale;
            CGFloat height = [UIScreen mainScreen].nativeBounds.size.width / nativeScale;
            return CGSizeMake(width, height);
        }
        else {
            return [UIScreen mainScreen].bounds.size;
        }
    }
    else {      // 竖屏
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            CGFloat nativeScale = [UIScreen mainScreen].nativeScale;
            CGFloat width = [UIScreen mainScreen].nativeBounds.size.width / nativeScale;
            CGFloat height = [UIScreen mainScreen].nativeBounds.size.height / nativeScale;
            return CGSizeMake(width, height);
        }
        else {
            return [UIScreen mainScreen].bounds.size;
        }
    }
}

/// 竖屏状态下
CGSize PrivateScreenSize()
{
    return [UIScreen mainScreen].bounds.size;
}

CGFloat ScreenWidth()
{
    return ScreenSize().width;
}

CGFloat ScreenHeight()
{
    return ScreenSize().height;
}

BOOL iPhone4s()
{
	if (PrivateScreenSize().height == 480) {
		return YES;
	}
	return NO;
}

BOOL iPhone5s()
{
	if (PrivateScreenSize().height == 568) {
		return YES;
	}
	return NO;
}

BOOL iPhone6()
{
	if (PrivateScreenSize().width == 375) {
		return YES;
	}
	return NO;
}

BOOL iPhone6p()
{
	if (PrivateScreenSize().width == 414) {
		return YES;
	}
	return NO;
}

NSArray *IPAddresses()
{
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) return nil;
    NSMutableArray *ips = [NSMutableArray array];
    
    int BUFFERSIZE = 4096;
    struct ifconf ifc;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifreq *ifr, ifrcopy;
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) >= 0){
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            ifr = (struct ifreq *)ptr;
            int len = sizeof(struct sockaddr);
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) continue;
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
            if ((ifrcopy.ifr_flags & IFF_UP) == 0) continue;
            
            NSString *ip = [NSString stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    close(sockfd);
    return ips;
}

double ZD_MemoryUsage(void)
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    double memoryUsageInMB = kerr == KERN_SUCCESS ? (info.resident_size / 1024.0 / 1024.0) : 0.0;
    
    return memoryUsageInMB;
}

#pragma mark - Function
#pragma mark -
double ZD_Round(CGFloat num, NSInteger num_digits)
{
    double zdpow = pow(10, num_digits);
    double i = round(num * zdpow) / zdpow;
    return i;
}

#pragma mark - Runtime
#pragma mark -
void ZD_PrintObjectMethods()
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



