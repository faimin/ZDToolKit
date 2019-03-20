//
//  ZDOrderedDictionary.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2019/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDOrderedDictionary<__covariant KeyType, __covariant ObjectType> : NSObject <NSFastEnumeration>

@property (nonatomic, copy, readonly) NSArray<KeyType> *allKeys;
@property (nonatomic, copy, readonly) NSArray<ObjectType> *allValues;

- (void)setObject:(ObjectType)anObject forKey:(KeyType<NSCopying>)aKey;
- (void)removeObjectForKey:(KeyType<NSCopying>)aKey;
- (void)insertObject:(ObjectType)anObject forKey:(KeyType<NSCopying>)aKey atIndex:(NSInteger)index;
- (id)objectAtIndex:(NSInteger)index;
- (id)objectForKey:(KeyType<NSCopying>)aKey;
- (void)removeAllObjects;

/// 实现下标语法糖
- (ObjectType)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(ObjectType)obj atIndexedSubscript:(NSUInteger)idx NS_UNAVAILABLE;
- (ObjectType)objectForKeyedSubscript:(KeyType)key;
- (void)setObject:(ObjectType)obj forKeyedSubscript:(KeyType)key;

@end

NS_ASSUME_NONNULL_END
