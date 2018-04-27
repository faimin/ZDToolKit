//
//  ViewController.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/1/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>
#import <ZDToolKit/ZDToolKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <ZDToolKit/ZDFastEnumeration.h>
#import <ZDToolKit/NSArray+ZDUtility.h>
#import "ZDPromise.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *testView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.navigationItem.title = @"ZDToolKitDemo";
    
    [self uiTest];
	//[self functionTest];
	//[self numberTest];
    //[self mainqueueTest];
    [self arrayTest];
    
    [self promise];
    
    BOOL setProxy = ZD_isSetProxy();
    NSLog(@"%@", setProxy ? @"本机设置了代理" : @"没设置代理");
    
    Class aClass = objc_getClass("TwoViewController");
    SEL selector = sel_registerName("executeMethodWithStr:num:");
    id result = [[aClass new] zd_invokeSelectorWithArgs:selector, @"数字", 999];
    NSLog(@"%@", result);
    
    NSArray<NSString *> *arr = @[@"awgea", @"125", @"145", @"880"];
    foreach(a, arr) {
        NSLog(@"%@", a.zd_isEmpty ? @"空字符串" : @"非空");
    }

    /*
     id target = [aClass new];
    NSString *str = @"数字";
    NSUInteger num = 999;
    //__unsafe_unretained id returnValue;
    void *returnValue;
    
    id result00 = ({
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
        [invocation setTarget:target];
        [invocation setSelector:selector];
        [invocation setArgument:&str atIndex:2];
        [invocation setArgument:&num atIndex:3];
        [invocation retainArguments];
        [invocation setReturnValue:&returnValue];
        [invocation invoke];
        [invocation getReturnValue:&returnValue];
        (__bridge id)returnValue;
    });
    
    NSLog(@"%@", result00);
     */
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

- (void)promise {
    [[[[ZDPromise async:^(ZDFulfillBlock  _Nonnull fulfill, ZDRejectBlock  _Nonnull reject) {
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://p.upyun.com/docs/cloud/demo.jpg"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (response) {
                UIImage *image = [UIImage imageWithData:data];
                fulfill(image);
            } else if (error) {
                reject(error);
            }
        }] resume];
    }] then:^id(UIImage * _Nonnull value) {
        NSLog(@"image = %@", value);
        //return @(111111);
        return [NSError errorWithDomain:NSCocoaErrorDomain code:404 userInfo:@{@"info" : @"xxxx"}];
    }] then:^id(NSNumber * _Nonnull value) {
        NSLog(@"%@", value);
        return value;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"error");
    }];
}

- (void)arrayTest {
    NSArray *arr = @[@1, @[@2, @[@3, @4, @[@5, @6, @7, @[@8, @9, @10, @11] ] ] ] ];
    NSMutableArray *mut = [arr zd_flatten];
    NSLog(@"%@", mut);
}

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
    
    //dispatch_queue_create("com.zd.saber", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_DEFAULT, 0))
    //ZD_CREATE_SERIAL_QUEUE(com.zd, QOS_CLASS_DEFAULT);
    
}

- (void)getCurrentQueue {
    dispatch_queue_t queueA = dispatch_queue_create("com.zd.queueA", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queueB = dispatch_queue_create("com.zd.queueB", DISPATCH_QUEUE_SERIAL);
    
    // deadlock 1
    dispatch_sync(queueA, ^{
        dispatch_sync(queueB, ^{
            dispatch_sync(queueA, ^{
                // Deadlock
            });
        });
    });
    
    // deadlock 2
    dispatch_sync(queueA, ^{
        dispatch_sync(queueB, ^{
            dispatch_block_t block = ^{
                // block
            };
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if (dispatch_get_current_queue() == queueA) {
#pragma clang diagnostic pop
                block();
            } else {
                dispatch_sync(queueA, block);
            }
        });
    });
    
    // correct
    static int kQueueSpecific;
    CFStringRef queueSpecificValue = CFSTR("queueA");
    
    dispatch_queue_set_specific(queueA,
                                &kQueueSpecific,
                                (void *)queueSpecificValue,
                                (dispatch_function_t)CFRelease);
    
    dispatch_sync(queueA, ^{
        dispatch_sync(queueB, ^{
            dispatch_block_t block = ^{
                // block
            };
            
            CFStringRef retrievedValue = dispatch_get_specific(&kQueueSpecific);
            if (retrievedValue) {
                // 当前队列是queueA
                block();
            }
            else {
                // 当前队列不是queueA
                dispatch_sync(queueA, block);
            }
        });
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
