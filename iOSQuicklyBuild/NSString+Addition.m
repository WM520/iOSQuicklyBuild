//
//  NSString+Addition.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "NSString+Addition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Addition)
- (NSString *)md5With32Bit
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [hash appendFormat:@"%02X", result[i]];
    }
    
    return [hash lowercaseString];
}

- (CGFloat)commonStringWidthForFont:(CGFloat)fontSize
{
    CGFloat width = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size.width;
    return width;
}

- (CGFloat)commonStringHeighforLabelWidth:(CGFloat)width withFontSize:(CGFloat)fontSize
{
    CGFloat heigh = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size.height;
    return heigh;
}

- (CGPoint)commonStringLastPointWithLabelFrame:(CGRect)frame withFontSize:(CGFloat)fontSize;
{
    CGPoint lastPoint;
    CGSize sz = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
    CGSize lineSize = [self boundingRectWithSize:CGSizeMake(frame.size.width, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
    if(sz.width <= lineSize.width) //判断是否折行
    {
        lastPoint = CGPointMake(frame.origin.x + sz.width, frame.origin.y);
    }
    else
    {
        lastPoint = CGPointMake(frame.origin.x + (int)sz.width % (int)lineSize.width,lineSize.height + sz.height);
    }
    return lastPoint;
}

@end
