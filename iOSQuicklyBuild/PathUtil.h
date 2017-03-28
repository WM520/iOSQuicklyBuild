//
//  PathUtil.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathUtil : NSObject

+ (void)ensureLocalDirsPresent;

//数据库文件路径
+ (NSString *)fmdbFilePath;

//document文件夹路径
+ (NSString *)documentsPath;

//获取main bundle根目录中名称为@name的资源的路径
+ (NSString *)pathOfResourceNamed:(NSString*)name;

//获取main bundle下指定目录中名称为@name的资源的路径
+ (NSString *)pathOfResourceNamed:(NSString *)name inBundleDir:(NSString*)dir;

+ (NSString*)rootPathOfUser;

//用户信息列表
+ (NSString*)pathOfUserInfo;

//用户头像
+ (NSString *)pathUserHeadPic;

@end
