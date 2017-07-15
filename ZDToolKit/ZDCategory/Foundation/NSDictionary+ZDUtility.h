//
//  NSDictionary+ZDUtility.h
//  Pods
//
//  Created by Zero on 2017/5/20.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (ZDUtility)

- (void)zd_storeToKeychainWithKey:(NSString *)aKey;

- (void)zd_deleteFromKeychainWithKey:(NSString *)aKey;

+ (nullable NSDictionary *)zd_dictionaryFromKeychainWithKey:(NSString *)aKey;

@end

NS_ASSUME_NONNULL_END
