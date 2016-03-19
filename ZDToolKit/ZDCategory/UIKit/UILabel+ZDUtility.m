//
//  UILabel+ZDUtility.m
//  ZDToolKitDemo
//
//  Created by 符现超 on 16/3/19.
//  Copyright © 2016年 Zero.D.Saber. All rights reserved.
//

#import "UILabel+ZDUtility.h"

@implementation UILabel (ZDUtility)

- (CGSize)contentSize
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.alignment = self.textAlignment;
    
    NSDictionary * attributes = @{NSFontAttributeName : self.font, NSParagraphStyleAttributeName : paragraphStyle};
    
    CGSize contentSize = [self.text boundingRectWithSize:self.frame.size
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:attributes
                                                 context:nil].size;
    return contentSize;
}

@end
