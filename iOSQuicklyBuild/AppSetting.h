//
//  AppSetting.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

#define USERNAME_KEY @"userloginname"
#define USERPWD_LEY @"userpwd"

#define GOTOHOMEPAGE    @"gotohomepage"
#define STRINGKEY_DEVICE_ID @"key0412"              //设备号

@interface AppSetting : NSObject

{
    NSUserDefaults* userDefaults;
}

+ (AppSetting *)sharedInstance;


- (void)setInteger:(NSInteger)value forKey:(NSString *)keyName;
- (void)setFloat:(float)value forKey:(NSString *)keyName;
- (void)setDouble:(double)value forKey:(NSString *)keyName;
- (void)setBool:(BOOL)value forKey:(NSString *)keyName;
- (void)setString:(NSString *)value forKey:(NSString *)keyName;
- (void)setURL:(NSURL *)value forKey:(NSString *)keyName;
- (void)setDate:(NSDate*)value forkey:(NSString *)keyName;

- (NSString *)stringForKey:(NSString *)keyName;
- (NSInteger)integerForKey:(NSString *)keyName;
- (float)floatForKey:(NSString *)keyName;
- (double)doubleForKey:(NSString *)keyName;
- (BOOL)boolForKey:(NSString *)keyName;
- (NSURL *)urlForKey:(NSString *)keyName;
- (NSDate*)dateForKey:(NSString *)keyName;

//个人数据
- (UserModel *)loginObject;
//个人信息保存到本地
-(void)loginsaveCache:(UserModel *)model;
//照相机权限判断
- (BOOL)isCameraAuthority;


@end
