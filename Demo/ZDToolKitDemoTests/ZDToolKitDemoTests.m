//
//  ZDToolKitDemoTests.m
//  ZDToolKitDemoTests
//
//  Created by Zero on 16/1/23.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import <XCTest/XCTest.h>
@import ObjectiveC;
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

//- (void)testBlockHook {
//    __auto_type block = ^NSString *(NSInteger count, NSString *str, NSObject *obj) {
//        NSString *result = [NSString stringWithFormat:@"%ld, %@, %@", count*2, str, obj];
//        return result;
//    };
//    id oldBlock = [block copy];
//
//    ZDHookWay hookWay = ZDHookWay_MsgForward;
//    [self zd_hookBlock:&block hookWay:hookWay];
//    id newBlock = [block copy];
//
//    if (hookWay == ZDHookWay_MsgForward) {
//        XCTAssertNotEqual(oldBlock, newBlock);
//    } else if (hookWay == ZDHookWay_Libffi) {
//        XCTAssertEqual(oldBlock, newBlock);
//    }
//
//    NSString *blockResult = block(123, @"2019年01月14日12:04:26", @999);
//    XCTAssertEqualObjects(blockResult, @"246, 2019年01月14日12:04:26, 999");
//}

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
    __auto_type block = ^int{
        zd_defer {
            /// 所谓作用域结束，包括大括号结束、return、goto、break、exception等各种情况
            NSLog(@"当前作用域结束,马上要出作用域了");
            i = 3;
        };
        i = 2;
        
        return 100;
    };
    
    NSLog(@"block result = %d", block());
    
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
        id value = ((NSArray *)nullValue)[1];
        XCTAssertNil(value);
    }
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

- (void)testCalculateTextSize {
    NSString *text = @"1999年，还在上中专艺校的文章就出来拍戏了，但都是饰演一些小角色。2004年，还在中央戏剧学院表演系读书的文章，在《与青春有关的日子》中成功饰演了卓越。虽然只是一个配角，但是他让文章逐渐为观众所熟悉。之后，他又在《奋斗》、《暗流》、《蜗居》、《雪豹》、《海洋天堂》等影视剧作中有突出表现，曾在2003年韩国釜山艺术节上，获“最佳男演员奖”。2009年，第十二届上海国际电影节“电影频道传媒大奖” 最佳新人奖；2010年，凭借《海洋天堂》获第十三届上海国际电影节“电影频道传媒大奖” 最佳男主角";
    
    UIFont *font = [UIFont systemFontOfSize:16];
    //CGSize coreTextSize = ZD_CalculateStringSize(text, font, (CGSize){414, CGFLOAT_MAX}, 4, 0);
    CGSize foundationSize = ZD_CalculateStringSize(text, font, (CGSize){414, CGFLOAT_MAX}, nil);
    NSLog(@"####### %@", NSStringFromCGSize(foundationSize));
}

- (void)testSerialOperation {
    NSMutableArray *allDatas = @[].mutableCopy;
    
    NSOperationQueue *myOperationQueue = [[NSOperationQueue alloc] init];
    myOperationQueue.maxConcurrentOperationCount = 1;
    
    ZDConcurrentOperation *op1 = [ZDConcurrentOperation operationWithBlock:^(ZDTaskOnComplteBlock  _Nonnull taskFinishCallback) {
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://api.douban.com/v2/movie/top250"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [allDatas addObject:data];
            NSLog(@"第一个任务结束");
            taskFinishCallback(YES);
        }];
        [task resume];
    }];
    
    ZDConcurrentOperation *op2 = [ZDConcurrentOperation operationWithBlock:^(ZDTaskOnComplteBlock  _Nonnull taskFinishCallback) {
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://www.weather.com.cn/data/cityinfo/101010100.html"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [allDatas addObject:data];
            NSLog(@"第二个任务结束");
            taskFinishCallback(YES);
        }];
        [task resume];
    }];
    
    [myOperationQueue addOperations:@[op1, op2] waitUntilFinished:YES];
    NSLog(@"都下载完毕");

    XCTAssertTrue(allDatas.count == 2);
}

- (void)testMetaClass {
    Class metaClass = objc_getMetaClass(class_getName(NSObject.class));
    Class metaClass2 = objc_getMetaClass(class_getName(NSObject.class));
    Class metaClass3 = objc_getMetaClass(class_getName(metaClass2));
    NSLog(@"NSObjec class的元类 = %p, %p, %p", metaClass, metaClass2, metaClass3);
    
    NSString *metaClassSuperClassName = NSStringFromClass(class_getSuperclass(metaClass));
    NSLog(@"NSObject元类的父类 = %@", metaClassSuperClassName);
    
    Class aClass = object_getClass([NSObject class]);
    if (metaClass == aClass) {
        NSLog(@"类和元类相等");
    }
    if (NSObject.class == aClass) {
        NSLog(@"类和类相等");
    }
    NSLog(@"!!!!!!! 元类：%@, 类：%@", [metaClass description], [aClass description]);
    
    NSObject *objInstance = [NSObject new];
    Class bClass1 = [objInstance class];
    Class bClass2 = object_getClass(objInstance);
    if (bClass1 == bClass2) {
        NSLog(@"class和object_getClass方法获取的类相等");
    }
    
    NSString *objectSuperClassName = NSStringFromClass(class_getSuperclass(aClass));
    NSLog(@"NSObject的父类 = %@", objectSuperClassName);
}

- (void)testInvocation {
    __auto_type block = ^id(id v) {
        return [NSString stringWithFormat:@"blockArg = %@", v];
    };
    
     __auto_type value = [ZDInvocationWrapper<ZDBaseModel *> zd_target:ZDBaseModel.class invokeSelectorWithArgs:@selector(new)];
    XCTAssertNotNil(value);
    
    id result = [ZDInvocationWrapper zd_target:value invokeSelectorWithArgs:@selector(setUrl:), [NSURL URLWithString:@"www.google.com"]];
    XCTAssertNil(result);
    
    [ZDInvocationWrapper zd_target:value invokeSelectorWithArgs:@selector(setBlock:), block];
    id(^b)(id) = [ZDInvocationWrapper zd_target:value invokeSelectorWithArgs:@selector(block)];
    if (b) {
        id x = b(@123);
        NSLog(@" ==== %@", x);
    }
    NSLog(@"#### %@, %@", value.url, result);
}

@end
