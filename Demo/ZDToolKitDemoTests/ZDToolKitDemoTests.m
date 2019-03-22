//
//  ZDToolKitDemoTests.m
//  ZDToolKitDemoTests
//
//  Created by Zero on 16/1/23.
//  Copyright © 2016年 Zero.D.Bourne. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ZDToolKit/ZDToolKit.h>
#import "ZDModel.h"

@interface ZDToolKitDemoTests : XCTestCase

@end

@implementation ZDToolKitDemoTests

- (void)setUp {
    NSLog(@"测试开始");
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    NSLog(@"测试结束");
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testBlockHook {
    __auto_type block = ^NSString *(NSInteger count, NSString *str, NSObject *obj) {
        NSString *result = [NSString stringWithFormat:@"%ld, %@, %@", count*2, str, obj];
        return result;
    };
    id oldBlock = [block copy];
    
    ZDHookWay hookWay = ZDHookWay_MsgForward;
    [self zd_hookBlock:&block hookWay:hookWay];
    id newBlock = [block copy];
    
    if (hookWay == ZDHookWay_MsgForward) {
        XCTAssertNotEqual(oldBlock, newBlock);
    } else if (hookWay == ZDHookWay_Libffi) {
        XCTAssertEqual(oldBlock, newBlock);
    }
    
    NSString *blockResult = block(123, @"2019年01月14日12:04:26", @999);
    XCTAssertEqualObjects(blockResult, @"246, 2019年01月14日12:04:26, 999");
}

- (void)testMutcopy {
    ZDModel *model = ({
        ZDModel *model = [ZDModel new];
        model.value = self;
        model.name = @"晓明";
        model.age = 10;
        model.sex = @"男";
        model.myName = @"快聊";
        model.myAge = 28;
        model.myValue = [UIView new];
        model.url = [NSURL URLWithString:@"www.google.com"];
        model;
    });
    
    ZDModel *newModel = [model zd_mutableCopy];
    
    NSLog(@"%@, %@, %@", newModel.value, newModel.name, newModel.url);
    
    XCTAssertNotEqual(model, newModel);
    
    XCTAssertEqualObjects(model.value, newModel.value);
    XCTAssertEqualObjects(model.name, newModel.name);
    XCTAssertEqual(model.age, newModel.age);
    XCTAssertEqualObjects(model.sex, newModel.sex);
    XCTAssertEqualObjects(model.myName, newModel.myName);
    XCTAssertEqual(model.myAge, newModel.myAge);
    XCTAssertEqualObjects(model.myValue, newModel.myValue);
    XCTAssertEqualObjects(model.url, newModel.url);
}

- (void)testNumber {
    XCTAssertTrue([@"2345" zd_isAllDigit]);
    XCTAssertFalse([@"123你好" zd_isAllDigit]);
    XCTAssertFalse([@"爱好爱好1234" zd_isAllDigit]);
}

- (void)testFlattenArray {
    NSArray *arr = @[@1, @[@2, @[@3, @4, @[@5, @6, @7, @[@8, @9, @10, @11] ] ] ] ];
    NSMutableArray *mutArray = [arr zd_flatten];
    NSArray *targetArr = @[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9), @(10), @(11)];
    XCTAssertEqualObjects(mutArray, targetArr);
}

- (void)testDefer {
    __block NSInteger i = 1;
    __auto_type block = ^{
        zd_defer {
            /// 所谓作用域结束，包括大括号结束、return、goto、break、exception等各种情况
            NSLog(@"当前作用域结束,马上要出作用域了");
            i = 3;
        };
        i = 2;
    };
    
    block();
    
    XCTAssertEqual(i, 3);
}

- (void)testMainqueue {
    // 同步切换队列时获取到是当前所在线程，而不是目标队列中的子线程
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"当前队列：%@", ZD_IsMainQueue() ? @"主队列" : @"子队列");
        XCTAssertFalse(ZD_IsMainQueue(), @"errorMsg: 当前所在队列：子队列");
        
        NSLog(@"当前线程：%@", pthread_main_np() ? @"主线程" : @"子线程");
        XCTAssertTrue(pthread_main_np() != 0); // 主线程;
    });
    
    // 异步切换队列时获取到是目标队列中的子线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"当前队列：%@", ZD_IsMainQueue() ? @"主队列" : @"子队列");
        XCTAssertFalse(ZD_IsMainQueue(), @"errorMsg: 当前所在队列：子队列");
        
        NSLog(@"当前线程：%@", pthread_main_np() ? @"主线程" : @"子线程");
        XCTAssertTrue(pthread_main_np() == 0); // 子线程
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertTrue(ZD_IsMainQueue(), @"errorMsg: 当前所在队列：子队列");
    });
    
    //dispatch_queue_create("com.zd.saber", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_DEFAULT, 0))
    //ZD_CREATE_SERIAL_QUEUE(com.zd, QOS_CLASS_DEFAULT);
}

- (void)testGetCurrentQueue {
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

- (void)testOrderedDictionary {
    ZDOrderedDictionary *orderedDict = [[ZDOrderedDictionary alloc] init];
    for (NSUInteger i = 0; i < 20; ++i) {
        orderedDict[@(i)] = @(i).stringValue;
    }
    
    orderedDict[@1] = nil;
    orderedDict[@11] = nil;
    NSLog(@"value of index => %@", orderedDict[10]);

    for (NSNumber *key in orderedDict) {
        if ([key isEqualToNumber:@10]) {
            continue;
        }
        NSLog(@"遍历key = %@", key);
    }
    
    XCTAssertEqualObjects(orderedDict[@(0)], @"0");
}

- (void)testSendMsgToNull {
    {
        NSString *jsonString = @"{\"key\":null}";
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSDictionary *errorInstance = dict[@"key"];
        id value1 = errorInstance[@"xxx"];
        XCTAssertEqual(value1, nil);
        
        NSMutableArray *mutArr = dict[@"key"];
        [mutArr addObject:@1];
    }
    
    id nullValue = [NSNull null];
    {
        NSString *result = [nullValue stringValue];
        XCTAssertNil(result);
    }
    {
        const void *result = [nullValue bytes];
        XCTAssertNil((__bridge id)result);
    }
    {
        NSString *result = NSStringFromClass([nullValue class]);
        XCTAssertEqualObjects(result, @"NSNull");
    }
}

@end
