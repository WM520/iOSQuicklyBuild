//
//  UIColor+HexColor.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (HexColor)

+ (UIColor *) ColorWithRandomColor
{
    CGFloat R = ( arc4random() % 256 / 256.0 );
    CGFloat G = ( arc4random() % 256 / 256.0 );
    CGFloat B = ( arc4random() % 256 / 256.0 );
    return [UIColor colorWithRed:R green:G blue:B alpha:1.0f];
}

//默认alpha值为1
+ (UIColor *) colorWithHex:(NSString*)hexString
{
    return [self colorWithHexString:hexString alpha:1.0f];
}

/**
 *  get UIClolor from hex string你传进来一段字符串 用来标记颜色的  例如 0x开头 #开头 先把其中有可能的空格删除 再去解析颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}


@end
