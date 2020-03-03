//
//  INTCTUserDefaults.m
//  LetDate
//
//  Created by Jeremy on 2019/1/19.
//  Copyright © 2019 JersiZhu. All rights reserved.
//

#import "INTCTUserDefaults.h"
#import "GVUserDefaults.h"
#import "INTCTUser.h"

@implementation INTCTUserDefaults

// 子类可重写该方法给属性设置默认值，key为属性名
- (NSDictionary *)setupDefaults {
    return nil;
}

// 子类可重写该方法 设置userDefaults的suit,为空的话是standardDefaults
- (NSString *)suitName{
    return [NSString stringWithFormat:@"%@_%@_%@", INTCTINSTANCE_USER.uid, NSStringFromClass([self class]), @"Debug"];
}

// 删除该对象的所有数据
- (void)resetDefaults {
    NSUserDefaults *defs = self.userDefaults;
    NSDictionary *dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

@end
