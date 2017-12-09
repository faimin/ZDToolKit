//
//  NSObject+RZBlockKVO.m
//
//  Created by Nick Donaldson on 10/21/13.

// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSObject+ZDBlockKVO.h"
#import <objc/runtime.h>

static void *kZDAssociatedObservationsKey = &kZDAssociatedObservationsKey;

@interface ZDBlockObservation : NSObject

/// @note
/// 这里用`unsafe_unretained`而没用`weak`是因为当`observedObject`即将释放时(e.g:在`observedObject`的`dealloc`方法里),
/// `observedObject`就已经变为`nil`了,虽然`observedObject`还没有真正释放吧(`observedObject`会先释放其关联对象后才会释放),
/// 这样就会导致在`ZDBlockObservation`的`dealloc`方法中无法移除观察者了。
@property (nonatomic, unsafe_unretained) NSObject *observedObject;
@property (nonatomic, unsafe_unretained) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) ZDKVOChangeBlock block;

- (instancetype)initWithObservedObject:(NSObject *)object observer:(NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(ZDKVOChangeBlock)block;

@end

// -------------

@implementation NSObject (ZDBlockKVO)

#pragma mark - Auto Remove

- (void)zd_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options withChangeBlock:(ZDKVOChangeBlock)block {
    ZDBlockObservation *observation = [[ZDBlockObservation alloc] initWithObservedObject:self observer:observer keyPath:keyPath options:options block:block];
    objc_setAssociatedObject(self, kZDAssociatedObservationsKey, observation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

// ----------

@implementation ZDBlockObservation

- (void)dealloc {
    if ( self.observedObject ) {
        @try {
            [self.observedObject removeObserver:self forKeyPath:self.keyPath];
        }
        @catch (NSException *exception) {}
    }
}

- (instancetype)initWithObservedObject:(NSObject *)object observer:(NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(ZDKVOChangeBlock)block {
    if ( self = [super init] ) {
        self.observedObject = object;
        self.observer = observer;
        self.keyPath = keyPath;
        self.block = block;
        
        [object addObserver:self forKeyPath:keyPath options:options context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if ( self.block ) {
        self.block(object, change);
    }
}

@end
