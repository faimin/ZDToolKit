//
//  NSString+ZDUtility.h
//  ZDUtility
//
//  Created by 符现超 on 15/12/26.
//  Copyright © 2015年 Fate.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZDRegex) {
    /**
     手机号以13，14，15，17，18开头，八个 \d 数字字符
     最全的正则：^(0|86|17951)?(13[0-9]|14[57])[0-9]{8}|15[012356789]|17[678]|18[0-9]$
    */
    ZDRegex_PhoneNumber = 1,
    ZDRegex_SMSVerifyCode,          ///< 短信验证码(6位纯数字的格式)
    ZDRegex_Nickname,               ///< 昵称(只能由中文、字母或数字组成)
    ZDRegex_Password,               ///< 密码(长度应为6-16个字符,密码必须包含字母和数字)
    ZDRegex_RealName,               ///< 实名认证(汉字)
    ZDRegex_Email,                  ///< 邮箱
};

static NSString *ZDRegexStr[] = {
    //@"^(0|86|17951)?(13[0-9]|14[57])[0-9]{8}|15[012356789]|17[678]|18[0-9]$"
    [ZDRegex_PhoneNumber] = @"^1[34578]\\d{9}$",
    [ZDRegex_SMSVerifyCode] = @"^\\d{6}$",
    [ZDRegex_Nickname] = @"^[A-Za-z0-9\u4e00-\u9fa5]{3,20}$",
    [ZDRegex_Password] = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,16}",
    [ZDRegex_RealName] = @"^[\u4E00-\u9FA5]{2,4}$",
    [ZDRegex_Email] = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}",
};


@interface NSString (ZDUtility)

//MARK: Size
///宽和高都是0的时候为默认值CGFloat_MAX
- (CGFloat)widthWithFont:(UIFont *)font;
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width height:(CGFloat)height;

//MARK: Emoji
- (BOOL)isContainsEmoji;
- (NSString *)filterEmoji;
- (NSString *)removeHalfEmoji;

//MARK: Function
- (NSString *)reservedNumberOnly;
- (NSString *)reverse;
- (BOOL)isContainsString:(NSString *)string;
- (BOOL)isAllNumber;

//MARK: Validate
- (BOOL)isValidWithRegex:(ZDRegex)regex;
- (BOOL)isValidEmail;
- (BOOL)isValidIdCard;
- (BOOL)isValidCardNo;

//MARK: JSON
- (NSDictionary *)dictionaryValue;
+ (NSString *)stringValueFromJson:(id)arrayOrDic;

//MARK: HTML
- (NSString *)decodeHTMLCharacterEntities;
- (NSString *)encodeHTMLCharacterEntities;

//MARK: Decode/Encode
- (NSString *)stringByAddingPercentEncodingForRFC3986;
- (NSString *)stringByAddingPercentEncodingForFormData:(BOOL)plusForSpace;
- (NSString *)stringByURLEncode;
- (NSString *)stringByURLDecode;

@end
