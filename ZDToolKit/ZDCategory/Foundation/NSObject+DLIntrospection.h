//
//  NSObject+DLIntrospection.h
//  DLIntrospection
//
//  Created by Denis Lebedev on 12/27/12.
//  Copyright (c) 2012 Denis Lebedev. All rights reserved.
//
/**
 *  https://github.com/garnett/DLIntrospection
 */
#import <Foundation/Foundation.h>

@interface NSObject (DLIntrospection)

+ (NSArray<NSString *> *)classes;
+ (NSArray<NSString *> *)subClasses;
+ (NSArray *)properties;
+ (NSArray *)instanceVariables;
+ (NSArray *)classMethods;
+ (NSArray *)instanceMethods;

+ (NSArray *)protocols;
+ (NSDictionary *)descriptionForProtocol:(Protocol *)proto;

+ (NSString *)parentClassHierarchy;

@end
