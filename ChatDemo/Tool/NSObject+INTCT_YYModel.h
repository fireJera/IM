//
//  NSObject+INTCT_YYModel.h
//  BanteaySrei
//
//  Created by Jeremy on 2019/4/15.
//  Copyright © 2019 BanteaySrei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (INTCT_YYModel)

+ (NSArray *)arrayWithClass:(NSString *)clsName array:(NSArray *)jsonArray;

+ (NSMutableArray *)mutableArrayWithClass:(NSString *)clsName array:(NSArray *)jsonArray;

+ (id)modelWithClass:(NSString *)clsName dictionary:(NSDictionary *)dictionary;

+ (NSDictionary *)modelCustomPropertyMapper;

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

@end

NS_ASSUME_NONNULL_END
