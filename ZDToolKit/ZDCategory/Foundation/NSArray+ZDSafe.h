//
//  NSArray+ZDSafe.h
//  ZDToolKit
//
//  Created by Zero.D.Saber on 2023/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (ZDSafe)

- (ObjectType)objectAtIndex:(NSUInteger)index kindOfClass:(Class)aClass;
- (ObjectType)objectAtIndex:(NSUInteger)index memberOfClass:(Class)aClass;

- (ObjectType)objectAtIndex:(NSUInteger)index defaultValue:(ObjectType)value;
- (NSString *)stringAtIndex:(NSUInteger)index defaultValue:(NSString *)value;
- (NSNumber *)numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)value;
- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)value;
- (NSArray *)arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)value;
- (NSData *)dataAtIndex:(NSUInteger)index defaultValue:(NSData *)value;
- (NSDate *)dateAtIndex:(NSUInteger)index defaultValue:(NSDate *)value;
- (float)floatAtIndex:(NSUInteger)index defaultValue:(float)value;
- (double)doubleAtIndex:(NSUInteger)index defaultValue:(double)value;
- (NSInteger)integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)value;
- (NSUInteger)unintegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)value;
- (BOOL)boolAtIndex:(NSUInteger)index defaultValue:(BOOL)value;

+ (ObjectType)array:(NSArray *)array objectAtIndex:(NSUInteger)index defaultValue:(ObjectType)value;
+ (NSString *)array:(NSArray *)array stringAtIndex:(NSUInteger)index defaultValue:(NSString *)value;
+ (NSNumber *)array:(NSArray *)array numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)value;
+ (NSDictionary *)array:(NSArray *)array dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)value;
+ (NSArray *)array:(NSArray *)array arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)value;
+ (NSData *)array:(NSArray *)array dataAtIndex:(NSUInteger)index defaultValue:(NSData *)value;
+ (NSDate *)array:(NSArray *)array dateAtIndex:(NSUInteger)index defaultValue:(NSDate *)value;
+ (float)array:(NSArray *)array floatAtIndex:(NSUInteger)index defaultValue:(float)value;
+ (double)array:(NSArray *)array doubleAtIndex:(NSUInteger)index defaultValue:(double)value;
+ (NSInteger)array:(NSArray *)array integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)value;
+ (NSUInteger)array:(NSArray *)array unintegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)value;
+ (BOOL)array:(NSArray *)array boolAtIndex:(NSUInteger)index defaultValue:(BOOL)value;

@end

@interface NSMutableArray<ObjectType> (Safe)

- (void)removeObjectAtIndexInBoundary:(NSUInteger)index;
- (void)insertObject:(ObjectType)anObject atIndexInBoundary:(NSUInteger)index;
- (void)replaceObjectAtInBoundaryIndex:(NSUInteger)index withObject:(ObjectType)anObject;

// delete nil & NSNull
- (void)addObjectSafe:(ObjectType)anObject;

@end

NS_ASSUME_NONNULL_END
