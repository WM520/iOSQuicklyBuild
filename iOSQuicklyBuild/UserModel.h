//
//  UserModel.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
// 用户名
@property (copy, nonatomic) NSString * username;
// 性别
@property (copy, nonatomic) NSString * sex;
// 手机号
@property (copy, nonatomic) NSString * mobile;
// 头像url
@property (copy, nonatomic) NSString * useravatar;



@end
