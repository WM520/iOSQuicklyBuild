//
//  RuntimeUtil.m
//  iOSQuicklyBuild
//
//  Created by wangmiao on 2017/3/28.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "RuntimeUtil.h"
#import <objc/runtime.h>

@implementation Property


@end

@implementation RuntimeUtil
+ (NSArray*) propertiesForClass:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray new];
    
    Class kls = klass;
    while (kls != [NSObject class])
    {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(kls, &outCount);
        for (i = 0; i < outCount; i++)
        {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName)
            {
                const char *attributes = property_getAttributes(property);
                
                //attrib looks like:
                //Ti,GintGetFoo,SintSetFoo:,VintSetterGetter
                
                Property* p = [Property new];
                p.name = [NSString stringWithUTF8String:propName];
                
                char buffer[1 + strlen(attributes)];
                strcpy(buffer, attributes);
                char *state = buffer, *attribute;
                while ((attribute = strsep(&state, ",")) != NULL)
                {
                    if (attribute[0] == 'T' && attribute[1] != '@')
                    {
                        // it's a C primitive type:
                        /*
                         if you want a list of what will be returned for these primitives, search online for
                         "objective-c" "Property Attribute Description Examples"
                         apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
                         */
                        NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
                        p.type = name;
                    }
                    else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2)
                    {
                        // it's an ObjC id type:
                        p.type = @"id";
                    }
                    else if (attribute[0] == 'T' && attribute[1] == '@')
                    {
                        // it's another ObjC object type:
                        NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
                        p.type = name;
                    }
                    else if(attribute[0] == 'G')
                    {
                        //getter
                        NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
                        p.getterSelector = NSSelectorFromString(name);
                    }
                    else if(attribute[0] == 'S')
                    {
                        //setter
                        NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
                        p.setterSelector = NSSelectorFromString(name);
                    }
                    else if(attribute[0] == 'V')
                    {
                        //iVar for property
                        NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
                        p.ivName = name;
                    }
                }
                
                if(p.getterSelector == NULL)
                {
                    //default getter
                    p.getterSelector = NSSelectorFromString(p.name);
                }
                if(p.setterSelector == NULL)
                {
                    //default setter
                    //format: setAbc
                    p.setterSelector = NSSelectorFromString([@"set" stringByAppendingFormat:@"%@:",[[[p.name substringWithRange:NSMakeRange(0, 1)] uppercaseString] stringByAppendingString:[p.name substringFromIndex:1]]]);
                }
                [array addObject:p];
            }
        }
        free(properties);
        kls = class_getSuperclass(kls);
    }
    
    return array;
}

+(void)swizzleClassMethod:(SEL)oldMtd ofClass:(Class)klass withNewMethod:(SEL)newMtd
{
    Method origMethod = class_getClassMethod(klass, oldMtd);
    Method newMethod = class_getClassMethod(klass, newMtd);
    klass = object_getClass((id)klass);
    if(class_addMethod(klass, oldMtd, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(klass, newMtd, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

+ (void) swizzleInstanceMethod:(SEL)oldMtd ofClass:(Class)klass withNewMethod:(SEL)newMtd
{
    Method origMethod = class_getInstanceMethod(klass, oldMtd);
    Method newMethod = class_getClassMethod(klass, newMtd);
    klass = object_getClass((id)klass);
    if(class_addMethod(klass, oldMtd, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(klass, newMtd, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@end
