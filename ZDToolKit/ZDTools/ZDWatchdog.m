//
//  ZDWatchdog.m
//  Pods
//
//  Created by Zero on 2016/12/8.
//
//

#import "ZDWatchdog.h"
#import <execinfo.h>

@interface ZDWatchdog ()
{
    CFRunLoopObserverRef _observer;
    @public
    dispatch_semaphore_t _semaphore;
    CFRunLoopActivity _activity;
}
@end

@implementation ZDWatchdog

#pragma mark - Lify Cycle

+ (instancetype)shareInstance {
    static ZDWatchdog *watchdog = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!watchdog) {
            watchdog = [[self alloc] init];
        }
    });
    return watchdog;
}

#pragma mark - Public Method

static void RunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    ZDWatchdog *watchdog = (__bridge ZDWatchdog *)(info);
    watchdog->_activity = activity;
    
    dispatch_semaphore_signal(watchdog->_semaphore);
}

- (void)start {
    if (_observer) return;
    
    // 创建添加观察者
    CFRunLoopObserverContext context;//{0, (__bridge void*)self, NULL, NULL, NULL}
    context.version         = 0;
    context.info            = (__bridge void *)self;
    context.retain          = NULL;
    context.release         = NULL;
    context.copyDescription = NULL;
    _observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                        kCFRunLoopAllActivities,
                                        true,
                                        0,
                                        &RunLoopObserverCallBack,
                                        &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    
    _semaphore = dispatch_semaphore_create(0);
    
    // 在子线程监控
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger timeoutCount = 0; // 一次循环过程中的卡顿次数
        
        while (true) {
            //超时后返回非0值,未超时返回0。默认等待50毫秒（0.05秒）
            long semaphoreResult = dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, (self.timeInterval>0 ?: 50) * NSEC_PER_MSEC));
            if (semaphoreResult != 0) { //超时
                //runloop观察者不存在时，所有条件重置
                if (!_observer) {
                    timeoutCount = 0;
                    _semaphore = NULL;
                    _activity = 0;
                }
                
                if (_activity == kCFRunLoopBeforeSources || _activity == kCFRunLoopAfterWaiting) {
                    if (++timeoutCount < 5) {
                        continue;
                    } else {
                        [self printTrace];
                    }
                }
            }
            //不超时的时候把卡顿次数重置为0（超时时执行++操作，然后continue，跳过此处）
            timeoutCount = 0;
        }
    });
}

- (void)stop {
    if (!_observer) return;
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
    CFRelease(_observer);
    _observer = NULL;
}

#pragma mark - Private Method

- (void)printTrace {
    void* callstack[128];
    int count = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, count);
    NSMutableArray *backtraceArr = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [backtraceArr addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    NSLog(@"zzzz===> \n%@", backtraceArr);
}


@end







