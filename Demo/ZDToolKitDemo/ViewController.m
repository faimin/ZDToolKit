//
//  ViewController.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/1/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import "ZDDefine.h"
#import "NSString+ZDUtility.h"
#import "UIView+ZDUtility.h"
#import "UIView+RZBorders.h"
#import "UIImageView+ZDUtility.h"
#import "UIImageView+WebCache.h"
#import "UITextView+ZDUtility.h"
#import "NSObject+DLIntrospection.h"
#import "NSObject+ZDUtility.h"
#import "ZDFunction.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *testView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.title = @"ZDToolKitDemo";
    
    [self uiTest];
	//[self functionTest];
	//[self numberTest];
    [self mainqueueTest];
    
    BOOL setProxy = isSetProxy();
    NSLog(@"%@", setProxy ? @"本机设置了代理" : @"没设置代理");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	/// 对于autolayout布局的视图，只有在视图显示出来的时候才能获取到真实的frame
	/// viewDidLoad和viewWillAppear方法中都不行，时机过早
	//self.testView.zd_cornerRadius = 30;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BOOL isContains = [self.navigationController.childViewControllers containsObject:self];
    if (isContains) {
        NSLog(@"控制器只是单纯的disappear，比如pushToVC");
    } else {
        NSLog(@"控制器将要释放了");
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark -

__unused UIKIT_STATIC_INLINE UIImage *drawImageWithSize(CGSize size) {
    //! General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //! Combined Shape
    UIBezierPath *combinedShape = [UIBezierPath bezierPath];
    
    [combinedShape moveToPoint:CGPointZero];
    [combinedShape addLineToPoint:CGPointMake(300, 0)];
    [combinedShape addLineToPoint:CGPointMake(300, 300)];
    [combinedShape addLineToPoint:CGPointMake(0, 300)];
    [combinedShape addLineToPoint:CGPointZero];
    [combinedShape closePath];
    
    [combinedShape moveToPoint:CGPointMake(150, 300)];
    [combinedShape addCurveToPoint:CGPointMake(300, 150) controlPoint1:CGPointMake(232.84, 300) controlPoint2:CGPointMake(300, 232.84)];
    [combinedShape addCurveToPoint:CGPointMake(150, 0) controlPoint1:CGPointMake(300, 67.16) controlPoint2:CGPointMake(232.84, 0)];
    [combinedShape addCurveToPoint:CGPointMake(0, 150) controlPoint1:CGPointMake(67.16, 0) controlPoint2:CGPointMake(0, 67.16)];
    [combinedShape addCurveToPoint:CGPointMake(150, 300) controlPoint1:CGPointMake(0, 232.84) controlPoint2:CGPointMake(67.16, 300)];
    [combinedShape closePath];
    
    [combinedShape moveToPoint:CGPointMake(150, 300)];
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, -280, -207);
    combinedShape.usesEvenOddFillRule = YES;
    [[UIColor colorWithWhite:0.847 alpha:1] setFill];
    [combinedShape fill];
    CGContextSaveGState(context);
    combinedShape.lineWidth = 2;
    
    CGContextBeginPath(context);
    CGContextAddPath(context, combinedShape.CGPath);
    CGContextEOClip(context);
    [[UIColor colorWithWhite:0.592 alpha:1] setStroke];
    [combinedShape stroke];
    CGContextRestoreGState(context);
    CGContextRestoreGState(context);
    
    return nil;
}

#pragma mark - Test

- (void)uiTest {
    NSString *urlStr = @"http://pic14.nipic.com/20110522/7411759_164157418126_2.jpg";
    //[self.testView rz_addBordersWithCornerRadius:30 width:1 color:[UIColor blueColor]];
#if 1
    [self.testImageView zd_setImageWithURL:urlStr placeholderImage:nil cornerRadius:30];
#else
    self.testImageView.aliCornerRadius = 35;
    [self.testImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
#endif
    
    [self.testImageView zd_addTapGestureWithBlock:^(UITapGestureRecognizer *tapGesture) {
        NSLog(@"\n轻击了, %@", tapGesture);
    }];
    
    self.textView.zd_placeHolderLabel = ({
        UILabel *label = [UILabel new];
        label.text = @"这是一个占位label";
        label.textColor = [UIColor redColor];
        label;
    });
    
    NSArray *propertys = [self.class properties];
    NSLog(@"所有的属性: \n%@", propertys);
    
    //id obj = [self zd_deepCopy];
    //NSLog(@"\n\n%@", obj);
}

- (void)functionTest {
	UIView *view = ({
		UIView *view = [UIView new];
		zd_defer {
		    /// 所谓作用域结束，包括大括号结束、return、goto、break、exception等各种情况
			NSLog(@"当前作用域结束,马上要出作用域了");
		};
		view.backgroundColor = [UIColor redColor];
		view.frame = CGRectMake(20, 100, 50, 50);
		view;
	});

	[self.view addSubview:view];

	NSLog(@"执行完毕");
}

- (void)numberTest {
	NSString *str = @"2345";
	BOOL isAllNum = [str zd_isAllNumber];

	NSLog(@"%@", isAllNum ? @"YES" : @"NO");
}

- (void)mainqueueTest {
	dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (ZD_IsMainQueue()) {
			NSLog(@"主队列");
		}
		else {
			NSLog(@"子队列");
		}
        
        if ([NSThread isMainThread]) {
            NSLog(@"主线程");
        }
        
        int mm = pthread_main_np();
        if (mm) {
            NSLog(@"主线程");
        }
        
	});

	dispatch_async(dispatch_get_main_queue(), ^{
		if (ZD_IsMainQueue()) {
			NSLog(@"主队列");
		}
		else {
			NSLog(@"子队列");
		}
	});
}

- (void)privateLib {
	void *FrontBoard = dlopen("/System/Library/PrivateFrameworks/FrontBoard.framework/FrontBoard", RTLD_LAZY);

	if (FrontBoard) {
		Class FBProcessManager = objc_getClass("FBProcessManager");

		//NSArray* allProcesses = [[FBProcessManager sharedInstance] allProcesses];
		if (FBProcessManager) {
			NSLog(@"find it");
		}
		id manager = ( (id (*)(id, SEL))(void *) objc_msgSend)((id)objc_getClass("FBProcessManager"), sel_registerName("sharedInstance"));
		NSLog(@"%@", manager);
		dlclose(FrontBoard);
	}
}

@end
