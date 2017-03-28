//
//  NSString+Addition.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Addition)

/**
 字符串md5加密
 */
- (NSString *)md5With32Bit;

/**
 计算单行行宽
 */
- (CGFloat)commonStringWidthForFont:(CGFloat)fontSize;

/**
 计算行高
 */
- (CGFloat)commonStringHeighforLabelWidth:(CGFloat)width withFontSize:(CGFloat)fontSize;

/**
 计算文本最后一个字坐标点,需输入Label的frame值
 */
- (CGPoint)commonStringLastPointWithLabelFrame:(CGRect)frame withFontSize:(CGFloat)fontSize;
// 可以在此处弄一个系统后台返回错误码的弹窗

@end
