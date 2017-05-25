//
//  ZDFunction.m
//  ZDUtility
//
//  Created by Zero on 15/9/13.
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
#import <pthread/pthread.h>
#import <Accelerate/Accelerate.h>

#pragma mark - Gif Image
#pragma mark -
// returns the frame duration for a given image in 1/100th seconds
// source: http://stackoverflow.com/questions/16964366/delaytime-or-unclampeddelaytime-for-gifs
static NSUInteger ZD_AnimatedGIFFrameDurationForImageAtIndex(CGImageSourceRef source, NSUInteger index)
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
static NSUInteger ZD_AnimatedGIFGreatestCommonFactor(NSUInteger num1, NSUInteger num2)
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
		return ZD_AnimatedGIFGreatestCommonFactor(num2, remainder);
	}
}

static UIImage *ZD_AnimatedGIFFromImageSource(CGImageSourceRef source)
{
	size_t const numImages = CGImageSourceGetCount(source);

	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numImages];

	// determine gretest common factor of all image durations
	NSUInteger greatestCommonFactor = ZD_AnimatedGIFFrameDurationForImageAtIndex(source, 0);

	for (NSUInteger i = 1; i < numImages; i++) {
		NSUInteger centiSecs = ZD_AnimatedGIFFrameDurationForImageAtIndex(source, i);
		greatestCommonFactor = ZD_AnimatedGIFGreatestCommonFactor(greatestCommonFactor, centiSecs);
	}

	// build array of images, duplicating as necessary
	for (NSUInteger i = 0; i < numImages; i++) {
		CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
		UIImage *frame = [UIImage imageWithCGImage:cgImage];

		NSUInteger centiSecs = ZD_AnimatedGIFFrameDurationForImageAtIndex(source, i);
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

UIImage *ZD_AnimatedGIFFromFile(NSString *path)
{
	NSURL *URL = [NSURL fileURLWithPath:path];
	CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)(URL), NULL);
	UIImage *image = ZD_AnimatedGIFFromImageSource(source);

	CFRelease(source);

	return image;
}

UIImage *ZD_AnimatedGIFFromData(NSData *data)
{
	CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
	UIImage *image = ZD_AnimatedGIFFromImageSource(source);

	CFRelease(source);

	return image;
}

UIImage *ZD_TintedImageWithColor(UIColor *tintColor, UIImage *image) {
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

UIImage *ZD_ThumbnailImageFromURl(NSURL *url, int imageSize)
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

NSString *ZD_TypeForImageData(NSData *data)
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

NSString *ZD_TypeForData(NSData *data)
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

UIImage *ZD_BlurImageWithBlurPercent(UIImage *image, CGFloat blur)
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
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    CGContextRelease(ctx);
    
    return returnImage;
}

//===============================================================

#pragma mark - UIView
#pragma mark -
/// 画虚线
UIView *ZD_CreateDashedLineWithFrame(CGRect lineFrame, int lineLength, int lineSpacing, UIColor *lineColor)
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

void ZD_AddHollowoutLayerToView(UIView *view, CGSize size, UIColor *fillColor) {
    if (!view) return;
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        size = view.bounds.size;
    }
    
    CAShapeLayer *hollowLayer = [CAShapeLayer layer];
    hollowLayer.bounds = (CGRect){CGPointZero, size};
    hollowLayer.position = (CGPoint){size.width/2.0, size.height/2.0};
    [view.layer addSublayer:hollowLayer];
    
    UIBezierPath *squarePath = [UIBezierPath bezierPathWithRect:hollowLayer.bounds];
    UIBezierPath *hollowPath = [UIBezierPath bezierPathWithOvalInRect:hollowLayer.bounds];
    [squarePath appendPath:hollowPath];
    hollowLayer.path = squarePath.CGPath;
    
    hollowLayer.fillColor = fillColor ? fillColor.CGColor : [UIColor whiteColor].CGColor;
    //设置路径的填充模式为两个图形的非交集
    hollowLayer.fillRule = kCAFillRuleEvenOdd;
}

#pragma mark - String
#pragma mark -
/// 设置文字行间距
NSMutableAttributedString *ZD_SetAttributeString(NSString *originString, CGFloat lineSpace, CGFloat fontSize)
{
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineSpacing = lineSpace;
	NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] initWithString:originString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName : paragraphStyle}];
	return mutStr;
}

/// 筛选设置文字color && font
NSMutableAttributedString *ZD_SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor, __kindof UIFont *filterFont)
{
	NSRange range = [orignString rangeOfString:filterString];
	NSMutableAttributedString *mutAttributeStr = [[NSMutableAttributedString alloc] initWithString:orignString];
    [mutAttributeStr addAttributes:@{NSForegroundColorAttributeName : filterColor, NSFontAttributeName : filterFont} range:range];
	return mutAttributeStr;
}

NSMutableAttributedString *ZD_AddImageToAttributeString(UIImage *image) {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, -2, image.size.width, image.size.height);
    
    NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *mutAttri = [[NSMutableAttributedString alloc] init];
    [mutAttri appendAttributedString:attachString];
    return mutAttri;
}

NSString *ZD_URLEncodedString(NSString *sourceText)
{
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)sourceText, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));

	return result;
}

/// 计算文字高度
CGFloat ZD_HeightOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth)
{
    return ZD_SizeOfString(sourceString, font, maxWidth, 0).height;
}

/// 计算文字宽度
CGFloat ZD_WidthOfString(NSString *sourceString, UIFont *font, CGFloat maxHeight)
{
    return ZD_SizeOfString(sourceString, font, 0, maxHeight).width;
}

CGSize ZD_SizeOfString(NSString *sourceString, UIFont *font, CGFloat maxWidth, CGFloat maxHeight)
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

NSString *ZD_ReverseString(NSString *sourceString)
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

BOOL ZD_IsEmptyString(NSString *str)
{
    if (!str || str == (id)[NSNull null]) return YES;
    if ([str isKindOfClass:[NSString class]]) {
        return str.length == 0;
    }
    else {
        return YES;
    }
}

BOOL ZD_IsEmptyOrNilString(NSString *string)
{
    if (string == nil || string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    
    return NO;
}

NSString *ZD_FirstCharacterWithString(NSString *string)
{
    NSMutableString *str = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *pingyin = [str capitalizedString];
    return [pingyin substringToIndex:1];
}

NSDictionary *ZD_DictionaryOrderByCharacterWithOriginalArray(NSArray<NSString *> *array)
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
        NSString *str = obj.firstObject;
        NSString *key = ZD_FirstCharacterWithString(str);
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

UIInterfaceOrientation ZD_CurrentInterfaceOrientation()
{
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    return orient;
}

BOOL isPortrait()
{
    return UIInterfaceOrientationIsPortrait(ZD_CurrentInterfaceOrientation());
}

BOOL isLandscape()
{
    return UIInterfaceOrientationIsLandscape(ZD_CurrentInterfaceOrientation());
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
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        return [UIScreen mainScreen].nativeScale >= 2;
    }
    else {
        return [UIScreen mainScreen].scale >= 2;
    }
}

BOOL isPad()
{
    static dispatch_once_t one;
    static BOOL pad;
    dispatch_once(&one, ^{
        pad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    return pad;
}

BOOL isSimulator()
{
#if 1
    
#if TARGET_IPHONE_SIMULATOR
    return YES;
#endif
    return NO;
    
#else
    static dispatch_once_t one;
    static BOOL simu;
    dispatch_once(&one, ^{
        simu = NSNotFound != [[UIDevice currentDevice].model rangeOfString:@"Simulator"].location;
    });
    return simu;
#endif
}

// 是否越狱 refer:YYCategories
BOOL isJailbroken()
{
    if (isSimulator()) return NO; // Dont't check simulator
    
    // iOS9 URL Scheme query changed ...
    // NSURL *cydiaURL = [NSURL URLWithString:@"cydia://package"];
    // if ([[UIApplication sharedApplication] canOpenURL:cydiaURL]) return YES;
    
    NSArray *paths = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt/",
                       @"/private/var/lib/cydia",
                       @"/private/var/stash"];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return YES;
    }
    
    FILE *bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return YES;
    }
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *UUIDString = (__bridge_transfer NSString *)string;
    NSString *path = [NSString stringWithFormat:@"/private/%@", UUIDString];
    if ([@"test" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return YES;
    }
    
    return NO;
}

// 当前设备是否设置了代理
BOOL isSetProxy() {
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"http://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    
    NSDictionary *settings = proxies[0];
    return ![[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:(NSString *)kCFProxyTypeNone];
}

double SystemVersion()
{
    static double _version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return _version;
}

CGFloat Scale()
{
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
        return [UIScreen mainScreen].nativeScale;
    }
    else {
        return [UIScreen mainScreen].scale;
    }
}

CGSize ScreenSize()
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) { // 横屏
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    else {
        return screenSize;
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

// refer: http://www.cnblogs.com/tandaxia/p/5820217.html
/// 获取 app 的 icon 图标名称
NSString *ZD_IconName() {
    NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
    NSArray<NSString *> *iconArr = infoDict[@"CFBundleIcons"][@"CFBundlePrimaryIcon"][@"CFBundleIconFiles"];
    NSString *iconLastName = iconArr.lastObject;
    return iconLastName;
}

NSString *ZD_LaunchImageName() {
    CGSize viewSize = [UIApplication sharedApplication].delegate.window.bounds.size;
    // 竖屏
    NSString *viewOrientation = @"Portrait";
    NSString *launchImageName = nil;
    NSArray *imagesDict = [[NSBundle mainBundle].infoDictionary valueForKey:@"UILaunchImages"];
    for (NSDictionary *dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImageName = dict[@"UILaunchImageName"];
        }
    }
    return launchImageName;
}

NSArray *ZD_IPAddresses()
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
    double zd_pow = pow(10, num_digits); // 指数函数，相当于10的digits次方
    double i = round(num * zd_pow) / zd_pow;
    return i;
}

NSData *ZD_ConvertIntToData(int intValue)
{
    Byte bytes[4];
    bytes[0] = (Byte)(intValue>>24);
    bytes[1] = (Byte)(intValue>>16);
    bytes[2] = (Byte)(intValue>>8);
    bytes[3] = (Byte)(intValue);
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
}

// http://blog.benjamin-encz.de/post/main-queue-vs-main-thread/
// 原理：给主队列设置一个标签，然后在当前队列获取标签，
// 如果获取到的标签与设置的标签不一样，说明当前队列就不是主队列
BOOL ZD_IsMainQueue()
{
#if 1
    static const void *mainQueueKey = &mainQueueKey;
    static void *mainQueueContext = &mainQueueContext;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, mainQueueContext, (dispatch_function_t)CFRelease);
    });
    void *context = dispatch_get_specific(mainQueueKey);
    return (context == mainQueueContext);
#else
    dispatch_queue_t mainQueue = (__bridge dispatch_queue_t)(pthread_getspecific(20));
    BOOL isMainQueue = !strcmp(dispatch_queue_get_label(mainQueue), @"com.apple.main-thread".UTF8String);
    return isMainQueue;
#endif
}

// https://github.com/cyanzhong/GCDThrottle/blob/master/GCDThrottle/GCDThrottle.m
void ZD_ExecuteFunctionThrottle(NSTimeInterval intervalInSeconds, dispatch_queue_t queue, NSString *key, void(^block)())
{
    static NSMutableDictionary *scheduleSourceDic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scheduleSourceDic = [[NSMutableDictionary alloc] init];
    });
    
    dispatch_source_t timer = scheduleSourceDic[key];
    if (timer) {
        dispatch_source_cancel(timer);
    }
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, intervalInSeconds * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(timer, ^{
        block();
        dispatch_source_cancel(timer);
        [scheduleSourceDic removeObjectForKey:key];
    });
    dispatch_resume(timer);
    scheduleSourceDic[key] = timer;
}

void ZD_Dispatch_throttle_on_mainQueue(NSTimeInterval intervalInSeconds, void(^block)())
{
    ZD_ExecuteFunctionThrottle(intervalInSeconds, dispatch_get_main_queue(), [NSThread callStackSymbols][1], block);
}

void ZD_Dispatch_throttle_on_queue(NSTimeInterval intervalInSeconds, dispatch_queue_t queue, void(^block)())
{
    ZD_ExecuteFunctionThrottle(intervalInSeconds, queue, [NSThread callStackSymbols][1], block);
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
    aClass = object_getClass(aClass);
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



