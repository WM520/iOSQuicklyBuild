//
//  NSDictionary+NULL.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "NSDictionary+NullDeal.h"

@implementation NSDictionary (NullDeal)

//将NSDictionary中的Null类型的项目转化成@""
+(NSDictionary *)nullDic:(NSDictionary *)myDic
{
    NSArray *keyArr = [myDic allKeys];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < keyArr.count; i ++)
    {
        id obj = [myDic objectForKey:keyArr[i]];
        obj = [self changeType:obj];
        [resDic setObject:obj forKey:keyArr[i]];
    }
    return resDic;
}
//将NSDictionary中的Null类型的项目转化成@""
+(NSArray *)nullArr:(NSArray *)myArr

{
    NSMutableArray *resArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < myArr.count; i ++)
    {
        id obj = myArr[i];
        obj = [self changeType:obj];
        [resArr addObject:obj];
    }
    return resArr;
}


//将NSString类型的原路返回
+(NSString *)stringToString:(NSString *)string

{
    return string;
}


//将Null类型的项目转化成@""
+ (NSString *)nullToString
{
    return @"";
}
/**
 对数据进行处理

 @param myObj 要处理的数据
 @return 处理后的数据
 */
+ (id)changeType:(id)myObj
{
    if ([myObj isKindOfClass:[NSDictionary class]]) {
        return [self nullDic:myObj];
    } else if([myObj isKindOfClass:[NSArray class]]) {
        return [self nullArr:myObj];
    } else if([myObj isKindOfClass:[NSString class]]) {
        return [self stringToString:myObj];
    } else if([myObj isKindOfClass:[NSNull class]]) {
        return [self nullToString];
    } else {
        return myObj;
    }
}

@end
