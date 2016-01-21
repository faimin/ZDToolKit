//
//  NSString+ZDUtility.h
//  ZDUtility
//
//  Created by 符现超 on 15/12/26.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (ZDUtility)

///宽和高都是0的时候为默认值CGFloat_MAX
- (CGFloat)widthWithFont:(UIFont *)font;
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width height:(CGFloat)height;

- (BOOL)isContainsEmoji;
- (NSString *)filterEmoji;
- (NSString *)removeHalfEmoji;

- (NSString *)reservedNumberOnly;
- (NSString *)reverse;
- (BOOL)isContainsString:(NSString *)string;
- (BOOL)isAllNumber;
- (BOOL)isValidEmail;

- (NSDictionary *)dictionaryValue;
+ (NSString *)stringValueFromJson:(id)arrayOrDic;

- (NSString *)decodeHTMLCharacterEntities;
- (NSString *)encodeHTMLCharacterEntities;

- (NSString *)stringByAddingPercentEncodingForRFC3986;
- (NSString *)stringByAddingPercentEncodingForFormData:(BOOL)plusForSpace;
- (NSString *)stringByURLEncode;
- (NSString *)stringByURLDecode;

@end
