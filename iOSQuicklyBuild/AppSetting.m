//
//  AppSetting.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "AppSetting.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation AppSetting
static AppSetting *sharedAppSettings = nil;

+ (AppSetting *)sharedInstance
{
    @synchronized(self){
        if(sharedAppSettings == nil){
            sharedAppSettings = [[self alloc] init];
        }
    }
    return sharedAppSettings;
}

- (id)init
{
    if (self = [super init]) {
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}


#pragma 设置
- (void)setInteger:(NSInteger)value forKey:(NSString *)keyName
{
    [userDefaults setInteger:value forKey:keyName];
    [userDefaults synchronize];
}
- (void)setFloat:(float)value forKey:(NSString *)keyName
{
    [userDefaults setFloat:value forKey:keyName];
    [userDefaults synchronize];
}
- (void)setDouble:(double)value forKey:(NSString *)keyName
{
    [userDefaults setDouble:value forKey:keyName];
    [userDefaults synchronize];
}
- (void)setBool:(BOOL)value forKey:(NSString *)keyName
{
    [userDefaults setBool:value forKey:keyName];
    [userDefaults synchronize];
}
- (void)setString:(NSString *)value forKey:(NSString *)keyName
{
    [userDefaults setObject:value forKey:keyName];
    [userDefaults synchronize];
}
- (void)setURL:(NSURL *)value forKey:(NSString *)keyName
{
    [userDefaults setURL:value forKey:keyName];
    [userDefaults synchronize];
}
- (void)setDate:(NSDate*)value forkey:(NSString *)keyName{
    [userDefaults setObject:value forKey:keyName];
    [userDefaults synchronize];
}

- (NSString *)stringForKey:(NSString *)keyName
{
    NSString *defValue = nil;
    if (![userDefaults objectForKey:keyName]){
        
    }
    else{
        defValue = [userDefaults stringForKey:keyName];
    }
    return defValue;
}
- (NSInteger)integerForKey:(NSString *)keyName
{
    NSInteger defValue = 0;
    if (![userDefaults objectForKey:keyName]) {
        // TODO 添加其它默认参数
        
    }
    else{
        defValue = [userDefaults integerForKey:keyName];
    }
    return defValue;
}
- (float)floatForKey:(NSString *)keyName
{
    float defValue = 0.0f;
    // 在没有值的情况下设置默认值
    if (![userDefaults objectForKey:keyName]){
        //        if ([keyName isEqualToString:FLOATKEY_ReaderBodyFontSize]){
        //            defValue = kWebContentSize2;
        //        }
        // TODO 添加其它默认参数
        
    }
    else{
        defValue = [userDefaults floatForKey:keyName];
    }
    return defValue;
}

- (double)doubleForKey:(NSString *)keyName
{
    double defValue = 0.0;
    if (![userDefaults objectForKey:keyName]){
        // TODO 添加其它默认参数
        
        
    }
    else{
        defValue = [userDefaults doubleForKey:keyName];
    }
    return defValue;
}
- (BOOL)boolForKey:(NSString *)keyName
{
    BOOL defValue = NO;
    if(![userDefaults objectForKey:keyName]){
        
    }
    else{
        defValue = [userDefaults boolForKey:keyName];
    }
    return defValue;
}

- (NSURL *)urlForKey:(NSString *)keyName
{
    NSURL *defValue = nil;
    
    if (![userDefaults objectForKey:keyName]) {
        // TODO 添加其它默认参数
        
        
    }
    else{
        defValue = [userDefaults URLForKey:keyName];
    }
    return defValue;
}
- (NSDate*)dateForKey:(NSString *)keyName{
    NSDate *defValue = nil;
    if (![userDefaults objectForKey:keyName]) {
        // TODO 添加其它默认参数
        
        
    }
    else{
        defValue = [userDefaults objectForKey:keyName];
    }
    return defValue;
}

-(NSString *)loadPath{
    
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/data.login"];
}

- (UserModel *)loginObject
{
    NSMutableData *data=[[NSMutableData alloc] initWithContentsOfFile:[self loadPath]];
    NSKeyedUnarchiver *unarchiver=[[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    UserModel *model = [unarchiver decodeObjectForKey:@"login"];
    [unarchiver finishDecoding];
    
    if (model == nil) {
        model = [[UserModel alloc]init];
    }
    return model;
}

- (void)loginsaveCache:(UserModel *)model
{
    NSMutableData *data=[[NSMutableData alloc] init];
    NSKeyedArchiver *archiver=[[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:model forKey:@"login"];
    [archiver finishEncoding];
    [data writeToFile:[self loadPath] atomically:YES];
}


- (BOOL)isCameraAuthority{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        
        return NO;
        
    }
    return YES;
}

@end
