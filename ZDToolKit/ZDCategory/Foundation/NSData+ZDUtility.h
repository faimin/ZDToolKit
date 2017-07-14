//
//  NSData+ZDUtility.h
//  Pods
//
//  Created by Zero.D.Saber on 2017/7/14.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (ZDUtility)

- (NSString *)zd_hexString;
+ (NSData *)zd_dataWithHexString:(NSString *)hexStr;

- (NSString *)zd_md5String;
- (NSData *)zd_md5Data;

- (NSString *)zd_sha1String;
- (NSData *)zd_sha1Data;

@end

NS_ASSUME_NONNULL_END
