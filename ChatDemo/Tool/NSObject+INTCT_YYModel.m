//
//  NSObject+INTCT_YYModel.m
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import "NSObject+INTCT_YYModel.h"
#import "Header.h"
#import <YYModel/YYModel.h>
#if DEBUG
#import <objc/runtime.h>
#endif

@implementation NSObject (INTCT_YYModel)

+ (NSArray *)arrayWithClass:(NSString *)clsName array:(nonnull NSArray *)jsonArray {
    if (!clsName || !jsonArray) return nil;
    return [[self mutableArrayWithClass:clsName array:jsonArray] copy];
}

+ (NSMutableArray *)mutableArrayWithClass:(NSString *)clsName array:(NSArray *)jsonArray {
    if (!clsName || !jsonArray) return nil;
    Class cls = NSClassFromString(clsName);
    NSAssert(cls, @"no class for clsName");
    if (!cls) return nil;
    if (IsArrayWithItems(jsonArray)) {
        NSMutableArray * array = [NSMutableArray array];
        for (NSDictionary * dic in jsonArray) {
            if (IsDictionaryWithItems(dic)) {
                id obj = [cls yy_modelWithJSON:dic];
                [array addObject:obj];
            }
        }
        return array;
    }
    return nil;
}

+ (id)modelWithClass:(NSString *)clsName dictionary:(NSDictionary *)dictionary {
    if (!clsName || !dictionary) return nil;
    Class cls = NSClassFromString(clsName);
    NSAssert(cls, @"no class for clsName");
    if (!cls) return nil;
    if (IsDictionaryWithItems(dictionary)) {
        id obj = [cls yy_modelWithJSON:dictionary];
        return obj;
    }
    return nil;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return nil;
}

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return nil;
}

#if DEBUG

//- (NSString *)description {
//    NSString *result = @"";
//    NSArray *proNames = [self allPropertyNames];;
//    for (int i = 0; i < proNames.count; i++) {
//        NSString *proName = [proNames objectAtIndex:i];
//        id  proValue = [self valueForKey:proName];
//        result = [result stringByAppendingFormat:@"%@:%@\n",proName,proValue];
//    }
//    return result;
//}

- (NSArray *)allPropertyNames {
    static NSArray *propertyNames = nil;
    if (!propertyNames) {
        NSMutableArray *proNames_M = [NSMutableArray array];
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            //获取属性名
            NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            [proNames_M addObject:propertyName];
        }
        propertyNames = [proNames_M copy];
    }
    return propertyNames;
}

#endif

@end
