//
//  ZDDefine.h
//  ZDUtility
//
//  Created by Zero on 15/8/18.
//  Copyright (c) 2015年 Zero.D.Saber. All rights reserved.
//

#ifndef ZDUtility_ZDDefine_h
#define ZDUtility_ZDDefine_h
#endif

#import <pthread.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//-------------------屏幕物理尺寸-------------------------
//获取屏幕宽度、高度
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0 // 当前Xcode支持iOS8及以上
	#ifndef ZD_SCREEN_WIDTH
		#define ZD_SCREEN_WIDTH   ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.width)
	#endif
	
	#ifndef ZD_SCREENH_HEIGHT
		#define ZD_SCREENH_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.height)
	#endif

	#ifndef ZD_SCREEN_SIZE
		#define ZD_SCREEN_SIZE    ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale, [UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale) : [UIScreen mainScreen].bounds.size)
	#endif
#else
	#ifndef ZD_SCREEN_WIDTH
		#define ZD_SCREEN_WIDTH   ([UIScreen mainScreen].bounds.size.width)
	#endif

	#ifndef ZD_SCREENH_HEIGHT
		#define ZD_SCREENH_HEIGHT ([UIScreen mainScreen].bounds.size.height)
	#endif

	#ifndef ZD_SCREEN_SIZE
		#define ZD_SCREEN_SIZE    ([UIScreen mainScreen].bounds.size)
	#endif
#endif


//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
    #define ZDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define ZDLog(...) ((void)0)
#endif

//重写NSLog,Debug模式下打印日志和当前行数
///A better version of NSLog
//refer : http://onevcat.com/2014/01/black-magic-in-macro/
#ifdef DEBUG
#define NSLog(format, ...) 														\
do {                                                 							\
    fprintf(stderr, "<%s : %d> %s\n",                                           \
    [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
    __LINE__, __PRETTY_FUNCTION__);                                             \
    (NSLog)((format), ##__VA_ARGS__);                                           \
    fprintf(stderr, "----------万恶的分割线---------\n\n");                       \
} while (0)
#endif


//打印宏展开后的函数
#define __toString(x) __toString_0(x)
#define __toString_0(x) #x
#define ZDLOG_MACRO(x) NSLog(@"%s=\n%s", #x, __toString(x))


//DEBUG  模式下打印日志,当前行 并弹出一个警告
#ifdef DEBUG
  #define ZDAlertLog(fmt, ...) {UIAlertView *alert = [[UIAlertView alloc]	\
							  initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
  #define ZDAlertLog(...)     ((void)0)
#endif

#define ZD_Assert(condition, ...)														\
	do {																				\
		if (!(condition))																\
		{																				\
			[[NSAssertionHandler currentHandler]										\
			handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__]	\
			file:[NSString stringWithUTF8String:__FILE__]								\
			lineNumber:__LINE__															\
			description:__VA_ARGS__];													\
		}																				\
	} while (0)

//---------------------打印日志--------------------------

//----------------------系统----------------------------

//获取系统版本
#define ZD_SYSTEMVERSION	[[[UIDevice currentDevice] systemVersion] floatValue]

//获取当前语言
#define ZD_CurrentLanguage	([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

//检查系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)					([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)				([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)	([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)					([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)		([[[UIDevice currentDevice] systemVersion] \
	compare:v options:NSNumericSearch] != NSOrderedDescending)

//----------------------系统----------------------------

//----------------------内存----------------------------
#pragma mark - 内存

#if !__has_feature(objc_arc)
	//释放一个对象
	#define ZD_SAFE_RELEASE(P)	  \
		if (P)					  \
		{						  \
			[P release], P = nil; \
		}
#endif

//----------------------内存----------------------------

//----------------------单例----------------------------

#ifndef SHARED_SERVICE
  #define SHARED_SERVICE(ServiceName)					 \
	+ (instancetype)sharedInstance						 \
	{													 \
		static ServiceName *sharedInstance;				 \
		static dispatch_once_t onceToken;				 \
		dispatch_once(&onceToken, ^{					 \
			sharedInstance = [[ServiceName alloc] init]; \
		});												 \
		return sharedInstance;							 \
	}
#endif

//-----------------------------------------------------

/**
 *******************************************************
 *  此单例支持ARC以及非MRC环境
 *
 *  使用说明
 *  1. 创建你的单例 比如我这里创建的是 SharedMaxTools
 *  2. 在.h文件添加  singleton_h(MaxTools)
 *  3. 在.m文件添加
 *
 *  - (instancetype)init
 *  {
 *  static dispatch_once_t onceToken;
 *  static id obj = nil;
 *  dispatch_once(&onceToken, ^{
 *  obj = [super init];
 *  if (obj) {
 *
 *  // 加载资源
 *
 *  }
 *  });
 *  return self;
 *  }
 *  singleton_m(MaxTools);
 *
 *******************************************************
 */

// ## : 连接字符串和参数
#define Singleton_h(name) + (instancetype)shared##name;

#if __has_feature(objc_arc) // ARC
  #define singleton_m(name)								 \
	static id _instance;								 \
	+ (instancetype)allocWithZone:(struct _NSZone *)zone \
	{													 \
		static dispatch_once_t onceToken;				 \
		dispatch_once(&onceToken, ^{					 \
			_instance = [super allocWithZone:zone];		 \
		});												 \
		return _instance;								 \
	}													 \
														 \
	+ (instancetype)shared##name						 \
	{													 \
		static dispatch_once_t onceToken;				 \
		dispatch_once(&onceToken, ^{					 \
			_instance = [[self alloc] init];			 \
		});												 \
		return _instance;								 \
	}													 \
	+ (instancetype)copyWithZone:(struct _NSZone *)zone	 \
	{													 \
		return _instance;								 \
	}													 \
	+ (instancetype)new									 \
	{													 \
		static dispatch_once_t onceToken;				 \
		dispatch_once(&onceToken, ^{					 \
			_instance = [[self alloc] init];			 \
		});												 \
		return _instance;								 \
	}

#else                       // MRC

  #define singleton_m(name)								\
	static id _instance;								\
	+ (id)allocWithZone:(struct _NSZone *)zone			\
	{													\
		static dispatch_once_t onceToken;				\
		dispatch_once(&onceToken, ^{					\
			_instance = [super allocWithZone:zone];		\
		});												\
		return _instance;								\
	}													\
														\
	+ (instancetype)shared##name						\
	{													\
		static dispatch_once_t onceToken;				\
		dispatch_once(&onceToken, ^{					\
			_instance = [[self alloc] init];			\
		});												\
		return _instance;								\
	}													\
														\
	- (oneway void)release								\
	{													\
														\
	}													\
														\
	- (instancetype)autorelease							\
	{													\
		return _instance;								\
	}													\
														\
	- (instancetype)retain								\
	{													\
		return _instance;								\
	}													\
														\
	- (NSUInteger)retainCount							\
	{													\
		return 1;										\
	}													\
														\
	+ (instancetype)copyWithZone:(struct _NSZone *)zone	\
	{													\
		return _instance;								\
	}													\
	+ (instancetype)new									\
	{													\
		static dispatch_once_t onceToken;				\
		dispatch_once(&onceToken, ^{					\
			_instance = [[self alloc] init];			\
		});												\
		return _instance;								\
	}
#endif

//----------------------图片----------------------------

//读取本地图片
#define ZD_BUNDLEIMAGE(file, type)	[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:type]]
//定义UIImage对象
#define ZD_ImageNamed(_imageName)	[UIImage imageNamed:_imageName]

//----------------------图片----------------------------

//----------------------颜色类---------------------------
/// RGB颜色转换（16进制->10进制）
#define ZD_UIColorFromHEX(rgbValue)                                     \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0    \
                green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0       \
                 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha: 1.0]    \

///  Create UIColor with a hex string.
///
///  Example: self.backgroundColor = UIColorHex(f9f9f9);
///  UIColorHex(0xF0F), UIColorHex(66ccff), UIColorHex(#66CCFF88)
//#ifndef UIColorHex
//#define UIColorHex(_hex_)   [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
//#endif

// 获取RGB颜色
#define ZD_RGBA(r, g, b, a)	[UIColor colorWithRed: r / 255.0f green: g / 255.0f blue: b / 255.0f alpha: a]
#define ZD_RGB(r, g, b)		ZD_RGBA(r, g, b, 1.0f)

//十六进制颜色
//#define COLOR_RGBA(r, g, b, a) \
//	[UIColor colorWithRed: (r) / 255.0 green: (g) / 255.0 blue: (b) / 255.0 alpha: a]
//#define COLOR_HEXA(hexValue, alpha)	\
//	COLOR_RGBA( ( (hexValue) >> 16) & 0xff, ( (hexValue) >> 8) & 0xff, ( (hexValue) >> 0) & 0xff, alpha)
//#define COLOR_HEX(hexValue) COLOR_HEXA(hexValue, 1)

//----------------------颜色类--------------------------

//----------------------其他----------------------------

//设置View的tag属性
#define ZD_VIEWWITHTAG(_OBJECT, _TAG)	[_OBJECT viewWithTag: _TAG]
//程序的本地化,引用国际化的文件
#define ZD_LOCAL(x, ...)				NSLocalizedString(x, nil)

//G－C－D
#define ZD_GLOBALQUEUE(block)  	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define ZD_MAINQUEUE(block)		dispatch_async(dispatch_get_main_queue(), block)

//由角度获取弧度 有弧度获取角度
#define ZD_DegreesToRadian(x)          (M_PI * (x) / 180.0)
#define ZD_RadianToDegrees(radian)     ((radian * 180.0) / (M_PI))

#define ZD_IS_KIND_OF_CLASS(obj_, Class_) [obj_ isKindOfClass:NSClassFromString(@#Class_)]
#define ZD_URL(urlString_) [NSURL URLWithString:urlString_]

//TODO宏 (http://blog.sunnyxx.com/2015/03/01/todo-macro/ )
#define STRINGIFY(S) #S                             // 转成字符串
#define DEFER_STRINGIFY(S) STRINGIFY(S)             // 需要解两次才解开的宏
#define PRAGMA_MESSAGE(MSG) _Pragma(STRINGIFY(message(MSG)))
#define FORMATTED_MESSAGE(MSG) "[TODO-" DEFER_STRINGIFY(__COUNTER__) "] " MSG " \n" DEFER_STRINGIFY(__FILE__) " line " DEFER_STRINGIFY(__LINE__)   // 为warning增加更多信息
#define KEYWORDIFY try {} @catch (...) {}           // 使宏前面可以加@
#define TODO(MSG) KEYWORDIFY PRAGMA_MESSAGE(FORMATTED_MESSAGE(MSG))// 最终使用的宏


static inline void ZD_Dispatch_async_on_main_queue(void (^block)()) {
    if (pthread_main_np()) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void ZD_Dispatch_sync_on_main_queue(void (^block)()) {
    if (pthread_main_np()) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static inline void ZD_PrintViewCoordinateInfo(UIView *view) {
    NSLog(@"\n frame = %@, bounds = %@, center = %@",
          NSStringFromCGRect(view.frame),
          NSStringFromCGRect(view.bounds),
          NSStringFromCGPoint(view.center)
    );
}

//defer(swift延迟调用关键字)宏 (http://blog.sunnyxx.com/2014/09/15/objc-attribute-cleanup/ )
static inline void CleanupBlock(__strong void(^*executeCleanupBlock)()) {
    (*executeCleanupBlock)();
}

/// 出了作用域时执行block
#ifndef zd_defer
	#define zd_defer \
        zd_keywordify \
        __strong void(^executeCleanupBlock)() __attribute__((cleanup(CleanupBlock), unused)) = ^
#endif

#if DEBUG
	#define zd_keywordify @autoreleasepool {}
#else
	#define zd_keywordify @try {} @catch (...) {}
#endif


#define zd_weakObjc(objc_) \
@autoreleasepool {} __weak __typeof__(objc_) self_weak_ = (objc_);

#define zd_strongObjc(objc_) \
@autoreleasepool {} __strong __typeof__(objc_) self = self_weak_;


#define ZD_BeforeMainFunction __attribute__((constructor))


/// 消除performSelector警告
#define ZD_SuppressPerformSelectorLeakWarning(Stuff)                    \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff                                                               \
    _Pragma("clang diagnostic pop")                                     \
} while (0)

/// 消除deprecated方法的警告
#define ZD_SuppressDeprecatedWarning(Stuff)                             \
do {                                                                    \
    _Pragma("clang diagnostic push")                                    \
    _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")   \
    Stuff                                                               \
    _Pragma("clang diagnostic pop")                                     \
} while (0)












































