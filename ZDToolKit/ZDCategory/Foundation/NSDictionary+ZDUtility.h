//
//  NSDictionary+ZDUtility.h
//  Pods
//
//  Created by Zero on 2017/5/20.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ZDUtility)

- (void)zd_storeToKeychainWithKey:(NSString *)aKey;

- (void)zd_deleteFromKeychainWithKey:(NSString *)aKey;

+ (NSDictionary *)zd_dictionaryFromKeychainWithKey:(NSString *)aKey;

@end
