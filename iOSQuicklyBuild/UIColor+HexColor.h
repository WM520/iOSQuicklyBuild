//
//  UIColor+HexColor.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

+ (UIColor *) ColorWithRandomColor;
+ (UIColor *) colorWithHex:(NSString*)hexString;


@end
