//
//  PathUtil.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "PathUtil.h"
#import "FileUtil.h"


static NSString* DOCPATH = nil;

#define UserDir @"User"

@implementation PathUtil

+ (void)ensureLocalDirsPresent
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    NSString* dir = [[self documentsPath]stringByAppendingPathComponent:UserDir];
    NSLog(@"dir: %@", dir);
    
    [fm createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
    
    
    //DO NOT BACKUP
    [FileUtil addSkipBackupAttributeForPath:[self documentsPath]];  //保险起见，把documents根目录也设为DO NOT BACKUP
    [FileUtil addSkipBackupAttributeForPath:dir];
}

+ (NSString *)fmdbFilePath
{
    return [[self documentsPath] stringByAppendingPathComponent:@"FMDB.sqlite"];
}

+ (NSString *)documentsPath
{
    if(!DOCPATH)
    {
        DOCPATH = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return DOCPATH;
}

+ (NSString *)pathOfResourceNamed:(NSString*)name
{
    return [[NSBundle mainBundle] pathForResource:[[name lastPathComponent] stringByDeletingPathExtension] ofType:[name pathExtension]];
}

+ (NSString *)pathOfResourceNamed:(NSString *)name inBundleDir:(NSString*)dir
{
    return [[NSBundle mainBundle] pathForResource:[[name lastPathComponent] stringByDeletingPathExtension] ofType:[name pathExtension] inDirectory:dir];
}

+ (NSString*)rootPathOfUser
{
    return [[self documentsPath] stringByAppendingPathComponent:UserDir];
}

+ (NSString*)pathOfUserInfo
{
    NSString *userPath = [[self rootPathOfUser] stringByAppendingPathComponent:@"userinfo.txt"];
    return userPath;
}

+ (NSString *)pathUserHeadPic{
    return [[self rootPathOfUser] stringByAppendingPathComponent:@"headPic.png"];
}


@end
