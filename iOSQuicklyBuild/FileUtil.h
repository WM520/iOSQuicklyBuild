//
//  FileUtil.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/xattr.h>

@interface FileUtil : NSObject

//为文件或文件夹添加“Do Not Backup”属性
//该属性只有在iOS 5.0.1+才有真正意义
//详情参考：
//http://www.cocoachina.com/bbs/read.php?tid=86244
+ (BOOL)addSkipBackupAttributeForPath:(NSString *)path;

+ (long long) fileSizeAtPath:(NSString*) filePath;

//判断某个路径是否是文件夹
+ (BOOL)isPathDir:(NSString*)path;

//判断某个文件是否存在
+ (BOOL)fileExists:(NSString*)path;

//判断某个目录是否存在
+ (BOOL)dirExists:(NSString*)path;

//确保某个路径的父目录路径存在
//例：
//path=@"/dir1/dir2/dir3/file"==>本函数会保证/dir1/dir2/dir3/这个路径存在
//path=@"/dir1/dir2/dir3/dir4"==>本函数会保证/dir1/dir2/dir3/这个路径存在
+ (void)ensureSuperPathExists:(NSString*)path;

//确保某个文件夹存在
+ (BOOL)ensureDirExists:(NSString*)dir;

//清空某个目录下的所有内容
+ (BOOL)deleteContentsOfDir:(NSString*) dir;

//清空某个目录下的所有内容除了指定的文件
+ (BOOL)deleteContentsOfDir:(NSString*) dir without:(NSString*)fileName;

//清空某个目录下的所有内容除了指定的几个文件
+ (BOOL)deleteContentsOfDir:(NSString*) dir withoutFiles:(NSArray*)fileNameArray;

//异步清空某个目录下的所有内容
+ (void)deleteContentsOfDir:(NSString*) dir withCompletionHandler:(void(^)(BOOL succeeded))handler;

//删除目录以及该目录下所有内容
+ (BOOL)deleteDirAndContents:(NSString*) dir;

//删除指定文件
+ (BOOL)deleteFileAtPath:(NSString*) file;

//移动指定文件，可用于重命名
+ (BOOL)moveFileAtPath:(NSString*) file toPath:(NSString*) path;

//获取某个目录下所有的子目录名
+ (NSArray*)getSubdirNamesOfDir:(NSString*) dir;

//将某个目录下的所有内容拷贝到目标文件夹
+ (BOOL)copyContentsOfDir:(NSString*)dir toDir:(NSString*)targetDir;

//异步计算某个目录下所有内容的总size
+ (void)calcContentsSizeOfDir:(NSString*)dir withCompletionHandler:(void(^)(double totalBytes))handler;

//同步计算某个目录下所有内容的总size除了指定文件
+ (double)calcContentsSizeOfDir:(NSString *)dir without:(NSString*)fileName;

@end
