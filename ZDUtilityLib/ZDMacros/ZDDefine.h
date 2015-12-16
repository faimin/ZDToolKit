//
//  ZDDefine.h
//  ZDUtility
//
//  Created by 符现超 on 15/8/18.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#ifndef ZDUtility_ZDDefine_h
#define ZDUtility_ZDDefine_h

//-------------------获取设备大小-------------------------
//NavBar高度
#define NavigationBar_HEIGHT	44
//获取屏幕 宽度、高度
#define kSCREEN_WIDTH			([UIScreen mainScreen].bounds.size.width)
#define kSCREEN_HEIGHT			([UIScreen mainScreen].bounds.size.height)

//-------------------获取设备大小-------------------------

//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
  #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
  #define DLog(...)
#endif

//重写NSLog,Debug模式下打印日志和当前行数
///A better version of NSLog
//refer : http://onevcat.com/2014/01/black-magic-in-macro/
#define NSLog(format, ...) do {                                             \
fprintf(stderr, "<%s : %d> %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-----------------\n");                                     \
} while (0)


//DEBUG  模式下打印日志,当前行 并弹出一个警告
#ifdef DEBUG
  #define ULog(fmt, ...) {UIAlertView *alert = [[UIAlertView alloc]	\
							  initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] essage:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
  #define ULog(...)
#endif

#define ITTDEBUG
#define ITTLOGLEVEL_INFO	10
#define ITTLOGLEVEL_WARNING 3
#define ITTLOGLEVEL_ERROR	1

#ifndef ITTMAXLOGLEVEL

  #ifdef DEBUG
	#define ITTMAXLOGLEVEL	ITTLOGLEVEL_INFO
  #else
	#define ITTMAXLOGLEVEL	ITTLOGLEVEL_ERROR
  #endif
#endif

// The general purpose logger. This ignores logging levels.
#ifdef ITTDEBUG
  #define ITTDPRINT(xx, ...)	NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
  #define ITTDPRINT(xx, ...)	((void)0)
#endif

// Prints the current method's name.
#define ITTDPRINTMETHODNAME() ITTDPRINT(@"%s", __PRETTY_FUNCTION__)

// Log-level based logging macros.
#if ITTLOGLEVEL_ERROR <= ITTMAXLOGLEVEL
  #define ITTDERROR(xx, ...)	ITTDPRINT(xx, ##__VA_ARGS__)
#else
  #define ITTDERROR(xx, ...)	((void)0)
#endif

#if ITTLOGLEVEL_WARNING <= ITTMAXLOGLEVEL
  #define ITTDWARNING(xx, ...)	ITTDPRINT(xx, ##__VA_ARGS__)
#else
  #define ITTDWARNING(xx, ...)	((void)0)
#endif

#if ITTLOGLEVEL_INFO <= ITTMAXLOGLEVEL
  #define ITTDINFO(xx, ...) ITTDPRINT(xx, ##__VA_ARGS__)
#else
  #define ITTDINFO(xx, ...) ((void)0)
#endif

#ifdef ITTDEBUG
  #define ITTDCONDITIONLOG(condition, xx, ...)	{if ((condition))				   \
												 {								   \
													 ITTDPRINT(xx, ##__VA_ARGS__); \
												 }								   \
} ((void)0)
#else
  #define ITTDCONDITIONLOG(condition, xx, ...)	((void)0)
#endif

#define ITTAssert(condition, ...)														\
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
#define IOS_VERSION				[[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion	[[UIDevice currentDevice] systemVersion]

//获取当前语言
#define CurrentLanguage			([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是否 Retina屏、设备是否%fhone 5、是否是iPad
#define isRetina				([UIScreen instancesRespondToSelector:@selector(currentMode)] ?	\
	CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5					([UIScreen instancesRespondToSelector:@selector(currentMode)] ?	\
	CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isPad					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

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

//使用ARC和不使用ARC
#if __has_feature(objc_arc)
//compiling with ARC
#else
// compiling without ARC
#endif

#pragma mark - common functions
#define RELEASE_SAFELY(__POINTER) {[__POINTER release]; __POINTER = nil; }

//释放一个对象
#define SAFE_DELETE(P)		  \
	if (P)					  \
	{						  \
		[P release], P = nil; \
	}

#define SAFE_RELEASE(x) [x release]; x = nil

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
 *  此单例支持arc已经非arc环境
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
#define singleton_h(name) + (instancetype)shared##name;

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

#else // F-ARC
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
#define LOADIMAGE(file, ext)	[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//定义UIImage对象
#define IMAGE(A)				[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

//定义UIImage对象
#define ImageNamed(_pointer)	[UIImage imageNamed:[UIUtil imageName:_pointer]]

//建议使用前两种宏定义,性能高于后者
//----------------------图片----------------------------

//----------------------颜色类---------------------------
// RGB颜色转换（16进制->10进制）
#define UIColorFromHEX(rgbValue)										  \
	[UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0						  \
blue: ((float)(rgbValue & 0xFF)) / 255.0 alpha: 1.0]

#define HEXCOLOR(c)                                                       \
[UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]

// 获取RGB颜色
#define RGBA(r, g, b, a)	[UIColor colorWithRed: r / 255.0f green: g / 255.0f blue: b / 255.0f alpha: a]
#define RGB(r, g, b)		RGBA(r, g, b, 1.0f)

//十六进制颜色
//#define COLOR_RGBA(r, g, b, a) \
//	[UIColor colorWithRed: (r) / 255.0 green: (g) / 255.0 blue: (b) / 255.0 alpha: a]
//#define COLOR_HEXA(hexValue, alpha)	\
//	COLOR_RGBA( ( (hexValue) >> 16) & 0xff, ( (hexValue) >> 8) & 0xff, ( (hexValue) >> 0) & 0xff, alpha)
//#define COLOR_HEX(hexValue) COLOR_HEXA(hexValue, 1)


//清除背景色
#define CLEARCOLOR			[UIColor clearColor]

//----------------------颜色类--------------------------

//----------------------其他----------------------------

//方正黑体简体字体定义
#define FONT(F)						[UIFont fontWithName: @"FZHTJW--GB1-0" size: F]

//设置View的tag属性
#define VIEWWITHTAG(_OBJECT, _TAG)	[_OBJECT viewWithTag: _TAG]
//程序的本地化,引用国际化的文件
#define MyLocal(x, ...)				NSLocalizedString(x, nil)

//G－C－D
#define BACK(block)					dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block)					dispatch_async(dispatch_get_main_queue(), block)

//NSUserDefaults 实例化
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]

//由角度获取弧度 有弧度获取角度
#define degreesToRadian(x)		(M_PI * (x) / 180.0)
#define radianToDegrees(radian) (radian * 180.0) / (M_PI)

#define LITE_RESOURCE_BUNDLE [[NSBundle mainBundle] pathForResource: \
	@"LiteResource"													 \
	ofType:@"bundle"];

#endif 
