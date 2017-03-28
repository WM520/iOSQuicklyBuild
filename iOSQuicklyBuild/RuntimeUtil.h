//
//  RuntimeUtil.h
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Property : NSObject
@property NSString* name;       //property name
@property NSString* type;       //property type
@property NSString* ivName;     //iVar name
@property SEL getterSelector;   //getter selector
@property SEL setterSelector;   //setter selector
@end


@interface RuntimeUtil : NSObject

/**
 *  @return: array of type Property
 */
+ (NSArray*) propertiesForClass:(Class)klass;

/**
 用于替换函数的默认实现
 举例说明一个常用的应用场景：
 UIImage-imageNamed函数，默认会缓存图片数据，我们可以将其改写为自己的版本。
 
 1.首先为UIImage定义一个新的category：
 interface UIImage (newcate)
 +(UIImage*)imageNamedNewImpl:(NSString*)name;
 @end
 
 2.实现：
 @implementation (newcate)
 +(UIImage*)imageNamedNewImpl:(NSString*)name
 {
 NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
 return [UIImage imageWithContentsOfFile:path];
 }
 @end
 
 3.交换：
 [RuntimeUtil swizzleMethod:@selector(imageNamed:) ofClass:[UIImage class] withNewMethod:@selector(imageNamedNewImpl:)];
 
 4.之后UIImage-imageNamed的实现就变成了我们自己的实现了。当然，imageNamedNewImpl这个函数的实现也相应地变成了原来的imageNamed的作用
 */
+ (void) swizzleClassMethod:(SEL)oldMtd ofClass:(Class)klass withNewMethod:(SEL)newMtd;

+ (void) swizzleInstanceMethod:(SEL)oldMtd ofClass:(Class)klass withNewMethod:(SEL)newMtd;


@end
