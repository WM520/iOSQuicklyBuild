//
//  FileUtil.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

//
//  FileUtil.m
//  SurfNewsHD
//
//  Created by yujiuyin on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "FileUtil.h"
#include <stdio.h>
#import <ftw.h>
#import <unistd.h>
#include <sys/socket.h>
#include <pthread.h>
#import "AppDelegate.h"

int cp(const char *from,const char *to)
{
    int fd_to, fd_from;
    char buf[4096];
    ssize_t nread;
    int saved_errno;
    
    fd_from = open(from, O_RDONLY);
    if (fd_from < 0)
        return -1;
    
    fd_to = open(to, O_WRONLY | O_CREAT | O_EXCL, 0666);
    if (fd_to < 0)
        goto out_error;
    
    while (nread = read(fd_from, buf, sizeof buf), nread > 0)
    {
        char *out_ptr = buf;
        ssize_t nwritten;
        
        do {
            nwritten = write(fd_to, out_ptr, nread);
            
            if (nwritten >= 0)
            {
                nread -= nwritten;
                out_ptr += nwritten;
            }
            else if (errno != EINTR)
            {
                goto out_error;
            }
        } while (nread > 0);
    }
    
    if (nread == 0)
    {
        if (close(fd_to) < 0)
        {
            fd_to = -1;
            goto out_error;
        }
        close(fd_from);
        
        /* Success! */
        return 0;
    }
    
out_error:
    saved_errno = errno;
    
    close(fd_from);
    if (fd_to >= 0)
        close(fd_to);
    
    errno = saved_errno;
    return -1;
}

//此函数只能在Mac上调用，因为用到了sendfile(内核模式)
//int BLCopyFile(const char* source, const char* destination)
//{
//    //Here we use kernel-space copying for performance reasons
//    int input, output;
//
//    if( (input = open(source, O_RDONLY)) == -1)
//        return 0;
//
//    if( (output = open(destination, O_WRONLY | O_CREAT)) == -1)
//    {
//        close(input);
//        return 0;
//    }
//
//    off_t bytesCopied;
//
//    int result = sendfile(output, input, 0, &bytesCopied, 0, 0) == -1;
//
//    close(input);
//    close(output);
//
//    return result;
//}

static NSString* del_contents_fn_without_file = NULL;
static __weak NSArray* del_contents_fn_without_file_array = NULL;
int del_contents_fn(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf)
{
    //跳过根文件夹本身
    if (ftwbuf->level == 0)
        return 0;
    
    //跳过指定的文件
    if (del_contents_fn_without_file && [[NSString stringWithCString:fpath encoding:NSUTF8StringEncoding] hasSuffix:del_contents_fn_without_file]) {
        return 0;
    }
    //跳过指定的几个文件
    if (del_contents_fn_without_file_array)
    {
        NSString* nameExclude = [[NSString stringWithUTF8String:fpath] lastPathComponent];
        if([del_contents_fn_without_file_array containsObject:nameExclude])
            return 0;
    }
    
    return remove(fpath);
}

int del_dir_and_contents_fn(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf)
{
    return remove(fpath);
}

__unsafe_unretained static NSMutableArray* get_sub_dirs_of_level1_fn_ret = nil;
int get_sub_dirs_of_level1_fn(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf)
{
    //我们只处理第一级子目录
    if(ftwbuf->level != 1)
        return 0;
    if((sb->st_mode & S_IFMT) == S_IFDIR)
    {
        NSString* dirName = [NSString stringWithUTF8String:fpath + ftwbuf->base];
        [get_sub_dirs_of_level1_fn_ret addObject:dirName];
    }
    return 0;
}

static const char* cp_contents_fn_source_dir = NULL;
static const char* cp_contents_fn_target_dir = NULL;
int cp_contents_fn(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf)
{
    //跳过根文件夹本身
    if(ftwbuf->level == 0)
        return 0;
    int srcDirLen = strlen(cp_contents_fn_source_dir);
    int dstDirLen = strlen(cp_contents_fn_target_dir);
    
    char* dest = malloc(dstDirLen + strlen(fpath) - srcDirLen + 1);
    memcpy(dest, cp_contents_fn_target_dir, dstDirLen + 1);
    strcat(dest, fpath + srcDirLen);
    
    if((sb->st_mode & S_IFMT) == S_IFDIR)
    {
        //文件夹，权限0777
        mkdir(dest, S_IRWXU | S_IRWXG | S_IRWXO);
    }
    else
    {
        //文件
        cp(fpath,dest);
    }
    free(dest);
    return 0;
}

static double calc_contents_size_bytes_count = 0;
static NSString* calc_contents_fn_without_file = NULL;
int calc_contents_size_fn(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf)
{
    //跳过指定文件
    if (calc_contents_fn_without_file &&
        [[NSString stringWithCString:fpath encoding:NSUTF8StringEncoding] hasSuffix:calc_contents_fn_without_file])
        return 0;
    
    if(sb)
    {
        if((sb->st_mode & S_IFMT) != S_IFDIR)
        {
            calc_contents_size_bytes_count += sb->st_size;
        }
    }
    return 0;
}

@implementation FileUtil(private)

+ (NSString*)escapePathForShellCommand:(NSString*)path
{
    //注意：为了简便起见，仅转义了空格，实际上空格、(、)都应该被转义
    return [path stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
}

@end

@implementation FileUtil

+ (BOOL)addSkipBackupAttributeForPath:(NSString *)path;
{
    const char* p = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(p, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

+ (long long) fileSizeAtPath:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}

+ (BOOL)isPathDir:(NSString*)path
{
    struct stat st;
    if(lstat([path cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0)
    {
        return (st.st_mode & S_IFMT) == S_IFDIR;
    }
    return NO;
}

+ (BOOL)fileExists:(NSString*)path
{
    struct stat st;
    if(lstat([path cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0)
    {
        return (st.st_mode & S_IFMT) != S_IFDIR;
    }
    return NO;
}

+ (BOOL)dirExists:(NSString*)path
{
    return [FileUtil isPathDir:path];
}

+ (void)ensureSuperPathExists:(NSString*)path
{
    NSString* superDir = [path stringByDeletingLastPathComponent];
    
    //尝试创建父目录
    int err = mkdir([superDir cStringUsingEncoding:NSUTF8StringEncoding], S_IRWXU | S_IRWXG | S_IRWXO);
    if(err == 0 || errno == EEXIST)   //创建成功或者提示路径已经存在
        return;
    
    //其他错误
    //最可能的情况是父目录的父目录不存在
    //则进行递归调用
    [FileUtil ensureSuperPathExists:superDir];
    mkdir([superDir cStringUsingEncoding:NSUTF8StringEncoding], S_IRWXU | S_IRWXG | S_IRWXO);
}

//确保某个文件夹存在
+ (BOOL)ensureDirExists:(NSString*)dir
{
    [FileUtil ensureSuperPathExists:dir];
    return (mkdir([dir cStringUsingEncoding:NSUTF8StringEncoding], S_IRWXU | S_IRWXG | S_IRWXO) == 0);
}

+ (BOOL)deleteContentsOfDir:(NSString*) dir
{
    if(![self isPathDir:dir]) return NO;
    
    //system() 会阻塞进程，所以不采用
    //    NSString* cmd = [@"rm -rf " stringByAppendingString:[[self escapePathForShellCommand:dir] stringByAppendingPathComponent:@"/*"]];
    //    system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    
    del_contents_fn_without_file = nil;
    del_contents_fn_without_file_array = nil;
    
    //根据apple文档，第三个参数depth未使用，因此随便设即可
    return nftw([dir fileSystemRepresentation], del_contents_fn, 64, FTW_PHYS | FTW_DEPTH) == 0;
}

+ (BOOL)deleteContentsOfDir:(NSString*) dir without:(NSString*)fileName
{
    if(![self isPathDir:dir]) return NO;
    
    del_contents_fn_without_file = fileName;
    
    return nftw([dir fileSystemRepresentation], del_contents_fn, 64, FTW_PHYS | FTW_DEPTH) == 0;
}

+ (BOOL)deleteContentsOfDir:(NSString*) dir withoutFiles:(NSArray*)fileNameArray
{
    if(![self isPathDir:dir]) return NO;
    
    del_contents_fn_without_file_array = fileNameArray;
    
    return nftw([dir fileSystemRepresentation], del_contents_fn, 64, FTW_PHYS | FTW_DEPTH) == 0;
}

+ (void)deleteContentsOfDir:(NSString*) dir withCompletionHandler:(void(^)(BOOL succeeded))handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       BOOL result = [self deleteContentsOfDir:dir];
                       dispatch_sync(dispatch_get_main_queue(), ^(void){
                           handler(result);
                       });
                   });
}

+ (BOOL)deleteDirAndContents:(NSString*) dir
{
    if(![self isPathDir:dir]) return NO;
    
    //    NSString* cmd = [@"rm -rf " stringByAppendingString:[self escapePathForShellCommand:dir]];
    //    system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    
    return nftw([dir fileSystemRepresentation], del_dir_and_contents_fn, 64, FTW_PHYS | FTW_DEPTH) == 0;
}

+ (BOOL)deleteFileAtPath:(NSString*) file
{
    return remove([file fileSystemRepresentation]) == 0;
}

+ (BOOL)moveFileAtPath:(NSString*) file toPath:(NSString*) path
{
    return rename([file fileSystemRepresentation], [path fileSystemRepresentation]) == 0;
}

+ (NSArray*)getSubdirNamesOfDir:(NSString*) dir
{
    if(![self isPathDir:dir]) return nil;
    
    //    NSMutableArray* array = [NSMutableArray new];
    //    NSFileManager* fm = [NSFileManager defaultManager];
    //    NSDirectoryEnumerator* enumerator = [fm enumeratorAtPath:dir];
    //
    //    NSString* name = nil;
    //    while (name = [enumerator nextObject])
    //    {
    //        [enumerator skipDescendants];
    //        NSString* fullPath = [dir stringByAppendingPathComponent:name];
    //        if([self isPathDir:fullPath])
    //            [array addObject:name];
    //    }
    //    return array;
    
    //TODO
    //加上@synchronized为了使得线程安全
    //以后需要改成多线程并发版本
    @synchronized([UIApplication sharedApplication])
    {
        NSMutableArray* array = [NSMutableArray new];
        get_sub_dirs_of_level1_fn_ret = array;
        nftw([dir fileSystemRepresentation], get_sub_dirs_of_level1_fn, 64, FTW_PHYS);
        return array;
    }
}

+ (BOOL)copyContentsOfDir:(NSString*)dir toDir:(NSString*)targetDir
{
    if(![self isPathDir:dir] || ![self isPathDir:targetDir]) return NO;
    
    //    NSString* cmd = [[@"cp -rf " stringByAppendingString:[[self escapePathForShellCommand:dir] stringByAppendingPathComponent:@"/*"]] stringByAppendingFormat:@" %@",[self escapePathForShellCommand:targetDir]];
    //    system([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
    
    //设置参数，这两个参数在cp_contents_fn()中需要被使用到
    cp_contents_fn_source_dir = [dir fileSystemRepresentation];
    cp_contents_fn_target_dir = [targetDir fileSystemRepresentation];
    
    //注意，这里不能指定FTW_DEPTH标志
    return nftw([dir fileSystemRepresentation], cp_contents_fn, 64, FTW_PHYS);
}

+ (void)calcContentsSizeOfDir:(NSString*)dir withCompletionHandler:(void(^)(double totalBytes))handler
{
    calc_contents_fn_without_file = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       calc_contents_size_bytes_count = 0;
                       nftw([dir fileSystemRepresentation], calc_contents_size_fn, 64, FTW_PHYS);
                       dispatch_sync(dispatch_get_main_queue(), ^(void){
                           handler(calc_contents_size_bytes_count);
                       });
                   });
}

+ (double)calcContentsSizeOfDir:(NSString *)dir without:(NSString*)fileName
{
    calc_contents_fn_without_file = fileName;
    
    calc_contents_size_bytes_count = 0;
    nftw([dir fileSystemRepresentation], calc_contents_size_fn, 64, FTW_PHYS);
    return calc_contents_size_bytes_count;
}

@end

