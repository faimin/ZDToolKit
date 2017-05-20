//
//  NSDictionary+ZDUtility.h
//  Pods
//
//  Created by Zero on 2017/5/20.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ZDUtility)

- (void)storeToKeychainWithKey:(NSString *)aKey;

- (void)deleteFromKeychainWithKey:(NSString *)aKey;

+ (NSDictionary *)dictionaryFromKeychainWithKey:(NSString *)aKey;

@end
