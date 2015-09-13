//
//  ZDFunction.h
//  ZDUtility
//
//  Created by 符现超 on 15/9/13.
//  Copyright (c) 2015年 Fate.D.Saber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//MARK:gif 图片
/**
 Loads an animated GIF from file, compatible with UIImageView
 */
UIImage *ZDAnimatedGIFFromFile(NSString *path);

/**
 Loads an animated GIF from data, compatible with UIImageView
 */
UIImage *ZDAnimatedGIFFromData(NSData *data);

//MARK:字符串
///设置文字行间距
UIKIT_EXTERN NSMutableAttributedString* SetAttributeString(NSString *string, CGFloat lineSpace, CGFloat fontSize);

///筛选设置文字color
UIKIT_EXTERN NSMutableAttributedString* SetAttributeStringByFilterStringAndColor(NSString *orignString, NSString *filterString, UIColor *filterColor);

///处理字符串
UIKIT_EXTERN NSString *UrlEncodedString(NSString *sourceText);


//MARK: Runtime
void PrintObjectMethods(void);