//
//  TwoViewController.m
//  ZDToolKitDemo
//
//  Created by Zero on 16/5/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "TwoViewController.h"
#import <ZDToolKit/ZDToolKit.h>
#import "ZDProtocols.h"

extern char *const ZDInjectableSectionName;

char *ZDInjectionTwoViewController ZDInjectable = "TwoViewController";

@interface TwoViewController () <ZDInjectionProtocol>
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ZDEdgeLabel *zdLabel;
@property (nonatomic, assign) NSInteger count1;
@property (nonatomic, assign) NSInteger count2;
@end

@implementation TwoViewController

- (void)dealloc {
    NSLog(@"");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSStringFromClass(self.class);
    
    [self setupTest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    BOOL isContains = [self.navigationController.childViewControllers containsObject:self];
    if (isContains) {
        NSLog(@"消失");
    } else {
        NSLog(@"释放");
    }
}

#pragma mark -

+ (void)foo {
    NSLog(@"injection success 😄 foo");
}

- (void)setupTest {
    [self autoreleaseTest];
    
    [self clickTextTest];
    
    //[self associateTest];
    
    //[self deadLock];
    [self kvoTest];
}

#pragma mark -

- (void)autoreleaseTest {
    dispatch_queue_t zdQueue = dispatch_queue_create("zdQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(zdQueue, ^{
        if ([NSThread isMainThread]) {
            NSLog(@"主线程");
        }
        
        
        for (NSUInteger i = 0; i < 500000; i++) {
            @autoreleasepool {
                // 说明：当在一个特别多的循环里创建多个临时变量时，需要加上@autoreleasepool，不加的话会导致内存升高
                NSNumber *num = [NSNumber numberWithUnsignedInteger:i];
                NSString *str = [NSString stringWithFormat:@"%zd ", i];
                [NSString stringWithFormat:@"%@%@", num, str];
                
                if (i % 3 == 0) {
                    __unused NSString *str = [NSString stringWithFormat:@"%f", ZD_MemoryUsage()];
                    //NSLog(@"   %@", str);
                }
            }
        }
    });
    
    dispatch_sync(zdQueue, ^{
        NSLog(@"Over");
    });
}

- (void)associateTest {
    NSObject *objc = [NSObject new];
    void *key = &key;
    {
        NSObject *weakObjc = [NSObject new];
        [objc zd_setWeakAssociateValue:weakObjc forKey:key];
        id a = [objc zd_getWeakAssociateValueForKey:key];
        NSLog(@"%@", a);
    }
    id b = [objc zd_getWeakAssociateValueForKey:key];
    NSLog(@"%@", b);
    
    NSPointerArray *arr = [NSPointerArray weakObjectsPointerArray];
    {
        NSObject *obj = [NSObject new];
        [arr addPointer:(__bridge void *)obj];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id s = [arr pointerAtIndex:0];
        NSArray *objcs = arr.allObjects;
        NSLog(@"%@, %@", s, objcs);
    });
    id s = [arr pointerAtIndex:0];
    NSArray *objcs = arr.allObjects;
    NSLog(@"%@, %@", s, objcs);
}

- (void)clickTextTest {
    self.imageView.zd_touchExtendInsets = UIEdgeInsetsMake(50, 50, 50, 50);
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.imageView addGestureRecognizer:tap];
    
    NSString *text = @"链接地址: www.baidu.com";
#if 1
    self.zdLabel.text = text;
    self.zdLabel.zd_edgeInsets = UIEdgeInsetsMake(10, 20, 0, 0);
    //self.zdLabel.zdAlignment = ZDAlignment_Bottom;
    [self.zdLabel sizeToFit];
#else
    NSRange range = [text rangeOfString:@"www.baidu.com"];
    [self.zdLabel addTarget:self action:@selector(textActionWithParams::) params:@[@"参数1", @"参数2"] ranges:@[[NSValue valueWithRange:range]]];
#endif
}

- (void)kvoTest {
    [self zd_addObserver:self forKeyPath:@"count1" options:NSKeyValueObservingOptionNew changeBlock:^(id object, NSDictionary<NSKeyValueChangeKey,id> *change) {
        NSNumber *number = change[NSKeyValueChangeNewKey];
        NSLog(@"============ kvo1: %@", number);
    }];
    
    [self zd_addObserver:self forKeyPath:@"count2" options:NSKeyValueObservingOptionNew changeBlock:^(id object, NSDictionary<NSKeyValueChangeKey,id> *change) {
        NSNumber *number = change[NSKeyValueChangeNewKey];
        NSLog(@"============ kvo2: %@", number);
    }];
}

- (void)deadLock {
    dispatch_semaphore_t signal = dispatch_semaphore_create(0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"执行了");
        dispatch_semaphore_signal(signal);
    });
    dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
}

#pragma mark -

- (void)textActionWithParams:(NSString *)param1 :(NSString *)param2 {
    NSLog(@"www.baidu.com被点击了,参数:\n%@, %@", param1, param2);
}

- (void)tapAction {
    NSLog(@"点到了。。。。。。");
}

- (NSString *)executeMethodWithStr:(NSString *)str num:(NSUInteger)num {
    NSString *string = [NSString stringWithFormat:@"%@ + %zd", str, num];
    return string;
}

- (IBAction)click:(UIButton *)sender forEvent:(UIEvent *)event {    
    ZD_Dispatch_throttle_on_mainQueue(ZDThrottleType_Invoke_First, 3, ^{
        NSLog(@"throttle方法执行了");
    });
    
    ++self.count1;
    
    ++self.count2;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
